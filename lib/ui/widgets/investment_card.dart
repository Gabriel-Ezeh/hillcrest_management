import 'package:flutter/material.dart';
import 'package:hillcrest_finance/utils/constants/values.dart';

class InvestmentCard extends StatelessWidget {
  final String title;
  final String tag;
  final String description;
  final VoidCallback onTap;

  const InvestmentCard({
    super.key,
    required this.title,
    required this.tag,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: Sizes.MARGIN_16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(Sizes.RADIUS_12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias, // Ensures background image doesn't bleed out
        child: Stack(
          children: [
            // --- Background Decorative Image (binaryVector) ---
            Positioned(
              right: -10,
              bottom: -10,
              child: Opacity(
                opacity: 0.1, // Subtle watermark effect
                child: Image.asset(
                  ImagePath.binaryVector, // As specified in prompt
                  height: 120,
                  width: 120,
                ),
              ),
            ),

            // --- Content ---
            Padding(
              padding: const EdgeInsets.all(Sizes.PADDING_20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row with Title and Tag
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.cabinBold18DarkBlue.copyWith(
                            height: 1.2,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SpaceW12(),
                      // The tag/button indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(Sizes.RADIUS_24),
                        ),
                        child: Text(
                          tag,
                          style: AppTextStyles.cabinBold12White,
                        ),
                      ),
                    ],
                  ),
                  const SpaceH12(),
                  // Description
                  Text(
                    description,
                    style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                      height: 1.5,
                    ),
                    maxLines: 6, // Matches the truncated look in design
                    overflow: TextOverflow.ellipsis,
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