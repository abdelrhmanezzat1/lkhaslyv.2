import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/features/auth/controllers/auth_controller.dart';
import 'package:flutter_application_1/features/cars/controllers/cars_controller.dart';
import 'package:flutter_application_1/shared/widgets/app_button.dart';
import 'package:flutter_application_1/shared/widgets/app_snackbar.dart';
import 'package:flutter_application_1/shared/widgets/app_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddCarScreen extends ConsumerStatefulWidget {
  const AddCarScreen({super.key});

  @override
  ConsumerState<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends ConsumerState<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _carTypeController = TextEditingController();
  final _carModelController = TextEditingController();
  final _carYearController = TextEditingController();
  final _plateNumberController = TextEditingController();
  final _colorController = TextEditingController();

  @override
  void dispose() {
    _carTypeController.dispose();
    _carModelController.dispose();
    _carYearController.dispose();
    _plateNumberController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _saveCar() async {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(authStateChangesProvider).valueOrNull;
      if (user == null) return;

      final result = await AsyncValue.guard(() => ref
          .read(carsControllerProvider.notifier)
          .saveCar(
            userId: user.id,
            carType: _carTypeController.text.trim(),
            carModel: _carModelController.text.trim(),
            plateNumber: _plateNumberController.text.trim(),
            carYear: _carYearController.text.trim().isEmpty
                ? null
                : _carYearController.text.trim(),
            color: _colorController.text.trim().isEmpty
                ? null
                : _colorController.text.trim(),
          ));

      if (mounted) {
        result.when(
          data: (_) {
            AppSnackbar.showSuccess(
              context,
              message: 'Car saved successfully!',
            );
            context.go(AppRoutes.home);
          },
          error: (error, _) {
            AppSnackbar.showError(context, message: error.toString());
          },
          loading: () {},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final carsController = ref.watch(carsControllerProvider);
    final isLoading = carsController is AsyncLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Your Car')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'Tell us about your car',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              AppTextField(
                controller: _carTypeController,
                hintText: 'Car Type',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the car type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _carModelController,
                hintText: 'Car Model',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the car model';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _colorController,
                hintText: 'Color',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the color';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _plateNumberController,
                hintText: 'Plate Number',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the plate number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _carYearController,
                hintText: 'Car Year (optional)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                onPressed: isLoading ? null : _saveCar,
                text: isLoading ? 'Saving...' : 'Save & Continue',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
