import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hillcrest_finance/features/investment/presentation/providers/investment_providers.dart';
import 'package:intl/intl.dart';
import 'package:hillcrest_finance/utils/constants/values.dart';
import 'package:hillcrest_finance/ui/widgets/app_button.dart';
import 'package:hillcrest_finance/ui/widgets/forms/app_textfields.dart';

@RoutePage()
class GenerateAccountStatementScreen extends ConsumerStatefulWidget {
  const GenerateAccountStatementScreen({super.key});

  @override
  ConsumerState<GenerateAccountStatementScreen> createState() =>
      _GenerateAccountStatementScreenState();
}

class _GenerateAccountStatementScreenState
    extends ConsumerState<GenerateAccountStatementScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _fundController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void dispose() {
    _fundController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.white,
              onSurface: AppColors.darkBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _onGenerate() {
    if (_formKey.currentState!.validate()) {
      // Proceed with statement generation logic
      debugPrint("Generating statement for: ${_fundController.text}");
    }
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
          StringConst.generateStatement,
          style: AppTextStyles.cabinBold18DarkBlue,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SpaceH24(),
                Text(
                  StringConst.generateStatement,
                  style: AppTextStyles.cabinBold20DarkBlue,
                ),
                const SpaceH8(),
                Text(
                  StringConst.enterAccurateDetails,
                  style: AppTextStyles.interRegular14HintGray,
                ),
                const SpaceH32(),

                // Fund Selection Dropdown
                AppTextField(
                  label: StringConst.selectFunds,
                  type: AppTextFieldType.dropdown,
                  hintText: StringConst.selectFunds,
                  dropdownItems: fundOptions,
                  onDropdownChanged: (value) {
                    _fundController.text = value ?? "";
                  },
                  validator: (value) => (value == null || value.isEmpty)
                      ? StringConst.fieldRequiredError
                      : null,
                ),
                const SpaceH20(),

                // Start Date Field
                AppTextField(
                  label: StringConst.startDateLabel,
                  type: AppTextFieldType.date,
                  controller: _startDateController,
                  hintText: StringConst.dateHint,
                  readOnly: true,
                  onTap: () => _selectDate(_startDateController),
                  prefixIcon: const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.mutedGray,
                    size: 20,
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? StringConst.fieldRequiredError
                      : null,
                ),
                const SpaceH20(),

                // End Date Field
                AppTextField(
                  label: StringConst.endDateLabel,
                  type: AppTextFieldType.date,
                  controller: _endDateController,
                  hintText: StringConst.dateHint,
                  readOnly: true,
                  onTap: () => _selectDate(_endDateController),
                  prefixIcon: const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.mutedGray,
                    size: 20,
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? StringConst.fieldRequiredError
                      : null,
                ),

                const SpaceH40(),

                // Generate Button
                AppButton(
                  text: StringConst.generateButton,
                  onPressed: _onGenerate,
                ),
                const SpaceH24(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
