import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart'; // Required for 'Key'
import 'package:hillcrest_finance/features/authentication/presentation/screens/splash_screen.dart';
import 'package:hillcrest_finance/features/authentication/presentation/screens/welcome_onboarding_screen.dart';
import 'package:hillcrest_finance/features/authentication/presentation/screens/sign_in_screen.dart';
import 'package:hillcrest_finance/features/authentication/presentation/screens/sign_up_screen.dart';
import 'package:hillcrest_finance/features/authentication/presentation/screens/verification_screens/email_verification_screen.dart';
import 'package:hillcrest_finance/features/authentication/presentation/screens/verification_screens/phone_verification_screen.dart';
import 'package:hillcrest_finance/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:hillcrest_finance/features/dashboard/presentation/screens/main_wrapper_screen.dart';
import 'package:hillcrest_finance/features/dashboard/presentation/screens/profile_screen.dart';
import 'package:hillcrest_finance/features/kyc/kyc_forms/individual_form/individual_personal_information_screen.dart';
import 'package:hillcrest_finance/features/kyc/kyc_forms/individual_form/individual_kyc_upload_document_screen.dart';
import 'package:hillcrest_finance/features/kyc/kyc_forms/widgets/liveness_check.dart';
import 'package:hillcrest_finance/features/investment/presentation/screens/my_investment_screen.dart';
import 'package:hillcrest_finance/features/investment/presentation/screens/investment_screen.dart';
import 'package:hillcrest_finance/features/investment/presentation/screens/portfolio_holdings_screen.dart';
import 'package:hillcrest_finance/features/investment/presentation/screens/view_all_investment_transactions_activities_by_an_investor.dart';
import 'package:hillcrest_finance/features/dashboard/presentation/screens/screens_inside_profile_screen/generate_reference_letter_screen.dart';
import 'package:hillcrest_finance/features/dashboard/presentation/screens/screens_inside_profile_screen/generate_account_statement_screen.dart';
import 'package:hillcrest_finance/features/dashboard/presentation/screens/screens_inside_profile_screen/faqs_screen.dart';
import 'package:hillcrest_finance/features/authentication/presentation/screens/forgot_password/forgot_password_screen.dart';
import 'package:hillcrest_finance/features/authentication/presentation/screens/forgot_password/create_new_password_screen.dart';
import 'package:hillcrest_finance/features/dashboard/presentation/screens/redeem_funds.dart';
import 'package:hillcrest_finance/features/dashboard/presentation/screens/screens_inside_profile_screen/edit_profile_screen.dart';
import 'package:hillcrest_finance/features/dashboard/presentation/screens/screens_inside_profile_screen/fund_price_screen.dart';

// Missing imports for InvestNowRoute
import 'package:hillcrest_finance/features/investment/presentation/screens/fund_investment_scheme_screen.dart';
import 'package:hillcrest_finance/features/investment/data/models/investment_scheme.dart'; // Assuming InvestmentDetail is here

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.material();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true, path: '/'),
        AutoRoute(page: WelcomeOnboardingRoute.page, path: '/onboarding'),
        AutoRoute(page: SignInRoute.page, path: '/sign-in'),
        AutoRoute(page: SignUpRoute.page, path: '/sign-up'),
        AutoRoute(page: EmailVerificationRoute.page, path: '/verify-email'),
        AutoRoute(page: PhoneVerificationRoute.page, path: '/verify-phone'),
        AutoRoute(
          page: IndividualPersonalInformationRoute.page,
          path: '/kyc/personal-info',
        ),
        AutoRoute(
          page: IndividualKycDocumentUploadRoute.page,
          path: '/kyc/upload-documents',
        ),
        AutoRoute(page: LivenessCheckRoute.page, path: '/liveness-check'),
        AutoRoute(
          page: MyInvestmentRoute.page,
          path: '/my-investments',
        ),
        AutoRoute(
          page: InvestorTransactionsRoute.page,
          path: '/investor-transactions',
        ),
        AutoRoute(
          page: PortfolioHoldingsRoute.page,
          path: '/portfolio/holdings',
        ),
        AutoRoute(
          page: GenerateReferenceLetterRoute.page,
          path: '/generate-reference-letter',
        ),
        AutoRoute(
          page: GenerateAccountStatementRoute.page,
          path: '/generate-account-statement',
        ),
        AutoRoute(
          page: FAQRoute.page,
          path: '/faqs',
        ),
        AutoRoute(
          page: ForgotPasswordRoute.page,
          path: '/forgot-password',
        ),
        AutoRoute(
          page: CreateNewPasswordRoute.page,
          path: '/create-new-password',
        ),
        AutoRoute(
          page: EditProfileRoute.page,
          path: '/edit-profile',
        ),
        AutoRoute(
          page: FundPriceRoute.page,
          path: '/fund-price',
        ),
        AutoRoute(
          page: InvestNowRoute.page,
          path: '/invest-now',
        ),
        AutoRoute(
          page: MainWrapperRoute.page,
          path: '/main',
          children: [
            AutoRoute(page: DashboardRoute.page, path: 'dashboard', initial: true),
            AutoRoute(page: InvestmentRoute.page, path: 'invest'),
            AutoRoute(page: ProfileRoute.page, path: 'profile'),
            AutoRoute(page: RedeemFundsRoute.page, path: 'redeem-funds'),
          ],
        ),
      ];
}
