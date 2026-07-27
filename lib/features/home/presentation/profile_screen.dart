import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auth/controllers/auth_controller.dart';
import 'package:flutter_application_1/shared/widgets/app_loader.dart';
import 'package:flutter_application_1/shared/widgets/app_snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the current user's name.
    final user = ref.read(authStateChangesProvider).valueOrNull;
    final currentName = user?.userMetadata?['full_name'] as String? ?? '';
    _nameController = TextEditingController(text: currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authControllerProvider.notifier)
          .updateUser(name: _nameController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      // Only handle state changes that come after a loading state.
      if (previous is! AsyncLoading) return;

      next.when(
        data: (_) {
          if (!mounted) return;
          AppSnackbar.showSuccess(
            context,
            message: 'Profile updated successfully!',
          );
          if (context.canPop()) {
            context.pop();
          }
        },
        error: (error, _) {
          if (!mounted) return;
          final errorMessage = error is AuthException
              ? error.message
              : 'An unknown error occurred.';
          AppSnackbar.showError(context, message: errorMessage);
        },
        loading: () {},
      );
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AsyncLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text(
                'Update Your Information',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _updateProfile,
                child: isLoading
                    ? const AppLoader()
                    : const Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
