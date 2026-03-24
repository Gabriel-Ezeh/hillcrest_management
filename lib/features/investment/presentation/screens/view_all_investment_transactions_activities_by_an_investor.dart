import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hillcrest_finance/utils/constants/values.dart';
import '../../data/models/investor_transaction.dart';
import '../providers/investment_providers.dart';

@RoutePage()
class InvestorTransactionsScreen extends ConsumerStatefulWidget {
  const InvestorTransactionsScreen({super.key});

  @override
  ConsumerState<InvestorTransactionsScreen> createState() =>
      _InvestorTransactionsScreenState();
}

class _InvestorTransactionsScreenState
    extends ConsumerState<InvestorTransactionsScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(investorTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        elevation: 0,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.darkBlue,
      ),
      body: Column(
        children: [
          // Filter buttons - Updated with Debit/Credit options
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton('All'),
                  const SizedBox(width: 12),
                  _buildFilterButton('Credits'),
                  const SizedBox(width: 12),
                  _buildFilterButton('Debits'),
                  const SizedBox(width: 12),
                  _buildFilterButton('Buy'),
                  const SizedBox(width: 12),
                  _buildFilterButton('Sell'),
                ],
              ),
            ),
          ),
          // Transactions list
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                final filteredTransactions = _filterTransactions(transactions);

                if (filteredTransactions.isEmpty) {
                  return Center(
                    child: Text(
                      'No transactions found',
                      style: AppTextStyles.cabinRegular14MutedGray,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    return _buildTransactionTile(transaction);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              ),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading transactions',
                      style: AppTextStyles.cabinRegular14MutedGray,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.refresh(investorTransactionsProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<InvestorTransaction> _filterTransactions(
    List<InvestorTransaction> transactions,
  ) {
    switch (_selectedFilter) {
      case 'All':
        return transactions;
      case 'Credits':
        return transactions.where((t) => t.isCredit()).toList();
      case 'Debits':
        return transactions.where((t) => t.isDebit()).toList();
      case 'Buy':
        return transactions.where((t) => t.isBuy()).toList();
      case 'Sell':
        return transactions.where((t) => t.isSell()).toList();
      case 'Deposit':
        return transactions.where((t) => t.isDeposit()).toList();
      case 'Withdrawal':
        return transactions.where((t) => t.isWithdrawal()).toList();
      default:
        return transactions;
    }
  }

  Widget _buildFilterButton(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.lightGray,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: isSelected
              ? AppTextStyles.cabinBold12White
              : AppTextStyles.cabinRegular14DarkBlue,
        ),
      ),
    );
  }

  Widget _buildTransactionTile(InvestorTransaction transaction) {
    final isDebit = transaction.isDebit(); // Withdrawal or Buy
    final icon = isDebit ? Icons.arrow_downward : Icons.arrow_upward;
    final iconColor = isDebit ? Colors.red : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(Sizes.RADIUS_12),
        border: Border.all(color: AppColors.lightGray, width: 1),
      ),
      child: Row(
        children: [
          // Transaction icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.getTransactionTypeDisplay(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.interSemiBold14DarkBlue,
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.transDate?.toString().split(' ')[0] ?? 'N/A',
                  style: AppTextStyles.cabinRegular14MutedGray,
                ),
              ],
            ),
          ),
          // Amount
          Text(
            transaction.getFormattedAmount(),
            style: AppTextStyles.interSemiBold14DarkBlue.copyWith(
              color: iconColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
