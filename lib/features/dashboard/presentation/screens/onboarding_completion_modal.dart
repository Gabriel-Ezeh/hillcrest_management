import 'package:flutter/material.dart';
import 'package:hillcrest_finance/utils/constants/values.dart';

class OnboardingCompletionModal extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback? onClose;

  const OnboardingCompletionModal({
    super.key,
    required this.onContinue,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
      ),
      backgroundColor: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(Sizes.PADDING_24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: onClose ?? () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.mutedGray.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: AppColors.darkBlue,
                  ),
                ),
              ),
            ),
            const SpaceH16(),

            // Title
            Text(
              StringConst.welcomeOnboard,
              style: AppTextStyles.cabinBold24DarkBlue.copyWith(fontSize: 22),
            ),
            const SpaceH8(),

            // Subtitle
            Text(
              StringConst.finishSettingUpProfile,
              style: AppTextStyles.cabinRegular14MutedGray,
            ),
            const SpaceH16(),

            // Description
            Text(
              StringConst.provideDetailsPrompt,
              style: AppTextStyles.cabinRegular14MutedGray,
            ),
            const SpaceH24(),

            // Checklist items
            _buildChecklistItem(
              icon: Icons.check_circle,
              iconColor: AppColors.successGreen,
              text: StringConst.signUpCompleted,
              isCompleted: true,
            ),
            const SpaceH16(),
            _buildChecklistItem(
              icon: Icons.radio_button_unchecked,
              iconColor: AppColors.mutedGray,
              text: StringConst.personalInformation,
              isCompleted: false,
            ),
            const SpaceH16(),
            _buildChecklistItem(
              icon: Icons.radio_button_unchecked,
              iconColor: AppColors.mutedGray,
              text: StringConst.kycDocumentUpload,
              isCompleted: false,
            ),
            const SpaceH32(),

            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Sizes.RADIUS_8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  StringConst.continueOnboarding,
                  style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem({
    required IconData icon,
    required Color iconColor,
    required String text,
    required bool isCompleted,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isCompleted ? AppColors.darkBlue : AppColors.mutedGray,
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

// In onboarding_completion_modal.dart

void showOnboardingCompletionModal(
    BuildContext context, {
      required String accountType, // ADDED
      required VoidCallback onContinue,
    }) {
  // Get steps based on account type
  final steps = _getStepsForAccountType(accountType);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Complete Your ${accountType} KYC'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Please complete the following steps:'),
          const SizedBox(height: 16),
          ...steps.map((step) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(step)),
              ],
            ),
          )),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onContinue,
          child: const Text('Continue'),
        ),
      ],
    ),
  );
}

List<String> _getStepsForAccountType(String accountType) {
  switch (accountType.toLowerCase()) {
    case 'individual':
      return [
        'Personal Information',
        'Identity Verification',
        'Address Proof Upload',
      ];
    case 'corporate':
      return [
        'Company Information',
        'Directors Information',
        'Business Registration Documents',
        'Tax Identification',
      ];
    case 'sme':
      return [
        'Business Information',
        'Owner Details',
        'Business Registration',
        'Bank Verification',
      ];
    default:
      return ['Complete KYC Process'];
  }
}