import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'package:hillcrest_finance/app/core/providers/notification_service_provider.dart';
import 'package:hillcrest_finance/app/core/providers/networking_provider.dart';
import 'package:hillcrest_finance/app/core/exceptions/network_exceptions.dart';
import 'package:hillcrest_finance/app/core/providers/user_local_storage_provider.dart';
import 'package:hillcrest_finance/ui/widgets/app_button.dart';
import 'package:hillcrest_finance/utils/constants/values.dart';
import '../../../../../app/core/router/app_router.dart';
import '../../providers/signup_data_provider.dart';

@RoutePage()
class PhoneVerificationScreen extends ConsumerStatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  ConsumerState<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends ConsumerState<PhoneVerificationScreen> {
  late TextEditingController _otpController;
  bool _isLoading = false;
  bool _isResending = false;
  bool _isVerifying = false;
  String _currentText = "";

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _sendOtp();
        // Show demo mode notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '📝 Demo Mode: Enter any 6-digit number to proceed',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.blue.shade600,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp({bool isResend = false}) async {
    if (!mounted) return;

    final signUpData = ref.read(signUpDataProvider);
    if (signUpData == null) {
      if (mounted) {
        ref.read(notificationServiceProvider).showError('Could not retrieve sign-up data.');
        context.router.pop();
      }
      return;
    }

    if (!mounted) return;
    setState(() => isResend ? _isResending = true : _isLoading = true);

    try {
      await ref.read(authRepositoryProvider).sendSmsOtp(signUpData.phoneNumber);
      if (!mounted) return;
      ref.read(notificationServiceProvider).showSuccess('An OTP has been sent to your phone.');
    } on NetworkException catch (e) {
      if (!mounted) return;
      ref.read(notificationServiceProvider).showError(e.message);
    } catch (e) {
      if (!mounted) return;
      ref.read(notificationServiceProvider).showError('An error occurred');
    } finally {
      if (mounted) {
        setState(() => isResend ? _isResending = false : _isLoading = false);
      }
    }
  }

  void _showSuccessDialog(String username) {
    if (!mounted) return;

    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      headerAnimationLoop: false,
      dialogBackgroundColor: AppColors.white,
      title: StringConst.phoneRegistrationSuccess,
      desc: StringConst.phoneRegistrationSuccessSub,
      titleTextStyle: AppTextStyles.cabinBold24DarkBlue.copyWith(fontSize: 20),
      descTextStyle: AppTextStyles.cabinRegular14MutedGray,
      btnOk: AppButton(
        text: StringConst.continueButton,
        onPressed: () async {
          Navigator.of(context, rootNavigator: true).pop();
          if (mounted) {
            await ref.read(userLocalStorageProvider).saveUsername(username);
            ref.read(signUpDataProvider.notifier).clearSignUpData();
            context.router.replaceAll([const SignInRoute()]);
          }
        },
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      buttonsBorderRadius: BorderRadius.circular(Sizes.RADIUS_8),
    ).show();
  }

  Future<void> _onVerifyPressed() async {
    if (!mounted) return;

    if (_currentText.length != 6) {
      ref.read(notificationServiceProvider).showError('Please enter the 6-digit OTP.');
      return;
    }

    final signUpData = ref.read(signUpDataProvider);
    if (signUpData == null) return;

    if (!mounted) return;
    setState(() => _isVerifying = true);

    try {
      await ref.read(authRepositoryProvider).verifySmsOtp(signUpData.phoneNumber, _currentText);
      if (!mounted) return;

      await ref.read(authRepositoryProvider).createKeycloakUser();
      if (!mounted) return;

      _showSuccessDialog(signUpData.username);
    } on NetworkException catch (e) {
      if (!mounted) return;
      ref.read(notificationServiceProvider).showError(e.message);
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    } catch (e) {
      if (!mounted) return;
      ref.read(notificationServiceProvider).showError('An unexpected error occurred.');
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use read instead of watch to avoid rebuilds
    final signUpData = ref.read(signUpDataProvider);
    final phoneNumber = signUpData?.phoneNumber ?? 'your phone number';

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SpaceH48(),
              Image.asset(ImagePath.logo, height: 40),
              const SpaceH24(),
              Text(StringConst.verifyPhone, style: AppTextStyles.cabinBold24DarkBlue),
              const SpaceH8(),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.cabinRegular14MutedGray,
                  children: [
                    const TextSpan(text: StringConst.verifyPhoneSubtitle),
                    TextSpan(
                        text: phoneNumber,
                        style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkBlue
                        )
                    ),
                    const TextSpan(text: StringConst.enterCode),
                  ],
                ),
              ),
              const SpaceH40(),
              // Demo mode info box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Demo Mode: Enter any 6-digit number to test',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SpaceH24(),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 6,
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.fade,
                    autoDisposeControllers: false, // Important: We manage disposal ourselves
                    enableActiveFill: true,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(8),
                      fieldHeight: 56,
                      fieldWidth: 46,
                      activeFillColor: AppColors.white,
                      inactiveFillColor: AppColors.white,
                      selectedFillColor: AppColors.white,
                      activeColor: AppColors.primaryColor,
                      inactiveColor: AppColors.mutedGray.withOpacity(0.3),
                      selectedColor: AppColors.primaryColor,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _currentText = value;
                      });
                    },
                    beforeTextPaste: (text) {
                      // Allow pasting only if text is numeric and 6 digits
                      return text?.length == 6 && int.tryParse(text!) != null;
                    },
                  ),
                ),
              const SpaceH32(),
              AppButton(
                  text: StringConst.continueButton,
                  onPressed: _onVerifyPressed,
                  isLoading: _isVerifying
              ),
              const SpaceH24(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(StringConst.resendPrompt, style: AppTextStyles.cabinRegular14MutedGray),
                  _isResending
                      ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)
                  )
                      : TextButton(
                    onPressed: () => _sendOtp(isResend: true),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Text(
                        StringConst.resendLink,
                        style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold
                        )
                    ),
                  ),
                ],
              ),
              const SpaceH40(),
              TextButton.icon(
                onPressed: () {
                  if (mounted) {
                    context.router.back();
                  }
                },
                icon: const Icon(Icons.arrow_back, size: 18, color: AppColors.darkBlue),
                label: Text(
                    StringConst.backToSignIn,
                    style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                        color: AppColors.darkBlue,
                        fontWeight: FontWeight.w600
                    )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}