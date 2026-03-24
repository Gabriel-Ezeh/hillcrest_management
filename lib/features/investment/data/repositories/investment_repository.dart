import '../models/investment_scheme.dart';
import '../models/investor_transaction.dart';
import '../models/buy_units_request.dart';
import '../models/portfolio_holding.dart';
import '../sources/investment_api_client.dart';

class InvestmentRepository {
  final InvestmentApiClient _apiClient;

  // Cache to store the fetched schemes
  List<InvestmentScheme>? _cachedSchemes;
  DateTime? _lastFetchTime;

  // Cache to store the fetched transactions
  List<InvestorTransaction>? _cachedTransactions;
  DateTime? _lastTransactionFetchTime;

  // Cache duration (5 minutes)
  static const _cacheDuration = Duration(minutes: 5);

  InvestmentRepository(this._apiClient);

  Future<List<InvestmentScheme>> getAllSchemes({bool forceRefresh = false}) async {
    // Return cached data if available and not expired
    if (!forceRefresh &&
        _cachedSchemes != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      print('🟢 Returning cached schemes (${_cachedSchemes!.length} items)');
      return _cachedSchemes!;
    }

    try {
      print('🔵 Fetching schemes from API...');
      final schemes = await _apiClient.getAllSchemes();

      // Filter out invalid schemes and take only first 4 valid ones
      final validSchemes = schemes.where((scheme) {
        return scheme.schemeName != null &&
            scheme.offerPrice != null &&
            scheme.totalUnits != null &&
            scheme.offerPrice! > 0; // Filter out negative prices
      }).take(4).toList();

      _cachedSchemes = validSchemes;
      _lastFetchTime = DateTime.now();

      print('✅ Fetched and cached ${_cachedSchemes!.length} valid schemes');
      return _cachedSchemes!;
    } catch (e) {
      print('❌ Error fetching schemes: $e');
      rethrow;
    }
  }

  Future<List<InvestorTransaction>> getInvestorTransactions({
    required String investorId,
    bool forceRefresh = false,
  }) async {
    // Return cached data if available and not expired
    if (!forceRefresh &&
        _cachedTransactions != null &&
        _lastTransactionFetchTime != null &&
        DateTime.now().difference(_lastTransactionFetchTime!) < _cacheDuration) {
      print('🟢 Returning cached transactions (${_cachedTransactions!.length} items)');
      return _cachedTransactions!;
    }

    try {
      print('🔵 Fetching transactions from API for investorId: $investorId...');
      final transactions = await _apiClient.getInvestorTransactions(investorId: investorId);

      // Filter out invalid transactions
      final validTransactions = transactions.where((transaction) {
        return transaction.transId != null &&
            transaction.amount != null &&
            transaction.transType != null &&
            transaction.transDate != null &&
            transaction.amount! > 0; // Filter out zero or negative amounts
      }).toList();

      _cachedTransactions = validTransactions;
      _lastTransactionFetchTime = DateTime.now();

      print('✅ Fetched and cached ${_cachedTransactions!.length} valid transactions');
      return _cachedTransactions!;
    } catch (e) {
      print('❌ Error fetching transactions: $e');
      rethrow;
    }
  }

  // Method to clear all caches if needed
  void clearCache() {
    _cachedSchemes = null;
    _lastFetchTime = null;
    _cachedTransactions = null;
    _lastTransactionFetchTime = null;
  }

  // Method to clear only schemes cache
  void clearSchemesCache() {
    _cachedSchemes = null;
    _lastFetchTime = null;
  }

  // Method to clear only transactions cache
  void clearTransactionsCache() {
    _cachedTransactions = null;
    _lastTransactionFetchTime = null;
  }

  // Method to buy units
  Future<InvestorTransaction> buyUnits({
    required String schemeId,
    required String investorId,
    required int transUnits,
  }) async {
    try {
      print('💳 [REPOSITORY] buyUnits called');
      print('   Scheme ID: $schemeId');
      print('   Investor ID: $investorId');
      print('   Trans Units: $transUnits');

      final request = BuyUnitsRequest(
        schemeId: schemeId,
        investorId: investorId,
        transUnits: transUnits.toString(),
      );

      print('   ✅ Request object created: ${request.toJson()}');
      print('   🔵 Calling API client...');

      final transaction = await _apiClient.buyUnits(request: request);

      print('   ✅ API call successful!');
      print('   Transaction ID: ${transaction.transId}');
      print('   Amount: ${transaction.amount}');

      // Clear transactions cache to force refresh on next fetch
      clearTransactionsCache();
      print('   ✅ Transaction cache cleared');

      return transaction;
    } catch (e) {
      print('   ❌ [REPOSITORY] Error in buyUnits: $e');
      print('   Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  // Get user portfolio/holdings
  Future<List<PortfolioHolding>> getPortfolio({required String investorId}) async {
    try {
      print('[PORTFOLIO] Fetching portfolio for investorId: $investorId');
      final portfolio = await _apiClient.getPortfolio(investorId: investorId);
      print('[PORTFOLIO] ✅ Fetched ${portfolio.length} holdings');
      return portfolio;
    } catch (e) {
      final message = e.toString();

      // Some backend responses for users with no holdings return null/empty payload.
      // Retrofit then throws a null-check/parse error; treat this as empty portfolio.
      final isEmptyPortfolioPayload =
          message.contains('Null check operator used on a null value') ||
          message.contains('type \'Null\' is not a subtype') ||
          message.contains('FormatException');

      if (isEmptyPortfolioPayload) {
        print('[PORTFOLIO] ℹ️ No portfolio data returned by API. Defaulting to empty list.');
        return [];
      }

      print('[PORTFOLIO] ❌ Error fetching portfolio: $e');
      rethrow;
    }
  }

  // Sell units from portfolio
  Future<InvestorTransaction> sellUnits({
    required String schemeId,
    required String investorId,
    required int transUnits,
  }) async {
    try {
      print('[SELL] Starting sell process...');
      print('   Scheme ID: $schemeId');
      print('   Investor ID: $investorId');
      print('   Units to Sell: $transUnits');

      final request = {
        'schemeId': schemeId,
        'investorId': investorId,
        'transUnits': transUnits,
      };

      final transaction = await _apiClient.sellUnits(request: request);

      print('[SELL] ✅ Sell successful');
      print('   Transaction ID: ${transaction.transId}');
      print('   Amount: ₦${transaction.amount}');

      clearTransactionsCache();
      print('   ✅ Transaction cache cleared');

      return transaction;
    } catch (e) {
      print('[SELL] ❌ Error selling units: $e');
      print('   Error type: ${e.runtimeType}');
      rethrow;
    }
  }
}

