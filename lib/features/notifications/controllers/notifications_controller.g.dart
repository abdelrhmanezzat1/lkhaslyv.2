// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentUserIdHash() => r'c1f8f23e8a220c02fbd42c7c6049058d8fe1b79c';

/// Exposes the current authenticated user id (null when signed out).
///
/// Copied from [currentUserId].
@ProviderFor(currentUserId)
final currentUserIdProvider = AutoDisposeStreamProvider<String?>.internal(
  currentUserId,
  name: r'currentUserIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentUserIdRef = AutoDisposeStreamProviderRef<String?>;
String _$unreadNotificationsCountHash() =>
    r'2dc53cb08aaf0ccd701d3ae64d540f4b05f822c8';

/// Unread badge count for the home screen bell. Rebuilt whenever the
/// auth state changes; invalidated by the inbox after read-state changes.
///
/// Copied from [UnreadNotificationsCount].
@ProviderFor(UnreadNotificationsCount)
final unreadNotificationsCountProvider =
    AutoDisposeAsyncNotifierProvider<UnreadNotificationsCount, int>.internal(
  UnreadNotificationsCount.new,
  name: r'unreadNotificationsCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadNotificationsCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UnreadNotificationsCount = AutoDisposeAsyncNotifier<int>;
String _$notificationsControllerHash() =>
    r'3d5a8740317d03e1fae89b9743b57743c5dce118';

/// See also [NotificationsController].
@ProviderFor(NotificationsController)
final notificationsControllerProvider = AutoDisposeAsyncNotifierProvider<
    NotificationsController, List<AppNotification>>.internal(
  NotificationsController.new,
  name: r'notificationsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotificationsController
    = AutoDisposeAsyncNotifier<List<AppNotification>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
