import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/core/theme/app_radius.dart';

/// A shimmer placeholder block with a gradient sweep effect.
class AppShimmer extends StatefulWidget {
  const AppShimmer({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
    this.isCircle = false,
  });

  final double? width;
  final double height;
  final BorderRadiusGeometry? borderRadius;
  final bool isCircle;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color base = isDark ? AppColors.surfaceVariant : AppColors.lightSurfaceVariant;
    final Color highlight = isDark ? AppColors.surface : AppColors.lightSurface;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final dx = _controller.value * bounds.width * 2 - bounds.width;
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [base, highlight, base],
              stops: const [0, 0.5, 1],
            ).createShader(Rect.fromLTWH(dx, 0, bounds.width, bounds.height));
          },
          child: Container(
            width: widget.isCircle ? widget.height : widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: base,
              borderRadius: widget.isCircle
                  ? BorderRadius.circular(widget.height / 2)
                  : (widget.borderRadius ?? AppRadius.borderRadiusMd),
            ),
          ),
        );
      },
    );
  }
}
