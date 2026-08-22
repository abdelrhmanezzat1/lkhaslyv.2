// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mechanical_catalog_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mechanicalIssuesForCarHash() =>
    r'9b686b463d116b615ad8f3e8b9584cf3a744cfb6';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Resolves the mechanical issues applicable to [car] from the catalog.
///
/// Matching is BRAND + MODEL ONLY (case-insensitive, trimmed) — the car's
/// year is never used. Returns a no-match result ([hasMatch] = false, empty
/// issue list) when the catalog has no entry for the car's brand+model;
/// callers then fall back to the free-text description field.
///
/// Copied from [mechanicalIssuesForCar].
@ProviderFor(mechanicalIssuesForCar)
const mechanicalIssuesForCarProvider = MechanicalIssuesForCarFamily();

/// Resolves the mechanical issues applicable to [car] from the catalog.
///
/// Matching is BRAND + MODEL ONLY (case-insensitive, trimmed) — the car's
/// year is never used. Returns a no-match result ([hasMatch] = false, empty
/// issue list) when the catalog has no entry for the car's brand+model;
/// callers then fall back to the free-text description field.
///
/// Copied from [mechanicalIssuesForCar].
class MechanicalIssuesForCarFamily
    extends Family<AsyncValue<MechanicalIssuesResult>> {
  /// Resolves the mechanical issues applicable to [car] from the catalog.
  ///
  /// Matching is BRAND + MODEL ONLY (case-insensitive, trimmed) — the car's
  /// year is never used. Returns a no-match result ([hasMatch] = false, empty
  /// issue list) when the catalog has no entry for the car's brand+model;
  /// callers then fall back to the free-text description field.
  ///
  /// Copied from [mechanicalIssuesForCar].
  const MechanicalIssuesForCarFamily();

  /// Resolves the mechanical issues applicable to [car] from the catalog.
  ///
  /// Matching is BRAND + MODEL ONLY (case-insensitive, trimmed) — the car's
  /// year is never used. Returns a no-match result ([hasMatch] = false, empty
  /// issue list) when the catalog has no entry for the car's brand+model;
  /// callers then fall back to the free-text description field.
  ///
  /// Copied from [mechanicalIssuesForCar].
  MechanicalIssuesForCarProvider call(Car car) {
    return MechanicalIssuesForCarProvider(car);
  }

  @override
  MechanicalIssuesForCarProvider getProviderOverride(
    covariant MechanicalIssuesForCarProvider provider,
  ) {
    return call(provider.car);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mechanicalIssuesForCarProvider';
}

/// Resolves the mechanical issues applicable to [car] from the catalog.
///
/// Matching is BRAND + MODEL ONLY (case-insensitive, trimmed) — the car's
/// year is never used. Returns a no-match result ([hasMatch] = false, empty
/// issue list) when the catalog has no entry for the car's brand+model;
/// callers then fall back to the free-text description field.
///
/// Copied from [mechanicalIssuesForCar].
class MechanicalIssuesForCarProvider
    extends AutoDisposeFutureProvider<MechanicalIssuesResult> {
  /// Resolves the mechanical issues applicable to [car] from the catalog.
  ///
  /// Matching is BRAND + MODEL ONLY (case-insensitive, trimmed) — the car's
  /// year is never used. Returns a no-match result ([hasMatch] = false, empty
  /// issue list) when the catalog has no entry for the car's brand+model;
  /// callers then fall back to the free-text description field.
  ///
  /// Copied from [mechanicalIssuesForCar].
  MechanicalIssuesForCarProvider(Car car)
    : this._internal(
        (ref) => mechanicalIssuesForCar(ref as MechanicalIssuesForCarRef, car),
        from: mechanicalIssuesForCarProvider,
        name: r'mechanicalIssuesForCarProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$mechanicalIssuesForCarHash,
        dependencies: MechanicalIssuesForCarFamily._dependencies,
        allTransitiveDependencies:
            MechanicalIssuesForCarFamily._allTransitiveDependencies,
        car: car,
      );

  MechanicalIssuesForCarProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.car,
  }) : super.internal();

  final Car car;

  @override
  Override overrideWith(
    FutureOr<MechanicalIssuesResult> Function(
      MechanicalIssuesForCarRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MechanicalIssuesForCarProvider._internal(
        (ref) => create(ref as MechanicalIssuesForCarRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        car: car,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MechanicalIssuesResult> createElement() {
    return _MechanicalIssuesForCarProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MechanicalIssuesForCarProvider && other.car == car;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, car.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MechanicalIssuesForCarRef
    on AutoDisposeFutureProviderRef<MechanicalIssuesResult> {
  /// The parameter `car` of this provider.
  Car get car;
}

class _MechanicalIssuesForCarProviderElement
    extends AutoDisposeFutureProviderElement<MechanicalIssuesResult>
    with MechanicalIssuesForCarRef {
  _MechanicalIssuesForCarProviderElement(super.provider);

  @override
  Car get car => (origin as MechanicalIssuesForCarProvider).car;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
