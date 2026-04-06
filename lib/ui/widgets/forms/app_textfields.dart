import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hillcrest_finance/utils/constants/validators/field_validators.dart';
import 'package:hillcrest_finance/utils/constants/values.dart';

// Enum to define the style of text field content
enum AppTextFieldType {
  // Standard Text Fields
  text,
  email,
  password,
  confirmPassword,
  phone,
  address,
  bvn,
  nin,
  // Special Fields
  dropdown,
  date,
}

class AppTextField extends StatefulWidget {
  // Required Properties
  final String label;
  final AppTextFieldType type;
  final String? Function(String?)? validator;
  final TextEditingController? controller;

  // NEW PROPERTY for Confirm Password
  final TextEditingController? originalPasswordController;

  // Optional Visual Properties
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? prefix; // For text/country code prefix
  final Widget? suffix; // For custom suffix widgets (like a button or spinner)

  // Optional Behavior Properties
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;

  // Password-Specific Properties
  final bool showPasswordStrength;

  // Dropdown-Specific Properties
  final List<String>? dropdownItems;
  final ValueChanged<String?>? onDropdownChanged;
  final String? initialDropdownValue;

  const AppTextField({
    super.key,
    required this.label,
    required this.type,
    this.validator,
    this.controller,
    this.originalPasswordController,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.inputFormatters,
    this.maxLines = 1,
    this.textInputAction,
    this.keyboardType,
    this.showPasswordStrength = false,
    this.dropdownItems,
    this.onDropdownChanged,
    this.initialDropdownValue,
  }) : assert(
         type != AppTextFieldType.dropdown ||
             (dropdownItems != null && onDropdownChanged != null),
         'Dropdown type requires dropdownItems and onDropdownChanged.',
       ),
       // Assertion for confirm password to ensure originalPasswordController is provided
       assert(
         type != AppTextFieldType.confirmPassword ||
             originalPasswordController != null,
         'ConfirmPassword type requires originalPasswordController.',
       );

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  // State for Password Field
  bool _isPasswordVisible = false;
  double _passwordStrength = 0.0;
  String _passwordHint = '';
  Color _passwordIndicatorColor = Colors.transparent;

  // Individual Validation States
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  // State for Dropdown Field
  String? _selectedDropdownValue;

  @override
  void initState() {
    super.initState();
    _selectedDropdownValue = widget.initialDropdownValue;

    // Listener to re-validate Confirm Password field when the Original Password changes
    if (widget.type == AppTextFieldType.confirmPassword &&
        widget.originalPasswordController != null) {
      widget.originalPasswordController!.addListener(
        _revalidateConfirmPassword,
      );
    }

    if (widget.type == AppTextFieldType.password &&
        widget.controller != null &&
        widget.controller!.text.isNotEmpty) {
      _checkPasswordStrength(widget.controller!.text);
    }
  }

  @override
  void dispose() {
    // Remove listener on dispose
    if (widget.type == AppTextFieldType.confirmPassword &&
        widget.originalPasswordController != null) {
      widget.originalPasswordController!.removeListener(
        _revalidateConfirmPassword,
      );
    }
    super.dispose();
  }

  // --- Utility Methods (Unchanged) ---

  void _revalidateConfirmPassword() {
    if (mounted) {
      setState(() {});
    }
  }

  String? Function(String?)? _getValidator() {
    if (widget.validator != null) return widget.validator;

    switch (widget.type) {
      case AppTextFieldType.email:
        return FieldValidators.validateEmail;
      case AppTextFieldType.password:
        return FieldValidators.validatePassword;
      case AppTextFieldType.confirmPassword:
        return (value) => FieldValidators.validateConfirmPassword(
          value,
          widget.originalPasswordController!.text,
        );
      case AppTextFieldType.phone:
        return FieldValidators.validatePhone;
      case AppTextFieldType.bvn:
        return FieldValidators.validateBVN;
      case AppTextFieldType.nin:
        return FieldValidators.validateNIN;
      case AppTextFieldType.address:
        return FieldValidators.validateAddress;
      case AppTextFieldType.text:
      case AppTextFieldType.dropdown:
      case AppTextFieldType.date:
      default:
        return (value) => (value == null || value.isEmpty)
            ? '${widget.label} is required'
            : null;
    }
  }

