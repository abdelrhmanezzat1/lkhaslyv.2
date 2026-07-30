import 'dart:async';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/features/_shared/domain/entities/car.dart';
import 'package:flutter_application_1/features/auth/controllers/auth_controller.dart';
import 'package:flutter_application_1/features/cars/controllers/cars_controller.dart';
import 'package:flutter_application_1/features/home/presentation/map_screen.dart';
import 'package:flutter_application_1/features/orders/controllers/orders_controller.dart';
import 'package:flutter_application_1/shared/widgets/app_card.dart';
import 'package:flutter_application_1/shared/widgets/app_loader.dart';
import 'package:flutter_application_1/shared/widgets/app_snackbar.dart';
import 'package:flutter_application_1/shared/widgets/app_text_field.dart';
import 'package:flutter_application_1/widgets/custom_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Screen for creating a new service request.
/// Uses [carsForUserProvider] for reactive car loading and [OrdersController] for order creation.
class ServiceRequestScreen extends ConsumerWidget {

  const ServiceRequestScreen({super.key, required this.serviceType});
  final String serviceType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).valueOrNull;
    final carsAsync = user != null
        ? ref.watch(carsForUserProvider(user.id))
        : const AsyncData<List<Car>>([]);

    return carsAsync.when(
      loading: () => _buildLoadingScaffold(context),
      error: (error, _) => _buildErrorScaffold(context, error.toString()),
      data: (cars) => _ServiceRequestContent(
        serviceType: serviceType,
        cars: cars,
      ),
    );
  }

  Scaffold _buildLoadingScaffold(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: Text(serviceType)),
      body: const Center(child: AppLoader()),
    );
  }

  Scaffold _buildErrorScaffold(BuildContext context, String error) {
    return Scaffold(
      appBar: CustomAppBar(title: Text(serviceType)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Failed to load vehicles: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal stateful content widget that handles the form state.
class _ServiceRequestContent extends ConsumerStatefulWidget {

  const _ServiceRequestContent({
    required this.serviceType,
    required this.cars,
  });
  final String serviceType;
  final List<Car> cars;

  @override
  ConsumerState<_ServiceRequestContent> createState() => _ServiceRequestContentState();
}

class _ServiceRequestContentState extends ConsumerState<_ServiceRequestContent> {
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  Car? _selectedCar;
  File? _imageFile;
  bool _isUploadingImage = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    // Auto-select if only one car exists
    if (widget.cars.length == 1) {
      _selectedCar = widget.cars.first;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (pickedFile != null && mounted) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, message: 'Failed to pick image: $e');
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final supabase = Supabase.instance.client;
      final user = ref.read(authStateChangesProvider).valueOrNull;
      if (user == null) return;

      final fileName =
          'orders/${user.id}/${DateTime.now().millisecondsSinceEpoch}_${_imageFile!.uri.pathSegments.last}';

      await supabase.storage.from('order-images').upload(fileName, _imageFile!);

      final publicUrl = supabase.storage.from('order-images').getPublicUrl(fileName);

      if (mounted) {
        setState(() {
          _imageUrl = publicUrl;
          _isUploadingImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        AppSnackbar.showError(context, message: 'Failed to upload image: $e');
      }
    }
  }

  Future<void> _continueToMap() async {
    if (_formKey.currentState!.validate() == false) return;

    if (_selectedCar == null) {
      AppSnackbar.showError(context, message: 'Please select a vehicle.');
      return;
    }

    // Upload image first if selected
    if (_imageFile != null && _imageUrl == null) {
      await _uploadImage();
      if (_imageUrl == null) return; // Upload failed
    }

    if (!mounted) return;

    final selectedCar = _selectedCar!;
    unawaited(
      context.push(
        AppRoutes.map,
        extra: MapExtra(
          MapScreenArgs(
            car: selectedCar,
            serviceType: widget.serviceType,
            description: _descriptionController.text.trim(),
            imageUrl: _imageUrl,
          ),
        ),
      ),
    );
  }

  Color _serviceColor(String serviceType) {
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

  IconData _serviceIcon(String serviceType) {
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

  @override
  Widget build(BuildContext context) {
    final color = _serviceColor(widget.serviceType);
    final icon = _serviceIcon(widget.serviceType);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: Text(widget.serviceType),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.15), colorScheme.surface],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: kToolbarHeight + 16),
                // Selected Service Card
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: AppCard(
                    key: ValueKey(color),
                    backgroundColor: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                color.withValues(alpha: 0.3),
                                color.withValues(alpha: 0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(icon, color: color, size: 28),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selected Service',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: color.withValues(alpha: 0.8),
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                widget.serviceType,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: color,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Vehicle Selector
                Row(
                  children: [
                    Icon(
                      Icons.directions_car_rounded,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Select Vehicle',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                if (widget.cars.isEmpty)
                  // Empty state
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.car_repair_rounded,
                          size: 56,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No vehicles found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => context.push(AppRoutes.addCar),
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: const Text('Add a vehicle'),
                        ),
                      ],
                    ),
                  )
                else
                  ...widget.cars.asMap().entries.map((entry) {
                    final index = entry.key;
                    final car = entry.value;
                    final isSelected = _selectedCar?.id == car.id;

                    return AnimatedContainer(
                      duration: Duration(milliseconds: 200 + (index * 50)),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: AppCard(
                        onTap: () => setState(() => _selectedCar = car),
                        backgroundColor: isSelected ? color.withValues(alpha: 0.1) : null,
                        borderRadius: BorderRadius.circular(16),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? color : colorScheme.outline,
                                  width: 2,
                                ),
                                color: isSelected ? color : Colors.transparent,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${car.carType} ${car.carModel}',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  if (car.plateNumber.isNotEmpty)
                                    Text(
                                      car.plateNumber,
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
                    );
                  }),
                const SizedBox(height: AppSpacing.lg),

                // Problem Description
                Row(
                  children: [
                    Icon(
                      Icons.description_rounded,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Problem Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _descriptionController,
                  hintText: 'Describe the issue you are experiencing...',
                  maxLines: 4,
                  minLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please describe the problem.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Upload Image
                Row(
                  children: [
                    Icon(
                      Icons.image_rounded,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Upload Image (optional)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                if (_imageFile != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _imageFile!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (_isUploadingImage)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(child: AppLoader()),
                          ),
                        ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                          onPressed: _isUploadingImage
                              ? null
                              : () {
                                  setState(() {
                                    _imageFile = null;
                                    _imageUrl = null;
                                  });
                                },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      if (_imageUrl != null)
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.green, Colors.green.shade700],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  'Uploaded',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  )
                else
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.surfaceContainerHighest,
                            colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.add_photo_alternate_rounded,
                                size: 32,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tap to upload an image',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'JPG, PNG up to 10MB',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.xl),

                // Continue Button
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: SizedBox(
                    key: ValueKey(_isUploadingImage),
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isUploadingImage ? null : _continueToMap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: color.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isUploadingImage
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Continue',
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
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

