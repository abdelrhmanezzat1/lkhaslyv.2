import 'package:flutter_application_1/core/di/service_locator_provider.dart';
import 'package:flutter_application_1/features/technician/domain/repositories/technician_repository.dart';
import 'package:flutter_application_1/features/technician/models/technician.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provides the [Technician] profile.
///
/// Phase 3.3: resolves the repository through the central DI bridge.
final technicianProfileProvider = Provider<Technician>((ref) {
  final repo = ref.watch(technicianRepositoryProvider);
  try {
    return repo.getTechnicianProfile();
  } on Exception {
    // Profile not yet loaded; return a safe placeholder that won't crash
    return Technician(id: '', name: '', email: '', phone: '');
  }
});

/// Controller for technician profile and online status.
class TechnicianController extends StateNotifier<Technician> {

  TechnicianController(this._repository) : super(_tryGetProfile(_repository)) {
    _loadProfileIfNeeded();
  }
  final TechnicianRepository _repository;

  static Technician _tryGetProfile(TechnicianRepository repository) {
    try {
      return repository.getTechnicianProfile();
    } on Exception {
      return Technician(id: '', name: '', email: '', phone: '');
    }
  }

  Future<void> _loadProfileIfNeeded() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      await _repository.loadTechnicianProfile(user.id);
      final profile = _repository.getTechnicianProfile();
      if (profile.id.isNotEmpty) {
        state = profile;
      }
      // After loading the profile, fetch pending and accepted orders from Supabase.
      await Future.wait([
        _repository.fetchPendingRequests(),
        _repository.fetchAcceptedRequests(),
      ]);
    } on Exception {
      // keep state as-is
    }
  }

  void toggleOnline() {
    _repository.toggleOnline();
    try {
      state = _repository.getTechnicianProfile();
    } on Exception {
      // Keep current state if profile isn't loaded yet
    }
  }

  int get pendingCount => _repository.pendingCount;
  int get acceptedCount => _repository.acceptedCount;
  int get completedCount => _repository.completedCount;
}

/// Provides the [TechnicianController].
///
/// Phase 3.3: pulls the repository from the central DI bridge so tests
/// can override `technicianRepositoryProvider` directly without
/// touching `get_it`.
final technicianControllerProvider =
    StateNotifierProvider<TechnicianController, Technician>((ref) {
      final repo = ref.watch(technicianRepositoryProvider);
      return TechnicianController(repo);
    });
