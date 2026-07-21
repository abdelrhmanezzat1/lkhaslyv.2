import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/features/auth/controllers/registration_controller.dart';
import 'package:flutter_application_1/shared/widgets/app_card.dart';
import 'package:flutter_application_1/shared/widgets/app_button.dart';
import 'package:flutter_application_1/shared/widgets/app_snackbar.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> orderData;

  const PaymentScreen({super.key, required this.orderData});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String? _selectedPaymentMethod;
  bool _isSubmitting = false;

  static const List<String> _paymentMethods = [
    'Wallet',
    'Card',
  ];

  Future<void> _submitPayment() async {
    final orderId = widget.orderData['id'] as String?;
    final paymentMethod = _selectedPaymentMethod;

    if (orderId == null || orderId.isEmpty) {
      AppSnackbar.showError(
        context,
        message: 'Unable to process payment. Order data is invalid.',
      );
      return;
    }

    if (paymentMethod == null) {
      AppSnackbar.showError(
        context,
        message: 'Please select a payment method.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(registrationControllerProvider.notifier).payOrder(
            orderId: orderId,
            paymentMethod: paymentMethod,
          );
      if (mounted) {
        AppSnackbar.showSuccess(
          context,
          message: 'Payment successful. Your order is now paid.',
        );
        context.go('/orders');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        AppSnackbar.showError(
          context,
          message: 'Failed to process payment: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceType = widget.orderData['service_type'] as String? ?? 'Service';
    final carInfo = widget.orderData['car_info'] as Map<String, dynamic>?;
    final brand = carInfo?['brand'] as String? ?? '';
    final model = carInfo?['model'] as String? ?? '';
    final vehicleName = [brand, model].where((part) => part.isNotEmpty).join(' ');
    final totalAmount = (widget.orderData['total_amount'] as num?)?.toDouble() ?? 0;
    final technicianName = widget.orderData['technician_name'] as String?;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _InfoRow(label: 'Service', value: serviceType),
                  _InfoRow(label: 'Vehicle', value: vehicleName.isNotEmpty ? vehicleName : 'N/A'),
                  _InfoRow(label: 'Technician', value: technicianName ?? 'N/A'),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Amount due',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '\$${totalAmount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Choose Payment Method',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                children: _paymentMethods.map((method) {
                  return RadioListTile<String>(
                    title: Text(method),
                    value: method,
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() => _selectedPaymentMethod = value);
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              text: _isSubmitting ? 'Processing...' : 'Pay Now',
              onPressed: _isSubmitting ? null : _submitPayment,
              isLoading: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
