import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hillcrest_finance/app/core/router/app_router.dart';
import 'package:hillcrest_finance/features/dashboard/presentation/widgets/home_no_transactions_card.dart';
import 'package:hillcrest_finance/features/investment/presentation/providers/investment_providers.dart';
import 'package:hillcrest_finance/utils/constants/values.dart';

class HomeRecentTransactionsSection extends ConsumerWidget {
  const HomeRecentTransactionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                'Recent Transactions',
                style: AppTextStyles.cabinBold24DarkBlue.copyWith(fontSize: 14),
              ),
              GestureDetector(
                onTap: () =>
                    context.router.push(const InvestorTransactionsRoute()),
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
              return const HomeNoTransactionsCard();
            }

            final schemeMapAsync = ref.watch(schemeNameMapProvider);
            return schemeMapAsync.when(
              data: (schemeMap) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayTransactions.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.PADDING_24,
                  ),
                  itemBuilder: (context, index) {
                    final transaction = displayTransactions[index];
                    final isCredit = transaction.isCredit();
                    final schemeName = transaction.schemeId != null
                        ? schemeMap[transaction.schemeId] ?? 'Unknown Fund'
                        : 'Unknown Fund';

                    String description = transaction
                        .getTransactionTypeDisplay();
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
                        border: Border.all(
                          color: AppColors.lightGray.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
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
                              isCredit
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: isCredit ? Colors.green : Colors.red,
                              size: 20,
                            ),
                          ),
                          const SpaceW12(),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.cabinBold24DarkBlue
                                      .copyWith(fontSize: 14),
                                ),
                                const SpaceH4(),
                                Text(
                                  transaction.transDate?.toString().split(
                                        ' ',
                                      )[0] ??
                                      'N/A',
                                  style: AppTextStyles.cabinRegular14MutedGray
                                      .copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            transaction.getFormattedAmount(),
                            style: AppTextStyles.cabinBold24DarkBlue.copyWith(
                              fontSize: 15,
                              color: isCredit ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => _errorContainer(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _errorContainer(),
        ),
      ],
    );
  }

  Widget _errorContainer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(Sizes.RADIUS_12),
        ),
        child: Center(
          child: Text(
            'Failed to load recent transactions',
            style: AppTextStyles.cabinRegular14MutedGray.copyWith(
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}
