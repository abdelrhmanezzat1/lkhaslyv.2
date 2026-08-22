import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/core/theme/app_typography.dart';
import 'package:flutter_application_1/features/auth/controllers/auth_controller.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/shared/widgets/app_brand_logo.dart';
import 'package:flutter_application_1/shared/widgets/app_button.dart';
import 'package:flutter_application_1/shared/widgets/app_card.dart';
import 'package:flutter_application_1/shared/widgets/app_snackbar.dart';
import 'package:flutter_application_1/shared/widgets/app_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authControllerProvider.notifier)
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authControllerProvider, (_, state) {
      state.when(
        data: (_) {},
        error: (error, _) {
          if (!mounted) return;
          final errorMessage = error is AuthException
              ? error.message
              : AppLocalizations.of(context)!.unknownError;
          AppSnackbar.showError(context, message: errorMessage);
        },
        loading: () {},
      );
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AsyncLoading;
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width > 600;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primary : AppColors.primary;
    final onPrimaryColor = isDark ? AppColors.onPrimary : AppColors.onLightSurface;
    final backgroundGradient = isDark
        ? [AppColors.background, AppColors.surface]
        : [AppColors.lightBackground, AppColors.lightSurface];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo
                            _AnimatedLogo(size: isWide ? 80 : 72),
                            const SizedBox(height: AppSpacing.xl),
                            // Title
                            Text(
                              AppLocalizations.of(context)!.welcomeBack,
                              textAlign: TextAlign.center,
                              style: AppTypography.textTheme.headlineMedium?.copyWith(
                                    color: onPrimaryColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              AppLocalizations.of(context)!.signInSubtitle,
                              textAlign: TextAlign.center,
                              style: AppTypography.textTheme.bodyLarge?.copyWith(
                                    color: onPrimaryColor.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            // Form Card
                            AppCard(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Email field
                                    AppTextField(
                                      controller: _emailController,
                                      focusNode: _emailFocusNode,
                                      labelText: AppLocalizations.of(context)!.email,
                                      hintText: AppLocalizations.of(context)!.emailHint,
                                      keyboardType: TextInputType.emailAddress,
                                      prefixIcon: const Icon(Icons.email_outlined),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return AppLocalizations.of(context)!.pleaseEnterEmail;
                                        }
                                        if (!RegExp(r'\S+@\S+\.\S+')
                                            .hasMatch(value)) {
                                          return AppLocalizations.of(context)!.pleaseEnterValidEmail;
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                    // Password field
                                    AppTextField(
                                      controller: _passwordController,
                                      focusNode: _passwordFocusNode,
                                      labelText: AppLocalizations.of(context)!.password,
                                      hintText: AppLocalizations.of(context)!.passwordHint,
                                      obscureText: true,
                                      prefixIcon: const Icon(Icons.lock_outlined),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return AppLocalizations.of(context)!.pleaseEnterPassword;
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    // Forgot password
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () => context.push(
                                          AppRoutes.forgotPassword,
                                        ),
                                        child: Text(
                                          AppLocalizations.of(context)!.forgotPassword,
                                          style: AppTypography.textTheme.bodySmall?.copyWith(
                                                color: primaryColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    // Login button
                                    AppButton(
                                      text: AppLocalizations.of(context)!.signIn,
                                      isLoading: isLoading,
                                      onPressed: _signIn,
                                      icon: const Icon(Icons.arrow_forward_rounded),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            // Create account
                            TextButton(
                              onPressed: () =>
                                  context.push(AppRoutes.register),
                              child: RichText(
                                text: TextSpan(
                                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                                        color: onPrimaryColor.withValues(alpha: 0.8),
                                      ),
                                  children: [
                                    TextSpan(
                                      text:
                                          AppLocalizations.of(context)!.dontHaveAccount,
                                    ),
                                    TextSpan(
                                      text: AppLocalizations.of(context)!.createOne,
                                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: onPrimaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedLogo extends StatefulWidget {
  const _AnimatedLogo({required this.size});
  final double size;

  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const ElasticOutCurve(0.8),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AppBrandLogoBadge(size: widget.size),
    );
  }
}
