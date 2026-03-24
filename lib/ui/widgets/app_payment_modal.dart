import 'package:flutter/material.dart';
import 'package:hillcrest_finance/ui/widgets/app_button.dart';
import 'package:hillcrest_finance/ui/widgets/forms/app_textfields.dart';
import 'package:hillcrest_finance/utils/constants/values.dart';

class PaymentModal extends StatefulWidget {
  final String title;
  final Function(String amount) onContinue;

  const PaymentModal({
    super.key,
    required this.title,
    required this.onContinue,
  });

  @override
  State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  final TextEditingController _amountController = TextEditingController();

  // Predefined figures to show below the text field
  final List<String> _quickAmounts = [
    "100,000",
    "200,000",
    "300,000",
    "400,000",
    "500,000",
    "1,000,000",
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// Updates the controller when a quick-amount chip is tapped
  void _selectAmount(String amount) {
    setState(() {
      // We remove commas for the raw input value
      _amountController.text = amount.replaceAll(',', '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: Sizes.PADDING_20,
        right: Sizes.PADDING_20,
        top: Sizes.PADDING_16,
        // Ensures the modal lifts up when the keyboard appears
        bottom: MediaQuery.of(context).viewInsets.bottom + Sizes.PADDING_32,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(Sizes.RADIUS_20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: AppTextStyles.cabinBold18DarkBlue,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: AppColors.white, size: 14),
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.brandSoftGray),
          const SpaceH20(),

          // The Amount Field (Using your AppTextField)
          AppTextField(
            label: StringConst.amountLabel,
            type: AppTextFieldType.text, // Fixed the missing 'type' error here
            controller: _amountController,
            hintText: StringConst.amountHint,
            keyboardType: TextInputType.number,
            prefixIcon: const Padding(
              padding: EdgeInsets.only(top: 14.0, left: 16.0),
              child: Text(
                "₦",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
            ),
          ),
          const SpaceH16(),

          // Quick Selection Figures
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: _quickAmounts.map((amount) {
              return InkWell(
                onTap: () => _selectAmount(amount),
                borderRadius: BorderRadius.circular(Sizes.RADIUS_20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Sizes.RADIUS_20),
                    border: Border.all(color: AppColors.lightGray.withOpacity(0.6)),
                  ),
                  child: Text(
                    "₦$amount",
                    style: AppTextStyles.interRegular14DarkBlue.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SpaceH32(),

          // Constant Action Button
          AppButton(
            text: StringConst.continueToPayment,
            onPressed: () {
              if (_amountController.text.isNotEmpty) {
                widget.onContinue(_amountController.text);
              }
            },
          ),
        ],
      ),
    );
  }
}