  TextInputType? _getKeyboardType() {
    if (widget.keyboardType != null) return widget.keyboardType;

    switch (widget.type) {
      case AppTextFieldType.email:
        return TextInputType.emailAddress;
      case AppTextFieldType.phone:
      case AppTextFieldType.bvn:
      case AppTextFieldType.nin:
        return TextInputType.phone;
      case AppTextFieldType.password:
      case AppTextFieldType.confirmPassword:
        return TextInputType.visiblePassword;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    if (widget.inputFormatters != null) return widget.inputFormatters;

    switch (widget.type) {
      case AppTextFieldType.bvn:
      case AppTextFieldType.nin:
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
        ];
      default:
        return null;
    }
  }

  void _checkPasswordStrength(String password) {
    if (!widget.showPasswordStrength ||
        widget.type != AppTextFieldType.password)
      return;

    _hasMinLength = password.length >= 8;
    _hasUppercase = password.contains(RegExp(r'[A-Z]'));
    _hasNumber = password.contains(RegExp(r'[0-9]'));
    _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    double strength = 0.0;
    if (_hasMinLength) strength += 0.25;
    if (_hasUppercase) strength += 0.25;
    if (_hasNumber) strength += 0.25;
    if (_hasSpecialChar) strength += 0.25;

    setState(() {
      _passwordStrength = strength.clamp(0.0, 1.0);
      if (_passwordStrength == 1.0) {
        _passwordHint = 'Strong';
        _passwordIndicatorColor = AppColors.passwordStrong;
      } else if (_passwordStrength >= 0.75) {
        _passwordHint = 'Medium';
        _passwordIndicatorColor = AppColors.primaryColor;
      } else if (_passwordStrength >= 0.25) {
        _passwordHint = 'Weak';
        _passwordIndicatorColor = AppColors.red;
      } else {
        _passwordHint = '';
        _passwordIndicatorColor = Colors.transparent;
      }
    });
  }

  // --- Build Methods ---

