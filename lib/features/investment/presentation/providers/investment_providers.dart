import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hillcrest_finance/app/core/providers/networking_provider.dart';
import 'package:hillcrest_finance/app/core/providers/user_local_storage_provider.dart';
import '../../data/models/investment_scheme.dart';
import '../../data/models/investor_transaction.dart';
import '../../data/models/portfolio_holding.dart';

class UserPortfolioNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void addUnits(int units) {
    if (units <= 0) return;
    state = state + units;
  }

  void reset() => state = 0;
}

// Local optimistic portfolio unit balance for immediate UI updates after payment.
final userPortfolioProvider = NotifierProvider<UserPortfolioNotifier, int>(
  UserPortfolioNotifier.new,
);

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

String _formatAmount(double value) {
  final parts = value.toStringAsFixed(2).split('.');
  return '${_formatIntegerWithCommas(parts[0])}.${parts[1]}';
}

// Investment Schemes Provider (existing)
final investmentSchemesProvider =
    FutureProvider.autoDispose<List<InvestmentScheme>>((ref) async {
      ref.keepAlive();

      final repository = ref.read(investmentRepositoryProvider);
      return repository.getAllSchemes();
    });

// Scheme Name Map Provider - Creates a lookup map of schemeId -> schemeName
final schemeNameMapProvider = FutureProvider.autoDispose<Map<int, String>>((
  ref,
) async {
  try {
    final schemes = await ref.read(investmentSchemesProvider.future);

    // Create a map of schemeId -> schemeName
    final schemeMap = <int, String>{};
    for (final scheme in schemes) {
      if (scheme.schemeId != null && scheme.schemeName != null) {
        schemeMap[scheme.schemeId!] = scheme.schemeName!;
      }
    }

    print('[SCHEME_MAP] Created map with ${schemeMap.length} schemes');
    return schemeMap;
  } catch (e) {
    print('[SCHEME_MAP] Error creating scheme map: $e');
    return {};
  }
});

// Helper function to extract customerNo from KeycloakUser attributes
String? _extractCustomerNo(Map<String, dynamic>? attributes) {
  if (attributes == null) return null;

  // Try both 'customerNo' and 'CustomerNo' (case-insensitive)
  dynamic customerNoValue =
      attributes['customerNo'] ?? attributes['CustomerNo'];

  if (customerNoValue == null) return null;

  // Handle both List and String types
  if (customerNoValue is List && customerNoValue.isNotEmpty) {
    return customerNoValue.first.toString();
  } else if (customerNoValue is String) {
    return customerNoValue;
  }

  return null;
}

// Investor Transactions Provider (UPDATED - with better error handling)
// Investor Transactions Provider (ALTERNATIVE - fetches user directly)
final investorTransactionsProvider =
    FutureProvider.autoDispose<List<InvestorTransaction>>((ref) async {
      ref.keepAlive();

      print('\n[TRANSACTIONS] === FETCHING INVESTOR TRANSACTIONS ===');

      // Get auth repository to fetch fresh user data
      final authRepository = ref.read(authRepositoryProvider);
      final userLocalStorage = ref.read(userLocalStorageProvider);

      // Get username
      final username = userLocalStorage.getUsername();

      if (username == null) {
        print('[TRANSACTIONS] ❌ No username found');
        throw Exception('User not logged in');
      }

      print('[TRANSACTIONS] Username: $username');

      // Fetch user onboarding status (which includes user object and customerNo)
      final statusMap = await authRepository.getUserOnboardingStatus(username);
      final customerNo = statusMap['customerNo'] as String?;

      print('[TRANSACTIONS] Fetched customerNo: $customerNo');

      if (customerNo == null || customerNo.isEmpty) {
        print('[TRANSACTIONS] ❌ No customerNo found');
        throw Exception(
          'Customer number not available. Please complete your profile.',
        );
      }

      print('[TRANSACTIONS] ✅ Using customerNo: $customerNo');

      final repository = ref.read(investmentRepositoryProvider);
      final transactions = await repository.getInvestorTransactions(
        investorId: customerNo,
      );

      print('[TRANSACTIONS] ✅ Fetched ${transactions.length} transactions');
      print('[TRANSACTIONS] === FETCH COMPLETE ===\n');

      return transactions;
    });

