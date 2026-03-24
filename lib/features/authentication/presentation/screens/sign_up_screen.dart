import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';

// --- Custom Imports (Verify these paths match your project structure) ---
import '../../../../app/core/exceptions/network_exceptions.dart';
import '../../../../app/core/providers/networking_provider.dart';
import '../../../../app/core/providers/notification_service_provider.dart';
import '../../../../app/core/router/app_router.dart';
import '../../../../ui/widgets/app_button.dart';
import '../../../../ui/widgets/forms/app_textfields.dart';
import '../../../../utils/constants/values.dart';
import '../providers/signup_data_provider.dart';
import '../providers/otp_provider.dart';

@RoutePage()
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  // --- Controllers ---
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // --- State ---
  bool _isLoading = false;
  bool _agreedToTerms = false;
  String? _selectedAccountType;
  final List<String> _accountTypes = ['Individual', 'Corporate', 'Joint'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- Helper: Terms Modal ---
  void _showDocumentModal(String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Sizes.RADIUS_20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(Sizes.PADDING_24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Fixed: Changed from .between
                children: [
                  Text(title, style: AppTextStyles.cabinBold18DarkBlue),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close)
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    Text(
                      "This is where your detailed $title content will go. You can fetch this from your constants or an API.",
                      style: AppTextStyles.cabinRegular14MutedGray,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onContinuePressed() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedAccountType == null) {
      ref.read(notificationServiceProvider).showError('Please select an account type.');
      return;
    }
    if (!_agreedToTerms) {
      ref.read(notificationServiceProvider).showError('Please agree to the Terms & Conditions.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Logic for checking user and sending OTP
      await ref.read(authRepositoryProvider).checkIfUserExists(
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      final signUpData = SignUpData(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        accountType: _selectedAccountType!,
        phoneNumber: _phoneController.text.trim(),
      );
      ref.read(signUpDataProvider.notifier).setSignUpData(signUpData);

      final otp = await ref.read(authRepositoryProvider).sendEmailOtp(_emailController.text.trim());
      ref.read(otpProvider.notifier).setOtp(otp);

      if (mounted) {
        context.router.push(const EmailVerificationRoute());
      }
    } on UserAlreadyExistsException catch (e) {
      ref.read(notificationServiceProvider).showError(e.message);
    } on NetworkException catch (e) {
      ref.read(notificationServiceProvider).showError(e.message);
    } catch (e) {
      ref.read(notificationServiceProvider).showError('An unexpected error occurred.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SpaceH48(),
                Image.asset(ImagePath.logoIcon, height: 40),
                const SpaceH24(),
                Text(StringConst.getStarted, style: AppTextStyles.cabinBold24DarkBlue),
                const SpaceH8(),
                Text(
                  StringConst.getStartedSubtitle,
                  style: AppTextStyles.cabinRegular14MutedGray,
                  textAlign: TextAlign.center,
                ),
                const SpaceH40(),
                AppTextField(controller: _firstNameController, label: StringConst.firstNameLabel,  type: AppTextFieldType.text, prefixIcon: const Icon(Icons.person_outline, color: AppColors.mutedGray, size: Sizes.ICON_SIZE_20)),
                const SpaceH16(),
                AppTextField(controller: _lastNameController, label: StringConst.lastNameLabel,  type: AppTextFieldType.text, prefixIcon: const Icon(Icons.person_outline, color: AppColors.mutedGray, size: Sizes.ICON_SIZE_20)),
                const SpaceH16(),
                AppTextField(controller: _usernameController, label: "Username",  type: AppTextFieldType.text, prefixIcon: const Icon(Icons.account_circle_outlined, color: AppColors.mutedGray, size: Sizes.ICON_SIZE_20)),
                const SpaceH16(),
                AppTextField(controller: _emailController, label: StringConst.emailLabel,  type: AppTextFieldType.email, prefixIcon: const Icon(Icons.email_outlined, color: AppColors.mutedGray, size: Sizes.ICON_SIZE_20)),
                const SpaceH16(),
                AppTextField(controller: _phoneController, label: StringConst.phoneNumberLabel,  type: AppTextFieldType.phone, prefix: Row(mainAxisSize: MainAxisSize.min, children: [Text(StringConst.countryCodeHint, style: AppTextStyles.interRegular14DarkBlue), const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.mutedGray), const SpaceW8(), Container(width: 1, height: Sizes.ICON_SIZE_20, color: AppColors.lightGray), const SpaceW8()])),
                const SpaceH16(),
                AppTextField(label: StringConst.accountTypeLabel, type: AppTextFieldType.dropdown, dropdownItems: _accountTypes, onDropdownChanged: (value) => setState(() => _selectedAccountType = value), initialDropdownValue: _selectedAccountType),
                const SpaceH16(),
                AppTextField(controller: _passwordController, label: StringConst.passwordLabel, type: AppTextFieldType.password, prefixIcon: const Icon(Icons.lock_outline, color: AppColors.mutedGray, size: Sizes.ICON_SIZE_20), showPasswordStrength: true),
                const SpaceH16(),
                AppTextField(controller: _confirmPasswordController, label: StringConst.confirmPasswordLabel, type: AppTextFieldType.confirmPassword, originalPasswordController: _passwordController, prefixIcon: const Icon(Icons.lock_outline, color: AppColors.mutedGray, size: Sizes.ICON_SIZE_20)),
                const SpaceH24(),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: Sizes.ICON_SIZE_20,
                      height: Sizes.ICON_SIZE_20,
                      child: Checkbox(
                        value: _agreedToTerms,
                        onChanged: (bool? newValue) => setState(() => _agreedToTerms = newValue ?? false),
                        activeColor: AppColors.primaryColor,
                      ),
                    ),
                    const SpaceW8(),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: '${StringConst.termsAgreement} ',
                          style: AppTextStyles.cabinRegular12DarkBlue,
                          children: [
                            TextSpan(
                              text: StringConst.termsandConditions,
                              style: AppTextStyles.cabinRegular12DarkBlue.copyWith(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => _showDocumentModal(StringConst.termsandConditions),
                            ),
                            TextSpan(
                              text: ' ${StringConst.and} ',
                              style: AppTextStyles.cabinRegular12DarkBlue,
                            ),
                            TextSpan(
                              text: StringConst.privacyPolicy,
                              style: AppTextStyles.cabinRegular12DarkBlue.copyWith(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => _showDocumentModal(StringConst.privacyPolicy),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SpaceH32(),
                AppButton(text: StringConst.continueButton, onPressed: _onContinuePressed, isLoading: _isLoading),
                const SpaceH24(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(StringConst.alreadyHaveAccountPrompt, style: AppTextStyles.cabinRegular14MutedGray),
                    TextButton(
                      onPressed: () => context.router.push(const SignInRoute()),
                      child: const Text(StringConst.signIn, style: AppTextStyles.cabinRegular14Primary),
                    ),
                  ],
                ),
                const SpaceH48(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}