import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hillcrest_finance/app/core/exceptions/network_exceptions.dart';
import 'package:hillcrest_finance/app/core/providers/notification_service_provider.dart';
import 'package:hillcrest_finance/app/core/providers/user_local_storage_provider.dart';
import 'package:hillcrest_finance/app/core/router/app_router.dart';
import 'package:hillcrest_finance/features/authentication/presentation/providers/auth_state_notifier.dart';
import 'package:hillcrest_finance/features/authentication/presentation/providers/auth_state_provider.dart';
import 'package:hillcrest_finance/ui/widgets/app_button.dart';
import 'package:hillcrest_finance/ui/widgets/forms/app_textfields.dart';

import '../../../../utils/constants/values.dart';

@RoutePage()
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _usernameController.text =
        ref.read(userLocalStorageProvider).lastUsedUsername ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    try {
      await ref.read(authStateProvider.notifier).login(username, password);
      // On success, save username and let the listener handle navigation
      await ref.read(userLocalStorageProvider).saveUsername(username);
    } on NetworkException catch (e) {
      ref.read(notificationServiceProvider).showError(e.message);
    } catch (e) {
      ref
          .read(notificationServiceProvider)
          .showError('An unexpected error occurred.');
    }
  }

  void _navigateToSignUp() {
    context.router.push(const SignUpRoute());
  }

  void _navigateToForgotPassword() {
    context.router.push(const ForgotPasswordRoute());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (previous, next) {
      if (next.isAuthenticated) {
        context.router.replaceNamed('/main/dashboard');
      }
    });

    final authState = ref.watch(authStateProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 👈 closes the keyboard
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SpaceH48(),
                  Image.asset(ImagePath.logo, height: 40),
                  const SpaceH24(),
                  Text(
                    StringConst.welcome,
                    style: AppTextStyles.cabinBold24DarkBlue,
                  ),
                  const SpaceH8(),
                  Text(
                    StringConst.signInSubtitle,
                    style: AppTextStyles.cabinRegular14MutedGray,
                    textAlign: TextAlign.center,
                  ),
                  const SpaceH40(),
                  AppTextField(
                    controller: _usernameController,
                    label: "Username",
                    // hintText: "Enter your username",
                    type: AppTextFieldType.text,
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppColors.mutedGray,
                      size: Sizes.ICON_SIZE_20,
                    ),
                  ),
                  const SpaceH24(),
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
                  ),
                  const SpaceH8(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _navigateToForgotPassword,
                      child: const Text(StringConst.forgotPassword),
                    ),
                  ),
                  const SpaceH32(),
                  AppButton(
                    text: StringConst.continueButton,
                    onPressed: _onLoginPressed,
                    isLoading: authState.isLoading,
                  ),
                  const SpaceH48(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        StringConst.noAccountPrompt,
                        style: AppTextStyles.cabinRegular14MutedGray,
                      ),
                      TextButton(
                        onPressed: _navigateToSignUp,
                        child: const Text(
                          StringConst.createOne,
                          style: AppTextStyles.cabinRegular14Primary,
                        ),
                      ),
                    ],
                  ),
                  const SpaceH48(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
