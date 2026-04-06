import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../network/auth_interceptor.dart';
import 'auth_interceptor_provider.dart';
import 'user_local_storage_provider.dart';
import '../../../features/authentication/data/sources/auth_api_client.dart';
import '../../../features/authentication/data/sources/onboarding_api_client.dart';
import '../../../features/authentication/data/sources/otp_api_client.dart';
import '../../../features/kyc/data/sources/kyc_api_client.dart';
import '../../../features/authentication/data/repositories/auth_repository.dart';
import '../../../features/investment/data/sources/investment_api_client.dart';
import '../../../features/investment/data/repositories/investment_repository.dart';

import '../../../features/kyc/data/models/bank.dart';
import '../../../features/kyc/data/models/redeem_bank_info.dart';

part 'networking_provider.g.dart';

@riverpod
FlutterSecureStorage secureStorage(Ref ref) {
  return const FlutterSecureStorage();
}

Dio _baseDio(String baseUrl) {
  final dio = Dio(BaseOptions(baseUrl: baseUrl));
  if (kDebugMode) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }
  return dio;
}

@riverpod
Dio authDio(Ref ref) => _baseDio(dotenv.env['KEYCLOAK_BASE_URL']!);

@riverpod
Dio onboardingDio(Ref ref) => _baseDio(dotenv.env['ISSL_API_DOMAIN']!);

@riverpod
Dio otpDio(Ref ref) {
  var baseUrl = dotenv.env['ISSLs_API_BASE_URL']!;
  if (!baseUrl.endsWith('/')) {
    baseUrl = '$baseUrl/';
  }
  return _baseDio(baseUrl);
}

@riverpod
Dio dio(Ref ref) {
  final dio = _baseDio(dotenv.env['ISSL_API_DOMAIN']!);

  // Create a NEW auth interceptor instance for this Dio
  final authInterceptor = createAuthInterceptor(ref);

  // Set the dio instance on the interceptor
  authInterceptor.setDio(dio);

  // Add the interceptor to dio
  dio.interceptors.add(authInterceptor);

  return dio;
}

@riverpod
Dio kycDio(Ref ref) {
  var baseUrl = dotenv.env['ISSLs_API_BASE_URL']!;
  if (!baseUrl.endsWith('/')) {
    baseUrl = '$baseUrl/';
  }
  final dio = _baseDio(baseUrl);

  final authInterceptor = createAuthInterceptor(ref);

  authInterceptor.setDio(dio);

  dio.interceptors.add(authInterceptor);

  return dio;
}

// ADDED: Dio instance for the new dummy API
@riverpod
Dio dummyDio(Ref ref) {
  final dio = Dio(BaseOptions(baseUrl: dotenv.env['DUMMY_API_BASE_URL']!));
  if (kDebugMode) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
        compact: true,
      ),
    );
  }
  return dio;
}

@riverpod
AuthApiClient authApiClient(Ref ref) =>
    AuthApiClient(ref.watch(authDioProvider));

@riverpod
OnboardingApiClient onboardingApiClient(Ref ref) =>
    OnboardingApiClient(ref.watch(onboardingDioProvider));

@riverpod
OtpApiClient otpApiClient(Ref ref) => OtpApiClient(ref.watch(otpDioProvider));

@riverpod
KycApiClient kycApiClient(Ref ref) => KycApiClient(ref.watch(kycDioProvider));

// ADDED: Investment API Client Provider
@riverpod
InvestmentApiClient investmentApiClient(Ref ref) {
  return InvestmentApiClient(ref.watch(dummyDioProvider));
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    authApiClient: ref.read(authApiClientProvider),
    otpApiClient: ref.read(otpApiClientProvider),
    kycApiClient: ref.read(kycApiClientProvider),
    secureStorage: ref.read(secureStorageProvider),
    userLocalStorage: ref.read(userLocalStorageProvider),
    ref: ref,
  );
}

@riverpod
InvestmentRepository investmentRepository(Ref ref) {
  return InvestmentRepository(ref.watch(investmentApiClientProvider));
}

/// PROVIDER: Fetch all banks (cached)
final banksProvider = FutureProvider<List<Bank>>((ref) async {
  final repo = ref.read(authRepositoryProvider);
  return await repo.getAllBanks();
});

/// PROVIDER: Lookup account name
final accountNameLookupProvider =
    FutureProvider.family<String, Map<String, String>>((ref, params) async {
      final repo = ref.read(authRepositoryProvider);
      final nuban = params['nuban'] ?? '';
      final bankCode = params['bankCode'] ?? '';
      if (nuban.isEmpty || bankCode.isEmpty) throw Exception('Missing params');
      return await repo.lookupAccountName(nuban: nuban, bankCode: bankCode);
    });

/// PROVIDER: Fetch redeem destination bank info for the signed-in customer.
final redeemBankInfoProvider =
    FutureProvider.family<RedeemBankInfo, String>((ref, customerNo) async {
      if (customerNo.trim().isEmpty) {
        throw Exception('Missing customer number');
      }
      final repo = ref.read(authRepositoryProvider);
      return await repo.getRedeemBankInfo(customerNo: customerNo);
    });
