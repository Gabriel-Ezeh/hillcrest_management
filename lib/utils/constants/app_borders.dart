part of 'values.dart';

/// Defines consistent and reusable InputDecoration borders for TextFields.
class AppBorders {
  // Common properties
  static const double _borderWidth = 1.0;

  // Common Border Radii
  static const BorderRadius _borderRadius8 = BorderRadius.all(Radius.circular(Sizes.RADIUS_8));
  static const BorderRadius _borderRadius10 = BorderRadius.all(Radius.circular(Sizes.RADIUS_10));

  // 1. Default/Enabled Border (Light Gray, 8px)
  /// Defines the standard border for an enabled, unfocused TextField.
  static const OutlineInputBorder defaultBorder = OutlineInputBorder(
    borderRadius: _borderRadius8,
    borderSide: BorderSide(
      color: AppColors.lightGray,
      width: _borderWidth,
    ),
  );

  // 2. Focused Border (Muted Gray, 8px)
  /// Defines the border when the TextField is actively focused.
  static const OutlineInputBorder focusedBorder = OutlineInputBorder(
    borderRadius: _borderRadius8,
    borderSide: BorderSide(
      color: AppColors.mutedGray,
      width: _borderWidth,
    ),
  );

  // 3. Error Border (Standard Red, 8px)
  /// Defines the border when the TextField is in an error state.
  static const OutlineInputBorder errorBorder = OutlineInputBorder(
    borderRadius: _borderRadius8,
    // Using standard Flutter red, as no specific error red was defined in AppColors.
    borderSide: BorderSide(
      color: Colors.red,
      width: _borderWidth,
    ),
  );

  // 4. Disabled Border (Often useful, defaulting to the light gray style, 8px)
  /// Defines the border when the TextField is disabled.
  static const OutlineInputBorder disabledBorder = OutlineInputBorder(
    borderRadius: _borderRadius8,
    borderSide: BorderSide(
      color: AppColors.lightGray,
      width: _borderWidth,
    ),
  );

  // 5. Custom Dashed Placeholder Border (Light Gray, 10px)
  /// Defines a border style suitable for a custom dashed implementation (e.g., for file upload fields).
  /// NOTE: OutlineInputBorder natively only supports BorderStyle.solid.
  /// To achieve a true dashed line with pattern [2, 2], this constant must be
  /// used within a custom widget that wraps the TextFormField and draws the border
  /// using Border.all(style: BorderStyle.dashed) on a Container/CustomPaint.
  static const OutlineInputBorder mockDashedBorder = OutlineInputBorder(
    borderRadius: _borderRadius10,
    borderSide: BorderSide(
      color: AppColors.lightGray,
      width: _borderWidth,
    ),
  );
}