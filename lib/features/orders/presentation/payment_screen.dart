import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/logger/app_logger.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/features/_shared/domain/entities/order.dart';
import 'package:flutter_application_1/features/orders/controllers/orders_controller.dart';
import 'package:flutter_application_1/shared/widgets/app_card.dart';
import 'package:flutter_application_1/shared/widgets/app_snackbar.dart';
import 'package:flutter_application_1/widgets/custom_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Payment screen that supports two flows:
///
/// 1. **Card (Paymob)** — calls the `create-payment` Supabase Edge Function,
///    which returns a Paymob iframe URL. The URL is loaded in a WebView.
///    After the user completes payment in the iframe, Paymob sends a
///    webhook to `paymob-webhook` which updates the order status to `paid`.
///    The screen polls the order status and navigates away on success.
///
/// 2. **Wallet / Cash** — calls the existing `payOrder` use-case directly
///    (same as before the refactor).
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, required this.order});
  final Order order;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isSubmitting = false;
  bool _isWebViewLoading = false;
  String? _iframeUrl;
  WebViewController? _webViewController;

  @override
  void dispose() {
    _webViewController?.clearCache();
    _webViewController = null;
    super.dispose();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Card payment flow via Paymob Edge Function + WebView
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _startCardPayment() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final supabase = Supabase.instance.client;

      // Calculate amount in EGP cents (Paymob expects cents)
      final totalAmount = widget.order.totalAmount ?? 0;
      final amountCents = (totalAmount * 100).round();

      appLogger.i(
        'PaymentScreen: invoking create-payment Edge Function '
        'orderId=${widget.order.id} amount=$totalAmount EGP ($amountCents cents)',
      );

      // Call the Supabase Edge Function
      final response = await supabase.functions.invoke(
        'create-payment',
        body: <String, dynamic>{
          'order_id': widget.order.id,
          'amount': amountCents,
        },
      );

      final data = response.data as Map<String, dynamic>?;

      if (data == null || data['success'] != true) {
        final error = data?['error']?.toString() ?? 'Unknown error';
        appLogger.e('create-payment Edge Function failed: $error');
        if (mounted) {
          AppSnackbar.showError(
            context,
            message: 'Failed to initiate payment: $error',
          );
        }
        return;
      }

      final iframeUrl = data['iframe_url']?.toString();
      if (iframeUrl == null || iframeUrl.isEmpty) {
        appLogger.e('create-payment returned no iframe_url');
        if (mounted) {
          AppSnackbar.showError(
            context,
            message: 'Failed to get payment URL from server.',
          );
        }
        return;
      }

      appLogger.i('Payment iframe URL obtained: $iframeUrl');

      setState(() {
        _iframeUrl = iframeUrl;
        _isWebViewLoading = true;
      });
    } catch (e, st) {
      appLogger.e('Card payment initiation failed', error: e, stackTrace: st);
      if (mounted) {
        AppSnackbar.showError(
          context,
          message: 'Failed to start card payment: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// Called when the WebView navigates to a URL. We use this to detect
  /// Paymob's success/failure redirect URLs.
  NavigationDecision _onWebViewNavigation(NavigationRequest request) {
    final url = request.url;

    appLogger.d('WebView navigation: $url');

    // Paymob redirects to success/failure URLs after payment.
    // Common patterns:
    //   - success: contains "success" or "thank-you"
    //   - failure: contains "failure" or "error"
    if (url.contains('success') || url.contains('thank-you')) {
      appLogger.i('Paymob payment success redirect detected: $url');
      _handlePaymentSuccess();
      return NavigationDecision.prevent;
    }

    if (url.contains('failure') || url.contains('error')) {
      appLogger.w('Paymob payment failure redirect detected: $url');
      _handlePaymentFailure('Payment was declined or failed.');
      return NavigationDecision.prevent;
    }

    // Allow navigation for Paymob domains, block everything else
    if (url.contains('paymob.com') || url.contains('accept.paymob.com')) {
      return NavigationDecision.navigate;
    }

    // Block navigation to external sites
    appLogger.w('Blocked navigation to external URL: $url');
    return NavigationDecision.prevent;
  }

  void _onWebViewPageFinished(String url) {
    if (mounted) {
      setState(() => _isWebViewLoading = false);
    }
    appLogger.d('WebView page finished: $url');
  }

  Future<void> _handlePaymentSuccess() async {
    appLogger.i('Payment success — polling order status...');

    // Poll the order status to confirm the webhook has updated it
    for (int i = 0; i < 10; i++) {
      await Future<void>.delayed(const Duration(seconds: 2));

      try {
        final supabase = Supabase.instance.client;
        final response = await supabase
            .from('orders')
            .select('status, payment_status')
            .eq('id', widget.order.id)
            .maybeSingle();

        if (response != null) {
          final status = response['status']?.toString();
          final paymentStatus = response['payment_status']?.toString();

          if (status == 'paid' || paymentStatus == 'paid') {
            appLogger.i('Order ${widget.order.id} confirmed as paid via polling.');
            if (mounted) {
              AppSnackbar.showSuccess(
                context,
                message: 'Payment successful! Your order is now paid.',
              );
              _invalidateOrders();
              context.go(
                AppRoutes.orderCompletion.replaceAll(
                  ':orderId',
                  widget.order.id,
                ),
              );
            }
            return;
          }
        }
      } catch (e) {
        appLogger.w('Polling error (will retry): $e');
      }
    }

    // If we reach here, the webhook may be delayed — still navigate away
    // but show a neutral message
    appLogger.w('Polling timed out — navigating away anyway.');
    if (mounted) {
      AppSnackbar.showSuccess(
        context,
        message: 'Payment submitted. Your order will update shortly.',
      );
      _invalidateOrders();
      context.go('/orders');
    }
  }

  void _handlePaymentFailure(String message) {
    setState(() {
      _iframeUrl = null;
      _webViewController = null;
    });
    if (mounted) {
      AppSnackbar.showError(context, message: message);
    }
  }

  /// Invalidates the watched `clientOrdersForUserProvider` feed so the
  /// orders screen shows the updated status after payment.
  void _invalidateOrders() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      ref
          .read(ordersControllerProvider.notifier)
          .refreshClientOrders(userId);
    }
  }

  void _closeWebView() {
    setState(() {
      _iframeUrl = null;
      _webViewController = null;
    });
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Cash / Wallet payment flow (unchanged from original)
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _submitCashOrWalletPayment(
    BuildContext context,
    WidgetRef ref,
    String? paymentMethod,
  ) async {
    if (_isSubmitting) return;

    final paymentMethodValue = paymentMethod;

    if (paymentMethodValue == null) {
      AppSnackbar.showError(
        context,
        message: 'Please select a payment method.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(ordersControllerProvider.notifier).payOrder(
            orderId: widget.order.id,
            paymentMethod: paymentMethodValue,
          );
      if (mounted) {
        AppSnackbar.showSuccess(
          context,
          message: 'Payment successful. Your order is now paid.',
        );
        _invalidateOrders();
        context.go(
          AppRoutes.orderCompletion.replaceAll(
            ':orderId',
            widget.order.id,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(
          context,
          message: 'Failed to process payment: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Build
  // ───────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // If we have an iframe URL, show the WebView
    if (_iframeUrl != null) {
      return _buildWebViewScreen();
    }

    return _buildPaymentSelectionScreen();
  }

  Widget _buildWebViewScreen() {
    _webViewController ??= WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _onWebViewNavigation,
          onPageFinished: _onWebViewPageFinished,
        ),
      )
      ..loadRequest(Uri.parse(_iframeUrl!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _closeWebView,
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController!),
          if (_isWebViewLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentSelectionScreen() {
    final vehicleName = _getVehicleName(widget.order.carInfo);
    final totalAmount = widget.order.totalAmount ?? 0;
    final technicianName = widget.order.technicianName;
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer(
      builder: (context, ref, child) {
        final selectedMethod = ref.watch(paymentMethodProvider);

        return Scaffold(
          appBar: CustomAppBar(
            title: Text(
              'Payment',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Premium Payment Summary Card
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  child: AppCard(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primaryContainer,
                            colorScheme.surfaceContainerHighest,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.receipt_long_rounded,
                                  size: 24,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Payment Summary',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurface,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _PremiumInfoRow(
                            icon: Icons.build_rounded,
                            label: 'Service',
                            value: widget.order.serviceType,
                          ),
                          _PremiumInfoRow(
                            icon: Icons.directions_car_rounded,
                            label: 'Vehicle',
                            value: vehicleName.isNotEmpty ? vehicleName : 'N/A',
                          ),
                          _PremiumInfoRow(
                            icon: Icons.person_rounded,
                            label: 'Technician',
                            value: technicianName ?? 'N/A',
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.outline.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Amount Due',
                                        style: Theme.of(context).textTheme.bodySmall
                                            ?.copyWith(
                                              color: colorScheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'EGP ${totalAmount.toStringAsFixed(2)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: colorScheme.primary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        colorScheme.primary,
                                        colorScheme.primaryContainer,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'PAY NOW',
                                    style: TextStyle(
                                      color: colorScheme.onPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Payment Method Selection
                Row(
                  children: [
                    Icon(
                      Icons.payment_rounded,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Choose Payment Method',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ..._paymentMethods.asMap().entries.map((entry) {
                  final index = entry.key;
                  final method = entry.value;
                  final isSelected = selectedMethod == method.id;

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: GestureDetector(
                      onTap: () => ref.read(paymentMethodProvider.notifier).state = method.id,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary.withValues(alpha: 0.08)
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outline.withValues(alpha: 0.2),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: colorScheme.primary.withValues(
                                      alpha: 0.15,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                method.icon,
                                size: 24,
                                color: isSelected
                                    ? Colors.white
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    method.label,
                                    style: Theme.of(context).textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? colorScheme.primary
                                              : colorScheme.onSurface,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    method.description,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.outline,
                                  width: 2,
                                ),
                                color: isSelected
                                    ? colorScheme.primary
                                    : Colors.transparent,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.xl),

                // Pay Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            if (selectedMethod == 'card') {
                              _startCardPayment();
                            } else {
                              _submitCashOrWalletPayment(context, ref, selectedMethod);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 8,
                      shadowColor: colorScheme.primary.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Pay Now',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getVehicleName(Map<String, dynamic>? carInfo) {
    if (carInfo == null) return '';
    final type = carInfo['car_type']?.toString() ?? '';
    final model = carInfo['car_model']?.toString() ?? '';
    return [type, model].where((p) => p.isNotEmpty).join(' ');
  }
}

/// Simple provider to track the selected payment method for this screen's session.
final paymentMethodProvider = StateProvider<String?>((ref) => null);

class _PaymentMethod {
  const _PaymentMethod({
    required this.id,
    required this.label,
    required this.icon,
    required this.description,
  });

  final String id;
  final String label;
  final IconData icon;
  final String description;
}

const List<_PaymentMethod> _paymentMethods = [
  _PaymentMethod(
    id: 'card',
    label: 'Card',
    icon: Icons.credit_card_rounded,
    description: 'Pay securely with credit/debit card via Paymob',
  ),
  _PaymentMethod(
    id: 'cash',
    label: 'Cash',
    icon: Icons.money_rounded,
    description: 'Pay with cash to the technician',
  ),
  _PaymentMethod(
    id: 'wallet',
    label: 'Wallet',
    icon: Icons.account_balance_wallet_rounded,
    description: 'Pay from your wallet balance',
  ),
];

class _PremiumInfoRow extends StatelessWidget {
  const _PremiumInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


