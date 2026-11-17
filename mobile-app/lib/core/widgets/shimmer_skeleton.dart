import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class ShimmerSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const ShimmerSkeleton({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = AppSpacing.roundedSm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: borderRadius,
      ),
    );
  }
}

class ShimmerSkeletonCard extends StatelessWidget {
  const ShimmerSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.p16,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.roundedMd,
        border: Border.fromBorderSide(BorderSide(color: AppColors.border, width: 1.0)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerSkeleton(width: 120, height: 16),
          AppSpacing.vGap12,
          ShimmerSkeleton(width: 220, height: 14),
          AppSpacing.vGap8,
          ShimmerSkeleton(width: 160, height: 12),
        ],
      ),
    );
  }
}
