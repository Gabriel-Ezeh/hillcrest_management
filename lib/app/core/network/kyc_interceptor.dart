import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hillcrest_finance/features/authentication/presentation/providers/auth_state_provider.dart';
import 'package:hillcrest_finance/features/dashboard/presentation/screens/onboarding_completion_modal.dart';


/// A utility to intercept actions that require a completed KYC/Onboarding.
///
/// It mimics the logic used in your listeners to provide a consistent
/// gatekeeping experience across the app.
class KycInterceptor {

  /// Checks the current auth state and either runs the [action]
  /// or triggers the Onboarding Completion Modal.
  static void runWithCheck({
    required BuildContext context,
    required WidgetRef ref,
    required VoidCallback action,
  }) {
    // 1. Read current state
    final authState = ref.read(authStateProvider);

    // 2. Perform the same logic check you used in the view
    if (authState.isAuthenticated && authState.hasCustomerNo != true) {
      final accountType = authState.accountType ?? 'Individual';

      // 3. Show the modal using your specific helper function
      showOnboardingCompletionModal(
        context,
        accountType: accountType,
        onContinue: () {
          // Close the modal
          Navigator.of(context).pop();
          // Navigate using your router logic
          _navigateToKYCFlow(context, accountType);
        },
      );
    } else {
      // 4. If KYC is fine (or user not logged in), proceed with action
      action();
    }
  }

  /// Consistent navigation to the KYC flow
  static void _navigateToKYCFlow(BuildContext context, String accountType) {
    // Using context.router as per your example
    context.router.pushNamed('/kyc/personal-info');
  }
}