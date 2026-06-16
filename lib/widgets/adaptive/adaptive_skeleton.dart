import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AdaptiveSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsets? margin;

  const AdaptiveSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 16.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: isDark ? Colors.grey[600]! : Colors.grey[100]!,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[200],
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        ),
      ),
    );
  }
}

class AdaptiveCardSkeleton extends StatelessWidget {
  final double height;
  final double borderRadius;
  final EdgeInsets? margin;

  const AdaptiveCardSkeleton({
    super.key,
    this.height = 200,
    this.borderRadius = 16.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveSkeleton(
      height: height,
      borderRadius: borderRadius,
      margin: margin ?? const EdgeInsets.all(16),
    );
  }
}

class AdaptiveStatsRowSkeleton extends StatelessWidget {
  const AdaptiveStatsRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(
          3,
          (index) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index > 0 ? 8 : 0,
                right: index < 2 ? 8 : 0,
              ),
              child: AdaptiveSkeleton(
                height: 100,
                borderRadius: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
