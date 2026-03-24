import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'package:hillcrest_finance/app/core/providers/notification_service_provider.dart';
import 'package:hillcrest_finance/app/core/providers/networking_provider.dart';
import 'package:hillcrest_finance/app/core/exceptions/network_exceptions.dart';
import 'package:hillcrest_finance/ui/widgets/app_button.dart';
import 'package:hillcrest_finance/utils/constants/values.dart';
import '../../../../../app/core/router/app_router.dart';
import '../../providers/otp_provider.dart'; // ADDED
import '../../providers/signup_data_provider.dart';

@RoutePage()
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  late TextEditingController _otpController;
  bool _isLoading = false;
  bool _isResending = false;
  bool _isVerifying = false;
  String _currentText = "";

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    // No automatic OTP sending - it was already sent in SignUpScreen
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  // MODIFIED: This method now captures the OTP from the repository
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
      // 1. Await the OTP string from the repository
      final otp = await ref.read(authRepositoryProvider).sendEmailOtp(signUpData.email);
      
      print('💾 OTP received in screen: "$otp"');

      // 2. Save the OTP to the provider using the notifier method
      ref.read(otpProvider.notifier).setOtp(otp);

      print('💾 OTP set via notifier: "${ref.read(otpProvider)}"');

      if (!mounted) return;
      ref.read(notificationServiceProvider).showSuccess('An OTP has been sent to your email.');
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

  void _showSuccessDialog() {
    if (!mounted) return;

    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      headerAnimationLoop: false,
      dialogBackgroundColor: AppColors.white,
      title: StringConst.registrationSuccess,
      desc: StringConst.registrationSuccessSub,
      titleTextStyle: AppTextStyles.cabinBold24DarkBlue.copyWith(fontSize: 20),
      descTextStyle: AppTextStyles.cabinRegular14MutedGray,
      btnOk: AppButton(
        text: StringConst.continueButton,
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
          if (mounted) {
            // Clear the OTP from memory after use
            ref.read(otpProvider.notifier).clearOtp();
            context.router.push(const PhoneVerificationRoute());
          }
        },
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      buttonsBorderRadius: BorderRadius.circular(Sizes.RADIUS_8),
    ).show();
  }

  // MODIFIED: This method now performs a simple offline check
  Future<void> _onContinuePressed() async {
    if (!mounted) return;

    if (_currentText.length != 6) {
      ref.read(notificationServiceProvider).showError('Please enter the 6-digit OTP.');
      return;
    }

    setState(() => _isVerifying = true);

    // Get the correct OTP from the provider
    final correctOtp = ref.read(otpProvider);

    print('🔍 Verification Debug:');
    print('   User entered: "$_currentText"');
    print('   User input length: ${_currentText.length}');
    print('   Stored OTP: "$correctOtp"');
    print('   Stored OTP length: ${correctOtp?.length}');
    print('   User input type: ${_currentText.runtimeType}');
    print('   Stored OTP type: ${correctOtp.runtimeType}');
    print('   Trimmed user input: "${_currentText.trim()}"');
    print('   Trimmed stored OTP: "${correctOtp?.trim()}"');
    print('   Are they equal? ${_currentText == correctOtp}');
    print('   Are they equal (trimmed)? ${_currentText.trim() == correctOtp?.trim()}');

    // Check if OTP exists in provider
    if (correctOtp == null || correctOtp.isEmpty) {
      ref.read(notificationServiceProvider).showError('OTP not found. Please request a new one.');
      if (mounted) {
        setState(() => _isVerifying = false);
      }
      return;
    }

    // Compare the user's input with the correct OTP (with trimming to be safe)
    if (_currentText.trim() == correctOtp.trim()) {
      print('✅ OTP MATCH - Verification successful!');
      _showSuccessDialog();

      // Clear the OTP after successful verification
      ref.read(otpProvider.notifier).clearOtp();
    } else {
      print('❌ OTP MISMATCH - Verification failed!');
      ref.read(notificationServiceProvider).showError('The OTP you entered is incorrect.');
    }

    if (mounted) {
      setState(() => _isVerifying = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final signUpData = ref.read(signUpDataProvider);
    final email = signUpData?.email ?? 'your email';

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
              Text(StringConst.verifyMail, style: AppTextStyles.cabinBold24DarkBlue),
              const SpaceH8(),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.cabinRegular14MutedGray,
                  children: [
                    const TextSpan(text: StringConst.verifyMailSubtitle),
                    TextSpan(
                      text: email,
                      style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue
                      ),
                    ),
                    const TextSpan(text: StringConst.enterCode),
                  ],
                ),
              ),
              const SpaceH40(),
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
                    autoDisposeControllers: false,
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
                      return text?.length == 6 && int.tryParse(text!) != null;
                    },
                  ),
                ),
              const SpaceH32(),
              AppButton(
                  text: StringConst.continueButton,
                  onPressed: _onContinuePressed,
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
