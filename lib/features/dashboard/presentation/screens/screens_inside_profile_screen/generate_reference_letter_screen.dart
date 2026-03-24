import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hillcrest_finance/features/investment/presentation/providers/investment_providers.dart';
import 'package:hillcrest_finance/utils/constants/values.dart';
import 'package:hillcrest_finance/ui/widgets/app_button.dart';
import 'package:hillcrest_finance/ui/widgets/forms/app_textfields.dart';
import 'package:hillcrest_finance/ui/widgets/currency_selector_modal.dart';

@RoutePage()
class GenerateReferenceLetterScreen extends ConsumerStatefulWidget {
  const GenerateReferenceLetterScreen({super.key});

  @override
  ConsumerState<GenerateReferenceLetterScreen> createState() =>
      _GenerateReferenceLetterScreenState();
}

class _GenerateReferenceLetterScreenState
    extends ConsumerState<GenerateReferenceLetterScreen> {
  bool _hasAcceptedReview = false;
  String _selectedCurrency = "NGN"; // Default currency code
  String? _selectedFund;

  // Controllers for text fields
  final TextEditingController _recipientNameController =
      TextEditingController();
  final TextEditingController _recipientAddressController =
      TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController(
    text: "NGN",
  );

  @override
  void dispose() {
    _recipientNameController.dispose();
    _recipientAddressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  void _showCurrencyPicker() {
    CurrencySelectorModal.show(
      context,
      selectedCurrency: _selectedCurrency,
      onCurrencySelected: (CurrencyData data) {
        setState(() {
          _selectedCurrency = data.currencyCode;
          _currencyController.text =
              "${data.currencyCode} - ${data.currencyName}";
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final investmentSchemesAsync = ref.watch(investmentSchemesProvider);
    final fundOptions = investmentSchemesAsync.maybeWhen(
      data: (schemes) => schemes
          .map((scheme) => (scheme.schemeName ?? '').trim())
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList(),
      orElse: () => <String>[],
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 30),
          onPressed: () => context.router.back(),
        ),
        centerTitle: true,
        title: Text(
          StringConst.generateReferenceLetter,
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
                StringConst.generateReferenceLetter,
                style: AppTextStyles.cabinBold20DarkBlue,
              ),
              const SpaceH32(),

              // --- Form Fields ---

              // Fund Selection Dropdown
              AppTextField(
                label: StringConst.enterAccurateDetails,
                type: AppTextFieldType.dropdown,
                hintText: StringConst.selectFundsHint,
                dropdownItems: fundOptions,
                onDropdownChanged: (val) => setState(() => _selectedFund = val),
                initialDropdownValue: _selectedFund,
              ),
              const SpaceH20(),

              AppTextField(
                label: StringConst.recipientNameLabel,
                type: AppTextFieldType.text,
                controller: _recipientNameController,
                hintText: StringConst.enterHereHint,
              ),
              const SpaceH20(),

              AppTextField(
                label: StringConst.recipientAddressLabel,
                type: AppTextFieldType.address,
                controller: _recipientAddressController,
                hintText: StringConst.enterHereHint,
              ),
              const SpaceH20(),

              AppTextField(
                label: StringConst.cityLabel,
                type: AppTextFieldType.text,
                controller: _cityController,
                hintText: StringConst.enterHereHint,
              ),
              const SpaceH20(),

              // State Dropdown
              AppTextField(
                label: StringConst.stateLabel,
                type: AppTextFieldType.dropdown,
                hintText: StringConst.stateLabel,
                dropdownItems: const ["Lagos", "Abuja", "Rivers"],
                onDropdownChanged: (val) {},
              ),
              const SpaceH20(),

              // Country Dropdown
              AppTextField(
                label: StringConst.countryLabel,
                type: AppTextFieldType.dropdown,
                hintText: StringConst.countryLabel,
                dropdownItems: const [
                  "Nigeria",
                  "United Kingdom",
                  "United States",
                ],
                onDropdownChanged: (val) {},
              ),
              const SpaceH20(),

              // Currency Field (Triggers your custom Modal)
              AppTextField(
                label: StringConst.currencyLabel,
                type: AppTextFieldType.text,
                controller: _currencyController,
                readOnly: true,
                onTap: _showCurrencyPicker,
                hintText: StringConst.currencyLabel,
                suffixIcon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.mutedGray,
                ),
              ),
              const SpaceH20(),

              AppTextField(
                label: StringConst.postalCodeLabel,
                type: AppTextFieldType.text,
                controller: _postalCodeController,
                hintText: StringConst.enterHereHint,
                keyboardType: TextInputType.number,
              ),
              const SpaceH32(),

              // --- Checkbox Section ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _hasAcceptedReview,
                      activeColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _hasAcceptedReview = value ?? false;
                        });
                      },
                    ),
                  ),
                  const SpaceW12(),
                  Expanded(
                    child: Text(
                      StringConst.reviewCheckboxText,
                      style: AppTextStyles.cabinRegular14DarkBlue,
                    ),
                  ),
                ],
              ),

              const SpaceH32(),

              // --- Generate Button ---
              AppButton(
                text: StringConst.generateButton,
                onPressed: _hasAcceptedReview
                    ? () {
                        // Logic for generating the letter
                      }
                    : null,
              ),
              const SpaceH40(),
            ],
          ),
        ),
      ),
    );
  }
}
