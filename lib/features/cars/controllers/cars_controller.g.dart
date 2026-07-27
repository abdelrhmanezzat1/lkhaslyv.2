// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cars_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$carsForUserHash() => r'02bfe5a6baa1b87f10cc35bea272cafec4bebf11';

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

/// Future provider variant — `ref.watch(carsForUserProvider(userId))` returns
/// an `AsyncValue<List<Car>>` so screens can render `.when` directly. This
/// is the public, fully-reactive API. The controller above is for imperative
/// loads called from `initState`.
///
/// Copied from [carsForUser].
@ProviderFor(carsForUser)
const carsForUserProvider = CarsForUserFamily();

/// Future provider variant — `ref.watch(carsForUserProvider(userId))` returns
/// an `AsyncValue<List<Car>>` so screens can render `.when` directly. This
/// is the public, fully-reactive API. The controller above is for imperative
/// loads called from `initState`.
///
/// Copied from [carsForUser].
class CarsForUserFamily extends Family<AsyncValue<List<Car>>> {
  /// Future provider variant — `ref.watch(carsForUserProvider(userId))` returns
  /// an `AsyncValue<List<Car>>` so screens can render `.when` directly. This
  /// is the public, fully-reactive API. The controller above is for imperative
  /// loads called from `initState`.
  ///
  /// Copied from [carsForUser].
  const CarsForUserFamily();

  /// Future provider variant — `ref.watch(carsForUserProvider(userId))` returns
  /// an `AsyncValue<List<Car>>` so screens can render `.when` directly. This
  /// is the public, fully-reactive API. The controller above is for imperative
  /// loads called from `initState`.
  ///
  /// Copied from [carsForUser].
  CarsForUserProvider call(String userId) {
    return CarsForUserProvider(userId);
  }

  @override
  CarsForUserProvider getProviderOverride(
    covariant CarsForUserProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'carsForUserProvider';
}

/// Future provider variant — `ref.watch(carsForUserProvider(userId))` returns
/// an `AsyncValue<List<Car>>` so screens can render `.when` directly. This
/// is the public, fully-reactive API. The controller above is for imperative
/// loads called from `initState`.
///
/// Copied from [carsForUser].
class CarsForUserProvider extends AutoDisposeFutureProvider<List<Car>> {
  /// Future provider variant — `ref.watch(carsForUserProvider(userId))` returns
  /// an `AsyncValue<List<Car>>` so screens can render `.when` directly. This
  /// is the public, fully-reactive API. The controller above is for imperative
  /// loads called from `initState`.
  ///
  /// Copied from [carsForUser].
  CarsForUserProvider(String userId)
    : this._internal(
        (ref) => carsForUser(ref as CarsForUserRef, userId),
        from: carsForUserProvider,
        name: r'carsForUserProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$carsForUserHash,
        dependencies: CarsForUserFamily._dependencies,
        allTransitiveDependencies: CarsForUserFamily._allTransitiveDependencies,
        userId: userId,
      );

  CarsForUserProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<List<Car>> Function(CarsForUserRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CarsForUserProvider._internal(
        (ref) => create(ref as CarsForUserRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Car>> createElement() {
    return _CarsForUserProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CarsForUserProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CarsForUserRef on AutoDisposeFutureProviderRef<List<Car>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _CarsForUserProviderElement
    extends AutoDisposeFutureProviderElement<List<Car>>
    with CarsForUserRef {
  _CarsForUserProviderElement(super.provider);

  @override
  String get userId => (origin as CarsForUserProvider).userId;
}

String _$carsControllerHash() => r'59e34f549bba6ccc7e8227f776b13c9d175c024a';

/// Controller for the Cars feature.
///
/// Phase 4.1 scope: read-only fetch (`getCars`) and the post-registration
/// `saveCar` convenience used by `add_car_screen.dart`. Action flows that
/// require a side-effect to a use-case (notifications, etc.) live in
/// `features/cars/domain/usecases/`.
///
/// Copied from [CarsController].
@ProviderFor(CarsController)
final carsControllerProvider =
    AutoDisposeAsyncNotifierProvider<CarsController, List<Car>>.internal(
      CarsController.new,
      name: r'carsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$carsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CarsController = AutoDisposeAsyncNotifier<List<Car>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
