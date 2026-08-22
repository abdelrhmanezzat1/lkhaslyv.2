import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_radius.dart';

/// A reusable skeleton loading widget that adapts to the application design system.
///
/// Renders shimmer placeholder blocks for text, circles, and cards
/// to indicate content is loading.
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    super.key,
    this.width,
    this.height = 16.0,
    this.borderRadius,
    this.isCircle = false,
  });

  /// The width of the skeleton. If null, expands to fill available space.
  final double? width;

  /// The height of the skeleton.
  final double height;

  /// The border radius of the skeleton block.
  final BorderRadiusGeometry? borderRadius;

  /// Whether to render as a circle.
  final bool isCircle;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color baseColor = isDark ? AppColors.surface : AppColors.lightSurface;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final Color animatedColor = baseColor.withValues(
          alpha: _animation.value,
        );
        return Container(
          width: widget.isCircle ? widget.height : widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: animatedColor,
            borderRadius: widget.isCircle
                ? BorderRadius.circular(widget.height / 2)
                : (widget.borderRadius ?? AppRadius.borderRadiusMd),
          ),
        );
      },
    );
  }
}

/// Static convenience methods for common skeleton layouts.
class AppSkeletonLayout {
  AppSkeletonLayout._();

  /// A list tile skeleton with a leading circle avatar, title and subtitle lines.
  static Widget listTile({
    double avatarRadius = 20.0,
    double titleWidth = 160.0,
    double subtitleWidth = 240.0,
  }) {
    return Row(
      children: [
        AppSkeleton(height: avatarRadius * 2, isCircle: true),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSkeleton(width: titleWidth, height: 14),
            const SizedBox(height: 8),
            AppSkeleton(width: subtitleWidth, height: 12),
          ],
        ),
      ],
    );
  }

  /// A card skeleton with multiple lines of text.
  static Widget card({int lineCount = 3}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSkeleton(width: double.infinity, height: 150),
        const SizedBox(height: 12),
        const AppSkeleton(width: double.infinity, height: 16),
        const SizedBox(height: 8),
        for (int i = 1; i < lineCount; i++) ...[
          const AppSkeleton(width: double.infinity, height: 12),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  /// A paragraph skeleton with multiple lines of varying widths.
  static Widget paragraph({int lineCount = 4}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < lineCount; i++) ...[
          AppSkeleton(
            width: i == lineCount - 1 ? 180.0 : double.infinity,
            height: 12,
          ),
          if (i < lineCount - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}
