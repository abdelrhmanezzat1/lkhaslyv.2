import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {

  const GlassAppBar({
    super.key,
    this.title,
    this.centerTitle = true,
    this.actions,
  });
  final Widget? title;
  final bool centerTitle;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.background : AppColors.lightBackground;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AppBar(
          backgroundColor: backgroundColor.withValues(alpha: 0.6),
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          title: title,
          centerTitle: centerTitle,
          actions: actions,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
