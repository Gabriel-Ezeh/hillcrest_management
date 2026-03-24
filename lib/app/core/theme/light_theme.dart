import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Import the part owner file 'values.dart' to get all constants
import 'package:hillcrest_finance/utils/constants/values.dart';

class AppTheme {
  // Use the primary brand color for the seed
  static const Color _primarySeed = AppColors.primaryColor;

  static final ThemeData lightTheme = _buildLightTheme();

  static ThemeData _buildLightTheme() {
    // Generate the color scheme based on the primary seed color
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: _primarySeed,
      brightness: Brightness.light,
      primary: AppColors.primaryColor,
      onPrimary: AppColors.white,
      secondary: AppColors.darkBlue,
      surface: AppColors.white,
      background: AppColors.white,
      error: AppColors.red,
      onBackground: AppColors.darkBlue,
      onSurface: AppColors.darkBlue,
    );

    // Define the base theme
    final ThemeData base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Inter', // Set Inter as the default/base font
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.white,
    );

    return base.copyWith(
      // --- TEXT & TYPOGRAPHY ---
      textTheme: _buildTextTheme(base.textTheme),

      // --- BUTTONS ---
      // Primary Button Style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.RADIUS_10),
          ),
          textStyle: AppTextStyles.cabinRegular14White.copyWith(
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
        ),
      ),
      // Text Button Style
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          textStyle: AppTextStyles.cabinRegular14Primary,
        ),
      ),

      // --- INPUT FIELDS (TextFields) ---
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.white,
        filled: true,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: Sizes.PADDING_14,
          horizontal: Sizes.PADDING_16,
        ),
        hintStyle: AppTextStyles.interRegular14HintGray,
        enabledBorder: AppBorders.defaultBorder,
        focusedBorder: AppBorders.focusedBorder,
        errorBorder: AppBorders.errorBorder,
        focusedErrorBorder: AppBorders.errorBorder,
        disabledBorder: AppBorders.disabledBorder,
      ),

      // --- APP BAR ---
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.darkBlue,
        centerTitle: false,
        titleTextStyle: AppTextStyles.cabinBold24DarkBlue.copyWith(fontFamily: null),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // Make status bar transparent
          statusBarIconBrightness: Brightness.dark, // Black icons for light backgrounds
          statusBarBrightness: Brightness.light, // iOS configuration for light background
        ),
      ),

      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.mutedGray,
        selectedLabelStyle: AppTextStyles.cabinRegular11Primary.copyWith(fontFamily: null),
        unselectedLabelStyle: AppTextStyles.cabinRegular11mutedGray.copyWith(fontFamily: null),
        elevation: 1,
      ),

      // --- DIALOGS ---
      dialogTheme: DialogThemeData( // <-- CORRECTED CLASS NAME
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
        ),
        backgroundColor: AppColors.white,
      ),
    );
  }

  // Helper method to build custom TextTheme based on the base theme
  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      // NOTE: .copyWith(fontFamily: null) is used here to ensure the original font (Cabin/Inter)
      // defined in AppTextStyles is used, instead of defaulting to the base theme's 'Inter'.

      displayLarge: AppTextStyles.cabinBold24DarkBlue.copyWith(fontFamily: null),
      headlineLarge: AppTextStyles.cabinBold24DarkBlue.copyWith(fontFamily: null),

      titleMedium: AppTextStyles.interSemiBold14DarkBlue.copyWith(fontFamily: null),

      bodyLarge: AppTextStyles.cabinRegular14DarkBlue.copyWith(fontFamily: null),
      bodyMedium: AppTextStyles.cabinRegular14MutedGray.copyWith(fontFamily: null),

      labelSmall: AppTextStyles.cabinRegular11mutedGray.copyWith(fontFamily: null),
    );
  }
}