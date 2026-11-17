import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ShimmerSkeletonCard extends StatefulWidget {
  final double height;
  final double width;
  final EdgeInsetsGeometry margin;

  const ShimmerSkeletonCard({
    super.key,
    this.height = 100,
    this.width = double.infinity,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  });

  @override
  State<ShimmerSkeletonCard> createState() => _ShimmerSkeletonCardState();
}

class _ShimmerSkeletonCardState extends State<ShimmerSkeletonCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          margin: widget.margin,
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight.withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.border.withValues(alpha: 0.4)),
          ),
        );
      },
    );
  }
}
