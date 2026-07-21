import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/features/technician/domain/repositories/technician_repository.dart';
import 'package:flutter_application_1/features/technician/models/technician_request.dart';
import 'package:flutter_application_1/features/technician/models/job_status.dart';
import 'package:flutter_application_1/shared/widgets/app_card.dart';
import 'package:flutter_application_1/shared/widgets/app_text_field.dart';
import 'package:flutter_application_1/shared/widgets/app_button.dart';
import 'package:flutter_application_1/shared/widgets/app_snackbar.dart';
import 'package:flutter_application_1/core/theme/app_spacing.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

/// Screen for finishing a job with notes and amount.
class FinishJobScreen extends ConsumerStatefulWidget {
  final String requestId;

  const FinishJobScreen({super.key, required this.requestId});

  @override
  ConsumerState<FinishJobScreen> createState() => _FinishJobScreenState();
}

class _FinishJobScreenState extends ConsumerState<FinishJobScreen> {
  final _notesController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(technicianRepositoryProvider);
    final request = repository.getActiveRequests().firstWhere(
      (r) => r.id == widget.requestId,
      orElse: () => TechnicianRequest(
        id: '',
        customerName: '',
        customerPhone: '',
        serviceType: '',
        vehicleName: '',
        vehiclePlate: '',
        description: '',
        distanceKm: 0,
        requestTime: DateTime.now(),
        latitude: 0,
        longitude: 0,
        status: JobStatus.completed,
      ),
    );

    if (request.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Finish Job')),
        body: const Center(child: Text('Job not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Finish Job')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Summary Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _InfoRow(label: 'Customer', value: request.customerName),
                  _InfoRow(label: 'Service', value: request.serviceType),
                  _InfoRow(
                    label: 'Vehicle',
                    value: '${request.vehicleName} - ${request.vehiclePlate}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Service Notes
            Text(
              'Service Notes',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: AppTextField(
                controller: _notesController,
                hintText: 'Describe the work done...',
                maxLines: 4,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Total Amount
            Text(
              'Total Amount',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: AppTextField(
                controller: _amountController,
                hintText: 'Enter total amount',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Finish Button
            AppButton(
              onPressed: _isSubmitting ? null : _finishJob,
              text: _isSubmitting ? 'Submitting...' : 'Finish Job',
              isLoading: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finishJob() async {
    final notes = _notesController.text.trim();
    final amountText = _amountController.text.trim();

    if (notes.isEmpty) {
      AppSnackbar.showError(context, message: 'Please enter service notes');
      return;
    }

    if (amountText.isEmpty) {
      AppSnackbar.showError(context, message: 'Please enter total amount');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      AppSnackbar.showError(context, message: 'Please enter a valid amount');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(technicianRepositoryProvider);
      repository.finishJob(widget.requestId, notes, amount);

      if (mounted) {
        AppSnackbar.showSuccess(context, message: 'Job finished successfully');
        context.go(AppRoutes.technicianHome);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        AppSnackbar.showError(context, message: 'Failed to finish job: $e');
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.secondaryText),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
