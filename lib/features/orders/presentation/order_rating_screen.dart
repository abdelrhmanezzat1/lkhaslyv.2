import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/features/auth/controllers/auth_controller.dart';
import 'package:flutter_application_1/features/orders/controllers/orders_controller.dart';
import 'package:flutter_application_1/shared/widgets/app_snackbar.dart';
import 'package:flutter_application_1/widgets/custom_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen for rating a completed order.
///
/// Persists the rating to the `orders` table (`rating`, `rating_comment`,
/// `rated_at`) and refreshes the client orders feed.
class OrderRatingScreen extends ConsumerStatefulWidget {
  const OrderRatingScreen({super.key, required this.orderId});
  final String orderId;

  @override
  ConsumerState<OrderRatingScreen> createState() =>
      _OrderRatingScreenState();
}

class _OrderRatingScreenState extends ConsumerState<OrderRatingScreen> {
  double _rating = 0;
  bool _isSubmitting = false;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: Text('Rate Your Experience')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How was your service?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // Star rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    size: 40,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 24),
            // Comment field
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Your feedback (optional)',
                border: OutlineInputBorder(),
                hintText: 'Tell us about your experience...',
              ),
            ),
            const SizedBox(height: 24),
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _rating > 0 && !_isSubmitting ? _submitRating : null,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Rating'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRating() async {
    setState(() => _isSubmitting = true);
    try {
      final userId = ref.read(authStateChangesProvider).valueOrNull?.id;
      final comment = _commentController.text.trim();
      await ref.read(ordersControllerProvider.notifier).rateOrder(
            orderId: widget.orderId,
            rating: _rating.round(),
            comment: comment.isEmpty ? null : comment,
            clientId: userId,
          );
      if (!mounted) return;
      AppSnackbar.showSuccess(context, message: 'Thank you for your rating!');
      context.go(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(context, message: 'Failed to submit rating: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
