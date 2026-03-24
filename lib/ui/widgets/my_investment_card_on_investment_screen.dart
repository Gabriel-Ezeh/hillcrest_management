import 'package:flutter/material.dart';
import 'package:hillcrest_finance/utils/constants/values.dart';

class MyInvestmentCard extends StatelessWidget {
  final String investmentType;
  final String investmentName;
  final String amount;
  final int totalUnits;
  final String interestInfo;
  final VoidCallback? onTap;
  final VoidCallback? onBuy;

  const MyInvestmentCard({
    super.key,
    required this.investmentType,
    required this.investmentName,
    required this.amount,
    required this.totalUnits,
    required this.interestInfo,
    this.onTap,
    this.onBuy,
  });

  String _formatIntegerWithCommas(String value) {
    if (value.isEmpty) return '0';
    final isNegative = value.startsWith('-');
    final digits = isNegative ? value.substring(1) : value;
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      final indexFromRight = digits.length - i;
      buffer.write(digits[i]);
      if (indexFromRight > 1 && indexFromRight % 3 == 1) {
        buffer.write(',');
      }
    }

    return isNegative ? '-$buffer' : buffer.toString();
  }

  String _formatAmount(String rawAmount) {
    final parsed = double.tryParse(rawAmount.replaceAll(',', '')) ?? 0;
    final parts = parsed.toStringAsFixed(2).split('.');
    return '${_formatIntegerWithCommas(parts[0])}.${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(Sizes.RADIUS_16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: 10,
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  ImagePath.transparentObjectOnMyInvestmentCard,
                  width: 120,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section with HIN badge and Buy/Sell buttons
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        investmentType,
                        style: AppTextStyles.cabinRegular14White.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Buy Button (Green)
                    GestureDetector(
                      onTap: onBuy,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50), // Green
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Subscribe',
                          style: AppTextStyles.cabinRegular14White.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SpaceH12(),
                Expanded(
                  child: Text(
                    investmentName,
                    style: AppTextStyles.cabinBold24DarkBlue.copyWith(
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SpaceH8(),
                Text(
                  '₦ ${_formatAmount(amount)}',
                  style: AppTextStyles.cabinBold24DarkBlue.copyWith(
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Units: $totalUnits',
                        style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      interestInfo,
                      style: AppTextStyles.cabinRegular14Primary.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
