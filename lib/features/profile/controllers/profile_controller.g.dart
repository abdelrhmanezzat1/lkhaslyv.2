// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileByIdHash() => r'02434b715fb02a420f93a3e783ee6c66469255c2';

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

/// Declarative read of a profile by user id. Lets a screen write
/// `final profile = ref.watch(profileByIdProvider(userId))` and react
/// to `AsyncValue` states without manually calling into the notifier
/// from `initState`.
///
/// Copied from [profileById].
@ProviderFor(profileById)
const profileByIdProvider = ProfileByIdFamily();

/// Declarative read of a profile by user id. Lets a screen write
/// `final profile = ref.watch(profileByIdProvider(userId))` and react
/// to `AsyncValue` states without manually calling into the notifier
/// from `initState`.
///
/// Copied from [profileById].
class ProfileByIdFamily extends Family<AsyncValue<UserProfile?>> {
  /// Declarative read of a profile by user id. Lets a screen write
  /// `final profile = ref.watch(profileByIdProvider(userId))` and react
  /// to `AsyncValue` states without manually calling into the notifier
  /// from `initState`.
  ///
  /// Copied from [profileById].
  const ProfileByIdFamily();

  /// Declarative read of a profile by user id. Lets a screen write
  /// `final profile = ref.watch(profileByIdProvider(userId))` and react
  /// to `AsyncValue` states without manually calling into the notifier
  /// from `initState`.
  ///
  /// Copied from [profileById].
  ProfileByIdProvider call(
    String userId,
  ) {
    return ProfileByIdProvider(
      userId,
    );
  }

  @override
  ProfileByIdProvider getProviderOverride(
    covariant ProfileByIdProvider provider,
  ) {
    return call(
      provider.userId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'profileByIdProvider';
}

/// Declarative read of a profile by user id. Lets a screen write
/// `final profile = ref.watch(profileByIdProvider(userId))` and react
/// to `AsyncValue` states without manually calling into the notifier
/// from `initState`.
///
/// Copied from [profileById].
class ProfileByIdProvider extends AutoDisposeFutureProvider<UserProfile?> {
  /// Declarative read of a profile by user id. Lets a screen write
  /// `final profile = ref.watch(profileByIdProvider(userId))` and react
  /// to `AsyncValue` states without manually calling into the notifier
  /// from `initState`.
  ///
  /// Copied from [profileById].
  ProfileByIdProvider(
    String userId,
  ) : this._internal(
          (ref) => profileById(
            ref as ProfileByIdRef,
            userId,
          ),
          from: profileByIdProvider,
          name: r'profileByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$profileByIdHash,
          dependencies: ProfileByIdFamily._dependencies,
          allTransitiveDependencies:
              ProfileByIdFamily._allTransitiveDependencies,
          userId: userId,
        );

  ProfileByIdProvider._internal(
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
    FutureOr<UserProfile?> Function(ProfileByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProfileByIdProvider._internal(
        (ref) => create(ref as ProfileByIdRef),
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
  AutoDisposeFutureProviderElement<UserProfile?> createElement() {
    return _ProfileByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileByIdProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ProfileByIdRef on AutoDisposeFutureProviderRef<UserProfile?> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _ProfileByIdProviderElement
    extends AutoDisposeFutureProviderElement<UserProfile?> with ProfileByIdRef {
  _ProfileByIdProviderElement(super.provider);

  @override
  String get userId => (origin as ProfileByIdProvider).userId;
}

String _$profileControllerHash() => r'ca7da2ed708d77cf2300da12f649c9a58a6ec8d9';

/// See also [ProfileController].
@ProviderFor(ProfileController)
final profileControllerProvider =
    AutoDisposeAsyncNotifierProvider<ProfileController, UserProfile?>.internal(
  ProfileController.new,
  name: r'profileControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProfileController = AutoDisposeAsyncNotifier<UserProfile?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
