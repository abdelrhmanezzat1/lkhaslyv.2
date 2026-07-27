import 'dart:async';

import 'package:flutter/material.dart';
// Phase 3.3: location repository provider moved to the central DI bridge.
import 'package:flutter_application_1/core/di/service_locator_provider.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/features/_shared/domain/entities/order.dart';
import 'package:flutter_application_1/features/auth/controllers/auth_controller.dart';
import 'package:flutter_application_1/features/auth/controllers/registration_controller.dart';
import 'package:flutter_application_1/shared/widgets/app_badge.dart';
import 'package:flutter_application_1/shared/widgets/app_button.dart';
import 'package:flutter_application_1/shared/widgets/app_card.dart';
import 'package:flutter_application_1/shared/widgets/app_empty_state.dart';
import 'package:flutter_application_1/shared/widgets/app_loader.dart';
import 'package:flutter_application_1/shared/widgets/app_snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TechnicianHomeScreen extends ConsumerStatefulWidget {
  const TechnicianHomeScreen({super.key});

  @override
  ConsumerState<TechnicianHomeScreen> createState() =>
      _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState extends ConsumerState<TechnicianHomeScreen> {
  List<Order> _orders = const <Order>[];
  bool _isLoading = true;
  StreamSubscription? _realtimeSubscription;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _loadPendingOrders();
    _setupRealtime();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _stopLocationTracking();
    _realtimeSubscription?.cancel();
    super.dispose();
  }

  void _startLocationTracking() {
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final user = ref.read(authStateChangesProvider).valueOrNull;
      if (user == null || !mounted) return;

      final userType = user.userMetadata?['user_type'] as String? ?? 'client';
      if (userType != 'technician') return;

      try {
        final ordersRepository = ref.read(ordersRepositoryProvider);
        final hasAccepted = await ordersRepository.hasAcceptedOrders(
          technicianId: user.id,
        );
        if (!hasAccepted || !mounted) return;

        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        if (!mounted) return;

        // Phase 2.5: technician live-location moved to TechnicianLocationRepository.
        final locationRepository =
            ref.read(technicianLocationRepositoryProvider);
        await locationRepository.updateLocation(
          technicianId: user.id,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      } catch (_) {
        // Silently ignore location errors to avoid spamming the user
      }
    });
  }

  void _stopLocationTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  void _setupRealtime() {
    final supabase = Supabase.instance.client;
    _realtimeSubscription = supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .listen((_) async {
          if (!mounted) return;
          await _loadPendingOrders();
        });
  }

  Future<void> _loadPendingOrders() async {
    try {
      final orders = await ref
          .read(registrationControllerProvider.notifier)
          .getPendingOrders();
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackbar.showError(context, message: 'Failed to load orders: $e');
      }
    }
  }

  Future<void> _acceptOrder(Order order) async {
    final user = ref.read(authStateChangesProvider).valueOrNull;
    if (user == null) return;

    final fullName = user.userMetadata?['full_name'] as String? ?? 'Technician';
    final orderId = order.id;

    try {
      await ref
          .read(registrationControllerProvider.notifier)
          .acceptOrder(
            orderId: orderId,
            technicianId: user.id,
            technicianName: fullName,
          );
      if (mounted) {
        AppSnackbar.showSuccess(
          context,
          message: 'Order accepted successfully!',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, message: 'Failed to accept order: $e');
      }
    }
  }

  String _formatDateTime(String isoString) {
    if (isoString.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(isoString);
      return DateFormat('MMM d, yyyy â€“ h:mm a').format(dateTime);
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsyncValue = ref.watch(authStateChangesProvider);
    final authControllerState = ref.watch(authControllerProvider);
    final isLoggingOut = authControllerState is AsyncLoading;

    if (_isLoading) {
      return const Scaffold(body: Center(child: AppLoader()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Orders'),
        automaticallyImplyLeading: false,
        actions: [
          if (isLoggingOut)
            const Padding(
              padding: EdgeInsets.only(right: 20),
              child: AppLoader(size: 20),
            )
          else
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                ref.read(authControllerProvider.notifier).signOut();
              },
              tooltip: 'Logout',
            ),
        ],
      ),
      body: userAsyncValue.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not logged in.'));
          }

          final userType =
              user.userMetadata?['user_type'] as String? ?? 'client';
          if (userType != 'technician') {
            return const Center(
              child: Text('This screen is for technicians only.'),
            );
          }

          if (_orders.isEmpty) {
            return const AppEmptyState(
              icon: Icons.engineering_outlined,
              title: 'No Pending Orders',
              message: 'New service orders will appear here.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: _orders.length,
            itemBuilder: (context, index) {
              final order = _orders[index];
              final serviceType =
                  order.serviceType.isEmpty ? 'Unknown' : order.serviceType;
              final description = order.description;
              final createdAt = order.createdAt.toIso8601String();
              final carInfo = order.carInfo;
              final carType = carInfo?['car_type'] as String? ?? '';
              final carModel = carInfo?['car_model'] as String? ?? '';
              final vehicleName = carType.isNotEmpty
                  ? '$carType $carModel'
                  : null;
              final latitude = order.latitude;
              final longitude = order.longitude;
              final distance = (carInfo?['distance'] as num?)?.toDouble();

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service type header
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              serviceType,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const AppBadge(
                            label: 'Pending',
                            backgroundColor: Colors.orange,
                            size: AppBadgeSize.small,
                          ),
                        ],
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey.shade600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      // Car info
                      if (vehicleName != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.directions_car,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                vehicleName,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: AppSpacing.xs),
                      // Client location
                      if (latitude != 0 && longitude != 0)
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      // Distance if available
                      if (distance != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            const Icon(
                              Icons.straighten,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '$distance',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xs),
                      // Created at
                      if (createdAt.isNotEmpty)
                        Text(
                          _formatDateTime(createdAt),
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      const SizedBox(height: AppSpacing.sm),
                      // Accept button
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          onPressed: () => _acceptOrder(order),
                          text: 'Accept',
                          variant: AppButtonVariant.filled,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: AppLoader()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
