import 'package:flutter/material.dart';

/// Centralized brand logo asset path.
abstract final class AppBrandAssets {
  static const logo = 'assets/logo.png';
}

/// The app brand logo as a plain image, sized for headers and inline use.
class AppBrandLogo extends StatelessWidget {
  const AppBrandLogo({
    super.key,
    this.height = 48,
    this.width,
    this.fit = BoxFit.contain,
  });

  final double height;
  final double? width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppBrandAssets.logo,
      height: height,
      width: width,
      fit: fit,
    );
  }
}

/// Brand logo inside the frosted rounded-square container used on hero screens.
class AppBrandLogoBadge extends StatelessWidget {
  const AppBrandLogoBadge({
    super.key,
    required this.size,
    this.borderRadius = 20,
    this.logoPaddingFactor = 0.18,
  });

  final double size;
  final double borderRadius;
  final double logoPaddingFactor;

  @override
  Widget build(BuildContext context) {
    final logoPadding = size * logoPaddingFactor;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(logoPadding),
        child: Image.asset(
          AppBrandAssets.logo,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
