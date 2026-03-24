import 'package:auto_route/auto_route.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hillcrest_finance/utils/constants/values.dart';
import 'package:intl/intl.dart';
import '../../data/models/investment_scheme.dart';

enum PurchaseInputMode { units, amount }

/// Model to pass into this screen when a user selects an investment
class InvestmentDetail {
  final String id;
  final String name;
  final double pricePerShare;

  InvestmentDetail({
    required this.id,
    required this.name,
    required this.pricePerShare,
  });
}

@RoutePage()
class InvestNowScreen extends ConsumerStatefulWidget {
  final InvestmentDetail? investment;
  final InvestmentScheme? scheme; // Pass the full scheme object

  const InvestNowScreen({super.key, this.investment, this.scheme});

  @override
  ConsumerState<InvestNowScreen> createState() => _InvestNowScreenState();
}

class _InvestNowScreenState extends ConsumerState<InvestNowScreen> {
  final TextEditingController _inputController = TextEditingController();
  PurchaseInputMode _inputMode = PurchaseInputMode.units;

  late String investmentName;
  late double unitPrice;
  late String schemeId;

  static const String _bankName = 'Hillcrest Finance Collection Account';
  static const String _bank = 'Wema Bank';
  static const String _accountNumber = '0134059287';

  @override
  void initState() {
    super.initState();

    if (widget.scheme != null) {
      investmentName = widget.scheme!.schemeName ?? "Investment Fund";
      unitPrice = widget.scheme!.offerPrice ?? 9508.93;
      schemeId = widget.scheme!.schemeId?.toString() ?? '';
    } else {
      investmentName = widget.investment?.name ?? "Hill Crest Balance Funds";
      unitPrice = widget.investment?.pricePerShare ?? 9508.93;
      schemeId = widget.investment?.id ?? '';
    }

    _inputController.addListener(() => setState(() {}));
  }

  int _parseUnits(String value) {
    final sanitized = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (sanitized.isEmpty) return 0;
    return int.tryParse(sanitized) ?? 0;
  }

  double _parseAmount(String value) {
    var sanitized = value
        .replaceAll(',', '')
        .replaceAll(RegExp(r'[^0-9.]'), '');
    if (sanitized.isEmpty) return 0;

    final firstDot = sanitized.indexOf('.');
    if (firstDot >= 0) {
      sanitized =
          sanitized.substring(0, firstDot + 1) +
          sanitized.substring(firstDot + 1).replaceAll('.', '');
    }

    return double.tryParse(sanitized) ?? 0;
  }

  int get _unitsToBuy {
    if (_inputMode == PurchaseInputMode.units) {
      return _parseUnits(_inputController.text);
    }
    return (_parseAmount(_inputController.text) / unitPrice).floor();
  }

  double get _enteredAmount {
    if (_inputMode == PurchaseInputMode.amount) {
      return _parseAmount(_inputController.text);
    }
    return _unitsToBuy * unitPrice;
  }

  double get _totalPayableAmount => _unitsToBuy * unitPrice;

  double get _leftOverAmount {
    if (_inputMode != PurchaseInputMode.amount) return 0;
    final balance = _enteredAmount - _totalPayableAmount;
    return balance > 0 ? balance : 0;
  }

