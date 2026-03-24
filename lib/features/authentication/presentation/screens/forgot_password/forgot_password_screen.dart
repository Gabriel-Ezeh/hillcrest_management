import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'package:hillcrest_finance/utils/constants/values.dart';
import 'package:hillcrest_finance/features/authentication/presentation/providers/auth_state_provider.dart';
import 'package:hillcrest_finance/app/core/router/app_router.dart';
import 'package:hillcrest_finance/ui/widgets/app_button.dart';

@RoutePage()
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  // MODIFIED
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  // MODIFIED
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleForgotPassword() async {
    // First, validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    await ref.read(authStateProvider.notifier).forgotPassword(email);

    // Show success dialog regardless of whether the email exists
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: 'Check Your Email',
      desc:
          'If your email is registered with us, you will receive a password reset link shortly.',
      btnOkOnPress: () {
        context.router.pop();
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 30),
          onPressed: () => context.router.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
          child: Form(
            // WRAPPED with Form
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SpaceH20(),
                Center(
                  child: Image.asset(ImagePath.logoIcon, height: 60, width: 60),
                ),
                const SpaceH8(),

                Text(
                  StringConst.passwordResetTitle,
                  style: AppTextStyles.cabinBold24DarkBlue,
                  textAlign: TextAlign.center,
                ),
                const SpaceH8(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    StringConst.passwordResetInstruction,
                    style: AppTextStyles.interRegular14HintGray.copyWith(
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SpaceH40(),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    StringConst.emailLabel,
                    style: AppTextStyles.interSemiBold14DarkBlue,
                  ),
                ),
                const SpaceH8(),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    // ADDED Validator
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                    ).hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    // hintText: StringConst.emailHint,
                    // hintStyle: AppTextStyles.interRegular14HintGray,
                    prefixIcon: const Icon(
                      Icons.mail_outline,
                      color: AppColors.lightGray,
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Sizes.RADIUS_8),
                      borderSide: const BorderSide(color: AppColors.lightGray),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Sizes.RADIUS_8),
                      borderSide: const BorderSide(color: AppColors.lightGray),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Sizes.RADIUS_8),
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                ),
                const SpaceH32(),

                AppButton(
                  text: StringConst.continueButton,
                  onPressed: _handleForgotPassword,
                  isLoading: authState.isLoading,
                ),
                const SpaceH40(),

                GestureDetector(
                  onTap: () => context.router.pop(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.arrow_back,
                        size: 16,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Back to Sign In",
                        style: AppTextStyles.interSemiBold14DarkBlue.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
