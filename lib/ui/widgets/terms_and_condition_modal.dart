import 'package:flutter/material.dart';
import '../../../utils/constants/values.dart';

class TermsAndConditionModal extends StatelessWidget {
  final String title;
  final String content;

  const TermsAndConditionModal({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sizes.PADDING_24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(Sizes.RADIUS_20)),
      ),
      // Fixed: Removed invalid maxHeight parameter and used proper BoxConstraints
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.5,
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // Fixed: Changed 'between' to 'spaceBetween'
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.cabinBold18DarkBlue,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.mutedGray),
              ),
            ],
          ),
          const Divider(height: Sizes.PADDING_32),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(
                content,
                style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                  height: 1.6,
                ),
              ),
            ),
          ),
          const SpaceH24(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: Sizes.PADDING_16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Sizes.RADIUS_12),
                ),
              ),
              child: const Text(
                "Close",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}