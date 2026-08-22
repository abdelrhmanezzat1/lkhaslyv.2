import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/features/_shared/domain/entities/car.dart';
import 'package:flutter_application_1/features/cars/controllers/cars_controller.dart';
import 'package:flutter_application_1/shared/widgets/app_button.dart';
import 'package:flutter_application_1/shared/widgets/app_snackbar.dart';
import 'package:flutter_application_1/shared/widgets/app_text_field.dart';
import 'package:flutter_application_1/widgets/custom_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen for editing an existing car's details.
class EditCarScreen extends ConsumerStatefulWidget {
  const EditCarScreen({super.key, required this.car});

  final Car car;

  @override
  ConsumerState<EditCarScreen> createState() => _EditCarScreenState();
}

class _EditCarScreenState extends ConsumerState<EditCarScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _carTypeController;
  late final TextEditingController _carModelController;
  late final TextEditingController _carYearController;
  late final TextEditingController _plateNumberController;
  late final TextEditingController _colorController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _carTypeController = TextEditingController(text: widget.car.carType);
    _carModelController = TextEditingController(text: widget.car.carModel);
    _carYearController = TextEditingController(text: widget.car.carYear ?? '');
    _plateNumberController = TextEditingController(text: widget.car.plateNumber);
    _colorController = TextEditingController(text: widget.car.color ?? '');
  }

  @override
  void dispose() {
    _carTypeController.dispose();
    _carModelController.dispose();
    _carYearController.dispose();
    _plateNumberController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (_formKey.currentState!.validate()) {
      _isSaving = true;
      setState(() {});

      final result = await AsyncValue.guard(() => ref
          .read(carsControllerProvider.notifier)
          .updateCar(
            carId: widget.car.id,
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

      _isSaving = false;
      if (mounted) {
        setState(() {});
        result.when(
          data: (_) {
            AppSnackbar.showSuccess(
              context,
              message: 'Car updated successfully!',
            );
            if (context.canPop()) context.pop();
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
      appBar: const CustomAppBar(title: Text('Edit Car')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'Update your car details',
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
                onPressed: (isLoading || _isSaving) ? null : _save,
                text: (isLoading || _isSaving) ? 'Saving...' : 'Save Changes',
              ),
            ],
          ),
        ),
      ),
    );
  }
}