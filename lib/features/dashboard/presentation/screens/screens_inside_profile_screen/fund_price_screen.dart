import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hillcrest_finance/utils/constants/values.dart';
import 'package:hillcrest_finance/features/investment/presentation/providers/investment_providers.dart';

/// Data model for the Fund Price List
class FundPriceModel {
  final String fundName;
  final String bidPrice;
  final String offerPrice;
  final bool isFlagged; // Represents the red asterisk in your screenshot

  FundPriceModel({
    required this.fundName,
    required this.bidPrice,
    required this.offerPrice,
    this.isFlagged = true,
  });
}

@RoutePage()
class FundPriceScreen extends ConsumerStatefulWidget {
  const FundPriceScreen({super.key});

  @override
  ConsumerState<FundPriceScreen> createState() => _FundPriceScreenState();
}

class _FundPriceScreenState extends ConsumerState<FundPriceScreen> {
  String _formatAmount(num value) {
    // Format with comma as thousand separator and two decimal places
    return value
        .toStringAsFixed(2)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  }

  @override
  Widget build(BuildContext context) {
    final schemesAsync = ref.watch(investmentSchemesProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
          onPressed: () => context.router.back(),
        ),
        title: Text(
          "Fund Price",
          style: AppTextStyles.cabinBold18DarkBlue.copyWith(
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: schemesAsync.when(
        data: (schemes) {
          final funds = schemes
              .map(
                (scheme) => FundPriceModel(
                  fundName: scheme.schemeName ?? '',
                  bidPrice: _formatAmount(scheme.bidPrice ?? 0),
                  offerPrice: _formatAmount(scheme.offerPrice ?? 0),
                  isFlagged: true,
                ),
              )
              .toList();
          return _buildContent(funds);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading funds')),
      ),
    );
  }

  Widget _buildContent(List<FundPriceModel> funds) {
    return SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
        itemCount: funds.length + 1, // +1 for the header
        separatorBuilder: (context, index) => index == 0
            ? const SizedBox.shrink()
            : const Divider(
                height: 32,
                thickness: 0.5,
                color: AppColors.lightGray,
              ),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildHeader();
          }
          final fund = funds[index - 1];
          return _buildFundItem(fund);
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Fund Price",
            style: AppTextStyles.cabinBold24DarkBlue.copyWith(
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Below is a list of funds",
            style: AppTextStyles.cabinRegular14MutedGray,
          ),
        ],
      ),
    );
  }

  Widget _buildFundItem(FundPriceModel fund) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fund Name with Asterisk
        Row(
          children: [
            Text(
              fund.fundName,
              style: AppTextStyles.cabinBold16DarkBlue.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (fund.isFlagged)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  "*",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Price Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bid Price Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bid Price",
                  style: AppTextStyles.cabinBold14DarkBlue.copyWith(
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₦${fund.bidPrice}',
                  style: AppTextStyles.cabinBold16DarkBlue.copyWith(
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            // Offer Price Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Offer Price",
                  style: AppTextStyles.cabinBold14DarkBlue.copyWith(
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₦${fund.offerPrice}',
                  style: AppTextStyles.cabinBold16DarkBlue.copyWith(
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
