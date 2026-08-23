import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/core/theme/app_dimensions.dart';
import 'package:flutter_application_1/features/notifications/controllers/notifications_controller.dart';
import 'package:flutter_application_1/features/notifications/domain/entities/app_notification.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// In-app notification center. Lists persisted notifications for the
/// signed-in user, supports mark-as-read (single / all) and deep-links
/// through `data['deep_link']`.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<AppNotification>> inbox =
        ref.watch(notificationsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: l10n.markAllAsRead,
            onPressed: () => ref
                .read(notificationsControllerProvider.notifier)
                .markAllAsRead(),
          ),
        ],
      ),
      body: inbox.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceL),
            child: Text(
              l10n.notificationsEmpty,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (List<AppNotification> items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 56,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: AppDimensions.spaceM),
                  Text(l10n.notificationsEmpty,
                      style: theme.textTheme.titleMedium),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(notificationsControllerProvider.notifier)
                  .refresh();
              await ref
                  .read(unreadNotificationsCountProvider.notifier)
                  .refresh();
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.spaceM),
              itemCount: items.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: AppDimensions.spaceS),
              itemBuilder: (BuildContext context, int index) =>
                  _NotificationTile(notification: items[index]),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool unread = !notification.read;
    final Color accent =
        unread ? theme.colorScheme.primary : theme.colorScheme.onSurface;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: unread
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.25)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: accent.withValues(alpha: 0.12),
          child: Icon(_iconForType(notification.type), size: 22, color: accent),
        ),
        title: Text(
          notification.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        subtitle: Text(
          notification.body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall,
        ),
        trailing: Text(
          _timeAgo(notification.createdAt),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        onTap: () => _handleTap(context, ref),
      ),
    );
  }

  Future<void> _handleTap(BuildContext context, WidgetRef ref) async {
    final NotificationsController notifier =
        ref.read(notificationsControllerProvider.notifier);
    await notifier.markAsRead(notification.id);

    if (!context.mounted) return;
    final String link = notification.deepLink ?? '';
    if (link.isNotEmpty) {
      context.push(link);
      return;
    }
    context.push(AppRoutes.home);
  }

  static IconData _iconForType(String type) {
    switch (type) {
      case 'technician_accepted':
      case 'technician_driving':
        return Icons.local_shipping_rounded;
      case 'technician_arrived':
        return Icons.where_to_vote_rounded;
      case 'technician_working':
        return Icons.build_rounded;
      case 'technician_finished':
      case 'order_completed':
        return Icons.task_alt_rounded;
      case 'payment_confirmed':
      case 'payment_received':
        return Icons.payments_rounded;
      case 'rating_reminder':
        return Icons.star_rate_rounded;
      case 'new_nearby_order':
        return Icons.add_alert_rounded;
      case 'customer_cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.notifications_rounded;
    }
  }

  static String _timeAgo(DateTime time) {
    final Duration diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return '<1m';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
