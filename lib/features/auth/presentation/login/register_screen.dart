import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/features/auth/controllers/registration_controller.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/shared/widgets/app_button.dart';
import 'package:flutter_application_1/shared/widgets/app_snackbar.dart';
import 'package:flutter_application_1/shared/widgets/app_text_field.dart';
import 'package:flutter_application_1/widgets/custom_app_bar.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  String _userType = 'client';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(registrationControllerProvider.notifier)
          .register(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            phone: _phoneController.text.trim(),
            userType: _userType,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<RegistrationResult?>>(
      registrationControllerProvider,
      (_, state) {
        state.when(
          data: (result) {
            if (result == null) return;
            if (!mounted) return;
            if (result.isTechnician) {
              context.go(AppRoutes.home);
            } else {
              context.go(AppRoutes.addCar);
            }
          },
          error: (error, _) {
            if (!mounted) return;
            AppSnackbar.showError(context, message: error.toString());
          },
          loading: () {},
        );
      },
    );

    final regState = ref.watch(registrationControllerProvider);
    final isLoading = regState is AsyncLoading;

    return Scaffold(
      appBar: CustomAppBar(title: Text(AppLocalizations.of(context)!.createAccount)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.joinUs,
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              AppTextField(
                controller: _firstNameController,
                hintText: AppLocalizations.of(context)!.firstName,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.pleaseEnterFirstName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _lastNameController,
                hintText: AppLocalizations.of(context)!.lastName,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.pleaseEnterLastName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _emailController,
                hintText: AppLocalizations.of(context)!.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.pleaseEnterEmail;
                  }
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                    return AppLocalizations.of(context)!.pleaseEnterValidEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _phoneController,
                hintText: AppLocalizations.of(context)!.phoneNumber,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.pleaseEnterPhoneNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _passwordController,
                hintText: AppLocalizations.of(context)!.password,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.pleaseEnterAPassword;
                  }
                  if (value.length < 6) {
                    return AppLocalizations.of(context)!.passwordMinLength;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _confirmPasswordController,
                hintText: AppLocalizations.of(context)!.confirmPassword,
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return AppLocalizations.of(context)!.passwordsDoNotMatch;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppLocalizations.of(context)!.iAmA,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.sm),
              RadioGroup<String>(
                groupValue: _userType,
                onChanged: (value) => setState(() => _userType = value!),
                child: Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        value: 'client',
                        title: Text(AppLocalizations.of(context)!.client),
                        activeColor: AppColors.primary,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        value: 'technician',
                        title: Text(AppLocalizations.of(context)!.technician),
                        activeColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                onPressed: isLoading ? null : _signUp,
                text: isLoading ? AppLocalizations.of(context)!.creatingAccount : AppLocalizations.of(context)!.createAccount,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