  bool get _canProceed => _unitsToBuy > 0 && schemeId.isNotEmpty;

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
    final whole = _formatIntegerWithCommas(parts[0]);
    return '₦$whole.${parts[1]}';
  }

  String get _modeInsightText {
    if (_inputMode == PurchaseInputMode.units) {
      if (_unitsToBuy == 0) {
        return 'Enter units and we will compute your total payable amount.';
      }
      return '${_formatIntegerWithCommas(_unitsToBuy.toString())} unit${_unitsToBuy == 1 ? '' : 's'} × ${_formatCurrency(unitPrice)} = ${_formatCurrency(_totalPayableAmount)}';
    }

    if (_enteredAmount <= 0) {
      return 'Enter an amount and we will calculate how many whole units you can buy.';
    }

    if (_unitsToBuy == 0) {
      return 'This amount is below one unit price (${_formatCurrency(unitPrice)}).';
    }

    final baseText =
        '${_formatCurrency(_enteredAmount)} buys ${_formatIntegerWithCommas(_unitsToBuy.toString())} unit${_unitsToBuy == 1 ? '' : 's'} at ${_formatCurrency(unitPrice)} each.';

    if (_leftOverAmount > 0.009) {
      return '$baseText ${_formatCurrency(_leftOverAmount)} remains unallocated.';
    }

    return '$baseText Full amount will be used.';
  }

  void _setMode(PurchaseInputMode mode) {
    if (_inputMode == mode) return;
    setState(() {
      _inputMode = mode;
      _inputController.clear();
    });
  }

  void _onContinueToPayment() {
    if (_inputController.text.trim().isEmpty) {
      _showErrorDialog(
        _inputMode == PurchaseInputMode.units
            ? 'Please enter how many units you want to buy.'
            : 'Please enter the amount you want to invest.',
      );
      return;
    }

    if (_inputMode == PurchaseInputMode.amount && _enteredAmount < unitPrice) {
      _showErrorDialog(
        'The entered amount is below one unit. Minimum for one unit is ${_formatCurrency(unitPrice)}.',
      );
      return;
    }

    if (!_canProceed) {
      _showErrorDialog('Please enter a valid purchase value to continue.');
      return;
    }

    _showPaymentMethodDialog();
  }

  void _showPaymentMethodDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SpaceH16(),
              Text(
                'Choose Payment Method',
                style: AppTextStyles.cabinBold20DarkBlue,
              ),
              const SizedBox(height: 6),
              Text(
                'Complete your ${_formatIntegerWithCommas(_unitsToBuy.toString())} units purchase (${_formatCurrency(_totalPayableAmount)}).',
                textAlign: TextAlign.center,
                style: AppTextStyles.cabinRegular14MutedGray,
              ),
              const SpaceH20(),
              _buildPaymentMethodTile(
                icon: Icons.account_balance_rounded,
                title: 'Bank Transfer',
                subtitle: 'Get account details and transfer instantly',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showBankTransferDialog();
                },
              ),
              const SpaceH12(),
              _buildPaymentMethodTile(
                icon: Icons.credit_card_rounded,
                title: 'Card Payment',
                subtitle: 'Pay securely with your debit card',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showCardComingSoonDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.lightGray.withOpacity(0.7)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryColor),
            ),
            const SpaceW12(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.cabinBold16DarkBlue),
                  const SpaceH2(),
                  Text(subtitle, style: AppTextStyles.cabinRegular14MutedGray),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.mutedGray),
          ],
        ),
      ),
    );
  }

  void _showCardComingSoonDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.credit_card_rounded,
              color: AppColors.primaryColor,
            ),
            const SpaceW8(),
            Text('Card Payments', style: AppTextStyles.cabinBold18DarkBlue),
          ],
        ),
        content: Text(
          'Card payment is coming soon. For now, kindly use bank transfer to complete your investment.',
          style: AppTextStyles.cabinRegular14MutedGray,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Got it',
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showBankTransferDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_rounded,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Bank Transfer Details',
                style: AppTextStyles.cabinBold18DarkBlue,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transfer ${_formatCurrency(_totalPayableAmount)} for ${_formatIntegerWithCommas(_unitsToBuy.toString())} unit${_unitsToBuy == 1 ? '' : 's'} to the account below.',
              style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                height: 1.45,
              ),
            ),
            const SpaceH16(),
            _buildTransferDetail(label: 'Account Name', value: _bankName),
            const SpaceH8(),
            _buildTransferDetail(label: 'Bank', value: _bank),
            const SpaceH8(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.brandSoftGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Number',
                          style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                            fontSize: 12,
                          ),
                        ),
                        const SpaceH4(),
                        Text(
                          _accountNumber,
                          style: AppTextStyles.cabinBold20DarkBlue.copyWith(
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await Clipboard.setData(
                        const ClipboardData(text: _accountNumber),
                      );
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Account number copied')),
                      );
                    },
                    icon: const Icon(
                      Icons.copy_rounded,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.mutedGray),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showTransferConfirmationDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'I Already Sent The Money',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferDetail({required String label, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.brandSoftGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.cabinRegular14MutedGray.copyWith(fontSize: 12),
          ),
          const SpaceH4(),
          Text(value, style: AppTextStyles.cabinBold16DarkBlue),
        ],
      ),
    );
  }

  void _showTransferConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.green),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Transfer Submitted',
                style: AppTextStyles.cabinBold18DarkBlue,
              ),
            ),
          ],
        ),
        content: Text(
          'Your transfer confirmation has been received for ${_formatCurrency(_totalPayableAmount)}. Once verified, your ${_formatIntegerWithCommas(_unitsToBuy.toString())} unit${_unitsToBuy == 1 ? '' : 's'} will be credited within the next 30 minutes.',
          style: AppTextStyles.cabinRegular14MutedGray.copyWith(height: 1.45),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              _inputController.clear();
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, color: Colors.red),
            ),
            const SpaceW8(),
            Text('Please Check', style: AppTextStyles.cabinBold18DarkBlue),
          ],
        ),
        content: Text(message, style: AppTextStyles.cabinRegular14MutedGray),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Okay',
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.cabinRegular14MutedGray),
          Text(
            value,
            style: AppTextStyles.cabinBold16DarkBlue.copyWith(
              color: highlight ? AppColors.primaryColor : AppColors.darkBlue,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: AppColors.darkBlue,
            size: 28,
          ),
          onPressed: () => context.router.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SpaceH12(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.darkBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invest Now',
                    style: AppTextStyles.cabinBold24DarkBlue.copyWith(
                      color: Colors.white,
                      fontSize: 26,
                    ),
                  ),
                  const SpaceH8(),
                  Text(
                    investmentName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cabinRegular14White.copyWith(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Price Per Unit',
                            style: AppTextStyles.cabinRegular14White.copyWith(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                          const SpaceH2(),
                          Text(
                            _formatCurrency(unitPrice),
                            style: AppTextStyles.cabinBold20DarkBlue.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Estimated Units',
                            style: AppTextStyles.cabinRegular14White.copyWith(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                          const SpaceH2(),
                          Text(
                            _formatIntegerWithCommas(_unitsToBuy.toString()),
                            style: AppTextStyles.cabinBold20DarkBlue.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SpaceH24(),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.lightGray.withOpacity(0.6)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _setMode(PurchaseInputMode.units),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _inputMode == PurchaseInputMode.units
                              ? AppColors.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Buy by Units',
                            style: AppTextStyles.cabinBold14DarkBlue.copyWith(
                              color: _inputMode == PurchaseInputMode.units
                                  ? Colors.white
                                  : AppColors.darkBlue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _setMode(PurchaseInputMode.amount),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _inputMode == PurchaseInputMode.amount
                              ? AppColors.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Buy by Amount',
                            style: AppTextStyles.cabinBold14DarkBlue.copyWith(
                              color: _inputMode == PurchaseInputMode.amount
                                  ? Colors.white
                                  : AppColors.darkBlue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _inputMode == PurchaseInputMode.units
                  ? 'How many units do you want to buy?'
                  : 'How much do you want to invest (₦)?',
              style: AppTextStyles.cabinBold14DarkBlue,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightGray.withOpacity(0.6)),
              ),
              child: Row(
                children: [
                  Icon(
                    _inputMode == PurchaseInputMode.units
                        ? Icons.tag_rounded
                        : Icons.account_balance_wallet_rounded,
                    color: AppColors.primaryColor,
                  ),
                  const SpaceW12(),
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: _inputMode == PurchaseInputMode.amount,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ThousandsSeparatorInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        hintText: _inputMode == PurchaseInputMode.units
                            ? 'e.g. 25 units'
                            : 'e.g. 200,000',
                        hintStyle: AppTextStyles.cabinRegular14MutedGray,
                        border: InputBorder.none,
                      ),
                      style: AppTextStyles.cabinBold20DarkBlue.copyWith(
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ),
                  if (_inputMode == PurchaseInputMode.amount)
                    Text(
                      'NGN',
                      style: AppTextStyles.cabinBold14DarkBlue.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _modeInsightText,
              style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightGray.withOpacity(0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Purchase Summary',
                    style: AppTextStyles.cabinBold16DarkBlue,
                  ),
                  const SpaceH8(),
                  if (_inputMode == PurchaseInputMode.amount)
                    _buildSummaryRow(
                      label: 'Entered Amount',
                      value: _formatCurrency(_enteredAmount),
                    ),
                  _buildSummaryRow(
                    label: 'Units to Buy',
                    value: _formatIntegerWithCommas(_unitsToBuy.toString()),
                  ),
                  _buildSummaryRow(
                    label: 'Price Per Unit',
                    value: _formatCurrency(unitPrice),
                  ),
                  _buildSummaryRow(
                    label: 'Total Payable',
                    value: _formatCurrency(_totalPayableAmount),
                    highlight: true,
                  ),
                  if (_inputMode == PurchaseInputMode.amount &&
                      _leftOverAmount > 0.009)
                    _buildSummaryRow(
                      label: 'Unallocated Balance',
                      value: _formatCurrency(_leftOverAmount),
                    ),
                  const SpaceH8(),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.brandSoftGray,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _inputMode == PurchaseInputMode.units
                          ? 'You are buying by units. Total payable is computed automatically.'
                          : 'You are buying by amount. We calculate the highest whole units this amount can purchase at ${_formatCurrency(unitPrice)} per unit.',
                      style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 10, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _canProceed ? _onContinueToPayment : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    disabledBackgroundColor: AppColors.primaryColor.withOpacity(
                      0.45,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _canProceed
                        ? 'Continue to Payment • ${_formatCurrency(_totalPayableAmount)}'
                        : 'Enter Purchase Details',
                    style: AppTextStyles.cabinBold16DarkBlue.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              _canProceed
                  ? 'You will receive ${_formatIntegerWithCommas(_unitsToBuy.toString())} unit${_unitsToBuy == 1 ? '' : 's'} after payment confirmation.'
                  : 'Enter a valid unit count or amount to continue.',
              style: AppTextStyles.cabinRegular14MutedGray.copyWith(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String sanitized = newValue.text.replaceAll(',', '');
    List<String> parts = sanitized.split('.');
    String wholePart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    if (wholePart.isEmpty && decimalPart != null) {
      wholePart = '0';
    } else if (wholePart.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final formatter = NumberFormat('#,###');
    String formattedWhole;
    try {
      formattedWhole = formatter.format(int.parse(wholePart));
    } catch (e) {
      formattedWhole = wholePart;
    }

    String formatted =
        formattedWhole + (decimalPart != null ? '.$decimalPart' : '');

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
