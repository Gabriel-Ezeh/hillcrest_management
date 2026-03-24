import 'package:flutter/material.dart';
import 'package:hillcrest_finance/utils/constants/values.dart';
import 'package:shimmer/shimmer.dart';


/// A reusable widget that wraps any layout (a "Skeleton") and applies
/// the global Shimmer loading animation effect.
class ShimmerWrapper extends StatelessWidget {
  /// The layout of placeholder blocks (e.g., DashboardSkeleton,
  /// PersonalInfoSkeleton) that will be animated.
  final Widget child;

  /// The duration of one shimmer cycle. Defaults to 1.5 seconds.
  final Duration period;

  /// Whether the shimmer effect should be actively animating.
  final bool enabled;

  const ShimmerWrapper({
    super.key,
    required this.child,
    this.period = const Duration(milliseconds: 1500),
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // We use Shimmer.fromColors for precise color control over the animation.
    return Shimmer.fromColors(
      enabled: enabled,
      period: period,

      // The base color is the stationary placeholder color.
      // We use a light, semi-transparent gray from your constants.
      baseColor: AppColors.brandSoftGray.withOpacity(0.5),

      // The highlight color is the color of the animated "wave" of light,
      // usually a brighter white or a very light gray.
      highlightColor: AppColors.white,

      // The actual skeleton layout goes inside the child property.
      child: child,
    );
  }
}