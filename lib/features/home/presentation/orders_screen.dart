import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/features/auth/controllers/auth_controller.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/features/auth/controllers/registration_controller.dart';
import 'package:flutter_application_1/shared/widgets/app_card.dart';
import 'package:flutter_application_1/shared/widgets/app_badge.dart';
import 'package:flutter_application_1/shared/widgets/app_button.dart';
import 'package:flutter_application_1/shared/widgets/app_loader.dart';
import 'package:flutter_application_1/shared/widgets/app_empty_state.dart';
import 'package:flutter_application_1/shared/widgets/app_snackbar.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/core/env/env.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  StreamSubscription? _ordersSubscription;
  StreamSubscription? _profilesSubscription;
  Map<String, Map<String, dynamic>> _technicianProfiles = {};

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _setupOrdersRealtime();
    _setupProfilesRealtime();
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    _profilesSubscription?.cancel();
    super.dispose();
  }

  void _setupOrdersRealtime() {
    final supabase = Supabase.instance.client;
    _ordersSubscription = supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .listen((orders) async {
          debugPrint("REALTIME EVENT RECEIVED");
          final user = ref.read(authStateChangesProvider).valueOrNull;
          if (user == null) return;

          final response = await supabase
              .from('orders')
              .select('*, car_info:cars(*)')
              .eq('customer_id', user.id)
              .order('created_at', ascending: false);

          final userOrders = (response as List).cast<Map<String, dynamic>>();

          debugPrint("Loaded ${userOrders.length} orders");
          debugPrint("Updating UI");
          if (mounted) {
            setState(() {
              _orders = userOrders;
              _isLoading = false;
            });
          }
        });
  }

  void _setupProfilesRealtime() {
    final supabase = Supabase.instance.client;
    _profilesSubscription = supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .listen((profiles) {
          if (!mounted) return;
          final profileMap = <String, Map<String, dynamic>>{};
          for (final profile in profiles) {
            final id = profile['id'] as String?;
            if (id != null) {
              profileMap[id] = profile;
            }
          }
          setState(() {
            _technicianProfiles = profileMap;
          });
        });
  }

  Future<void> _loadOrders() async {
    debugPrint("LOADING CUSTOMER ORDERS");
    final user = ref.read(authStateChangesProvider).valueOrNull;
    if (user == null) return;

    try {
      final orders = await ref
          .read(registrationControllerProvider.notifier)
          .getOrders(user.id);
      for (final order in orders) {
        final orderId = order['id']?.toString() ?? '';
        final status = order['status']?.toString() ?? '';
        final technicianId = order['technician_id']?.toString() ?? '';
        final customerId = order['customer_id']?.toString() ?? '';
        debugPrint("Order:\nid=$orderId\nstatus=$status\ntechnician_id=$technicianId\ncustomer_id=$customerId\n");
      }
      debugPrint("Loaded ${orders.length} orders");
      debugPrint("Updating UI");
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'on_the_way':
      case 'technician_on_the_way':
      case 'technician on the way':
        return Colors.indigo;
      case 'arrived':
        return Colors.teal;
      case 'working':
      case 'in_progress':
      case 'in progress':
        return Colors.purple;
      case 'finished':
        return Colors.cyan;
      case 'paid':
        return AppColors.success;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
      case 'rejected':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Technician Assigned';
      case 'on_the_way':
      case 'technician_on_the_way':
      case 'technician on the way':
        return 'Technician On The Way';
      case 'arrived':
        return 'Arrived';
      case 'working':
      case 'in_progress':
      case 'in progress':
        return 'Service In Progress';
      case 'finished':
        return 'Pending Payment';
      case 'paid':
        return 'Paid';
      case 'completed':
        return 'Completed';
      case 'cancelled':
      case 'rejected':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _formatDateTime(String isoString) {
    if (isoString.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(isoString);
      return DateFormat('MMM d, yyyy – h:mm a').format(dateTime);
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: AppLoader()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: _orders.isEmpty
          ? const AppEmptyState(
              icon: Icons.inbox_outlined,
              title: 'No Orders Yet',
              message:
                  'Your service orders will appear here once you create them.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                debugPrint("UI ORDER -> id=${order['id']} status=${order['status']}");
                final status = (order['status'] as String? ?? 'pending')
                    .toLowerCase();
                final serviceType =
                    order['service_type'] as String? ?? 'Unknown';
                final createdAt = order['created_at'] as String? ?? '';
                final carInfo = order['car_info'] as Map<String, dynamic>?;
                final carType = carInfo?['car_type'] as String? ?? '';
                final carModel = carInfo?['car_model'] as String? ?? '';
                final vehicleName =
                    [carType, carModel].where((part) => part.isNotEmpty).join(' ');
                final techId = order['technician_id']?.toString();
                final orderId = order['id']?.toString() ?? '';
                final orderLat = (order['latitude'] as num?)?.toDouble();
                final orderLng = (order['longitude'] as num?)?.toDouble();

                final techProfile =
                    techId != null ? _technicianProfiles[techId] : null;
                final techLat = (techProfile?['current_lat'] as num?)?.toDouble();
                final techLng = (techProfile?['current_lng'] as num?)?.toDouble();

                if (status == 'finished' && orderId.isNotEmpty) {
                  final totalAmount = (order['total_amount'] as num?)?.toDouble() ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serviceType,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Technician completed the service. Proceed to payment to finish your order.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.blue),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppButton(
                            text: 'Pay Now',
                            onPressed: () => context.push(
                              AppRoutes.payment,
                              extra: order,
                            ),
                            variant: AppButtonVariant.filled,
                          ),
                          if (totalAmount > 0) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Amount due: \$${totalAmount.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    serviceType,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  if (vehicleName.isNotEmpty) ...[
                                    const SizedBox(height: AppSpacing.xs),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.directions_car,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          vehicleName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: AppSpacing.xs),
                                  if (createdAt.isNotEmpty)
                                    Text(
                                      _formatDateTime(createdAt),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                  const SizedBox(height: AppSpacing.xs),
                                  AppBadge(
                                    label: _getStatusLabel(status),
                                    backgroundColor: _getStatusColor(status),
                                    size: AppBadgeSize.small,
                                  ),
                                  if (status == 'accepted') ...[
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      'Technician assigned. Waiting for pickup.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.blue,
                                            fontStyle: FontStyle.italic,
                                          ),
                                    ),
                                  ] else if (status == 'on_the_way' ||
                                      status == 'technician_on_the_way' ||
                                      status == 'technician on the way') ...[
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      'Technician is on the way.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.blue,
                                            fontStyle: FontStyle.italic,
                                          ),
                                    ),
                                  ] else if (status == 'arrived') ...[
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      'Technician has arrived.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.blue,
                                            fontStyle: FontStyle.italic,
                                          ),
                                    ),
                                  ] else if (status == 'working' ||
                                      status == 'in_progress' ||
                                      status == 'in progress') ...[
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      'Service is in progress.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.blue,
                                            fontStyle: FontStyle.italic,
                                          ),
                                    ),
                                  ] else if (status == 'finished') ...[
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      'Service completed. Please confirm.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.blue,
                                            fontStyle: FontStyle.italic,
                                          ),
                                    ),
                                  ],
                                  if (status == 'accepted' ||
                                      status == 'on_the_way' ||
                                      status == 'technician_on_the_way' ||
                                      status == 'technician on the way' ||
                                      status == 'arrived' ||
                                      status == 'working' ||
                                      status == 'in_progress' ||
                                      status == 'in progress') ...[
                                    const SizedBox(height: AppSpacing.sm),
                                    AppButton(
                                      text: 'Track Technician',
                                      onPressed: () {
                                        context.push(
                                          AppRoutes.map,
                                          extra: {
                                            'tracking': true,
                                            'order': order,
                                          },
                                        );
                                      },
                                      variant: AppButtonVariant.outlined,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                        if (status == 'accepted' &&
                            orderLat != null &&
                            orderLng != null &&
                            techLat != null &&
                            techLng != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 220,
                              child: FlutterMap(
                                options: MapOptions(
                                  initialCenter: LatLng(orderLat, orderLng),
                                  initialZoom: 14.0,
                                  initialCameraFit: CameraFit.bounds(
                                    bounds: LatLngBounds.fromPoints([
                                      LatLng(orderLat, orderLng),
                                      LatLng(techLat, techLng),
                                    ]),
                                    padding: const EdgeInsets.all(40),
                                  ),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}@2x?access_token=${Env.mapboxAccessToken}',
                                    tileProvider: NetworkTileProvider(),
                                    userAgentPackageName: 'com.example.app',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: LatLng(orderLat, orderLng),
                                        width: 80,
                                        height: 80,
                                        child: const Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              color: Colors.red,
                                              size: 36,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Marker(
                                        point: LatLng(techLat, techLng),
                                        width: 80,
                                        height: 80,
                                        child: const Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.engineering,
                                              color: Colors.blue,
                                              size: 36,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  PolylineLayer(
                                    polylines: [
                                      Polyline(
                                        points: [
                                          LatLng(orderLat, orderLng),
                                          LatLng(techLat, techLng),
                                        ],
                                        color: Colors.blue,
                                        strokeWidth: 3,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
