// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [CreateNewPasswordScreen]
class CreateNewPasswordRoute extends PageRouteInfo<void> {
  const CreateNewPasswordRoute({List<PageRouteInfo>? children})
    : super(CreateNewPasswordRoute.name, initialChildren: children);

  static const String name = 'CreateNewPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CreateNewPasswordScreen();
    },
  );
}

/// generated route for
/// [DashboardScreen]
class DashboardRoute extends PageRouteInfo<void> {
  const DashboardRoute({List<PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DashboardScreen();
    },
  );
}

/// generated route for
/// [EditProfileScreen]
class EditProfileRoute extends PageRouteInfo<void> {
  const EditProfileRoute({List<PageRouteInfo>? children})
    : super(EditProfileRoute.name, initialChildren: children);

  static const String name = 'EditProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const EditProfileScreen();
    },
  );
}

/// generated route for
/// [EmailVerificationScreen]
class EmailVerificationRoute extends PageRouteInfo<void> {
  const EmailVerificationRoute({List<PageRouteInfo>? children})
    : super(EmailVerificationRoute.name, initialChildren: children);

  static const String name = 'EmailVerificationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const EmailVerificationScreen();
    },
  );
}

/// generated route for
/// [FAQScreen]
class FAQRoute extends PageRouteInfo<void> {
  const FAQRoute({List<PageRouteInfo>? children})
    : super(FAQRoute.name, initialChildren: children);

  static const String name = 'FAQRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FAQScreen();
    },
  );
}

/// generated route for
/// [FaceCaptureScreen]
class FaceCaptureRoute extends PageRouteInfo<void> {
  const FaceCaptureRoute({List<PageRouteInfo>? children})
    : super(FaceCaptureRoute.name, initialChildren: children);

  static const String name = 'FaceCaptureRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FaceCaptureScreen();
    },
  );
}

/// generated route for
/// [ForgotPasswordScreen]
class ForgotPasswordRoute extends PageRouteInfo<void> {
  const ForgotPasswordRoute({List<PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ForgotPasswordScreen();
    },
  );
}

/// generated route for
/// [FundPriceScreen]
class FundPriceRoute extends PageRouteInfo<void> {
  const FundPriceRoute({List<PageRouteInfo>? children})
    : super(FundPriceRoute.name, initialChildren: children);

  static const String name = 'FundPriceRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FundPriceScreen();
    },
  );
}

/// generated route for
/// [GenerateAccountStatementScreen]
class GenerateAccountStatementRoute extends PageRouteInfo<void> {
  const GenerateAccountStatementRoute({List<PageRouteInfo>? children})
    : super(GenerateAccountStatementRoute.name, initialChildren: children);

  static const String name = 'GenerateAccountStatementRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const GenerateAccountStatementScreen();
    },
  );
}

/// generated route for
/// [GenerateReferenceLetterScreen]
class GenerateReferenceLetterRoute extends PageRouteInfo<void> {
  const GenerateReferenceLetterRoute({List<PageRouteInfo>? children})
    : super(GenerateReferenceLetterRoute.name, initialChildren: children);

  static const String name = 'GenerateReferenceLetterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const GenerateReferenceLetterScreen();
    },
  );
}

/// generated route for
/// [IndividualKycDocumentUploadScreen]
class IndividualKycDocumentUploadRoute extends PageRouteInfo<void> {
  const IndividualKycDocumentUploadRoute({List<PageRouteInfo>? children})
    : super(IndividualKycDocumentUploadRoute.name, initialChildren: children);

  static const String name = 'IndividualKycDocumentUploadRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const IndividualKycDocumentUploadScreen();
    },
  );
}

/// generated route for
/// [IndividualPersonalInformationScreen]
class IndividualPersonalInformationRoute extends PageRouteInfo<void> {
  const IndividualPersonalInformationRoute({List<PageRouteInfo>? children})
    : super(IndividualPersonalInformationRoute.name, initialChildren: children);

  static const String name = 'IndividualPersonalInformationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const IndividualPersonalInformationScreen();
    },
  );
}

/// generated route for
/// [InvestNowScreen]
class InvestNowRoute extends PageRouteInfo<InvestNowRouteArgs> {
  InvestNowRoute({
    Key? key,
    InvestmentDetail? investment,
    InvestmentScheme? scheme,
    List<PageRouteInfo>? children,
  }) : super(
         InvestNowRoute.name,
         args: InvestNowRouteArgs(
           key: key,
           investment: investment,
           scheme: scheme,
         ),
         initialChildren: children,
       );

