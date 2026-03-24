import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hillcrest_finance/utils/constants/values.dart';

@RoutePage()
class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List of FAQ data for easy iteration
    final List<Map<String, String>> faqs = [
      {'q': StringConst.faqQ1, 'a': StringConst.faqA1},
      {'q': StringConst.faqQ2, 'a': StringConst.faqA2},
      {'q': StringConst.faqQ3, 'a': StringConst.faqA3},
      {'q': StringConst.faqQ4, 'a': StringConst.faqA4},
      {'q': StringConst.faqQ5, 'a': StringConst.faqA5},
      {'q': StringConst.faqQ6, 'a': StringConst.faqA6},
      {'q': StringConst.faqQ7, 'a': StringConst.faqA7},
      {'q': StringConst.faqQ8, 'a': StringConst.faqA8},
      {'q': StringConst.faqQ9, 'a': StringConst.faqA9},
      {'q': StringConst.faqQ10, 'a': StringConst.faqA10},
      {'q': StringConst.faqQ11, 'a': StringConst.faqA11},
      {'q': StringConst.faqQ12, 'a': StringConst.faqA12},
    ];

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 30),
          onPressed: () => context.router.back(),
        ),
        centerTitle: false,
        title: Text(
          StringConst.faqsTitle,
          style: AppTextStyles.cabinBold18DarkBlue,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SpaceH24(),
              Text(
                StringConst.frequentlyAskedQuestions,
                style: AppTextStyles.cabinBold20DarkBlue,
              ),
              const SpaceH32(),

              // FAQ List
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent, // Prevents ExpansionTile from showing its own internal borders
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: faqs.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: const EdgeInsets.only(bottom: 16.0),
                          iconColor: AppColors.darkBlue,
                          collapsedIconColor: AppColors.darkBlue,
                          title: Text(
                            faqs[index]['q']!,
                            style: AppTextStyles.interRegular14DarkBlue.copyWith(
                              // fontWeight: FontWeight.w600,
                            ),
                          ),
                          children: [
                            Text(
                              faqs[index]['a']!,
                              style: AppTextStyles.interRegular14HintGray.copyWith(
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                        // Divider added after the ExpansionTile
                        // It will move down automatically when the tile expands
                        Divider(
                          color: AppColors.lightGray.withOpacity(0.5),
                          thickness: 1,
                          height: 1,
                        ),
                        const SpaceH8(),
                      ],
                    );
                  },
                ),
              ),
              const SpaceH40(),
            ],
          ),
        ),
      ),
    );
  }
}