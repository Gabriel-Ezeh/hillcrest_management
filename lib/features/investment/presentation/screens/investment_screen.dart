import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:hillcrest_finance/app/core/router/app_router.dart';
import 'package:hillcrest_finance/features/authentication/presentation/providers/auth_state_provider.dart';
import 'package:hillcrest_finance/features/dashboard/presentation/screens/onboarding_completion_modal.dart';
import 'package:hillcrest_finance/features/investment/presentation/providers/investment_providers.dart';
import 'package:hillcrest_finance/features/investment/data/models/investment_scheme.dart';
import 'package:hillcrest_finance/ui/widgets/app_payment_modal.dart';
import 'package:hillcrest_finance/ui/widgets/my_investment_card_on_investment_screen.dart';

import 'package:hillcrest_finance/utils/constants/values.dart';

@RoutePage()
class InvestmentScreen extends ConsumerStatefulWidget {
  const InvestmentScreen({super.key});

  @override
  ConsumerState<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends ConsumerState<InvestmentScreen> {
  bool hasUnreadNotifications = true;

  Future<void> _onRefresh() async {
    ref.refresh(investmentSchemesProvider);
    ref.refresh(investorTransactionsProvider);
    ref.refresh(portfolioProvider);
    ref.refresh(portfolioSummaryProvider);
    await Future.wait([
      ref.read(investmentSchemesProvider.future),
      ref.read(investorTransactionsProvider.future),
      ref.read(portfolioProvider.future),
      ref.read(portfolioSummaryProvider.future),
    ]);
  }

  /// Gatekeeper function integrated with your Onboarding Modal flow
  void _runGatedAction(VoidCallback action) {
    final authState = ref.read(authStateProvider);

    if (authState.hasCustomerNo == true) {
      action();
    } else {
      _checkOnboardingStatusAndShowModal();
    }
  }

  /// Triggers the standardized onboarding modal based on current auth state
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
          _navigateToKYCFlow();
        },
      );
    }
  }

  /// Navigates to the specific KYC named route
  void _navigateToKYCFlow() {
    context.router.pushNamed('/kyc/personal-info');
  }

  @override
  Widget build(BuildContext context) {
    // Listen for state changes to auto-show modal if needed
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
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primaryColor,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(),
                const SpaceH24(),
                // _buildTotalInvestmentCard(),
                // const SpaceH32(),
                _buildPortfolioSummaryCard(),
                const SpaceH32(),
                _buildAvailableInvestmentSection(),
                const SpaceH32(),
                _buildInvestmentActivitiesSection(),
                const SpaceH24(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.PADDING_24,
        vertical: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Investment',
            style: AppTextStyles.cabinBold24DarkBlue.copyWith(fontSize: 20),
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  hasUnreadNotifications
                      ? Icons.notifications
                      : Icons.notifications_outlined,
                  color: AppColors.darkBlue,
                  size: 28,
                ),
                onPressed: () => setState(
                  () => hasUnreadNotifications = !hasUnreadNotifications,
                ),
              ),
              if (hasUnreadNotifications)
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalInvestmentCard() {
    const String totalBalance = "0.00";
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
      padding: const EdgeInsets.all(Sizes.PADDING_24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -10,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                ImagePath.objectOnTotalInvestmentBalanceCard,
                width: 150,
                height: 150,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SpaceH8(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₦',
                          style: AppTextStyles.cabinBold24DarkBlue.copyWith(
                            fontSize: 32,
                          ),
                        ),
                        const SpaceW4(),
                        Flexible(
                          child: Text(
                            totalBalance,
                            style: AppTextStyles.cabinBold24DarkBlue.copyWith(
                              fontSize: 32,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // GATED: Add Icon Button
                  GestureDetector(
                    onTap: () => _runGatedAction(() => _showPaymentModal()),
                    child: Image.asset(
                      ImagePath.redAddButton,
                      width: 48,
                      height: 48,
                    ),
                  ),
                ],
              ),
              const SpaceH8(),
              Text(
                'Total Investment balance',
                style: AppTextStyles.cabinRegular14MutedGray,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Portfolio Summary Card
  Widget _buildPortfolioSummaryCard() {
    final portfolioSummaryAsync = ref.watch(portfolioSummaryProvider);

    return portfolioSummaryAsync.when(
      data: (summary) {
        final holdingCount = summary['holdingCount'] as int;
        final totalValue = summary['formattedValue'] as String;
        final totalUnits = summary['formattedUnits'] as String;

        return GestureDetector(
          onTap: () => _runGatedAction(
            () => context.router.pushNamed('/portfolio/holdings'),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
            padding: const EdgeInsets.all(Sizes.PADDING_24),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MY PORTFOLIO',
                      style: AppTextStyles.cabinBold24DarkBlue.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$holdingCount fund${holdingCount != 1 ? 's' : ''}',
                        style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                          fontSize: 11,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SpaceH16(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Units Owned',
                      style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                        fontSize: 12,
                      ),
                    ),
                    const SpaceH4(),
                    Text(
                      totalUnits,
                      style: AppTextStyles.cabinBold24DarkBlue.copyWith(
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                const SpaceH12(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Portfolio Value',
                      style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                        fontSize: 12,
                      ),
                    ),
                    const SpaceH4(),
                    Text(
                      totalValue,
                      style: AppTextStyles.cabinBold24DarkBlue.copyWith(
                        fontSize: 24,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SpaceH16(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (holdingCount == 0)
                      Expanded(
                        child: Text(
                          'You haven\'t purchased any funds yet. Start investing below!',
                          style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: Text(
                          'Tap to view all your holdings',
                          style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (holdingCount > 0)
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppColors.primaryColor,
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        margin: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
        padding: const EdgeInsets.all(Sizes.PADDING_24),
        decoration: BoxDecoration(
          color: AppColors.lightGray.withOpacity(0.1),
          borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
        ),
        child: const SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Container(
        margin: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
        padding: const EdgeInsets.all(Sizes.PADDING_24),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
        ),
        child: Text(
          'Error loading portfolio',
          style: AppTextStyles.cabinRegular14MutedGray.copyWith(
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableInvestmentSection() {
    const interestRateConstant = 12.8;
    final investmentSchemesAsync = ref.watch(investmentSchemesProvider);

    return investmentSchemesAsync.when(
      data: (investments) {
        if (investments.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Sizes.PADDING_24,
                ),
                child: Text(
                  'Available Investment Products',
                  style: AppTextStyles.cabinBold24DarkBlue.copyWith(
                    fontSize: 18,
                  ),
                ),
              ),
              const SpaceH16(),
              SizedBox(
                height: 160,
                child: Center(
                  child: Text(
                    'No investments available',
                    style: AppTextStyles.cabinRegular14MutedGray,
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Investment Products',
                    style: AppTextStyles.cabinBold24DarkBlue.copyWith(
                      fontSize: 18,
                    ),
                  ),
                  // GATED: View All Text
                  GestureDetector(
                    onTap: () => _runGatedAction(
                      () => context.router.push(const MyInvestmentRoute()),
                    ),
                    child: Text(
                      'view all',
                      style: AppTextStyles.cabinRegular14Primary.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SpaceH16(),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: Sizes.PADDING_24,
                ),
                itemCount: investments.length,
                itemBuilder: (context, index) {
                  final investment = investments[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < investments.length - 1 ? 16 : 0,
                    ),
                    child: MyInvestmentCard(
                      investmentType: 'HIN',
                      investmentName: investment.schemeName ?? 'Unknown',
                      amount:
                          investment.offerPrice?.toStringAsFixed(2) ?? '0.00',
                      totalUnits: investment.totalUnits?.toInt() ?? 0,
                      interestInfo: '$interestRateConstant%',
                      // Navigate to InvestNowScreen when Subscribe is tapped
                      onTap: () => _runGatedAction(() {
                        context.router.push(InvestNowRoute(scheme: investment));
                      }),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
            child: Text(
              'My Investment',
              style: AppTextStyles.cabinBold24DarkBlue.copyWith(fontSize: 18),
            ),
          ),
          const SpaceH16(),
          const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      error: (error, stack) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
            child: Text(
              'My Investment',
              style: AppTextStyles.cabinBold24DarkBlue.copyWith(fontSize: 18),
            ),
          ),
          const SpaceH16(),
          SizedBox(
            height: 160,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load investments',
                    style: AppTextStyles.cabinRegular14MutedGray,
                  ),
                  const SpaceH8(),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(investmentSchemesProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentActivitiesSection() {
    final transactionsAsync = ref.watch(investorTransactionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Investment Activities',
                style: AppTextStyles.cabinBold24DarkBlue.copyWith(fontSize: 18),
              ),
              // GATED: View All Text
              GestureDetector(
                onTap: () => _runGatedAction(
                  () => context.router.push(const InvestorTransactionsRoute()),
                ),
                child: Text(
                  'view all',
                  style: AppTextStyles.cabinRegular14Primary.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SpaceH16(),
        transactionsAsync.when(
          data: (transactions) {
            final displayTransactions = transactions.take(4).toList();

            if (displayTransactions.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.symmetric(
                  horizontal: Sizes.PADDING_24,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightGray.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Sizes.RADIUS_12),
                ),
                child: Center(
                  child: Text(
                    'No activities yet',
                    style: AppTextStyles.cabinRegular14MutedGray,
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayTransactions.length,
              padding: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
              itemBuilder: (context, index) {
                final transaction = displayTransactions[index];
                return GestureDetector(
                  onTap: () => _runGatedAction(
                    () => print('Transaction tapped: ${transaction.transId}'),
                  ),
                  child: _buildTransactionTile(transaction),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Sizes.RADIUS_12),
            ),
            child: Column(
              children: [
                Text(
                  'Failed to load activities',
                  style: AppTextStyles.cabinRegular14MutedGray,
                ),
                const SpaceH8(),
                ElevatedButton(
                  onPressed: () => ref.invalidate(investorTransactionsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTile(dynamic transaction) {
    final isCredit = transaction.isCredit(); // Deposit or Sell
    final schemeMapAsync = ref.watch(schemeNameMapProvider);

    return schemeMapAsync.when(
      data: (schemeMap) {
        final schemeName = transaction.schemeId != null
            ? schemeMap[transaction.schemeId] ?? 'Unknown Fund'
            : 'Unknown Fund';

        // Build description: "Bought 3 units of STANBIC IBTC NIGERIAN EQUITY FUND"
        String description = transaction.getTransactionTypeDisplay();
        if ((transaction.isBuy() || transaction.isSell()) &&
            schemeName.isNotEmpty) {
          description =
              '${transaction.getTransactionTypeShort()} ${transaction.transUnits?.toStringAsFixed(0) ?? '0'} units\nof $schemeName';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(Sizes.RADIUS_12),
            border: Border.all(color: AppColors.lightGray.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCredit
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCredit ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isCredit ? Colors.green : Colors.red,
                  size: 20,
                ),
              ),
              const SpaceW12(),
              // Transaction details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cabinBold24DarkBlue.copyWith(
                        fontSize: 14,
                      ),
                    ),
                    const SpaceH4(),
                    Text(
                      transaction.transDate?.toString().split(' ')[0] ?? 'N/A',
                      style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Amount
              Text(
                transaction.getFormattedAmount(),
                style: AppTextStyles.cabinBold24DarkBlue.copyWith(
                  fontSize: 16,
                  color: isCredit ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(Sizes.RADIUS_12),
          border: Border.all(color: AppColors.lightGray.withOpacity(0.3)),
        ),
        child: const SizedBox(
          height: 40,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(Sizes.RADIUS_12),
          border: Border.all(color: AppColors.lightGray.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_downward, color: Colors.red, size: 20),
            ),
            const SpaceW12(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.getTransactionTypeDisplay(),
                    style: AppTextStyles.cabinBold24DarkBlue.copyWith(
                      fontSize: 14,
                    ),
                  ),
                  const SpaceH4(),
                  Text(
                    transaction.transDate?.toString().split(' ')[0] ?? 'N/A',
                    style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              transaction.getFormattedAmount(),
              style: AppTextStyles.cabinBold24DarkBlue.copyWith(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PaymentModal(
        title: 'Add Investment',
        onContinue: (amount) {
          Navigator.pop(context);
          _showSuccessDialog(amount);
        },
      ),
    );
  }

  void _showSuccessDialog(String amount) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      title: 'Success',
      desc: 'Investment of ₦$amount processed.',
      btnOkOnPress: () {},
    ).show();
  }

  void _showBuyDialog(String investmentName) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      title: 'Subscribe to $investmentName',
      desc:
          'Subscription functionality coming soon. You will be able to purchase units of this investment.',
      btnOkText: 'Got it',
      btnOkOnPress: () {},
    ).show();
  }

  void _showSellDialog(String investmentName) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      title: 'Sell $investmentName',
      desc:
          'Sell functionality coming soon. You will be able to sell units of this investment.',
      btnOkText: 'Got it',
      btnOkOnPress: () {},
    ).show();
  }
}
