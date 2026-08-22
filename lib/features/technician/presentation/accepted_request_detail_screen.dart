import 'package:flutter/material.dart';
// Phase 3.3: repository providers now live in the central DI bridge.
import 'package:flutter_application_1/core/di/service_locator_provider.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/features/_shared/data/mappers/entity_mappers.dart';
import 'package:flutter_application_1/features/_shared/domain/entities/order.dart';
import 'package:flutter_application_1/features/technician/domain/repositories/technician_repository.dart';

import 'package:flutter_application_1/features/technician/technician.dart';
import 'package:flutter_application_1/shared/widgets/app_loader.dart';
import 'package:flutter_application_1/widgets/custom_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen displaying a single accepted service request detail for technicians.
class AcceptedRequestDetailScreen extends ConsumerWidget {

  const AcceptedRequestDetailScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(technicianRepositoryProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: Text('Job Details'),
        elevation: 0,
      ),
      body: FutureBuilder<TechnicianRequest?>(
        future: _fetchRequestDetails(repository),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: AppLoader(message: 'Loading job details...'));
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: 'Failed to load job: ${snapshot.error}',
              onRetry: () => ref.invalidate(technicianRepositoryProvider),
            );
          }

          final request = snapshot.data;
          if (request == null) {
            return _ErrorState(
              message: 'Job not found',
              onRetry: () => context.pop(),
            );
          }

          return _buildDetailView(context, request);
        },
      ),
    );
  }

  Future<TechnicianRequest?> _fetchRequestDetails(
    TechnicianRepository repository,
  ) async {
    try {
      final rawOrder = await repository.getOrderById(orderId);
      if (rawOrder == null) return null;

      final order = EntityMappers.orderFromJson(rawOrder);

      // Map order to TechnicianRequest
      final carInfo = order.carInfo;
      final carType = carInfo?['car_type']?.toString() ?? '';
      final carModel = carInfo?['car_model']?.toString() ?? '';
      final plateNumber = carInfo?['plate_number']?.toString() ?? '';
      final vehicleName = '$carType $carModel'.trim();

      return TechnicianRequest(
        id: order.id,
        customerName: carInfo?['customer_name']?.toString() ?? 'Unknown',
        customerPhone: carInfo?['customer_phone']?.toString() ?? '',
        serviceType: order.serviceType.isEmpty ? 'Unknown' : order.serviceType,
        vehicleName: vehicleName.isEmpty ? 'N/A' : vehicleName,
        vehiclePlate: plateNumber,
        description: order.description,
        distanceKm: 0,
        requestTime: order.createdAt,
        latitude: order.latitude,
        longitude: order.longitude,
        status: JobStatusExtension.fromString(order.status.dbValue),
      );
    } catch (e) {
      return null;
    }
  }

  Widget _buildDetailView(BuildContext context, TechnicianRequest request) {
    final colorScheme = Theme.of(context).colorScheme;
    final serviceColor = _getServiceColor(request.serviceType);
    final serviceIcon = _getServiceIcon(request.serviceType);
    final statusColor = _getStatusColor(request.status);
    final statusIcon = _getStatusIcon(request.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with service type badge and status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      serviceColor.withValues(alpha: 0.2),
                      serviceColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: serviceColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(serviceIcon, size: 16, color: serviceColor),
                    const SizedBox(width: 6),
                    Text(
                      request.serviceType,
                      style: TextStyle(
                        color: serviceColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusColor.withValues(alpha: 0.2),
                      statusColor.withValues(alpha: 0.1),
                    ],
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
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      request.status.label,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Customer info with avatar
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: serviceColor.withValues(alpha: 0.15),
                child: Text(
                  request.customerName.isNotEmpty
                      ? request.customerName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: serviceColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.customerName,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Active Job',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Details Grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Vehicle info
                _DetailRow(
                  icon: Icons.directions_car_rounded,
                  label: 'Vehicle',
                  value: '${request.vehicleName} - ${request.vehiclePlate}',
                  iconColor: colorScheme.primary,
                ),
                const SizedBox(height: 12),
                // Distance
                _DetailRow(
                  icon: Icons.straighten_rounded,
                  label: 'Distance',
                  value: '${request.distanceKm} km away',
                  iconColor: Colors.blue,
                ),
                if (request.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  // Description
                  _DetailRow(
                    icon: Icons.description_rounded,
                    label: 'Details',
                    value: request.description,
                    iconColor: Colors.purple,
                    isMultiline: true,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.push(AppRoutes.liveStatus, extra: LiveStatusExtra(request.id));
              },
              icon: const Icon(Icons.visibility_rounded, size: 18),
              label: const Text('View Live Status'),
              style: ElevatedButton.styleFrom(
                backgroundColor: serviceColor,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: serviceColor.withValues(alpha: 0.4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getServiceColor(String serviceType) {
    switch (serviceType) {
      case 'Mechanical':
        return const Color(0xFFFF7043);
      case 'Electrical':
        return const Color(0xFFFFCA28);
      case 'Diagnostics':
        return const Color(0xFF42A5F5);
      case 'Spare Parts':
        return const Color(0xFF66BB6A);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType) {
      case 'Mechanical':
        return Icons.build_rounded;
      case 'Electrical':
        return Icons.bolt_rounded;
      case 'Diagnostics':
        return Icons.bug_report_rounded;
      case 'Spare Parts':
        return Icons.inventory_2_rounded;
      default:
        return Icons.miscellaneous_services_rounded;
    }
  }

  Color _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.accepted:
        return const Color(0xFF42A5F5);
      case JobStatus.driving:
        return const Color(0xFF42A5F5);
      case JobStatus.arrived:
        return const Color(0xFFAB47BC);
      case JobStatus.working:
        return const Color(0xFF5C6BC0);
      case JobStatus.finished:
        return const Color(0xFF26A69A);
      default:
        return AppColors.primary;
    }
  }

  IconData _getStatusIcon(JobStatus status) {
    switch (status) {
      case JobStatus.accepted:
        return Icons.check_circle_outline_rounded;
      case JobStatus.driving:
        return Icons.directions_car_rounded;
      case JobStatus.arrived:
        return Icons.location_on_rounded;
      case JobStatus.working:
        return Icons.build_rounded;
      case JobStatus.finished:
        return Icons.check_circle_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    this.isMultiline = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final bool isMultiline;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: iconColor),
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
                maxLines: isMultiline ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.error.withValues(alpha: 0.15),
                    AppColors.error.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    height: 1.6,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
