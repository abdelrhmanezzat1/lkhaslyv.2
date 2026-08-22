import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/features/auth/controllers/auth_controller.dart';
import 'package:flutter_application_1/features/orders/controllers/orders_controller.dart';
import 'package:flutter_application_1/shared/widgets/app_snackbar.dart';
import 'package:flutter_application_1/widgets/custom_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen for order completion confirmation.
///
/// Marks the order as `completed` in Supabase and offers the client the
/// chance to rate the technician.
class OrderCompletionScreen extends ConsumerStatefulWidget {
  const OrderCompletionScreen({super.key, required this.orderId});
  final String orderId;

  @override
  ConsumerState<OrderCompletionScreen> createState() =>
      _OrderCompletionScreenState();
}

class _OrderCompletionScreenState extends ConsumerState<OrderCompletionScreen> {
  bool _confirming = false;

  @override
  void initState() {
    super.initState();
    _confirmOrderCompleted();
  }

  Future<void> _confirmOrderCompleted() async {
    if (_confirming) return;
    setState(() => _confirming = true);
    try {
      await ref
          .read(ordersControllerProvider.notifier)
          .confirmOrderCompletion(orderId: widget.orderId);
      _refreshOrdersFeed();
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(
          context,
          message: 'Failed to confirm order: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _confirming = false);
      }
    }
  }

  void _refreshOrdersFeed() {
    final userId =
        ref.read(authStateChangesProvider).valueOrNull?.id;
    if (userId != null) {
      ref
          .read(ordersControllerProvider.notifier)
          .refreshClientOrders(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: Text('Order Completed')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 80, color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                'Order Completed Successfully!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('Order ID: ${widget.orderId}'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _confirming
                    ? null
                    : () => context.push(
                          AppRoutes.orderRating.replaceAll(
                            ':orderId',
                            widget.orderId,
                          ),
                        ),
                icon: const Icon(Icons.star_rounded, size: 18),
                label: const Text('Rate Your Experience'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
