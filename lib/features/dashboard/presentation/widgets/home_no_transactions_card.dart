import 'package:flutter/material.dart';
import 'package:hillcrest_finance/utils/constants/values.dart';

class HomeNoTransactionsCard extends StatelessWidget {
  const HomeNoTransactionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Sizes.RADIUS_12),
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor.withOpacity(0.08),
              AppColors.primaryColor.withOpacity(0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.18)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: AppColors.primaryColor,
                size: 24,
              ),
            ),
            const SpaceW12(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "You don't have any recent transactions",
                    style: AppTextStyles.cabinBold16DarkBlue,
                  ),
                  const SpaceH4(),
                  Text(
                    'Your latest investment activity will appear here.',
                    style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                      fontSize: 12,
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
}
