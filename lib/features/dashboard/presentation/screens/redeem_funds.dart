import 'package:auto_route/auto_route.dart'; // 🚀 Added AutoRoute import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hillcrest_finance/app/core/providers/networking_provider.dart';
import 'package:hillcrest_finance/app/core/providers/user_local_storage_provider.dart';
import 'package:hillcrest_finance/features/authentication/presentation/providers/auth_state_provider.dart';
import 'package:hillcrest_finance/features/dashboard/presentation/screens/onboarding_completion_modal.dart';
import 'package:hillcrest_finance/features/investment/data/models/portfolio_holding.dart';
import 'package:hillcrest_finance/features/investment/presentation/providers/investment_providers.dart';
import 'package:hillcrest_finance/utils/constants/values.dart';

@RoutePage()
class RedeemFundsScreen extends ConsumerStatefulWidget {
  const RedeemFundsScreen({super.key});

  @override
  ConsumerState<RedeemFundsScreen> createState() => _RedeemFundsScreenState();
}

class _RedeemFundsScreenState extends ConsumerState<RedeemFundsScreen> {
  void _runGatedRedeemAction(VoidCallback action) {
    final authState = ref.read(authStateProvider);
    if (authState.hasCustomerNo == true) {
      action();
    } else {
      _checkOnboardingStatusAndShowModal();
    }
  }

  String? _selectedFund;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _unitsController = TextEditingController();
  double _selectedFundAvailableAmount = 0;
  double _selectedFundAvailableUnits = 0;
  String? _amountValidationError;
  bool _redeemByNaira = true; // Toggle between Naira and Units

  @override
  void initState() {
    super.initState();
    // Removed auto-show KYC modal. Users can view the screen regardless of KYC status.
  }

