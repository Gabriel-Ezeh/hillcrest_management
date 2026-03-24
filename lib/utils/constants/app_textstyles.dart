part of 'values.dart';

/// Defines consistent and reusable TextStyle constants for the application.
class AppTextStyles {
  // Define font family strings (ensure these are loaded in pubspec.yaml)
  static const String _cabinFont = 'Cabin';
  static const String _interFont = 'Inter';

  // --- CABIN FONT STYLES ---

  /// Cabin Bold 24px, Dark Blue (For large headings)
  static const TextStyle cabinBold24DarkBlue = TextStyle(
    fontFamily: _cabinFont,
    fontSize: Sizes.TEXT_SIZE_24,
    fontWeight: FontWeight.w700,
    color: AppColors.darkBlue,
  );

  static const TextStyle cabinBold20DarkBlue = TextStyle(
    fontFamily: _cabinFont,
    fontSize: Sizes.TEXT_SIZE_20,
    fontWeight: FontWeight.w700,
    color: AppColors.darkBlue,
  );

  /// Cabin Regular 14px, Muted Gray (For body text and captions)
  static const TextStyle cabinRegular14MutedGray = TextStyle(
    fontFamily: _cabinFont,
    fontSize: Sizes.TEXT_SIZE_14,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedGray,
  );

  /// Cabin Regular 14px, Primary Color (For body text and captions)
  static const TextStyle cabinRegular14Primary = TextStyle(
    fontFamily: _cabinFont,
    fontSize: Sizes.TEXT_SIZE_14,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryColor,
  );

  /// Cabin Regular 14px, White (For button text on primary backgrounds)
  static const TextStyle cabinRegular14White = TextStyle(
    fontFamily: _cabinFont,
    fontSize: Sizes.TEXT_SIZE_14,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
  );

  /// Cabin Regular 14px, Dark blue Color (For TextButtons/links)
  static const TextStyle cabinRegular14DarkBlue = TextStyle(
    fontFamily: _cabinFont,
    fontSize: Sizes.TEXT_SIZE_14,
    fontWeight: FontWeight.w400,
    color: AppColors.darkBlue,
  );

  static const TextStyle cabinRegular11Primary = TextStyle(
    fontFamily: _cabinFont,
    fontSize: Sizes.TEXT_SIZE_11,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryColor,
  );

  /// Use for low-emphasis description text (error/helper)
  static const TextStyle cabinRegular11mutedGray = TextStyle(
    fontFamily: _cabinFont,
    fontSize: Sizes.TEXT_SIZE_11,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedGray,
  );

  /// Use for low-emphasis description text (error/helper)
  static const TextStyle cabinRegular12DarkBlue = TextStyle(
    fontFamily: _cabinFont,
    fontSize: Sizes.TEXT_SIZE_12,
    fontWeight: FontWeight.w400,
    color: AppColors.darkBlue,
  );


  static const TextStyle cabinBold14Primary = TextStyle(
    fontFamily: _cabinFont,
    fontSize: Sizes.TEXT_SIZE_14,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryColor,
  );

  static const TextStyle cabinBold18DarkBlue = TextStyle(
    fontFamily: _cabinFont,
    fontSize: Sizes.TEXT_SIZE_18,
    fontWeight: FontWeight.w700,
    color: AppColors.darkBlue,
  );

  static const TextStyle cabinBold12White = TextStyle(
    fontFamily: _cabinFont,
    fontSize: Sizes.TEXT_SIZE_12,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  static const TextStyle cabinBold16White = TextStyle(
    fontFamily: _cabinFont,
    fontSize: Sizes.TEXT_SIZE_16,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  static const TextStyle cabinBold14DarkBlue = TextStyle(
    fontFamily: _cabinFont,
    fontSize: Sizes.TEXT_SIZE_14,
    fontWeight: FontWeight.w700,
    color: AppColors.darkBlue,
  );

  static const TextStyle cabinBold16DarkBlue = TextStyle(
    fontFamily: _cabinFont,
    fontSize: Sizes.TEXT_SIZE_16,
    fontWeight: FontWeight.w700,
    color: AppColors.darkBlue,
  );


    // --- INTER FONT STYLES ---

    /// Inter Regular 14px, Dark Blue (For general text input or dense body copy)
    static const TextStyle interRegular14DarkBlue = TextStyle(
    fontFamily: _interFont,
    fontSize: Sizes.TEXT_SIZE_14,
    fontWeight: FontWeight.w400,
    color: AppColors.darkBlue,
  );

  /// Inter Regular 14px, Primary Color (For secondary text buttons or links)
  static const TextStyle interRegular14Primary = TextStyle(
    fontFamily: _interFont,
    fontSize: Sizes.TEXT_SIZE_14,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryColor,
  );

  // --- NEW FIELD STYLES ---

  /// Inter Regular 14px, Muted Gray (REQUIRED: For hint text inside fields)
  static const TextStyle interRegular14HintGray = TextStyle(
    fontFamily: _interFont,
    fontSize: Sizes.TEXT_SIZE_14,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedGray,
  );

  static const TextStyle interRegular10HintGray = TextStyle(
    fontFamily: _interFont,
    fontSize: Sizes.TEXT_SIZE_10,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedGray,
  );

  static const TextStyle interRegular10Primary = TextStyle(
    fontFamily: _interFont,
    fontSize: Sizes.TEXT_SIZE_10,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryColor,
  );


  /// Inter Semi-Bold 14px, Dark Blue (REQUIRED: For field labels/titles)
  static const TextStyle interSemiBold14DarkBlue = TextStyle(
    fontFamily: _interFont,
    fontSize: Sizes.TEXT_SIZE_14,
    fontWeight: FontWeight.w600,
    color: AppColors.darkBlue,
  );

  static const TextStyle interMedium16DarkBlue = TextStyle(
    fontFamily: _interFont,
    fontSize: Sizes.TEXT_SIZE_16,
    fontWeight: FontWeight.w600,
    color: AppColors.darkBlue,
  );

}