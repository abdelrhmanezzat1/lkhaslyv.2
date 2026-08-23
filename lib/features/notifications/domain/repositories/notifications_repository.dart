import 'package:flutter_application_1/features/notifications/domain/entities/app_notification.dart';

/// Contract for the in-app notifications inbox.
abstract class NotificationsRepository {
  /// Lists the current user's notifications, newest first.
  ///
  /// Returns an empty list when the table is unavailable (e.g. the
  /// migration hasn't been applied yet) so the UI degrades gracefully.
  Future<List<AppNotification>> getNotifications({int limit = 50});

  /// Marks [notificationId] as read for the current user.
  Future<void> markAsRead(String notificationId);

  /// Marks every unread notification of the current user as read.
  Future<void> markAllAsRead();

  /// Number of unread notifications for the current user (0 when the
  /// table is unavailable).
  Future<int> getUnreadCount();
}
