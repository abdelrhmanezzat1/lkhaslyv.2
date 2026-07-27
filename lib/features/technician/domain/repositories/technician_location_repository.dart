// Phase 3.3: the implementation import was removed — the concrete class
// lives at `lib/features/technician/data/repositories/technician_location_repository_impl.dart`
// and is wired in through `service_locator_provider.dart`. The legacy local
// `Provider` was deleted to centralise DI; callers should import
// `technicianLocationRepositoryProvider` from `core/di/service_locator_provider.dart`.

/// Persists the live technician geo-location in the `profiles` table.
///
/// The previous (god-repository) implementation lived inside
/// `AuthRepository.updateTechnicianLocation`. With Phase 2.5 the concern
/// is moved to the *technician* feature where it canonically belongs:
/// profiles-based live tracking is a technician-only write, never used
/// by client flows.
abstract class TechnicianLocationRepository {
  /// Writes the newest lat/lng sample for the given technician.
  ///
  /// `updated_at` is set server-side style to `DateTime.now()` so that
  /// dashboards and the map screen can reason about staleness.
  Future<void> updateLocation({
    required String technicianId,
    required double latitude,
    required double longitude,
  });

  /// Reads the most recent (cached) location. Implementations may return
  /// `null` when the technician has never broadcast a position.
  Future<({double latitude, double longitude, DateTime updatedAt})?>
      readLatest(String technicianId);
}