// Buy Units Provider
final buyUnitsProvider =
    FutureProvider.family<InvestorTransaction, ({String schemeId, int units})>((
      ref,
      params,
    ) async {
      print('🛒 [BUY_UNITS_PROVIDER] Starting...');
      print('   Scheme ID: ${params.schemeId}');
      print('   Units: ${params.units}');

      try {
        final repository = ref.read(investmentRepositoryProvider);
        print('   ✅ Repository obtained');

        final userLocalStorage = ref.read(userLocalStorageProvider);
        print('   ✅ UserLocalStorage obtained');

        // Get customerNo from local storage
        final customerNo = userLocalStorage.getCustomerNo();
        print('   CustomerNo from storage: $customerNo');

        if (customerNo == null || customerNo.isEmpty) {
          print('   ❌ CustomerNo is null or empty');
          throw Exception(
            'Customer number not found. Please complete your profile.',
          );
        }

        print('   ✅ CustomerNo validated: $customerNo');
        print('   🔵 Calling repository.buyUnits...');

        final result = await repository.buyUnits(
          schemeId: params.schemeId,
          investorId: customerNo,
          transUnits: params.units,
        );

        print('   ✅ Purchase completed successfully');

        // Invalidate portfolio and transactions after successful buy
        ref.invalidate(portfolioProvider);
        ref.invalidate(portfolioSummaryProvider);
        ref.invalidate(investorTransactionsProvider);

        return result;
      } catch (e, stackTrace) {
        print('   ❌ [BUY_UNITS_PROVIDER] Error: $e');
        print('   Stack trace: $stackTrace');
        rethrow;
      }
    });

// Portfolio Provider - Fetches user's portfolio holdings
final portfolioProvider = FutureProvider.autoDispose<List<PortfolioHolding>>((
  ref,
) async {
  ref.keepAlive();

  print('\n[PORTFOLIO_PROVIDER] === FETCHING PORTFOLIO ===');

  final authRepository = ref.read(authRepositoryProvider);
  final userLocalStorage = ref.read(userLocalStorageProvider);
  final investmentRepository = ref.read(investmentRepositoryProvider);

  // Get username
  final username = userLocalStorage.getUsername();

  if (username == null) {
    print('[PORTFOLIO_PROVIDER] ❌ No username found');
    throw Exception('User not logged in');
  }

  print('[PORTFOLIO_PROVIDER] Username: $username');

  // Fetch user onboarding status to get customerNo
  final statusMap = await authRepository.getUserOnboardingStatus(username);
  final customerNo = statusMap['customerNo'] as String?;

  print('[PORTFOLIO_PROVIDER] Fetched customerNo: $customerNo');

  if (customerNo == null || customerNo.isEmpty) {
    print('[PORTFOLIO_PROVIDER] ❌ No customerNo found');
    return []; // Return empty list instead of throwing
  }

  print('[PORTFOLIO_PROVIDER] ✅ Using customerNo: $customerNo');

  final portfolio = await investmentRepository.getPortfolio(
    investorId: customerNo,
  );

  print('[PORTFOLIO_PROVIDER] ✅ Fetched ${portfolio.length} holdings');
  print('[PORTFOLIO_PROVIDER] === FETCH COMPLETE ===\n');

  return portfolio;
});

// Portfolio Summary Provider - Calculates total units and value
final portfolioSummaryProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
      final portfolio = await ref.read(portfolioProvider.future);

      double totalValue = 0;
      double totalUnits = 0;

      for (final holding in portfolio) {
        totalValue += holding.getTotalValue();
        totalUnits += holding.netUnits ?? 0;
      }

      return {
        'totalValue': totalValue,
        'totalUnits': totalUnits,
        'holdingCount': portfolio.length,
        'formattedValue': '₦${_formatAmount(totalValue)}',
        'formattedUnits': _formatIntegerWithCommas(
          totalUnits.toStringAsFixed(0),
        ),
      };
    });

// Sell Units Provider
final sellUnitsProvider =
    FutureProvider.family<InvestorTransaction, ({String schemeId, int units})>((
      ref,
      params,
    ) async {
      print('[SELL_PROVIDER] Starting sell...');
      print('   Scheme ID: ${params.schemeId}');
      print('   Units: ${params.units}');

      try {
        final repository = ref.read(investmentRepositoryProvider);
        final userLocalStorage = ref.read(userLocalStorageProvider);

        final customerNo = userLocalStorage.getCustomerNo();
        print('   CustomerNo: $customerNo');

        if (customerNo == null || customerNo.isEmpty) {
          throw Exception('Customer number not found');
        }

        final result = await repository.sellUnits(
          schemeId: params.schemeId,
          investorId: customerNo,
          transUnits: params.units,
        );

        // Invalidate portfolio and transactions after successful sell
        ref.invalidate(portfolioProvider);
        ref.invalidate(portfolioSummaryProvider);
        ref.invalidate(investorTransactionsProvider);

        print('[SELL_PROVIDER] ✅ Sale completed');
        return result;
      } catch (e) {
        print('[SELL_PROVIDER] ❌ Error: $e');
        rethrow;
      }
    });
