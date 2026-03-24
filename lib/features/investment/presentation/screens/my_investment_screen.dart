import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hillcrest_finance/features/investment/presentation/providers/investment_providers.dart';
import 'package:hillcrest_finance/app/core/router/app_router.dart';
import 'package:hillcrest_finance/utils/constants/values.dart';

@RoutePage()
class MyInvestmentScreen extends ConsumerWidget {
  const MyInvestmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investmentSchemesAsync = ref.watch(investmentSchemesProvider);
    const String interestRateConstant = "12.8";

    return Scaffold(
      backgroundColor: const Color(
        0xFFF9F9F9,
      ), // Light background to make cards pop
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.darkBlue,
            size: 20,
          ),
          onPressed: () => context.router.pop(),
        ),
        title: Text("Investment", style: AppTextStyles.cabinBold20DarkBlue),
        centerTitle: false,
      ),
      body: investmentSchemesAsync.when(
        data: (investments) {
          if (investments.isEmpty) {
            return Center(
              child: Text(
                'No investments available',
                style: AppTextStyles.cabinRegular14MutedGray,
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SpaceH12(),
                // --- Section Header Text ---
                Text(
                  "We provide investment opportunities of specific products in the following areas:",
                  style: AppTextStyles.cabinRegular14DarkBlue.copyWith(
                    height: 1.5,
                  ),
                ),
                const SpaceH24(),

                // --- Investment Product List from API ---
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: investments.length,
                  itemBuilder: (context, index) {
                    final investment = investments[index];
                    final investmentName =
                        investment.schemeName ?? 'Unknown Investment';
                    final price = investment.offerPrice ?? 0.0;
                    final totalUnits = investment.totalUnits ?? 0.0;

                    return GestureDetector(
                      onTap: () {
                        print("Clicked $investmentName");
                      },
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
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            // --- Background Decorative Image ---
                            Positioned(
                              right: -10,
                              bottom: -10,
                              child: Opacity(
                                opacity: 0.1,
                                child: Image.asset(
                                  ImagePath.binaryVector,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Investment Name
                                            Text(
                                              investmentName,
                                              style: AppTextStyles
                                                  .cabinBold18DarkBlue
                                                  .copyWith(
                                                    height: 1.2,
                                                    letterSpacing: 0.5,
                                                  ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SpaceH8(),
                                            // Price
                                            Text(
                                              '₦${price.toStringAsFixed(2)}',
                                              style: AppTextStyles
                                                  .cabinBold16DarkBlue
                                                  .copyWith(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SpaceW12(),
                                      // Interest Rate Tag (Top Right)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor,
                                          borderRadius: BorderRadius.circular(
                                            Sizes.RADIUS_24,
                                          ),
                                        ),
                                        child: Text(
                                          '$interestRateConstant%',
                                          style: AppTextStyles.cabinBold12White,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SpaceH12(),

                                  // Description
                                  Text(
                                    "We recognize the need to encourage periodic installment investments of funds to meet specific future needs such as school fees/education and project needs of the investor.",
                                    style: AppTextStyles.cabinRegular14MutedGray
                                        .copyWith(height: 1.5),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SpaceH12(),

                                  // Total Units and Subscribe Button Row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Total Units (Left)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Total Units',
                                              style: AppTextStyles
                                                  .cabinRegular11mutedGray
                                                  .copyWith(
                                                    fontSize: 11,
                                                    color: AppColors.mutedGray,
                                                  ),
                                            ),
                                            const SpaceH4(),
                                            Text(
                                              totalUnits.toStringAsFixed(0),
                                              style: AppTextStyles
                                                  .cabinBold12White
                                                  .copyWith(
                                                    fontSize: 13,
                                                    color: AppColors.darkBlue,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Subscribe Button (Green)
                                      SizedBox(
                                        height: 32,
                                        width: 60,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            context.router.push(
                                              InvestNowRoute(
                                                scheme: investment,
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            padding: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                          child: const Text(
                                            'Subscribe',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SpaceH32(), // Bottom padding for scrollability
              ],
            ),
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SpaceH16(),
              Text(
                'Loading investments...',
                style: AppTextStyles.cabinRegular14MutedGray,
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Failed to load investments',
                style: AppTextStyles.cabinRegular14MutedGray,
              ),
              const SpaceH16(),
              ElevatedButton(
                onPressed: () {
                  ref.refresh(investmentSchemesProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
