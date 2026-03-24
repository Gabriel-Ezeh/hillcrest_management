import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hillcrest_finance/app/core/router/app_router.dart';
import 'package:hillcrest_finance/features/authentication/presentation/providers/auth_state_provider.dart';
import 'package:hillcrest_finance/features/dashboard/presentation/screens/onboarding_completion_modal.dart';
import 'package:hillcrest_finance/ui/widgets/bottom_navbar.dart';

@RoutePage()
class MainWrapperScreen extends ConsumerWidget {
  const MainWrapperScreen({super.key});

  void _showKycModal(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated) return;

    final accountType = authState.accountType ?? 'Individual';
    showOnboardingCompletionModal(
      context,
      accountType: accountType,
      onContinue: () {
        Navigator.of(context).pop();
        context.router.pushNamed('/kyc/personal-info');
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AutoTabsScaffold(
      routes: const [
        DashboardRoute(),
        RedeemFundsRoute(), // Placeholder for Wallet
        InvestmentRoute(), // Placeholder for Invest
        ProfileRoute(),
      ],
      bottomNavigationBuilder: (context, tabsRouter) {
        return AppBottomNav(
          currentIndex: tabsRouter.activeIndex,
          onTap: (index) {
            final authState = ref.read(authStateProvider);
            final requiresKyc = index == 1 || index == 2;

            if (requiresKyc && authState.hasCustomerNo != true) {
              _showKycModal(context, ref);
              return;
            }

            tabsRouter.setActiveIndex(index);
          },
        );
      },
    );
  }
}
