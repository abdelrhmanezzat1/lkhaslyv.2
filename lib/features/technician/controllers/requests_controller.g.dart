// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requests_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$requestsControllerHash() =>
    r'628c956838ccf7908d042b20ce04afc1f1306dbc';

/// Controller for managing incoming and active requests.
///
/// Copied from [RequestsController].
@ProviderFor(RequestsController)
final requestsControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      RequestsController,
      List<TechnicianRequest>
    >.internal(
      RequestsController.new,
      name: r'requestsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$requestsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RequestsController =
    AutoDisposeAsyncNotifier<List<TechnicianRequest>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
