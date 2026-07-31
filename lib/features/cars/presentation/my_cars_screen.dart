import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/features/_shared/domain/entities/car.dart';
import 'package:flutter_application_1/features/auth/controllers/auth_controller.dart';
import 'package:flutter_application_1/features/cars/controllers/cars_controller.dart';
import 'package:flutter_application_1/shared/widgets/app_card.dart';
import 'package:flutter_application_1/shared/widgets/app_loader.dart';
import 'package:flutter_application_1/shared/widgets/app_snackbar.dart';
import 'package:flutter_application_1/widgets/custom_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen displaying all cars owned by the current user, with add/edit/delete.
class MyCarsScreen extends ConsumerStatefulWidget {
  const MyCarsScreen({super.key});

  @override
  ConsumerState<MyCarsScreen> createState() => _MyCarsScreenState();
}

class _MyCarsScreenState extends ConsumerState<MyCarsScreen> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateChangesProvider).valueOrNull;
    final colorScheme = Theme.of(context).colorScheme;

    if (user == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: Text('My Cars')),
        body: const Center(child: Text('Not logged in.')),
      );
    }

    final carsAsync = ref.watch(carsForUserProvider(user.id));

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          'My Cars',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addCar(context),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('Add Car'),
      ),
      body: carsAsync.when(
        loading: () => const Center(child: AppLoader(message: 'Loading cars...')),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Could not load cars: $error',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ),
        data: (cars) {
          if (cars.isEmpty) {
            return _EmptyState(colorScheme: colorScheme);
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(carsForUserProvider(user.id));
            },
            color: colorScheme.primary,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: cars.length,
              itemBuilder: (context, index) => _CarCard(
                car: cars[index],
                onEdit: () => _editCar(context, cars[index]),
                onDelete: () => _deleteCar(context, cars[index]),
                isDeleting: _isDeleting,
              ),
            ),
          );
        },
      ),
    );
  }

  void _addCar(BuildContext context) {
    context.push(AppRoutes.addCar).then((_) {
      // Refresh the list when returning from add-car screen.
      final user = ref.read(authStateChangesProvider).valueOrNull;
      if (user != null) {
        ref.invalidate(carsForUserProvider(user.id));
      }
    });
  }

  void _editCar(BuildContext context, Car car) {
    context.push(
      AppRoutes.editCar,
      extra: car,
    ).then((_) {
      // Refresh the list when returning from edit screen.
      final user = ref.read(authStateChangesProvider).valueOrNull;
      if (user != null) {
        ref.invalidate(carsForUserProvider(user.id));
      }
    });
  }

  Future<void> _deleteCar(BuildContext context, Car car) async {
    if (_isDeleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Car'),
        content: Text(
          'Are you sure you want to delete ${car.displayName} (${car.plateNumber})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      await ref.read(carsControllerProvider.notifier).deleteCar(car.id);
      if (mounted) {
        AppSnackbar.showSuccess(context, message: 'Car deleted successfully.');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, message: e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }
}

class _CarCard extends StatelessWidget {
  const _CarCard({
    required this.car,
    required this.onEdit,
    required this.onDelete,
    required this.isDeleting,
  });

  final Car car;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Car icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.directions_car_rounded,
                  color: colorScheme.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              // Car details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.displayName.isNotEmpty ? car.displayName : 'Unknown',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (car.plateNumber.isNotEmpty) ...[
                          Icon(
                            Icons.confirmation_number_rounded,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            car.plateNumber,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (car.carYear != null && car.carYear!.isNotEmpty) ...[
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            car.carYear!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ],
                    ),
                    if (car.color != null && car.color!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _parseColor(car.color!),
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                  color: colorScheme.outline.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              car.color!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Edit button
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 20),
                color: colorScheme.primary,
                onPressed: isDeleting ? null : onEdit,
                tooltip: 'Edit',
              ),
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                color: colorScheme.error,
                onPressed: isDeleting ? null : onDelete,
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'silver':
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'brown':
        return Colors.brown;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.grey;
    }
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
            Icons.car_repair_rounded,
            size: 80,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No cars yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first car to get started',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to add car — handled by parent via FAB
            },
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Add Car'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}