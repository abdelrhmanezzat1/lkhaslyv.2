import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_dimensions.dart';
import 'package:flutter_application_1/core/theme/app_shadows.dart';

/// A premium greeting section that displays a time-aware greeting,
/// the user's name, a circular profile avatar, and a notification
/// bell with an unread badge.
class HomeGreetingBar extends StatelessWidget {
  const HomeGreetingBar({
    super.key,
    required this.userName,
    this.avatarUrl,
    this.hasUnreadNotifications = false,
    this.onAvatarTap,
    this.onNotificationTap,
  });

  /// The display name of the current user.
  final String userName;

  /// An optional URL pointing to the user's profile image.
  final String? avatarUrl;

  /// Whether to show the unread badge on the notification button.
  final bool hasUnreadNotifications;

  /// Callback invoked when the avatar is tapped.
  final VoidCallback? onAvatarTap;

  /// Callback invoked when the notification bell is tapped.
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final String greeting = _greetingForNow();
    final Color textColor = isDark
        ? AppColors.onSurface
        : AppColors.onLightSurface;
    final Color secondaryTextColor = isDark
        ? AppColors.secondaryText
        : Colors.grey.shade600;
    final Color badgeColor = AppColors.error;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceL,
        vertical: AppDimensions.spaceM,
      ),
      child: Row(
        children: [
          // ── Avatar ──
          GestureDetector(
            onTap: onAvatarTap,
            child: _AvatarWidget(avatarUrl: avatarUrl, userName: userName),
          ),
          const SizedBox(width: AppDimensions.spaceM),

          // ── Greeting + Name ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  greeting,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spaceXXS),
                Text(
                  userName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // ── Notification Bell ──
          _NotificationBadge(
            hasUnread: hasUnreadNotifications,
            badgeColor: badgeColor,
            onTap: onNotificationTap,
          ),
        ],
      ),
    );
  }

  /// Returns a time-aware greeting string.
  String _greetingForNow() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 18) return 'Good Afternoon,';
    return 'Good Evening,';
  }
}

// ────────────────────────────────────────────────────
//  Internal avatar widget
// ────────────────────────────────────────────────────

class _AvatarWidget extends StatelessWidget {
  const _AvatarWidget({this.avatarUrl, required this.userName});

  final String? avatarUrl;
  final String userName;

  String get _initials {
    final List<String> parts = userName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return userName.isNotEmpty ? userName[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    const double size = 48;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? AppColors.surface : Colors.grey.shade300;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        boxShadow: AppShadows.subtle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: avatarUrl != null && avatarUrl!.isNotEmpty
          ? ClipOval(
              child: Image.network(
                avatarUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _initialsWidget(size),
              ),
            )
          : _initialsWidget(size),
    );
  }

  Widget _initialsWidget(double size) {
    return Center(
      child: Text(
        _initials,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────
//  Internal notification badge widget
// ────────────────────────────────────────────────────

class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge({
    required this.hasUnread,
    required this.badgeColor,
    this.onTap,
  });

  final bool hasUnread;
  final Color badgeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? AppColors.surface : Colors.grey.shade300;
    final Color iconColor = isDark
        ? AppColors.onSurface
        : AppColors.onLightSurface;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
            child: Icon(
              Icons.notifications_outlined,
              color: iconColor,
              size: 24,
            ),
          ),
        ),
        if (hasUnread)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badgeColor,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
