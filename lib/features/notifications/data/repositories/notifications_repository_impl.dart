import 'package:flutter_application_1/core/logger/app_logger.dart';
import 'package:flutter_application_1/features/notifications/domain/entities/app_notification.dart';
import 'package:flutter_application_1/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed implementation of [NotificationsRepository].
///
/// Every read is defensive: when the `notifications` table doesn't exist
/// yet (migration not applied) or RLS denies access, we log and return
/// empty results instead of crashing the inbox UI.
class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._supabase);

  final SupabaseClient _supabase;

  static const String _table = 'notifications';

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  @override
  Future<List<AppNotification>> getNotifications({int limit = 50}) async {
    final userId = _currentUserId;
    if (userId == null) return const <AppNotification>[];
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);
      return response
          .cast<Map<String, dynamic>>()
          .map(AppNotification.fromJson)
          .toList(growable: false);
    } on PostgrestException catch (e) {
      appLogger.w(
        'NotificationsRepository.getNotifications unavailable: '
        'code=${e.code} message=${e.message}',
      );
      return const <AppNotification>[];
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      await _supabase
          .from(_table)
          .update({'read': true})
          .eq('id', notificationId)
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      appLogger.w('NotificationsRepository.markAsRead failed: ${e.message}');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      await _supabase
          .from(_table)
          .update({'read': true})
          .eq('user_id', userId)
          .eq('read', false);
    } on PostgrestException catch (e) {
      appLogger.w('NotificationsRepository.markAllAsRead failed: ${e.message}');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    final userId = _currentUserId;
    if (userId == null) return 0;
    try {
      final response = await _supabase
          .from(_table)
          .select('id')
          .eq('user_id', userId)
          .eq('read', false);
      return response.length;
    } on PostgrestException catch (e) {
      appLogger.w(
        'NotificationsRepository.getUnreadCount unavailable: ${e.message}',
      );
      return 0;
    }
  }
}
