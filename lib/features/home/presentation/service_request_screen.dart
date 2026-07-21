import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/features/auth/controllers/auth_controller.dart';
import 'package:flutter_application_1/features/auth/controllers/registration_controller.dart';
import 'package:flutter_application_1/shared/widgets/app_snackbar.dart';
import 'package:flutter_application_1/shared/widgets/app_button.dart';
import 'package:flutter_application_1/shared/widgets/app_text_field.dart';
import 'package:flutter_application_1/shared/widgets/app_card.dart';
import 'package:flutter_application_1/shared/widgets/app_loader.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceRequestScreen extends ConsumerStatefulWidget {
  final String serviceType;

  const ServiceRequestScreen({super.key, required this.serviceType});

  @override
  ConsumerState<ServiceRequestScreen> createState() =>
      _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends ConsumerState<ServiceRequestScreen> {
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  List<Map<String, dynamic>> _cars = [];
  Map<String, dynamic>? _selectedCar;
  bool _isLoadingCars = true;
  File? _imageFile;
  bool _isUploadingImage = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCars() async {
    final user = ref.read(authStateChangesProvider).valueOrNull;
    if (user == null) return;

    try {
      final cars = await ref
          .read(registrationControllerProvider.notifier)
          .getCars(user.id);
      if (mounted) {
        setState(() {
          _cars = cars;
          _isLoadingCars = false;
          // Auto-select if only one car exists
          if (cars.length == 1) {
            _selectedCar = cars.first;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCars = false);
        AppSnackbar.showError(context, message: 'Failed to load cars: $e');
      }
    }
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

      final publicUrl = supabase.storage
          .from('order-images')
          .getPublicUrl(fileName);

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

  Future<void> _continue() async {
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
    context.push(
      AppRoutes.map,
      extra: {
        'car': selectedCar,
        'serviceType': widget.serviceType,
        'description': _descriptionController.text.trim(),
        'imageUrl': _imageUrl,
      },
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
        return Icons.build;
      case 'Electrical':
        return Icons.bolt;
      case 'Diagnostics':
        return Icons.bug_report;
      case 'Spare Parts':
        return Icons.inventory_2;
      default:
        return Icons.miscellaneous_services;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _serviceColor(widget.serviceType);
    final icon = _serviceIcon(widget.serviceType);

    return Scaffold(
      appBar: AppBar(title: const Text('Service Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Selected Service Card
              AppCard(
                backgroundColor: color.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Service',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: color.withValues(alpha: 0.8)),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            widget.serviceType,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Vehicle Selector
              Text(
                'Select Vehicle',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (_isLoadingCars)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: AppLoader(),
                )
              else if (_cars.isEmpty)
                AppCard(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.car_repair,
                        size: 40,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'No vehicles found.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: () {
                          context.push(AppRoutes.addCar);
                        },
                        child: const Text('Add a vehicle'),
                      ),
                    ],
                  ),
                )
              else
                ..._cars.map((car) {
                  final int carId = car['id'] as int;
                  final carType = car['car_type'] as String? ?? '';
                  final carModel = car['car_model'] as String? ?? '';
                  final plateNumber = car['plate_number'] as String? ?? '';
                  final isSelected =
                      _selectedCar != null && _selectedCar!['id'] == carId;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      onTap: () {
                        setState(() => _selectedCar = car);
                      },
                      backgroundColor: isSelected
                          ? color.withValues(alpha: 0.1)
                          : null,
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? color : Colors.grey,
                                width: 2,
                              ),
                              color: isSelected ? color : null,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$carType $carModel',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                if (plateNumber.isNotEmpty)
                                  Text(
                                    plateNumber,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey),
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
              Text(
                'Problem Description',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
              Text(
                'Upload Image (optional)',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (_imageFile != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _imageFile!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (_isUploadingImage)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(child: AppLoader()),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
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
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check, size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Uploaded',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                )
              else
                AppCard(
                  onTap: _pickImage,
                  child: Column(
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Tap to upload an image',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),

              // Continue Button
              AppButton(
                onPressed: _isUploadingImage ? null : _continue,
                text: 'Continue',
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