  Widget _buildValidationRow(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: isValid ? AppColors.passwordStrong : AppColors.mutedGray,
          size: 14,
        ),
        const SpaceW8(),
        Text(
          text,
          style: AppTextStyles.cabinRegular11mutedGray.copyWith(
            color: isValid ? AppColors.passwordStrong : AppColors.mutedGray,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    if (widget.type != AppTextFieldType.password ||
        !widget.showPasswordStrength) {
      return const SizedBox.shrink();
    }

    final isVisible =
        widget.controller != null && widget.controller!.text.isNotEmpty;

    if (!isVisible) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: Sizes.PADDING_12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Password Strength',
                style: AppTextStyles.cabinRegular11mutedGray,
              ),
              if (_passwordHint.isNotEmpty)
                Text(
                  _passwordHint,
                  style: AppTextStyles.cabinRegular11mutedGray.copyWith(
                    color: _passwordIndicatorColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SpaceH8(),
          ClipRRect(
            borderRadius: BorderRadius.circular(Sizes.RADIUS_4),
            child: LinearProgressIndicator(
              value: _passwordStrength,
              backgroundColor: AppColors.lightGray.withOpacity(0.5),
              valueColor:
                  AlwaysStoppedAnimation<Color>(_passwordIndicatorColor),
              minHeight: 6,
            ),
          ),
          const SpaceH12(),
          Wrap(
            spacing: Sizes.PADDING_16,
            runSpacing: Sizes.PADDING_8,
            children: [
              _buildValidationRow('At least 8 characters', _hasMinLength),
              _buildValidationRow('Uppercase letter', _hasUppercase),
              _buildValidationRow('One number', _hasNumber),
              _buildValidationRow('Special character', _hasSpecialChar),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedDropdownValue,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: Sizes.PADDING_14,
          horizontal: Sizes.PADDING_16,
        ),
        hintText: widget.hintText,
        hintStyle: AppTextStyles.interRegular14HintGray,
        errorStyle: AppTextStyles.cabinRegular11mutedGray.copyWith(
          color: AppColors.red,
        ),
        enabledBorder: AppBorders.defaultBorder,
        focusedBorder: AppBorders.focusedBorder,
        errorBorder: AppBorders.errorBorder,
        focusedErrorBorder: AppBorders.errorBorder,
        disabledBorder: AppBorders.disabledBorder,
      ),
      style: AppTextStyles.interRegular14DarkBlue,
      items: widget.dropdownItems!
          .map(
            (String item) =>
                DropdownMenuItem<String>(value: item, child: Text(item)),
          )
          .toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedDropdownValue = newValue;
        });
        widget.onDropdownChanged!(newValue);
      },
      validator: _getValidator(),
      icon:
          widget.suffixIcon ??
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.mutedGray,
          ),
    );
  }

  // 💡 NEW: Builds the custom widget for the Phone number prefix (+234 | v)
  Widget _buildPhonePrefix() {
    return Padding(
      // Padding is crucial here to adjust the positioning within the prefixIcon slot
      padding: const EdgeInsets.only(left: Sizes.PADDING_16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            StringConst.countryCodeHint, // "+234"
            style: AppTextStyles.interRegular14DarkBlue,
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.mutedGray,
            size: Sizes.ICON_SIZE_20,
          ),
          const SpaceW8(), // Horizontal spacing
          // Use a fixed-width line for separation
          Container(
            width: 1,
            height: Sizes.ICON_SIZE_20,
            color: AppColors.lightGray,
          ),
          const SpaceW8(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldObscure =
        (widget.type == AppTextFieldType.password ||
            widget.type == AppTextFieldType.confirmPassword) &&
        !_isPasswordVisible;

    final labelWidget = Text(
      widget.label,
      style: AppTextStyles.cabinRegular14DarkBlue,
    );

    // If it's a dropdown, return the custom dropdown widget structure
    if (widget.type == AppTextFieldType.dropdown) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [labelWidget, const SpaceH8(), _buildDropdownField()],
      );
    }

    // --- Standard Text Field Structure ---
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labelWidget,
        const SpaceH8(),
        TextFormField(
          controller: widget.controller,
          onChanged: (value) {
            if (widget.type == AppTextFieldType.password) {
              _checkPasswordStrength(value);
              if (widget.originalPasswordController != null) {
                _revalidateConfirmPassword();
              }
            }
            if (widget.type == AppTextFieldType.confirmPassword &&
                widget.controller != null) {
              (context as Element).markNeedsBuild();
            }

            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
          },
          validator: _getValidator(),
          readOnly: widget.readOnly || widget.type == AppTextFieldType.date,
          onTap: widget.onTap,
          obscureText: shouldObscure,
          keyboardType: _getKeyboardType(),
          textInputAction: widget.textInputAction,
          inputFormatters: _getInputFormatters(),
          maxLines: widget.maxLines,
          style: AppTextStyles.interRegular14DarkBlue,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: Sizes.PADDING_14,
              horizontal: Sizes.PADDING_16,
            ),

            hintText: widget.hintText,
            hintStyle: AppTextStyles.interRegular14HintGray,
            errorStyle: AppTextStyles.cabinRegular11mutedGray.copyWith(
              color: AppColors.red,
            ),

            // 💡 FIX: Use prefixIcon for phone number to ensure it's always visible
            prefixIcon: widget.type == AppTextFieldType.phone
                ? _buildPhonePrefix()
                : widget.prefixIcon,

            // If using the dedicated phone prefix, ensure widget.prefix is null to avoid conflicts.
            prefix: (widget.type != AppTextFieldType.phone)
                ? widget.prefix
                : null,

            suffix: widget.suffix,

            // Suffix Icon (handled special for password visibility)
            suffixIcon:
                (widget.type == AppTextFieldType.password ||
                    widget.type == AppTextFieldType.confirmPassword)
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.mutedGray,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )
                : widget.suffixIcon,

            // Borders
            enabledBorder: AppBorders.defaultBorder,
            focusedBorder: AppBorders.focusedBorder,
            errorBorder: AppBorders.errorBorder,
            focusedErrorBorder: AppBorders.errorBorder,
            disabledBorder: AppBorders.disabledBorder,
          ),
        ),
        _buildPasswordStrengthIndicator(),
      ],
    );
  }
}
