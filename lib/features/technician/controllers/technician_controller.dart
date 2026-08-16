import 'package:flutter/foundation.dart';
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

  bool _isProfileLoading = false;
  String? _profileLoadError;

  /// Whether the technician profile is currently being loaded.
  bool get isProfileLoading => _isProfileLoading;

  /// Whether the technician profile has been successfully loaded
  /// (i.e. the local profile has a non-empty id).
  bool get isProfileLoaded => state.id.isNotEmpty;

  /// The last error encountered while loading the profile, if any.
  String? get profileLoadError => _profileLoadError;

  static Technician _tryGetProfile(TechnicianRepository repository) {
    try {
      return repository.getTechnicianProfile();
    } on Exception {
      return Technician(id: '', name: '', email: '', phone: '');
    }
  }

  Future<void> _loadProfileIfNeeded() async {
    if (_isProfileLoading) return;
    _isProfileLoading = true;
    _profileLoadError = null;
    _notifyListeners();
    debugPrint(
      '🔧 [TechnicianController] _loadProfileIfNeeded() START — '
      'currentUser=${Supabase.instance.client.auth.currentUser?.id}',
    );
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      debugPrint(
        '🔧 [TechnicianController] _loadProfileIfNeeded() — user is null, '
        'cannot load profile. Will retry when session is available.',
      );
      _isProfileLoading = false;
      _notifyListeners();
      return;
    }
    try {
      await _repository.loadTechnicianProfile(user.id);
      final profile = _repository.getTechnicianProfile();
      debugPrint(
        '🔧 [TechnicianController] _loadProfileIfNeeded() — profile loaded: '
        'id="${profile.id}" name="${profile.name}"',
      );
      if (profile.id.isNotEmpty) {
        state = profile;
      } else {
        debugPrint(
          '🔧 [TechnicianController] _loadProfileIfNeeded() — profile returned '
          'empty id; keeping current state.',
        );
      }
      // After loading the profile, fetch pending and accepted orders from Supabase.
      await Future.wait([
        _repository.fetchPendingRequests(),
        _repository.fetchAcceptedRequests(),
      ]);
      debugPrint(
        '🔧 [TechnicianController] _loadProfileIfNeeded() — pending/accepted '
        'requests fetched.',
      );
    } on Exception catch (e, stack) {
      _profileLoadError = e.toString();
      debugPrint(
        '🔧 [TechnicianController] _loadProfileIfNeeded() FAILED: $e\n$stack',
      );
      // keep state as-is
    } finally {
      _isProfileLoading = false;
      debugPrint(
        '🔧 [TechnicianController] _loadProfileIfNeeded() END — '
        'isProfileLoaded=$isProfileLoaded error=$_profileLoadError',
      );
      // Force a rebuild so the UI can react to the loading/error state
      // (these are plain fields, not part of the StateNotifier state).
      _notifyListeners();
    }
  }

  /// Emits a new state instance so StateNotifier listeners (which skip
  /// `identical` values) are notified even when only the plain fields
  /// (`_isProfileLoading`, `_profileLoadError`) changed.
  void _notifyListeners() {
    final current = state;
    state = Technician(
      id: current.id,
      name: current.name,
      email: current.email,
      phone: current.phone,
      rating: current.rating,
      completedJobs: current.completedJobs,
      isOnline: current.isOnline,
    );
  }

  /// Retries loading the technician profile (e.g. after a failure or when
  /// the Supabase session becomes available).
  Future<void> retryLoadProfile() => _loadProfileIfNeeded();

  Future<void> toggleOnline() async {
    try {
      await _repository.toggleOnline();
      state = _repository.getTechnicianProfile();
    } on Exception catch (e) {
      debugPrint('🔧 [TechnicianController] toggleOnline() FAILED: $e');
      rethrow;
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
