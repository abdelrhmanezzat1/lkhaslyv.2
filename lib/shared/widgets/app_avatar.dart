import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_typography.dart';

/// A reusable avatar widget that adapts to the application design system.
///
/// Supports image-based avatars, text-based initials, and optional
/// status indicators for online/offline states.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.icon,
    this.radius = 24.0,
    this.backgroundColor,
    this.foregroundColor,
    this.showOnlineBadge = false,
    this.isOnline = false,
  });

  /// A network image URL for the avatar.
  final String? imageUrl;

  /// Fallback initials displayed when no image URL is provided.
  final String? initials;

  /// An optional icon to display instead of initials or image.
  final IconData? icon;

  /// The radius of the circular avatar.
  final double radius;

  /// Background color when showing initials or icon.
  final Color? backgroundColor;

  /// Foreground (text/icon) color when showing initials or icon.
  final Color? foregroundColor;

  /// Whether to show an online/offline status badge.
  final bool showOnlineBadge;

  /// Whether the user is online (green badge).
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = backgroundColor ?? AppColors.primary;
    final Color fgColor =
        foregroundColor ?? (isDark ? AppColors.onPrimary : Colors.white);

    Widget avatar;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl!),
        backgroundColor: bgColor,
      );
    } else if (initials != null && initials!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        child: Text(
          initials!.length > 2 ? initials!.substring(0, 2) : initials!,
          style: AppTypography.textTheme.titleSmall?.copyWith(
            color: fgColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        child: Icon(icon ?? Icons.person, color: fgColor, size: radius),
      );
    }

    if (!showOnlineBadge) return avatar;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: radius * 0.5,
            height: radius * 0.5,
            decoration: BoxDecoration(
              color: isOnline ? AppColors.success : Colors.grey,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.surface : AppColors.lightSurface,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