  void _checkOnboardingStatusAndShowModal() {
    if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? false)) return;
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated || authState.hasCustomerNo == true) return;

    final accountType = authState.accountType ?? 'Individual';
    showOnboardingCompletionModal(
      context,
      accountType: accountType,
      onContinue: () {
        Navigator.of(context).pop();
        context.router.pushPath('/kyc/personal-info');
      },
    );
  }

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

  String _formatCurrency(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    return '₦${_formatIntegerWithCommas(parts[0])}.${parts[1]}';
  }

  double _parseAmount(String value) {
    final sanitized = value
        .replaceAll(',', '')
        .replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(sanitized) ?? 0;
  }

  void _formatAmountInput() {
    final amount = _parseAmount(_amountController.text);
    final formatted = _formatIntegerWithCommas(amount.toInt().toString());
    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _formatUnitsInput() {
    final units = _parseAmount(_unitsController.text);
    final formatted = _formatIntegerWithCommas(units.toInt().toString());
    _unitsController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _validateAmountAgainstAvailable() {
    if (_redeemByNaira) {
      final amount = _parseAmount(_amountController.text);
      if (_selectedFundAvailableAmount > 0 &&
          amount > _selectedFundAvailableAmount) {
        _amountValidationError =
            'Amount exceeds available balance for selected fund.';
        return;
      }
    } else {
      final units = _parseAmount(_unitsController.text);
      if (_selectedFundAvailableUnits > 0 &&
          units > _selectedFundAvailableUnits) {
        _amountValidationError =
            'Units exceed available units for selected fund.';
        return;
      }
    }
    _amountValidationError = null;
  }

  void _showSubmissionDialog(double amount) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Redemption Submitted',
          style: AppTextStyles.cabinBold18DarkBlue,
        ),
        content: Text(
          'Your redemption request for ${_formatCurrency(amount)} has been submitted successfully. Once confirmed, your bank account will be credited within the next 30 minutes.',
          style: AppTextStyles.cabinRegular14MutedGray.copyWith(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Done',
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _unitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final portfolioAsync = ref.watch(portfolioProvider);
    ref.watch(authStateProvider);
    final storage = ref.read(userLocalStorageProvider);
    final customerNo = (storage.getCustomerNo() ?? '').trim();
    final redeemBankInfoAsync = customerNo.isEmpty
        ? const AsyncValue.error('Missing customer number', StackTrace.empty)
        : ref.watch(redeemBankInfoProvider(customerNo));

    final portfolioFunds = portfolioAsync.maybeWhen(
      data: (holdings) => holdings
          .where((h) => (h.schemeName ?? '').trim().isNotEmpty)
          .map((h) => h.schemeName?.trim() ?? '')
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList(),
      orElse: () => <String>[],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => context.router.back(),
        ),
        title: Text('Redeem Funds', style: AppTextStyles.cabinBold18DarkBlue),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SpaceH16(),
              Text(
                'Redeem Mutual Funds',
                style: AppTextStyles.cabinBold24DarkBlue.copyWith(fontSize: 20),
              ),
              const SpaceH24(),

              // --- Fund Selector ---
              _buildLabel('Choose a fund to redeem from'),
              const SpaceH8(),
              _buildDropdownField(portfolioFunds),
              const SpaceH4(),
              Text(
                _selectedFund != null
                    ? 'Available for Redemption: ${_formatCurrency(_selectedFundAvailableAmount)}'
                    : 'Available for Redemption',
                style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                  fontSize: 12,
                ),
              ),

              const SpaceH24(),

              // --- Toggle Redeem By Naira/Units ---
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _redeemByNaira = true;
                          _amountValidationError = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _redeemByNaira
                              ? AppColors.primaryColor.withOpacity(0.1)
                              : Colors.white,
                          border: Border.all(color: AppColors.primaryColor),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Redeem by Naira',
                            style: TextStyle(
                              color: _redeemByNaira
                                  ? AppColors.primaryColor
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _redeemByNaira = false;
                          _amountValidationError = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_redeemByNaira
                              ? AppColors.primaryColor.withOpacity(0.1)
                              : Colors.white,
                          border: Border.all(color: AppColors.primaryColor),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Redeem by Units',
                            style: TextStyle(
                              color: !_redeemByNaira
                                  ? AppColors.primaryColor
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SpaceH16(),
              _buildLabel(
                _redeemByNaira
                    ? 'How much would you like to redeem? (₦)'
                    : 'How many units would you like to redeem?',
              ),
              const SpaceH8(),
              _redeemByNaira ? _buildAmountInput() : _buildUnitsInput(),
              if (_amountValidationError != null) ...[
                const SpaceH6(),
                Text(
                  _amountValidationError ?? '',
                  style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],

              const SpaceH24(),

              // --- Destination Bank Card ---
              _buildLabel('Funds would be credited to'),
              const SpaceH8(),
              redeemBankInfoAsync.when(
                data: (info) => _buildBankInfoCard(
                  accountName: info.accountName,
                  accountNumber: info.accountNumber,
                  bankName: info.bankName,
                ),
                loading: () => _buildBankInfoLoadingCard(),
                error: (error, _) => _buildBankInfoErrorCard(),
              ),

              const SpaceH32(),

              // --- Info Alert Box ---
              _buildInfoAlert(),

              const SpaceH40(),

              // --- Action Button ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _runGatedRedeemAction(() {
                    if ((_selectedFund ?? '').isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a fund to redeem.'),
                        ),
                      );
                      return;
                    }
                    double value = 0;
                    if (_redeemByNaira) {
                      value = _parseAmount(_amountController.text);
                      if (value <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please enter a valid redemption amount.',
                            ),
                          ),
                        );
                        return;
                      }
                    } else {
                      value = _parseAmount(_unitsController.text);
                      if (value <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please enter a valid number of units.',
                            ),
                          ),
                        );
                        return;
                      }
                    }
                    if (_amountValidationError != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_amountValidationError ?? '')),
                      );
                      return;
                    }
                    _showSubmissionDialog(value);
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Sizes.RADIUS_12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Confirm & Redeem',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SpaceH24(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.cabinRegular14MutedGray.copyWith(
        color: const Color(0xFF4F4F4F),
      ),
    );
  }

  Widget _buildDropdownField(List<String> funds) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sizes.RADIUS_8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFund,
          hint: Text(
            funds.isEmpty ? 'No portfolio fund available' : 'Choose Fund',
            style: AppTextStyles.cabinRegular14MutedGray,
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: funds
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: funds.isEmpty
              ? null
              : (val) {
                  setState(() {
                    _selectedFund = val;
                    final holdings = ref
                        .read(portfolioProvider)
                        .maybeWhen(
                          data: (data) => data,
                          orElse: () => <PortfolioHolding>[],
                        );

                    PortfolioHolding? selectedHolding;
                    for (final holding in holdings) {
                      if (holding.schemeName == val) {
                        selectedHolding = holding;
                        break;
                      }
                    }

                    _selectedFundAvailableAmount =
                        selectedHolding?.currentValue ?? 0;
                    _selectedFundAvailableUnits =
                        selectedHolding?.netUnits ?? 0;
                    _validateAmountAgainstAvailable();
                  });
                },
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sizes.RADIUS_8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          const Text(
            'N',
            style: TextStyle(color: Color(0xFF828282), fontSize: 16),
          ),
          const SpaceW8(),
          Expanded(
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              onChanged: (_) {
                setState(() {
                  _formatAmountInput();
                  _validateAmountAgainstAvailable();
                });
              },
              decoration: const InputDecoration(
                hintText: 'Enter Amount',
                border: InputBorder.none,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final fullAmount = _selectedFundAvailableAmount <= 0
                  ? 0
                  : _selectedFundAvailableAmount;
              setState(() {
                _amountController.text = _formatIntegerWithCommas(
                  fullAmount.toInt().toString(),
                );
                _validateAmountAgainstAvailable();
              });
            },
            child: Text(
              'Redeem Full Amount',
              style: AppTextStyles.cabinRegular14Primary.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitsInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sizes.RADIUS_8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          const Text(
            'Units',
            style: TextStyle(color: Color(0xFF828282), fontSize: 16),
          ),
          const SpaceW8(),
          Expanded(
            child: TextField(
              controller: _unitsController,
              keyboardType: TextInputType.number,
              onChanged: (_) {
                setState(() {
                  _formatUnitsInput();
                  _validateAmountAgainstAvailable();
                });
              },
              decoration: const InputDecoration(
                hintText: 'Enter Units',
                border: InputBorder.none,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final fullUnits = _selectedFundAvailableUnits <= 0
                  ? 0
                  : _selectedFundAvailableUnits;
              setState(() {
                _unitsController.text = _formatIntegerWithCommas(
                  fullUnits.toInt().toString(),
                );
                _validateAmountAgainstAvailable();
              });
            },
            child: Text(
              'Redeem All Units',
              style: AppTextStyles.cabinRegular14Primary.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankInfoCard({
    required String accountName,
    required String accountNumber,
    required String bankName,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sizes.RADIUS_8),
        border: Border.all(color: AppColors.primaryColor),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_outlined,
            color: Colors.black,
            size: 28,
          ),
          const SpaceW16(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accountName.toUpperCase(),
                  style: AppTextStyles.cabinBold16DarkBlue.copyWith(
                    fontSize: 14,
                  ),
                ),
                Text(
                  accountNumber,
                  style: AppTextStyles.cabinRegular14MutedGray,
                ),
                Text(bankName, style: AppTextStyles.cabinRegular14MutedGray),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankInfoLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sizes.RADIUS_8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: const [
          SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SpaceW12(),
          Text('Loading account details...'),
        ],
      ),
    );
  }

  Widget _buildBankInfoErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sizes.RADIUS_8),
        border: Border.all(color: Colors.red.shade200),
        color: Colors.red.shade50,
      ),
      child: Text(
        'Unable to load bank account details right now.',
        style: AppTextStyles.cabinRegular14MutedGray.copyWith(
          color: Colors.red.shade700,
        ),
      ),
    );
  }

  Widget _buildReviewRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTextStyles.cabinBold16DarkBlue
                : AppTextStyles.cabinRegular14MutedGray,
          ),
          Text(
            value,
            style: isTotal
                ? AppTextStyles.cabinBold16DarkBlue
                : AppTextStyles.cabinRegular14MutedGray.copyWith(
                    color: Colors.black,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F9F3), // Light green
        borderRadius: BorderRadius.circular(Sizes.RADIUS_12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info, color: Color(0xFF569B60), size: 20),
          const SpaceW12(),
          const Expanded(
            child: Text(
              'Orders placed before 12:00PM on a business day will be processed within the same day\'s NAV.',
              style: TextStyle(
                color: Color(0xFF569B60),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
