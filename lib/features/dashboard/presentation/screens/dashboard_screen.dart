import 'package:auto_route/auto_route.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:hillcrest_finance/app/core/router/app_router.dart';
import 'package:hillcrest_finance/features/authentication/presentation/providers/auth_state_provider.dart';
import 'package:hillcrest_finance/features/dashboard/presentation/screens/onboarding_completion_modal.dart';
import 'package:hillcrest_finance/features/dashboard/presentation/widgets/home_recent_transactions_section.dart';
import 'package:hillcrest_finance/features/investment/presentation/providers/investment_providers.dart';
import 'package:hillcrest_finance/ui/widgets/app_payment_modal.dart';
import 'package:hillcrest_finance/ui/widgets/currency_selector_modal.dart';
import 'package:hillcrest_finance/utils/constants/values.dart';
import 'package:flutter/services.dart';

@RoutePage()
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedCurrency = 'NGN';
  String _selectedCountryCode = 'ng';
  bool _isBalanceVisible = true;

  Future<void> _handleLogout() async {
    await ref.read(authStateProvider.notifier).logout();
    if (!mounted) return;
    context.router.root.replaceAll([const SignInRoute()]);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOnboardingStatusAndShowModal();
    });
  }

  /// Refreshes user data globally via the AuthStateProvider
  Future<void> _handleRefresh() async {
    // Assuming your notifier has a method to fetch updated user data
    // This will update the state, which both this screen and the profile screen watch.
    try {
      await ref.read(authStateProvider.notifier).refreshUserData();
    } catch (e) {
      // Handle potential errors (e.g., network issues)
      debugPrint("Refresh failed: $e");
    }
  }

  /// --- Creative Transaction Success Flow ---
  Future<void> _handleTransactionFlow(String title, String amount) async {
    Navigator.pop(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) Navigator.pop(context);

    if (mounted) {
      _showSuccessDialog(title, amount);
    }
  }

  void _showSuccessDialog(String type, String amount) {
    AwesomeDialog(
      context: context,
      animType: AnimType.scale,
      dialogType: DialogType.success,
      headerAnimationLoop: false,
      title: 'Success!',
      desc: 'Transaction of $_selectedCurrency$amount was successful.',
      btnOkOnPress: () {},
      btnOkColor: AppColors.primaryColor,
      body: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 60),
          const SpaceH12(),
          Text(
            'Transaction Successful',
            style: AppTextStyles.cabinBold24DarkBlue.copyWith(fontSize: 18),
          ),
          const SpaceH8(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Your $type request has been processed. Your new balance will reflect in a few moments.',
              textAlign: TextAlign.center,
              style: AppTextStyles.cabinRegular14MutedGray,
            ),
          ),
          const SpaceH20(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 18,
                  color: AppColors.primaryColor,
                ),
                const SpaceW8(),
                Text(
                  "REF: HF-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
                  style: AppTextStyles.cabinRegular14Primary.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SpaceH16(),
          TextButton(
            onPressed: () {},
            child: const Text(
              "View Receipt",
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    ).show();
  }

  void _showPaymentModal(String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentModal(
        title: title,
        onContinue: (amount) => _handleTransactionFlow(title, amount),
      ),
    );
  }

  void _runGatedAction(VoidCallback action) {
    final authState = ref.read(authStateProvider);
    if (authState.hasCustomerNo == true) {
      action();
      return;
    }
    _checkOnboardingStatusAndShowModal();
  }

  void _checkOnboardingStatusAndShowModal() {
    if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? false)) return;
    final authState = ref.read(authStateProvider);
    if (authState.isAuthenticated && authState.hasCustomerNo != true) {
      final accountType = authState.accountType ?? 'Individual';
      showOnboardingCompletionModal(
        context,
        accountType: accountType,
        onContinue: () {
          Navigator.of(context).pop();
          _navigateToKYCFlow(accountType);
        },
      );
    }
  }

  void _navigateToKYCFlow(String accountType) {
    context.router.pushNamed('/kyc/personal-info');
  }

  void _showCurrencySelector() {
    CurrencySelectorModal.show(
      context,
      selectedCurrency: _selectedCurrency,
      onCurrencySelected: (currencyData) {
        setState(() {
          _selectedCurrency = currencyData.currencyCode;
          _selectedCountryCode = currencyData.countryCode;
        });
      },
    );
  }

  // --- Support Modal ---
  void _showSupportModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.support_agent, color: AppColors.primaryColor, size: 28),
                  const SizedBox(width: 12),
                  Text('Support', style: AppTextStyles.cabinBold18DarkBlue),
                ],
              ),
              const SizedBox(height: 16),
              Text('Need help? Contact us:', style: AppTextStyles.cabinRegular14MutedGray),
              const SizedBox(height: 16),
              _buildSupportContactRow(Icons.email_outlined, 'Info@hillcrestcapmgt.com', 'Email'),
              const SizedBox(height: 12),
              _buildSupportContactRow(Icons.phone_outlined, '08164218808', 'Phone number'),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSupportContactRow(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(value, style: AppTextStyles.cabinBold16DarkBlue
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 18),
          color: AppColors.primaryColor,
          tooltip: 'Copy',
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: value));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label copied')),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    final String firstName = authState.firstName?.trim().isNotEmpty == true
        ? authState.firstName!.trim()
        : "User";
    final String displayName = firstName;
    final String firstNameInitial = firstName.substring(0, 1).toUpperCase();

    ref.listen(authStateProvider.select((state) => state.hasCustomerNo), (
      previous,
      next,
    ) {
      if (ref.read(authStateProvider).isAuthenticated && next != true) {
        _checkOnboardingStatusAndShowModal();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.primaryColor,
          displacement: 20,
          child: SingleChildScrollView(
            // physics ensures scrollability even if content is short,
            // allowing the RefreshIndicator to trigger.
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. Top Navigation Bar ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.PADDING_24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        StringConst.home,
                        style: AppTextStyles.cabinBold24DarkBlue,
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.logout),
                            onPressed: _handleLogout,
                          ),
                          const SpaceW16(),
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.15),
                            child: Text(
                              firstNameInitial,
                              style: AppTextStyles.cabinBold24DarkBlue.copyWith(
                                fontSize: 14,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // --- 2. Welcome Section ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.PADDING_24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome, $displayName,",
                        style: AppTextStyles.cabinBold24DarkBlue.copyWith(
                          fontSize: 22,
                        ),
                      ),
                      const SpaceH4(),
                      GestureDetector(
                        onTap: () =>
                            context.router.push(const EditProfileRoute()),
                        child: Text(
                          StringConst.editProfile,
                          style: AppTextStyles.cabinRegular14Primary.copyWith(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SpaceH24(),
                _buildBalanceCard(),
                const SpaceH24(),
                _buildSectionHeader('Quick Actions'),
                const SpaceH16(),
                _buildQuickActionIcons(),
                const SpaceH24(),
                const HomeRecentTransactionsSection(),
                // const SpaceH32(),
                // _buildSectionHeader('AVAILABLE INVESTMENTS'),
                // const SpaceH16(),
                // _buildInvestmentCards(),
                const SpaceH24(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ... rest of the helper methods remain the same ...
    Widget _buildQuickActionIcons() {
    final actions = [
      {
        'name': 'Invest',
        'icon': Icons.trending_up_rounded,
        'onTap': () =>
            _runGatedAction(() => AutoTabsRouter.of(context).setActiveIndex(2)),
      },
      {
        'name': 'Support',
        'icon': Icons.support_agent,
        'onTap': _showSupportModal,
      },
      {
        'name': 'Redeem',
        'icon': Icons.redeem_rounded,
        'onTap': () =>
            _runGatedAction(() => AutoTabsRouter.of(context).setActiveIndex(1)),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
          border: Border.all(color: const Color(0xFFFFF5F0), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((item) {
            return GestureDetector(
              onTap: item['onTap'] as VoidCallback,
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF5F0),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        item['icon'] as IconData,
                        size: 24,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SpaceH8(),
                  Text(
                    item['name'] as String,
                    style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
    }

  Widget _buildBalanceCard() {
    final portfolioSummaryAsync = ref.watch(portfolioSummaryProvider);

    return portfolioSummaryAsync.when(
      data: (summary) {
        final String formattedValue =
            summary['formattedValue'] as String? ?? '₦0.00';
        final String formattedUnits =
            summary['formattedUnits'] as String? ?? '0';
        final int holdingCount = summary['holdingCount'] as int? ?? 0;

        return _buildPortfolioBalanceCardContent(
          formattedValue: formattedValue,
          formattedUnits: formattedUnits,
          holdingCount: holdingCount,
        );
      },
      loading: () => Container(
        margin: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
        height: 230,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
      error: (_, __) => _buildPortfolioBalanceCardContent(
        formattedValue: '₦0.00',
        formattedUnits: '0',
        holdingCount: 0,
      ),
    );
  }

  Widget _buildPortfolioBalanceCardContent({
    required String formattedValue,
    required String formattedUnits,
    required int holdingCount,
  }) {
    const String hiddenAmount = '**********';
    final String visibleValue = _isBalanceVisible
        ? formattedValue
        : '₦$hiddenAmount';
    final String visibleUnits = _isBalanceVisible
        ? formattedUnits
        : hiddenAmount;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
      height: 230,
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: CardPatternPainter())),
            Padding(
              padding: const EdgeInsets.all(Sizes.PADDING_20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'MY PORTFOLIO',
                        style: AppTextStyles.cabinRegular14White.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$holdingCount fund${holdingCount == 1 ? '' : 's'}',
                          style: AppTextStyles.cabinRegular14White.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(
                          () => _isBalanceVisible = !_isBalanceVisible,
                        ),
                        icon: Icon(
                          _isBalanceVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SpaceH8(),
                  Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Units Owned',
                                style: AppTextStyles.cabinRegular14White
                                    .copyWith(
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                              ),
                              const SpaceH4(),
                              Text(
                                visibleUnits,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.cabinBold24DarkBlue
                                    .copyWith(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SpaceW12(),
                      Flexible(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Portfolio Value',
                                style: AppTextStyles.cabinRegular14White
                                    .copyWith(
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                              ),
                              const SpaceH4(),
                              Text(
                                visibleValue,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.cabinBold24DarkBlue
                                    .copyWith(
                                      color: Colors.white,
                                      fontSize: 19,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    holdingCount == 0
                        ? 'Your portfolio is empty for now. Tap Invest below to start building wealth.'
                        : 'Tap Investment to view your holdings, track growth, and manage redemptions.',
                    style: AppTextStyles.cabinRegular14White.copyWith(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentCards() {
    final investments = [
      {'name': 'Investment A', 'minAmount': '15,000,000.00'},
      {'name': 'Investment B', 'minAmount': '10,000,000.00'},
    ];

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
        itemCount: investments.length,
        itemBuilder: (context, index) {
          final investment = investments[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(Sizes.PADDING_20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Min Investment',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SpaceH12(),
                  Text(
                    'N${investment['minAmount']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _showCurrencySelector,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 15,
                            child: CountryFlag.fromCountryCode(
                              _selectedCountryCode,
                            ),
                          ),
                          const SpaceW8(),
                          Text(
                            _selectedCurrency,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
      child: Text(
        title,
        style: AppTextStyles.cabinBold24DarkBlue.copyWith(fontSize: 14),
      ),
    );
  }
}

class CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(size.width * 0.4, 0);
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.4,
      size.width,
      size.height * 0.2,
    );
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
