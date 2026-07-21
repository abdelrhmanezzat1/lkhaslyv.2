import 'package:flutter_application_1/core/di/service_locator.dart';
import 'package:flutter_application_1/features/technician/domain/repositories/technician_repository.dart';
import 'package:flutter_application_1/features/technician/models/technician.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the [Technician] profile.
final technicianProfileProvider = Provider<Technician>((ref) {
  final repo = sl<TechnicianRepository>();
  return repo.getTechnicianProfile();
});

/// Controller for technician profile and online status.
class TechnicianController extends StateNotifier<Technician> {
  final TechnicianRepository _repository;

  TechnicianController(this._repository)
    : super(_repository.getTechnicianProfile());

  void toggleOnline() {
    _repository.toggleOnline();
    state = _repository.getTechnicianProfile();
  }

  int get pendingCount => _repository.pendingCount;
  int get acceptedCount => _repository.acceptedCount;
  int get completedCount => _repository.completedCount;
}

/// Provides the [TechnicianController].
final technicianControllerProvider =
    StateNotifierProvider<TechnicianController, Technician>((ref) {
      final repo = sl<TechnicianRepository>();
      return TechnicianController(repo);
    });
