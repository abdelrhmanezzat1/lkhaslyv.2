import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/features/_shared/domain/entities/order.dart';
import 'package:flutter_application_1/features/auth/controllers/auth_controller.dart';
import 'package:flutter_application_1/features/orders/controllers/orders_controller.dart';
import 'package:flutter_application_1/shared/widgets/app_card.dart';
import 'package:flutter_application_1/shared/widgets/app_loader.dart';
import 'package:flutter_application_1/shared/widgets/app_snackbar.dart';
import 'package:flutter_application_1/shared/widgets/fade_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Client "My Orders" screen.
///
/// Phase 4.2: converted from a `ConsumerStatefulWidget` with `_orders`
/// + `_isLoading` local state + imperative `getOrders()` from the legacy
/// `RegistrationController` to a pure `ConsumerWidget` that renders the
/// `AsyncValue<List<Order>>` returned by
/// [`clientOrdersForUserProvider`](package:flutter_application_1/features/orders/controllers/orders_controller.dart).
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(authStateChangesProvider).valueOrNull;

    if (user == null) {
      return _buildScaffold(
        context,
        title: 'My Orders',
        body: const Center(child: AppLoader(message: 'Loading orders...')),
      );
    }

    // Errors should not interrupt the UI tree (an AsyncValue.error widget
    // builds fine), but spec wants a snackbar surfaced. `ref.listen` is
    // safe inside `build` for a ConsumerWidget.
    ref.listen<AsyncValue<List<Order>>>(
      clientOrdersForUserProvider(user.id),
      (_, next) => next.whenOrNull(
        error: (error, _) {
          if (!context.mounted) return;
          AppSnackbar.showError(
            context,
            message: 'Failed to load orders: $error',
          );
        },
      ),
    );

    final ordersAsync = ref.watch(clientOrdersForUserProvider(user.id));

    return _buildScaffold(
      context,
      title: 'My Orders',
      body: ordersAsync.when(
        loading: () =>
            const Center(child: AppLoader(message: 'Loading orders...')),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Could not load orders: $error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.error,
                  ),
            ),
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return _EmptyState(colorScheme: colorScheme);
          }

          return FadeIn(
            child: RefreshIndicator(
              onRefresh: () => ref
                  .read(ordersControllerProvider.notifier)
                  .loadClientOrders(user.id),
              color: colorScheme.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: orders.length,
                itemBuilder: (context, index) =>
                    _OrderCard(order: orders[index], index: index),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context, {
    required String title,
    required Widget body,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: body,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 80,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No orders yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Request a service to see your orders here',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.index});

  final Order order;
  final int index;

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '';
    try {
      final dt = DateTime.parse(dateTimeStr);
      return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  String _getStatusTitle(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'on_the_way':
        return 'Technician on the Way';
      case 'arrived':
        return 'Technician Arrived';
      case 'working':
        return 'In Progress';
      case 'finished':
        return 'Finished';
      case 'completed':
        return 'Completed';
      case 'paid':
        return 'Paid';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFFA726);
      case 'accepted':
      case 'on_the_way':
        return const Color(0xFF42A5F5);
      case 'arrived':
        return const Color(0xFFAB47BC);
      case 'working':
        return const Color(0xFF5C6BC0);
      case 'finished':
        return const Color(0xFF26A69A);
      case 'completed':
      case 'paid':
        return const Color(0xFF66BB6A);
      default:
        return AppColors.primary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.access_time_rounded;
      case 'accepted':
        return Icons.check_circle_outline_rounded;
      case 'on_the_way':
        return Icons.directions_car_rounded;
      case 'arrived':
        return Icons.location_on_rounded;
      case 'working':
        return Icons.build_rounded;
      case 'finished':
        return Icons.check_circle_rounded;
      case 'completed':
      case 'paid':
        return Icons.verified_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusDb = order.status.dbValue;
    final statusTitle = _getStatusTitle(statusDb);
    final statusColor = _getStatusColor(statusDb);
    final statusIcon = _getStatusIcon(statusDb);
    final carInfo = order.carInfo;
    final carType = carInfo?['car_type'] as String? ?? '';
    final carModel = carInfo?['car_model'] as String? ?? '';
    final vehicleName =
        [carType, carModel].where((part) => part.isNotEmpty).join(' ');
    final serviceType = order.serviceType;
    final description = order.description;
    final technicianName = order.technicianName;
    final createdAt = _formatDateTime(order.createdAt.toIso8601String());
    final isPaid = order.paymentStatus == PaymentStatus.paid;
    final paymentStatus = isPaid ? 'paid' : '';

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withValues(alpha: 0.2),
                        statusColor.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(size: 16, color: statusColor, statusIcon),
                      const SizedBox(width: 8),
                      Text(
                        statusTitle,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Text(
                    serviceType.isNotEmpty ? serviceType : 'Service',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            if (vehicleName.isNotEmpty)
              _OrderDetailRow(
                icon: Icons.directions_car_rounded,
                label: 'Vehicle',
                value: vehicleName,
              ),
            if (technicianName != null && technicianName.isNotEmpty)
              _OrderDetailRow(
                icon: Icons.person_rounded,
                label: 'Technician',
                value: technicianName,
              ),
            _OrderDetailRow(
              icon: Icons.access_time_rounded,
              label: 'Date',
              value: createdAt,
            ),
            if (paymentStatus.isNotEmpty)
              _OrderDetailRow(
                icon: Icons.payment_rounded,
                label: 'Payment',
                value: isPaid ? 'Paid' : 'Pending',
                valueColor:
                    isPaid ? const Color(0xFF66BB6A) : const Color(0xFFFFA726),
              ),
            const SizedBox(height: AppSpacing.md),
            if (!isPaid)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _onPayPressed(context),
                  icon: const Icon(Icons.payment_rounded, size: 18),
                  label: const Text('Pay Now'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(
                      color: colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            if (order.status != OrderStatus.completed &&
                order.status != OrderStatus.pending &&
                order.status != OrderStatus.paid) ...[
              if (isPaid) const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _onTrackPressed(context),
                  icon: const Icon(Icons.map_rounded, size: 18),
                  label: const Text('Track Technician'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Navigates to the payment screen with the [Order] payload.
  ///
  /// Phase 4.2: no longer re-fetches via `registration_controller.getOrders`.
  /// The payment screen itself will refresh the controller after success.
  void _onPayPressed(BuildContext context) {
    if (order.paymentStatus == PaymentStatus.paid) {
      AppSnackbar.showSuccess(context, message: 'This order is already paid.');
      return;
    }
    if (order.id.isEmpty) {
      AppSnackbar.showError(context, message: 'Invalid order data.');
      return;
    }
    context.push(AppRoutes.payment, extra: order);
  }

  void _onTrackPressed(BuildContext context) {
    context.push(
      AppRoutes.map,
      extra: <String, Object?>{'tracking': true, 'order': order},
    );
  }
}

class _OrderDetailRow extends StatelessWidget {
  const _OrderDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: valueColor ?? colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
