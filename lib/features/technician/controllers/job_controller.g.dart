// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$jobControllerHash() => r'724c5c6909a1d3bcfcc42067f7eb86e23f46f6c2';

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

abstract class _$JobController
    extends BuildlessAutoDisposeAsyncNotifier<TechnicianRequest?> {
  late final String requestId;

  FutureOr<TechnicianRequest?> build(String requestId);
}

/// Controller for managing active job status.
///
/// Copied from [JobController].
@ProviderFor(JobController)
const jobControllerProvider = JobControllerFamily();

/// Controller for managing active job status.
///
/// Copied from [JobController].
class JobControllerFamily extends Family<AsyncValue<TechnicianRequest?>> {
  /// Controller for managing active job status.
  ///
  /// Copied from [JobController].
  const JobControllerFamily();

  /// Controller for managing active job status.
  ///
  /// Copied from [JobController].
  JobControllerProvider call(String requestId) {
    return JobControllerProvider(requestId);
  }

  @override
  JobControllerProvider getProviderOverride(
    covariant JobControllerProvider provider,
  ) {
    return call(provider.requestId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'jobControllerProvider';
}

/// Controller for managing active job status.
///
/// Copied from [JobController].
class JobControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          JobController,
          TechnicianRequest?
        > {
  /// Controller for managing active job status.
  ///
  /// Copied from [JobController].
  JobControllerProvider(String requestId)
    : this._internal(
        () => JobController()..requestId = requestId,
        from: jobControllerProvider,
        name: r'jobControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$jobControllerHash,
        dependencies: JobControllerFamily._dependencies,
        allTransitiveDependencies:
            JobControllerFamily._allTransitiveDependencies,
        requestId: requestId,
      );

  JobControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.requestId,
  }) : super.internal();

  final String requestId;

  @override
  FutureOr<TechnicianRequest?> runNotifierBuild(
    covariant JobController notifier,
  ) {
    return notifier.build(requestId);
  }

  @override
  Override overrideWith(JobController Function() create) {
    return ProviderOverride(
      origin: this,
      override: JobControllerProvider._internal(
        () => create()..requestId = requestId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        requestId: requestId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<JobController, TechnicianRequest?>
  createElement() {
    return _JobControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is JobControllerProvider && other.requestId == requestId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, requestId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin JobControllerRef
    on AutoDisposeAsyncNotifierProviderRef<TechnicianRequest?> {
  /// The parameter `requestId` of this provider.
  String get requestId;
}

class _JobControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          JobController,
          TechnicianRequest?
        >
    with JobControllerRef {
  _JobControllerProviderElement(super.provider);

  @override
  String get requestId => (origin as JobControllerProvider).requestId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
