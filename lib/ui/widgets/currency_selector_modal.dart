import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import 'package:hillcrest_finance/utils/constants/values.dart';

class CurrencyData {
  final String countryName;
  final String countryCode;
  final String currencyCode;
  final String currencyName;

  CurrencyData({
    required this.countryName,
    required this.countryCode,
    required this.currencyCode,
    required this.currencyName,
  });
}

class CurrencySelectorModal extends StatelessWidget {
  final String selectedCurrency;
  final Function(CurrencyData) onCurrencySelected;

  const CurrencySelectorModal({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencySelected,
  });

  static final List<CurrencyData> _topCurrencies = [
    CurrencyData(
      countryName: 'United States',
      countryCode: 'us',
      currencyCode: 'USD',
      currencyName: 'US Dollar',
    ),
    CurrencyData(
      countryName: 'European Union',
      countryCode: 'eu',
      currencyCode: 'EUR',
      currencyName: 'Euro',
    ),
    CurrencyData(
      countryName: 'United Kingdom',
      countryCode: 'gb',
      currencyCode: 'GBP',
      currencyName: 'British Pound',
    ),
    CurrencyData(
      countryName: 'Japan',
      countryCode: 'jp',
      currencyCode: 'JPY',
      currencyName: 'Japanese Yen',
    ),
    CurrencyData(
      countryName: 'Switzerland',
      countryCode: 'ch',
      currencyCode: 'CHF',
      currencyName: 'Swiss Franc',
    ),
    CurrencyData(
      countryName: 'Canada',
      countryCode: 'ca',
      currencyCode: 'CAD',
      currencyName: 'Canadian Dollar',
    ),
    CurrencyData(
      countryName: 'Australia',
      countryCode: 'au',
      currencyCode: 'AUD',
      currencyName: 'Australian Dollar',
    ),
    CurrencyData(
      countryName: 'China',
      countryCode: 'cn',
      currencyCode: 'CNY',
      currencyName: 'Chinese Yuan',
    ),
    CurrencyData(
      countryName: 'Nigeria',
      countryCode: 'ng',
      currencyCode: 'NGN',
      currencyName: 'Nigerian Naira',
    ),
    CurrencyData(
      countryName: 'South Africa',
      countryCode: 'za',
      currencyCode: 'ZAR',
      currencyName: 'South African Rand',
    ),
    CurrencyData(
      countryName: 'India',
      countryCode: 'in',
      currencyCode: 'INR',
      currencyName: 'Indian Rupee',
    ),
    CurrencyData(
      countryName: 'Brazil',
      countryCode: 'br',
      currencyCode: 'BRL',
      currencyName: 'Brazilian Real',
    ),
    CurrencyData(
      countryName: 'Singapore',
      countryCode: 'sg',
      currencyCode: 'SGD',
      currencyName: 'Singapore Dollar',
    ),
    CurrencyData(
      countryName: 'Hong Kong',
      countryCode: 'hk',
      currencyCode: 'HKD',
      currencyName: 'Hong Kong Dollar',
    ),
    CurrencyData(
      countryName: 'South Korea',
      countryCode: 'kr',
      currencyCode: 'KRW',
      currencyName: 'South Korean Won',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Sizes.RADIUS_24),
          topRight: Radius.circular(Sizes.RADIUS_24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(Sizes.PADDING_24),
            child: Text(
              'Select Currency',
              style: AppTextStyles.cabinBold24DarkBlue,
            ),
          ),

          // Currency list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _topCurrencies.length,
              padding: const EdgeInsets.symmetric(horizontal: Sizes.PADDING_24),
              itemBuilder: (context, index) {
                final currency = _topCurrencies[index];
                final isSelected = currency.currencyCode == selectedCurrency;

                return InkWell(
                  onTap: () {
                    onCurrencySelected(currency);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryColor.withOpacity(0.1)
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(Sizes.RADIUS_12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColor
                            : AppColors.lightGray.withOpacity(0.5),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Country flag
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            width: 32,
                            height: 24,
                            child: CountryFlag.fromCountryCode(currency.countryCode),
                          ),
                        ),
                        const SpaceW16(),

                        // Country and currency info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currency.countryName,
                                style: AppTextStyles.cabinBold24DarkBlue.copyWith(
                                  fontSize: 16,
                                ),
                              ),
                              const SpaceH4(),
                              Text(
                                '${currency.currencyCode} - ${currency.currencyName}',
                                style: AppTextStyles.cabinRegular14MutedGray,
                              ),
                            ],
                          ),
                        ),

                        // Selected indicator
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primaryColor,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SpaceH24(),
        ],
      ),
    );
  }

  // Static method to show the modal
  static Future<void> show(
      BuildContext context, {
        required String selectedCurrency,
        required Function(CurrencyData) onCurrencySelected,
      }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CurrencySelectorModal(
        selectedCurrency: selectedCurrency,
        onCurrencySelected: onCurrencySelected,
      ),
    );
  }
}