  static const String name = 'InvestNowRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<InvestNowRouteArgs>(
        orElse: () => const InvestNowRouteArgs(),
      );
      return InvestNowScreen(
        key: args.key,
        investment: args.investment,
        scheme: args.scheme,
      );
    },
  );
}

class InvestNowRouteArgs {
  const InvestNowRouteArgs({this.key, this.investment, this.scheme});

  final Key? key;

  final InvestmentDetail? investment;

  final InvestmentScheme? scheme;

  @override
  String toString() {
    return 'InvestNowRouteArgs{key: $key, investment: $investment, scheme: $scheme}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! InvestNowRouteArgs) return false;
    return key == other.key &&
        investment == other.investment &&
        scheme == other.scheme;
  }

  @override
  int get hashCode => key.hashCode ^ investment.hashCode ^ scheme.hashCode;
}

/// generated route for
/// [InvestmentScreen]
class InvestmentRoute extends PageRouteInfo<void> {
  const InvestmentRoute({List<PageRouteInfo>? children})
    : super(InvestmentRoute.name, initialChildren: children);

  static const String name = 'InvestmentRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const InvestmentScreen();
    },
  );
}

/// generated route for
/// [InvestorTransactionsScreen]
class InvestorTransactionsRoute extends PageRouteInfo<void> {
  const InvestorTransactionsRoute({List<PageRouteInfo>? children})
    : super(InvestorTransactionsRoute.name, initialChildren: children);

  static const String name = 'InvestorTransactionsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const InvestorTransactionsScreen();
    },
  );
}

/// generated route for
/// [MainWrapperScreen]
class MainWrapperRoute extends PageRouteInfo<void> {
  const MainWrapperRoute({List<PageRouteInfo>? children})
    : super(MainWrapperRoute.name, initialChildren: children);

  static const String name = 'MainWrapperRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainWrapperScreen();
    },
  );
}

/// generated route for
/// [MyInvestmentScreen]
class MyInvestmentRoute extends PageRouteInfo<void> {
  const MyInvestmentRoute({List<PageRouteInfo>? children})
    : super(MyInvestmentRoute.name, initialChildren: children);

  static const String name = 'MyInvestmentRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MyInvestmentScreen();
    },
  );
}

/// generated route for
/// [PhoneVerificationScreen]
class PhoneVerificationRoute extends PageRouteInfo<void> {
  const PhoneVerificationRoute({List<PageRouteInfo>? children})
    : super(PhoneVerificationRoute.name, initialChildren: children);

  static const String name = 'PhoneVerificationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PhoneVerificationScreen();
    },
  );
}

/// generated route for
/// [PortfolioHoldingsScreen]
class PortfolioHoldingsRoute extends PageRouteInfo<void> {
  const PortfolioHoldingsRoute({List<PageRouteInfo>? children})
    : super(PortfolioHoldingsRoute.name, initialChildren: children);

  static const String name = 'PortfolioHoldingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PortfolioHoldingsScreen();
    },
  );
}

/// generated route for
/// [ProfileScreen]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileScreen();
    },
  );
}

/// generated route for
/// [RedeemFundsScreen]
class RedeemFundsRoute extends PageRouteInfo<void> {
  const RedeemFundsRoute({List<PageRouteInfo>? children})
    : super(RedeemFundsRoute.name, initialChildren: children);

  static const String name = 'RedeemFundsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RedeemFundsScreen();
    },
  );
}

/// generated route for
/// [SignInScreen]
class SignInRoute extends PageRouteInfo<void> {
  const SignInRoute({List<PageRouteInfo>? children})
    : super(SignInRoute.name, initialChildren: children);

  static const String name = 'SignInRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SignInScreen();
    },
  );
}

/// generated route for
/// [SignUpScreen]
class SignUpRoute extends PageRouteInfo<void> {
  const SignUpRoute({List<PageRouteInfo>? children})
    : super(SignUpRoute.name, initialChildren: children);

  static const String name = 'SignUpRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SignUpScreen();
    },
  );
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
}

/// generated route for
/// [WelcomeOnboardingScreen]
class WelcomeOnboardingRoute extends PageRouteInfo<void> {
  const WelcomeOnboardingRoute({List<PageRouteInfo>? children})
    : super(WelcomeOnboardingRoute.name, initialChildren: children);

  static const String name = 'WelcomeOnboardingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WelcomeOnboardingScreen();
    },
  );
}
