import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hillcrest_finance/app/core/router/app_router.dart';
import 'package:hillcrest_finance/ui/widgets/app_button.dart';
import 'package:hillcrest_finance/ui/widgets/forms/app_textfields.dart';
import 'package:hillcrest_finance/utils/constants/values.dart';

@RoutePage()
class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onContinuePressed() {
    if (_formKey.currentState!.validate()) {
      // Logic for password reset update
      print('Password updated successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.darkBlue, size: 30),
          onPressed: () => context.router.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SpaceH20(),

                // --- 1. Logo Icon ---
                Image.asset(
                  ImagePath.logoIcon,
                  height: 40,
                ),
                const SpaceH24(),

                // --- 2. Title ---
                Text(
                  StringConst.createNewPassword,
                  style: AppTextStyles.cabinBold24DarkBlue,
                  textAlign: TextAlign.center,
                ),
                const SpaceH12(),

                // --- 3. Subtitle/Requirements ---
                Text(
                  StringConst.passwordRequirements,
                  style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SpaceH40(),

                // --- 4. Password Field ---
                AppTextField(
                  controller: _passwordController,
                  label: StringConst.passwordLabel,
                  // hintText: StringConst.passwordHint,
                  type: AppTextFieldType.password,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.mutedGray,
                    size: Sizes.ICON_SIZE_20,
                  ),
                  showPasswordStrength: true, // Shows the strength bar
                  validator: (value) {
                    if (value == null || value.length < 8) {
                      return 'Password must be at least 8 characters.';
                    }
                    return null;
                  },
                ),
                const SpaceH24(),

                // --- 5. Confirm Password Field ---
                AppTextField(
                  controller: _confirmPasswordController,
                  label: StringConst.confirmPasswordLabel,
                  // hintText: StringConst.confirmPasswordHint,
                  type: AppTextFieldType.confirmPassword,
                  originalPasswordController: _passwordController, // Matches against password
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.mutedGray,
                    size: Sizes.ICON_SIZE_20,
                  ),
                ),
                const SpaceH32(),

                // --- 6. Continue Button ---
                AppButton(
                  text: StringConst.continueButton,
                  onPressed: _onContinuePressed,
                ),
                const SpaceH24(),

                // --- 7. Resend Code Section ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      StringConst.resendCodePrompt,
                      style: AppTextStyles.cabinRegular14MutedGray,
                    ),
                    TextButton(
                      onPressed: () {
                        // Logic for resending code
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Text(
                        StringConst.resendAction,
                        style: AppTextStyles.cabinBold14Primary.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SpaceH40(),

                // --- 8. Back to Sign In ---
                TextButton.icon(
                  onPressed: () => context.router.replaceAll([const SignInRoute()]),
                  icon: const Icon(Icons.arrow_back, size: 18, color: AppColors.darkBlue),
                  label: Text(
                    StringConst.backToSignIn,
                    style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                      color: AppColors.darkBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SpaceH24(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}