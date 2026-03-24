import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:hillcrest_finance/features/investment/presentation/providers/investment_providers.dart';
import 'package:hillcrest_finance/utils/constants/values.dart';

@RoutePage()
class PortfolioHoldingsScreen extends ConsumerStatefulWidget {
  const PortfolioHoldingsScreen({super.key});

  @override
  ConsumerState<PortfolioHoldingsScreen> createState() =>
      _PortfolioHoldingsScreenState();
}

class _PortfolioHoldingsScreenState
    extends ConsumerState<PortfolioHoldingsScreen> {
  int? _selectedHoldingIndex;
  late Map<int, int> _sellQuantities; // Track quantity for each holding

  @override
  void initState() {
    super.initState();
    _sellQuantities = {};
  }

  @override
  Widget build(BuildContext context) {
    final portfolioAsync = ref.watch(portfolioProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Portfolio'),
        elevation: 0,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.darkBlue,
      ),
      body: portfolioAsync.when(
        data: (portfolio) {
          if (portfolio.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: portfolio.length,
            itemBuilder: (context, index) {
              final holding = portfolio[index];
              _sellQuantities.putIfAbsent(index, () => 1);
              return _buildHoldingCard(holding, index, portfolio.length);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading portfolio:\n$error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(portfolioProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assessment, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'You haven\'t purchased any funds yet',
            style: AppTextStyles.cabinBold24DarkBlue.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Start investing below to build your portfolio',
            style: AppTextStyles.cabinRegular14MutedGray,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingCard(dynamic holding, int index, int totalHoldings) {
    final isSelected = _selectedHoldingIndex == index;
    final quantity = _sellQuantities[index] ?? 1;
    final maxQuantity = (holding.netUnits ?? 0).toInt();

    return GestureDetector(
      onTap: () =>
          setState(() => _selectedHoldingIndex = isSelected ? null : index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(Sizes.RADIUS_12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.lightGray.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        holding.schemeName ?? 'Unknown Fund',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cabinBold24DarkBlue.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Units: ${holding.getFormattedUnits()}',
                        style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      holding.getFormattedValue(),
                      style: AppTextStyles.cabinBold24DarkBlue.copyWith(
                        fontSize: 16,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₦${holding.currentBidPrice?.toStringAsFixed(2) ?? '0.00'}/unit',
                      style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Sell Section
            if (isSelected) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Sell Units',
                style: AppTextStyles.cabinBold24DarkBlue.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 12),
              // Quantity Selector
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightGray),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() {
                        if (quantity > 1) _sellQuantities[index] = quantity - 1;
                      }),
                      child: const Icon(Icons.remove, size: 20),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          quantity.toString(),
                          style: AppTextStyles.cabinBold24DarkBlue.copyWith(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        if (quantity < maxQuantity) {
                          _sellQuantities[index] = quantity + 1;
                        }
                      }),
                      child: const Icon(Icons.add, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Max: $maxQuantity units',
                style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              // Estimated Value
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Estimated Value:',
                      style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '₦${((holding.currentBidPrice ?? 0) * quantity).toStringAsFixed(2)}',
                      style: AppTextStyles.cabinBold24DarkBlue.copyWith(
                        fontSize: 14,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Sell Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => _onSellPressed(holding, quantity),
                  child: const Text(
                    'Confirm Sell',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onSellPressed(dynamic holding, int quantity) {
    // Show confirmation dialog before selling
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      title: 'Confirm Sale',
      desc:
          'Are you sure you want to sell $quantity units of ${holding.schemeName}?\n\nEstimated Value: ₦${((holding.currentBidPrice ?? 0) * quantity).toStringAsFixed(2)}',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        _executeSell(holding, quantity);
      },
      btnOkText: 'Confirm',
      btnCancelText: 'Cancel',
    ).show();
  }

  void _executeSell(dynamic holding, int quantity) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Call the sell provider and wait for result using .future
      final result = await ref.read(
        sellUnitsProvider((
          schemeId: holding.schemeId.toString(),
          units: quantity,
        )).future,
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show success dialog
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        title: 'Sale Successful',
        desc:
            'You have successfully sold $quantity units of ${holding.schemeName}.\n\nTransaction ID: ${result.transId}',
        btnOkOnPress: () {
          // Refresh the portfolio
          ref.refresh(portfolioProvider);
          if (mounted) {
            setState(() => _selectedHoldingIndex = null);
          }
        },
        btnOkText: 'Done',
      ).show();
    } catch (error) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error dialog
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Sale Failed',
        desc: 'Failed to sell units: $error',
        btnOkOnPress: () {},
        btnOkText: 'Retry',
      ).show();
    }
  }
}
