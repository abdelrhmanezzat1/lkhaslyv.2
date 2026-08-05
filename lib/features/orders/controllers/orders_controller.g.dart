// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$clientOrdersForUserHash() =>
    r'6381dd43f50f7ac3a9dba9ef3bea44998d0a52db';

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

/// Read-only family provider returning the placed orders for a given
/// client. Phase 4.2 will switch the relevant screens to this read
/// shape instead of the imperative `loadClientOrders(...)` calls.
///
/// Copied from [clientOrdersForUser].
@ProviderFor(clientOrdersForUser)
const clientOrdersForUserProvider = ClientOrdersForUserFamily();

/// Read-only family provider returning the placed orders for a given
/// client. Phase 4.2 will switch the relevant screens to this read
/// shape instead of the imperative `loadClientOrders(...)` calls.
///
/// Copied from [clientOrdersForUser].
class ClientOrdersForUserFamily extends Family<AsyncValue<List<Order>>> {
  /// Read-only family provider returning the placed orders for a given
  /// client. Phase 4.2 will switch the relevant screens to this read
  /// shape instead of the imperative `loadClientOrders(...)` calls.
  ///
  /// Copied from [clientOrdersForUser].
  const ClientOrdersForUserFamily();

  /// Read-only family provider returning the placed orders for a given
  /// client. Phase 4.2 will switch the relevant screens to this read
  /// shape instead of the imperative `loadClientOrders(...)` calls.
  ///
  /// Copied from [clientOrdersForUser].
  ClientOrdersForUserProvider call(String clientId) {
    return ClientOrdersForUserProvider(clientId);
  }

  @override
  ClientOrdersForUserProvider getProviderOverride(
    covariant ClientOrdersForUserProvider provider,
  ) {
    return call(provider.clientId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'clientOrdersForUserProvider';
}

/// Read-only family provider returning the placed orders for a given
/// client. Phase 4.2 will switch the relevant screens to this read
/// shape instead of the imperative `loadClientOrders(...)` calls.
///
/// Copied from [clientOrdersForUser].
class ClientOrdersForUserProvider
    extends AutoDisposeFutureProvider<List<Order>> {
  /// Read-only family provider returning the placed orders for a given
  /// client. Phase 4.2 will switch the relevant screens to this read
  /// shape instead of the imperative `loadClientOrders(...)` calls.
  ///
  /// Copied from [clientOrdersForUser].
  ClientOrdersForUserProvider(String clientId)
    : this._internal(
        (ref) => clientOrdersForUser(ref as ClientOrdersForUserRef, clientId),
        from: clientOrdersForUserProvider,
        name: r'clientOrdersForUserProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$clientOrdersForUserHash,
        dependencies: ClientOrdersForUserFamily._dependencies,
        allTransitiveDependencies:
            ClientOrdersForUserFamily._allTransitiveDependencies,
        clientId: clientId,
      );

  ClientOrdersForUserProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.clientId,
  }) : super.internal();

  final String clientId;

  @override
  Override overrideWith(
    FutureOr<List<Order>> Function(ClientOrdersForUserRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ClientOrdersForUserProvider._internal(
        (ref) => create(ref as ClientOrdersForUserRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        clientId: clientId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Order>> createElement() {
    return _ClientOrdersForUserProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClientOrdersForUserProvider && other.clientId == clientId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, clientId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ClientOrdersForUserRef on AutoDisposeFutureProviderRef<List<Order>> {
  /// The parameter `clientId` of this provider.
  String get clientId;
}

class _ClientOrdersForUserProviderElement
    extends AutoDisposeFutureProviderElement<List<Order>>
    with ClientOrdersForUserRef {
  _ClientOrdersForUserProviderElement(super.provider);

  @override
  String get clientId => (origin as ClientOrdersForUserProvider).clientId;
}

String _$pendingOrdersFeedHash() => r'e67187f7a6f42bb5baefd2cbc1de7212bd5463d5';

/// Read-only feed of pending orders for a technician to pick up.
///
/// Copied from [pendingOrdersFeed].
@ProviderFor(pendingOrdersFeed)
final pendingOrdersFeedProvider =
    AutoDisposeFutureProvider<List<Order>>.internal(
      pendingOrdersFeed,
      name: r'pendingOrdersFeedProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pendingOrdersFeedHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingOrdersFeedRef = AutoDisposeFutureProviderRef<List<Order>>;
String _$ordersControllerHash() => r'68b448b483195656f08f16f2ab380a3814915d05';

/// See also [OrdersController].
@ProviderFor(OrdersController)
final ordersControllerProvider =
    AutoDisposeAsyncNotifierProvider<OrdersController, List<Order>>.internal(
      OrdersController.new,
      name: r'ordersControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ordersControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OrdersController = AutoDisposeAsyncNotifier<List<Order>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
