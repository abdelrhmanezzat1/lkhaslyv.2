// Domain entity for an in-app notification row.
//
// Mirrors the `notifications` table created by
// `supabase/migrations/20260823000000_notifications_inbox.sql`.
class AppNotification {
  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        body: json['body']?.toString() ?? '',
        data: (json['data'] as Map<String, dynamic>?) ??
            const <String, dynamic>{},
        read: json['read'] as bool? ?? false,
        createdAt: DateTime.tryParse(
              json['created_at']?.toString() ?? '',
            )?.toLocal() ??
            DateTime.now(),
      );
  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data = const <String, dynamic>{},
    this.read = false,
    required this.createdAt,
  });

  final String id;
  final String userId;

  /// Notification type key (e.g. `technician_accepted`, `rating_reminder`).
  final String type;
  final String title;
  final String body;

  /// Free-form payload. `deep_link` is used by the inbox to navigate.
  final Map<String, dynamic> data;
  final bool read;
  final DateTime createdAt;

  /// Deep link route extracted from [data], if any.
  String? get deepLink => data['deep_link']?.toString();
}
