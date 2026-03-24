class FieldValidators {
  // Regular Expressions
  static final RegExp _emailRegExp =
  RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  static final RegExp _phoneRegExp =
  RegExp(r'^\+?[0-9]{7,15}$'); // 7–15 digits, optional '+'

  static final RegExp _passwordRegExp =
  RegExp(r'^(?=.*[a-z])');

  static final RegExp _nameRegExp = RegExp(r"^[A-Za-z]+$");

  static final RegExp _usernameRegExp = RegExp(r'^[A-Za-z0-9._-]+$');

  static final RegExp _bvnRegExp = RegExp(r'^\d{11}$');

  static final RegExp _ninRegExp = RegExp(r'^\d{11}$');

  static final RegExp _addressRegExp =
  RegExp(r"^[a-zA-Z0-9\s,'-/#.]+$"); // Basic address pattern

  // Validation Methods
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!_emailRegExp.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (!_phoneRegExp.hasMatch(value)) return 'Enter a valid phone number';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (!_passwordRegExp.hasMatch(value)) {
      return 'Password must contain:\n• Lowercase';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) return 'Confirm password is required';
    if (value != originalPassword) return 'Passwords do not match';
    return null;
  }

  static String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) return 'First name is required';
    if (!_nameRegExp.hasMatch(value)) return 'Only letters allowed';
    return null;
  }

  static String? validateLastName(String? value) {
    if (value == null || value.isEmpty) return 'Last name is required';
    if (!_nameRegExp.hasMatch(value)) return 'Only letters allowed';
    return null;
  }

  static String? validateMiddleName(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    if (!_nameRegExp.hasMatch(value)) return 'Only letters allowed';
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Username is required';
    if (!_usernameRegExp.hasMatch(value)) {
      return 'Username can only contain letters, numbers, ., _, or -';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) return 'Address is required';
    if (!_addressRegExp.hasMatch(value)) return 'Invalid address format';
    return null;
  }

  static String? validateBVN(String? value) {
    if (value == null || value.isEmpty) return 'BVN is required';
    if (!_bvnRegExp.hasMatch(value)) return 'BVN must be 11 digits';
    return null;
  }

  static String? validateNIN(String? value) {
    if (value == null || value.isEmpty) return 'NIN is required';
    if (!_ninRegExp.hasMatch(value)) return 'NIN must be 11 digits';
    return null;
  }

  static String? validateDateOfBirth(String? value) {
    if (value == null || value.isEmpty) return 'Date of birth is required';

    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();

      if (date.isAfter(now)) return 'Date of birth cannot be in the future';

      final age = now.year - date.year -
          (now.month < date.month ||
              (now.month == date.month && now.day < date.day)
              ? 1
              : 0);

      if (age < 18) return 'You must be at least 18 years old';
    } catch (_) {
      return 'Enter a valid date in YYYY-MM-DD format';
    }

    return null;
  }
}