// Feature-local controller for the notifications inbox.
//
// Follows the OrdersController conventions: repositories are sourced from
// the typed providers in `core/di/service_locator_provider.dart` (never
// `sl<T>()` directly) so tests can override them.

import 'package:flutter_application_1/core/di/service_locator_provider.dart';
import 'package:flutter_application_1/features/notifications/domain/entities/app_notification.dart';
import 'package:flutter_application_1/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'notifications_controller.g.dart';

/// Exposes the current authenticated user id (null when signed out).
@riverpod
Stream<String?> currentUserId(Ref ref) {
  return Supabase.instance.client.auth.onAuthStateChange
      .map((event) => event.session?.user.id)
      .distinct();
}

/// Unread badge count for the home screen bell. Rebuilt whenever the
/// auth state changes; invalidated by the inbox after read-state changes.
@riverpod
class UnreadNotificationsCount extends _$UnreadNotificationsCount {
  @override
  FutureOr<int> build() async {
    final NotificationsRepository repository =
        ref.watch(notificationsRepositoryProvider);
    return repository.getUnreadCount();
  }

  Future<void> refresh() async {
    state = const AsyncLoading<int>().copyWithPrevious(state);
    final NotificationsRepository repository =
        ref.read(notificationsRepositoryProvider);
    state = AsyncData<int>(await repository.getUnreadCount());
  }
}

@riverpod
class NotificationsController extends _$NotificationsController {
  @override
  FutureOr<List<AppNotification>> build() async {
    final NotificationsRepository repository =
        ref.watch(notificationsRepositoryProvider);
    return repository.getNotifications();
  }

  Future<void> refresh() async {
    final NotificationsRepository repository =
        ref.read(notificationsRepositoryProvider);
    state = AsyncData<List<AppNotification>>(
      await repository.getNotifications(),
    );
  }

  /// Marks a single notification as read and updates the cached list.
  Future<void> markAsRead(String notificationId) async {
    final NotificationsRepository repository =
        ref.read(notificationsRepositoryProvider);
    await repository.markAsRead(notificationId);
    _patchLocal(notificationId, read: true);
    ref.invalidate(unreadNotificationsCountProvider);
  }

  /// Marks every notification as read.
  Future<void> markAllAsRead() async {
    final NotificationsRepository repository =
        ref.read(notificationsRepositoryProvider);
    await repository.markAllAsRead();
    final previous = state.value ?? const <AppNotification>[];
    state = AsyncData<List<AppNotification>>([
      for (final AppNotification n in previous) _withRead(n, true),
    ]);
    ref.invalidate(unreadNotificationsCountProvider);
  }

  void _patchLocal(String notificationId, {required bool read}) {
    final previous = state.value ?? const <AppNotification>[];
    state = AsyncData<List<AppNotification>>([
      for (final AppNotification n in previous)
        if (n.id == notificationId) _withRead(n, read) else n,
    ]);
  }

  static AppNotification _withRead(AppNotification n, bool read) =>
      AppNotification(
        id: n.id,
        userId: n.userId,
        type: n.type,
        title: n.title,
        body: n.body,
        data: n.data,
        read: read,
        createdAt: n.createdAt,
      );
}
