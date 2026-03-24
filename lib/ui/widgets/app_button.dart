import 'package:flutter/material.dart';
import '../../utils/constants/values.dart';


/// A custom button widget that consistently applies the application's primary
/// button style defined in AppTheme.
class AppButton extends StatelessWidget {
  /// The text displayed on the button.
  final String text;

  /// The action to perform when the button is pressed.
  /// If null, the button will be disabled.
  final VoidCallback? onPressed;

  /// Whether the button is currently in a loading state.
  final bool isLoading;

  /// The minimum width of the button. Defaults to double.infinity (full width).
  final double minWidth;

  /// The minimum height of the button. Defaults to 56.0 (standard large button height).
  final double minHeight;

  /// Optional prefix icon to display before the text.
  final IconData? icon;

  /// Optional margin/padding around the button.
  final EdgeInsetsGeometry margin;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.minWidth = double.infinity,
    this.minHeight = 56.0,
    this.icon,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the effective onPressed callback:
    // 1. If loading, the button is disabled (null).
    // 2. Otherwise, use the provided onPressed callback.
    final VoidCallback? effectiveOnPressed = isLoading ? null : onPressed;

    return Padding(
      padding: margin,
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          // Ensure the theme's minimum size is respected, but allow override
          minimumSize: Size(minWidth, minHeight),
          // Use fixed padding to maintain consistency with theme design
          padding: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_16),
        ),
        child: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: AppColors.white, // Ensure loader is visible on primary color
            strokeWidth: 3.0,
          ),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon display (optional)
            if (icon != null) ...[
              Icon(icon, size: Sizes.ICON_SIZE_20),
              const SpaceW8(),
            ],

            // Button Text
            Text(
              text,
              // The TextStyle is managed by the elevatedButtonTheme in AppTheme,
              // which uses AppTextStyles.cabinRegular14White.
            ),
          ],
        ),
      ),
    );
  }
}