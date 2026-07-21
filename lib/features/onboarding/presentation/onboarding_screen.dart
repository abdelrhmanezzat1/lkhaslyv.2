import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/shared/widgets/lakhsly_button.dart';
import 'package:flutter_application_1/core/storage/storage_keys.dart';
import 'package:flutter_application_1/core/storage/storage_service.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'Welcome to Lakhsly',
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'The future of car service management is here. Track your orders, manage your garage, and connect with service providers seamlessly.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
              const Spacer(flex: 2),
              AppButton(
                onPressed: () {
                  StorageService.setBool(StorageKeys.hasSeenOnboarding, true);
                  context.go(AppRoutes.login);
                },
                text: 'Get Started',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
