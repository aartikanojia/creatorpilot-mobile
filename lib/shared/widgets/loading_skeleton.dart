import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';

/// Shimmer-based loading skeleton for placeholder UI during data fetches.
///
/// Usage:
/// ```dart
/// LoadingSkeleton(width: 120, height: 20)       // text placeholder
/// LoadingSkeleton(width: double.infinity, height: 180)  // card placeholder
/// LoadingSkeleton.circular(size: 48)             // avatar placeholder
/// ```
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  /// Circular skeleton (e.g., for avatars).
  const LoadingSkeleton.circular({
    super.key,
    double size = 48,
  })  : width = size,
        height = size,
        borderRadius = 999;

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.cardBg,
      highlightColor: AppColors.cardBgElevated,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
