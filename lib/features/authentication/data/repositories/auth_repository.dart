import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hillcrest_finance/app/core/exceptions/network_exceptions.dart';
import 'package:hillcrest_finance/app/core/storage/user_local_storage.dart';
import 'package:hillcrest_finance/features/authentication/data/models/keycloak_user.dart';
import 'package:hillcrest_finance/features/authentication/data/models/send_email_request.dart';
import 'package:hillcrest_finance/features/authentication/data/models/sign_up_request.dart';
import 'package:hillcrest_finance/features/authentication/data/models/token_response.dart';
import 'package:hillcrest_finance/features/authentication/data/sources/auth_api_client.dart';
import 'package:hillcrest_finance/features/authentication/data/sources/otp_api_client.dart';
import 'package:hillcrest_finance/features/authentication/presentation/providers/signup_data_provider.dart';
import 'package:hillcrest_finance/features/kyc/data/models/bank.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../../../app/core/providers/networking_provider.dart';
// Add this import at the top
import 'package:hillcrest_finance/features/kyc/data/models/bvn_validation_request.dart';
import 'package:hillcrest_finance/features/kyc/data/models/signup_retail_customer_request.dart';
import 'package:hillcrest_finance/features/kyc/data/models/kyc_document_submission_request.dart';
import 'package:hillcrest_finance/features/kyc/data/models/redeem_bank_info.dart';

import '../../../kyc/data/sources/kyc_api_client.dart';

class AuthRepository {
  final AuthApiClient _authApiClient;
  final OtpApiClient _otpApiClient;
  final KycApiClient _kycApiClient;
  final FlutterSecureStorage _secureStorage;
  final UserLocalStorage _userLocalStorage;
  final Ref _ref;
  final Dio _dio;

  /// Dedicated Dio instance for Service-to-Service calls
  late final Dio _serviceDio;

  AuthRepository({
    required AuthApiClient authApiClient,
    required OtpApiClient otpApiClient,
    required KycApiClient kycApiClient,
    required FlutterSecureStorage secureStorage,
    required UserLocalStorage userLocalStorage,
    required Ref ref,
  }) : _authApiClient = authApiClient,
       _otpApiClient = otpApiClient,
       _kycApiClient = kycApiClient,
       _secureStorage = secureStorage,
       _userLocalStorage = userLocalStorage,
       _ref = ref,
       _dio = ref.read(dioProvider) {
    _serviceDio = Dio(
      BaseOptions(
        // NOTE: Verify if your KYC service uses the same base URL as your Auth service.
        // If it's different, replace _dio.options.baseUrl with the correct env variable.
        baseUrl: _dio.options.baseUrl,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // Add Logger Interceptor for easier debugging of the 404
    if (kDebugMode) {
      _serviceDio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          compact: false,
        ),
      );
      print(
        '[SERVICE_DIO] Initialized with BaseURL: ${_serviceDio.options.baseUrl}',
      );
    }
  }

  static const _kAccessToken = "ACCESS_TOKEN";
  static const _kRefreshToken = "REFRESH_TOKEN";
  static const _kSavedUsername = "SAVED_LOGIN_USERNAME";
  // --- Full Sign-Up Flow ---

  Future<void> checkIfUserExists({
    required String email,
    required String phoneNumber,
  }) async {
    try {
      final realm = dotenv.env['CC_REALM']!;
      final adminToken = await getAdminAuthToken();
      final bearerAdminToken = 'Bearer $adminToken';

      // Check for existing email
      var existingUsers = await _authApiClient.getUsers(
        realm: realm,
        email: email,
        adminToken: bearerAdminToken,
      );
      if (existingUsers.isNotEmpty) {
        throw EmailAlreadyExistsException();
      }

      // Check for existing phone number with pagination
      const int pageSize = 100;
      int page = 0;
      bool phoneFound = false;

      while (!phoneFound) {
        final users = await _authApiClient.getUsers(
          realm: realm,
          adminToken: bearerAdminToken,
          first: page * pageSize,
          max: pageSize,
        );

        if (users.isEmpty) break;

        // Check if any user has the phone number
        phoneFound = users.any((user) {
          final phoneAttr = user.attributes?['phoneNumber'];

          // Handle both List and String types
          if (phoneAttr is List) {
            return phoneAttr.contains(phoneNumber);
          } else if (phoneAttr is String) {
            return phoneAttr == phoneNumber;
          }
          return false;
        });

        if (phoneFound) {
          throw PhoneNumberAlreadyExistsException();
        }

        // If we got fewer results than pageSize, we've reached the end
        if (users.length < pageSize) break;

        page++;
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout)
        throw TimeoutException();
      throw ServerException();
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw UnexpectedException();
    }
  }

  Future<String> _getOrFetchNeosToken() async {
    String? token = await _secureStorage.read(key: 'NEOS_SERVICE_TOKEN');
    if (token == null || token.isEmpty) {
      token = await getNeosServiceToken();
    }
    if (token == null || token.isEmpty) {
      throw ClientException(message: 'Authorization failed. Please try again.');
    }
    return token;
  }

  Future<String> sendEmailOtp(String email) async {
    final tenantId = dotenv.env['xTenantId']!;

    Future<String> attempt(String token) async {
      print('📞 Calling generateEmailOtp API...');
      final otp = await _otpApiClient.generateEmailOtp(
        tenantId: tenantId,
        token: 'Bearer $token',
        email: email,
      );
      print('📥 Raw OTP from API: "$otp"');

      final emailRequest = SendEmailRequest(
        attachments: [],
        body:
            "Good day,\n\nThis is your One-time password for your online profile creation with Hillcrest Capital.\n\nPin: $otp",
        from: "customerservice@hillcrestcapmgt.com",
        subject: "OTP Verification",
        to: email,
      );

      print('📧 Sending email with OTP in body...');
      await _otpApiClient.sendEmail(
        tenantId: tenantId,
        token: 'Bearer $token',
        body: emailRequest,
      );
      return otp.trim();
    }

    try {
      final token = await _getOrFetchNeosToken();
      return await attempt(token);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print('[AUTH] Token expired, retrying with fresh token...');
        await _secureStorage.delete(key: 'NEOS_SERVICE_TOKEN');
        final freshToken = await getNeosServiceToken();
        if (freshToken != null) {
          return await attempt(freshToken);
        }
      }
      print('❌ DioException: ${e.message}');
      throw ClientException(
        message:
            'Failed to send email OTP. Please check the address and try again.',
      );
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw UnexpectedException();
    }
  }

  Future<void> sendSmsOtp(String phoneNumber) async {
    final tenantId = dotenv.env['xTenantId']!;

    Future<void> attempt(String token) async {
      print('Generating OTP for phone: $phoneNumber');
      final otp = await _otpApiClient.generateEmailOtp(
        tenantId: tenantId,
        token: 'Bearer $token',
        email: phoneNumber,
      );

      print('Sending SMS to: $phoneNumber');
      final response = await _otpApiClient.sendSmsOtp(
        tenantId: tenantId,
        message: otp,
        phoneNumber: phoneNumber,
        token: 'Bearer $token',
      );

      if (!response.sentOK) {
        throw ClientException(
          message: 'SMS service failed to send the message.',
        );
      }
    }

    try {
      final token = await _getOrFetchNeosToken();
      await attempt(token);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print('[AUTH] Token expired, retrying with fresh token...');
        await _secureStorage.delete(key: 'NEOS_SERVICE_TOKEN');
        final freshToken = await getNeosServiceToken();
        if (freshToken != null) {
          return await attempt(freshToken);
        }
      }
      throw ClientException(
        message: 'Failed to send SMS OTP. Please try again.',
      );
    } catch (e) {
      throw UnexpectedException();
    }
  }

  /// Validate BVN with the KYC service
  Future<void> validateBvn({
    required String bvn,
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String tenantId,
  }) async {
    final request = BvnValidationRequest(
      bvn: bvn,
      firstname: firstName,
      lastname: lastName,
      dob: dateOfBirth,
    );

    Future<void> attempt(String token) async {
      await _kycApiClient.validateBvn(tenantId, 'Bearer $token', request);
    }

    try {
      final token = await _getOrFetchNeosToken();
      await attempt(token);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _secureStorage.delete(key: 'NEOS_SERVICE_TOKEN');
        final freshToken = await getNeosServiceToken();
        if (freshToken != null) {
          return await attempt(freshToken);
        }
      }
      if (e.response?.statusCode == 400) {
        throw ClientException(
          message: 'Invalid BVN. Please check and try again.',
        );
      } else if (e.response?.statusCode == 404) {
        throw ClientException(message: 'BVN not found in the system.');
      }
      throw ServerException();
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw UnexpectedException();
    }
  }

  /// Submit personal information to create a retail customer
  Future<String?> submitPersonalInfo({
    required String customerType,
    required String customerCategory,
    required String firstName,
    required String? middleName,
    required String lastName,
    required String gender,
    required String dateOfBirth,
    required String maritalStatus,
    required String phoneNumber,
    required String email,
    required String bvn,
    required String address,
    required String city,
    required String? nin,
    required String? tin,
    String? bankers,
    String? bankAccountNo,
    String? bankAccountName,
    String? bankCode,
    String? bankName,
  }) async {
    final tenantId = dotenv.env['xTenantId']!;
    final request = SignupRetailCustomerRequest(
      customerType: customerType,
      customerCategory: customerCategory,
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      gender: gender,
      dob: dateOfBirth,
      maritalStatus: maritalStatus,
      phoneRef: phoneNumber,
      email: email,
      bvn: bvn,
      address: address,
      city: city,
      nin: nin,
      tin: tin,
      idempotentKey: DateTime.now().millisecondsSinceEpoch.toString(),
      tenantId: tenantId,
      bankers: bankers,
      bankAccountNo: bankAccountNo,
      bankAccountName: bankAccountName,
      bankCode: bankCode,
      bankName: bankName,
    );

    Future<String?> attempt(String token) async {
      final response = await _kycApiClient.signupRetailCustomer(
        tenantId,
        'Bearer $token',
        request,
      );

      String? customerNo;
      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        customerNo = (map['customerNo'] ?? map['customerno'])?.toString();
      }
      return customerNo;
    }

    try {
      final token = await _getOrFetchNeosToken();
      return await attempt(token);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _secureStorage.delete(key: 'NEOS_SERVICE_TOKEN');
        final freshToken = await getNeosServiceToken();
        if (freshToken != null) {
          return await attempt(freshToken);
        }
      }
      if (e.response?.statusCode == 400) {
        throw ClientException(
          message: 'Invalid information provided. Please check your details.',
        );
      } else if (e.response?.statusCode == 409) {
        throw ClientException(
          message: 'A customer record already exists with this information.',
        );
      }
      throw ServerException();
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw UnexpectedException();
    }
  }

  Future<void> verifyEmailOtp(String email, String otp) async {
    // Implementation for verifyEmailOtp
  }

  Future<void> verifySmsOtp(String phoneNumber, String otp) async {
    // Implementation for verifySmsOtp
  }

  Future<void> createKeycloakUser() async {
    final signUpData = _ref.read(signUpDataProvider);
    if (signUpData == null) {
      throw UnexpectedException(
        message: "Could not retrieve user data to create account.",
      );
    }

    try {
      final adminToken = await getAdminAuthToken();
      final signUpRequest = SignUpRequest(
        username: signUpData.username,
        email: signUpData.email,
        firstName: signUpData.firstName,
        lastName: signUpData.lastName,
        enabled: true,
        emailVerified: true, // MODIFIED: Set email as verified
        credentials: [
          KeycloakCredential(type: 'password', value: signUpData.password),
        ],
        attributes: {
          // MODIFIED: Correctly pass all attributes
          'phoneNumber': signUpData.phoneNumber,
          'accountType': signUpData.accountType,
        },
      );
      await _authApiClient.createUser(
        realm: dotenv.env['CC_REALM']!,
        user: signUpRequest,
        adminToken: 'Bearer $adminToken',
      );

      await _userLocalStorage.saveUsername(signUpData.username);
    } on DioException catch (e) {
      if (e.response?.data['errorMessage']?.toString().contains(
            'already exists',
          ) ??
          false) {
        throw UserAlreadyExistsException();
      }
      throw ServerException();
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw UnexpectedException();
    }
  }

  /// Returns a map with customerNo status, accountType, and the KeycloakUser object
  Future<Map<String, dynamic>> getUserOnboardingStatus(String username) async {
    try {
      print('\n[AUTH] === FETCHING ONBOARDING STATUS ===');
      print('[AUTH] Username: $username');

      final realm = dotenv.env['CC_REALM']!;

      // Step 1: Get Admin Token
      final adminToken = await getAdminAuthToken();
      final bearerAdminToken = 'Bearer $adminToken';

      // Step 2: Get user details from Keycloak
      final users = await _authApiClient.getUsers(
        realm: realm,
        username: username,
        adminToken: bearerAdminToken,
      );

      if (users.isEmpty) {
        print('[AUTH] ❌ User not found in Keycloak: $username');
        return {
          'hasCustomerNo': false,
          'customerNo': null,
          'accountType': null,
          'user': null,
        };
      }

      // This is the KeycloakUser object containing firstName, lastName, etc.
      final user = users.first;
      final attributes = user.attributes ?? {};

      print('[AUTH] Raw Attributes Found: $attributes');
      print('[AUTH] Available Keys: ${attributes.keys.toList()}');

      // Step 3: Extract CustomerNo (Case-Insensitive Check)
      dynamic customerNoValue =
          attributes['customerNo'] ?? attributes['CustomerNo'];

      String? finalCustomerNo;
      bool hasCustomerNo = false;

      if (customerNoValue != null) {
        if (customerNoValue is List && customerNoValue.isNotEmpty) {
          finalCustomerNo = customerNoValue.first.toString();
        } else if (customerNoValue is String) {
          finalCustomerNo = customerNoValue;
        }

        if (finalCustomerNo != null && finalCustomerNo.trim().isNotEmpty) {
          hasCustomerNo = true;
        }
      }

      // Step 4: Extract AccountType (Case-Insensitive Check)
      dynamic accountTypeValue =
          attributes['accountType'] ?? attributes['AccountType']; String? finalAccountType;

      if (accountTypeValue != null) {
        if (accountTypeValue is List && accountTypeValue.isNotEmpty) {
          finalAccountType = accountTypeValue.first.toString();
        } else if (accountTypeValue is String) {
          finalAccountType = accountTypeValue;
        }
      }

      print(
        '[AUTH] ✅ Sync Result - hasCustomerNo: $hasCustomerNo, customerNo: $finalCustomerNo, accountType: $finalAccountType',
      );
      print('[AUTH] User Name found: ${user.firstName} ${user.lastName}');
      print('[AUTH] === ONBOARDING SYNC COMPLETE ===\n');

      return {
        'hasCustomerNo': hasCustomerNo,
        'customerNo': finalCustomerNo,
        'accountType': finalAccountType,
        'user':
            user, // Included the user object so the Notifier can save it to state
      };
    } catch (e, stackTrace) {
      print('[AUTH] ❌ Error in getUserOnboardingStatus: $e');
      print('[AUTH] Stack trace: $stackTrace');
      return {
        'hasCustomerNo': false,
        'customerNo': null,
        'accountType': null,
        'user': null,
      };
    }
  }

  // Keep the old method for backward compatibility if needed
  Future<bool> checkForCustomerNo(String username) async {
    final status = await getUserOnboardingStatus(username);
    return status['hasCustomerNo'] as bool;
  }

  // --- NEW FORGOT PASSWORD METHOD --- //
  Future<void> forgotPassword(String email) async {
    try {
      final realm = dotenv.env['CC_REALM']!;
      final adminToken = await getAdminAuthToken();
      final bearerAdminToken = 'Bearer $adminToken';

      // Step 1: Find the user by email to get their ID
      final users = await _authApiClient.getUsers(
        realm: realm,
        email: email,
        adminToken: bearerAdminToken,
      );

      if (users.isEmpty) {
        // To prevent user enumeration, we don't throw an error here.
        // The UI will show a generic success message regardless.
        print('[AUTH] Password reset requested for non-existent email: $email');
        return;
      }
      final userId = users.first.id;

      // Step 2: Trigger the password reset email action
      await _authApiClient.executeActionsEmail(
        realm: realm,
        userId: userId,
        adminToken: bearerAdminToken,
        actions: ["UPDATE_PASSWORD"],
      );

      print('[AUTH] Password reset email sent to: $email');
    } on DioException {
      // Even on a server error, we don't want to let the user know if the email exists or not.
      // We can log the error for debugging, but we won't rethrow it to the UI.
      print('[AUTH] A server error occurred during password reset.');
    } catch (e) {
      print('[AUTH] An unexpected error occurred during password reset: $e');
    }
  }

  // --- BANKS & ACCOUNT LOOKUP --- //
  List<Bank>? _cachedBanks;

  /// Fetch all banks (with in-memory caching and retry)
  Future<List<Bank>> getAllBanks() async {
    if (_cachedBanks != null) return _cachedBanks!;

    final tenantId = dotenv.env['xTenantId']!;

    Future<List<Bank>> attempt(String token) async {
      return await _kycApiClient.getAllBanks(tenantId, 'Bearer $token');
    }

    try {
      final token = await _getOrFetchNeosToken();
      final banks = await attempt(token);
      _cachedBanks = banks;
      return banks;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print('[AUTH] Neos token expired during bank fetch, retrying...');
        await _secureStorage.delete(key: 'NEOS_SERVICE_TOKEN');
        final freshToken = await getNeosServiceToken();
        if (freshToken != null) {
          final banks = await attempt(freshToken);
          _cachedBanks = banks;
          return banks;
        }
      }
      if (e.type == DioExceptionType.connectionTimeout)
        throw TimeoutException();
      throw NetworkException('Failed to fetch banks. Please try again.');
    } catch (e) {
      throw NetworkException('Failed to fetch banks. Please try again.');
    }
  }

  /// Fetch redeem destination bank details by customer number.
  ///
  /// Flow:
  /// 1) getCustomerDetailsV4 -> bankers, bankCode, bankAccountNo
  /// 2) accountNameLookup (fallback if bankAccountName is empty)
  Future<RedeemBankInfo> getRedeemBankInfo({required String customerNo}) async {
    final tenantId = dotenv.env['xTenantId']!;

    Future<RedeemBankInfo> attempt(String token) async {
      final customerDetails = await _kycApiClient.getCustomerDetailsV4(
        tenantId,
        'Bearer $token',
        customerNo,
      );

      final accountNumber = customerDetails.bankAccountNo.trim();
      final bankCode = customerDetails.bankCode.trim();
      final bankName = customerDetails.bankers.trim();

      if (accountNumber.isEmpty || bankCode.isEmpty) {
        throw NetworkException(
          'Bank account details are not available for this customer.',
        );
      }

      String accountName = (customerDetails.bankAccountName ?? '').trim();

      if (accountName.isEmpty) {
        final lookup = await _kycApiClient.accountNameLookup(
          tenantId,
          'Bearer $token',
          'application/json',
          accountNumber,
          bankCode,
        );
        accountName = lookup.accountName.trim();
      }

      if (accountName.isEmpty) {
        throw NetworkException(
          'Account name not found. Please verify bank details.',
        );
      }

      return RedeemBankInfo(
        accountName: accountName,
        accountNumber: accountNumber,
        bankName: bankName.isEmpty ? 'Bank' : bankName,
        bankCode: bankCode,
      );
    }

    try {
      final token = await _getOrFetchNeosToken();
      return await attempt(token);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print('[AUTH] Neos token expired during customer bank fetch, retrying...');
        await _secureStorage.delete(key: 'NEOS_SERVICE_TOKEN');
        final freshToken = await getNeosServiceToken();
        if (freshToken != null) {
          return await attempt(freshToken);
        }
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw TimeoutException();
      }
      throw NetworkException(
        'Failed to fetch account details. Please try again.',
      );
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw NetworkException(
        'Failed to fetch account details. Please try again.',
      );
    }
  }

  /// Lookup account name by account number and bank code (with retry)
  Future<String> lookupAccountName({
    required String nuban,
    required String bankCode,
  }) async {
    final tenantId = dotenv.env['xTenantId']!;

    Future<String> attempt(String token) async {
      final response = await _kycApiClient.accountNameLookup(
        tenantId,
        'Bearer $token',
        'application/json',
        nuban,
        bankCode,
      );

      final name = response.accountName.trim();

      if (name.isNotEmpty) {
        return name;
      }

      throw NetworkException(
        'Account name not found. Please check the details.',
      );
    }

    try {
      final token = await _getOrFetchNeosToken();
      return await attempt(token);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print('[AUTH] Neos token expired during name lookup, retrying...');
        await _secureStorage.delete(key: 'NEOS_SERVICE_TOKEN');
        final freshToken = await getNeosServiceToken();
        if (freshToken != null) {
          return await attempt(freshToken);
        }
      }
      if (e.type == DioExceptionType.connectionTimeout)
        throw TimeoutException();
      throw NetworkException(
        'Failed to verify account name. Please try again.',
      );
    } catch (e) {
      throw NetworkException(
        'Failed to verify account name. Please try again.',
      );
    }
  }

  Future<bool> isSignedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getPhoneNumberFromUsername(String username) async {
    try {
      final realm = dotenv.env['CC_REALM']!;
      final adminToken = await getAdminAuthToken();
      final bearerAdminToken = 'Bearer $adminToken';

      final users = await _authApiClient.getUsers(
        realm: realm,
        username: username, // Exact username match
        adminToken: bearerAdminToken,
      );

      if (users.isEmpty) {
        return null;
      }

      // Extract phone number from attributes
      final phoneAttr = users.first.attributes?['MobilePhoneNo'];

      if (phoneAttr is List && phoneAttr.isNotEmpty) {
        return phoneAttr.first.toString();
      } else if (phoneAttr is String) {
        return phoneAttr;
      }

      return null;
    } catch (e) {
      print('[AUTH] Error getting phone number: $e');
      return null;
    }
  }

  Future<TokenResponse> login(String username, String password) async {
    try {
      // 1. Log the start of the attempt
      if (kDebugMode) {
        print('[AUTH] Attempting login for: $username');
      }

      final response = await _authApiClient.login(
        realm: dotenv.env['CC_REALM']!,
        grantType: "password",
        clientId: dotenv.env['CC_CLIENT_ID']!,
        clientSecret: dotenv.env['CC_CLIENT_SECRET']!,
        username: username,
        password: password,
      );

      // 2. Save tokens and the username
      await _saveTokens(response);
      await _secureStorage.write(key: _kSavedUsername, value: username);

      if (kDebugMode) {
        print(
          '[AUTH] Login successful. Username "$username" persisted to secure storage.',
        );
      }

      return response;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout)
        throw TimeoutException();
      if (e.response?.statusCode == 401) throw InvalidCredentialsException();
      throw ServerException();
    } catch (e) {
      if (kDebugMode) print('[AUTH] Unexpected Error: $e');
      throw UnexpectedException();
    }
  }

  /// Helper method to retrieve the username when the login screen builds
  Future<String?> getPersistedUsername() async {
    try {
      final username = await _secureStorage.read(key: _kSavedUsername);
      if (kDebugMode) print('[AUTH] Fetched persisted username: $username');
      return username;
    } catch (e) {
      return null;
    }
  }

  Future<TokenResponse> refreshAccessToken(String refreshToken) async {
    try {
      final realm = dotenv.env['CC_REALM']!;
      return await _authApiClient.refreshToken(
        realm: realm,
        grantType: 'refresh_token',
        clientId: 'bankeasy',
        clientSecret: dotenv.env['CC_CLIENT_SECRET']!,
        refreshToken: refreshToken,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout)
        throw TimeoutException();
      throw ServerException();
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw UnexpectedException();
    }
  }

  /// Get service-to-service token using Neos credentials
  /// Get Neos service token (for KYC uploads)
  Future<String?> getNeosServiceToken() async {
    try {
      print('[AUTH] Fetching Neos service token...');

      // Check if all required env variables are present
      final neosRealm = dotenv.env['NEOS_REALM'];
      final neosClientId = dotenv.env['NEOS_CLIENT_ID'];
      final neosClientSecret = dotenv.env['NEOS_CLIENT_SECRET'];
      final neosUsername = dotenv.env['NEOS_USERNAME'];
      final neosPassword = dotenv.env['NEOS_PASSWORD'];

      print('[AUTH] Checking env variables:');
      print('[AUTH] - NEOS_REALM: ${neosRealm != null ? "✓" : "✗"}');
      print('[AUTH] - NEOS_CLIENT_ID: ${neosClientId != null ? "✓" : "✗"}');
      print(
        '[AUTH] - NEOS_CLIENT_SECRET: ${neosClientSecret != null ? "✓" : "✗"}',
      );
      print('[AUTH] - NEOS_USERNAME: ${neosUsername != null ? "✓" : "✗"}');
      print('[AUTH] - NEOS_PASSWORD: ${neosPassword != null ? "✓" : "✗"}');

      if (neosRealm == null ||
          neosClientId == null ||
          neosClientSecret == null ||
          neosUsername == null ||
          neosPassword == null) {
        print('[AUTH] ERROR: Missing required Neos environment variables');
        throw ClientException(
          message:
              'Neos service configuration is incomplete. Please contact support.',
        );
      }

      print('[AUTH] All env variables present, calling API...');

      final response = await _authApiClient.getNeosServiceToken(
        realm: neosRealm,
        grantType: 'password',
        clientId: neosClientId,
        clientSecret: neosClientSecret,
        username: neosUsername,
        password: neosPassword,
      );

      print('[AUTH] Neos service token obtained successfully');
      print('[AUTH] Token: ${response.accessToken.substring(0, 50)}...');

      // Save token to secure storage
      await _secureStorage.write(
        key: 'NEOS_SERVICE_TOKEN',
        value: response.accessToken,
      );

      return response.accessToken;
    } on DioException catch (e) {
      print('[AUTH] DioException while getting Neos token:');
      print('[AUTH] Status: ${e.response?.statusCode}');
      print('[AUTH] Response: ${e.response?.data}');
      print('[AUTH] Message: ${e.message}');
      return null;
    } catch (e) {
      print('[AUTH] Failed to get Neos service token: $e');
      return null;
    }
  }

  Future<Response<dynamic>> _submitKycDocumentsRequest({
    required String tenantId,
    required String token,
    required String screenName,
    required String fullName,
    required Map<String, dynamic> body,
  }) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['ISSL_API_DOMAIN']!,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

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

    return dio.post(
      '/ibank/api/v1/submitTransaction',
      queryParameters: {
        'transactiontype': 'KYCDOCUPDATE',
        'screenname': screenName,
        'fullname': fullName,
      },
      data: body,
      options: Options(
        headers: {
          'X-TenantId': tenantId,
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  /// Upload KYC documents
  Future<void> uploadKycDocuments({
    required String screenName,
    required String fullName,
    required String customerNo,
    required List<KycDocument> documents,
  }) async {
    try {
      print('[KYC] Preparing to submit KYC documents...');
      print('[KYC] Customer No: $customerNo');
      print('[KYC] Number of documents: ${documents.length}');

      final body = {
        'customerno': customerNo,
        'documents': documents.map((e) => e.toJson()).toList(),
      };

      final tenantId = dotenv.env['xTenantId']!;

      // STEP 1: Use cached token if available, otherwise fetch a fresh one.
      String? neosToken = await _secureStorage.read(key: 'NEOS_SERVICE_TOKEN');
      if (neosToken == null || neosToken.isEmpty) {
        print('[KYC] No cached Neos token found, fetching new token...');
        neosToken = await getNeosServiceToken();
      }

      if (neosToken == null || neosToken.isEmpty) {
        throw ClientException(
          message:
              'Unable to authorize upload right now. Kindly try again in a moment.',
        );
      }

      print('[KYC] Neos service token obtained, making request...');

      Response<dynamic> response;
      try {
        // STEP 2: First attempt.
        response = await _submitKycDocumentsRequest(
          tenantId: tenantId,
          token: neosToken,
          screenName: screenName,
          fullName: fullName,
          body: body,
        );
      } on DioException catch (e) {
        // STEP 3: If unauthorized, invalidate token, fetch fresh token, and retry once.
        if (e.response?.statusCode == 401) {
          print(
            '[KYC] First attempt returned 401. Refreshing service token and retrying once...',
          );
          await _secureStorage.delete(key: 'NEOS_SERVICE_TOKEN');

          final refreshedToken = await getNeosServiceToken();
          if (refreshedToken == null || refreshedToken.isEmpty) {
            throw ClientException(
              message:
                  'Your session expired while uploading. Kindly tap submit again.',
            );
          }

          response = await _submitKycDocumentsRequest(
            tenantId: tenantId,
            token: refreshedToken,
            screenName: screenName,
            fullName: fullName,
            body: body,
          );
        } else {
          rethrow;
        }
      }

      print('[KYC] Response status: ${response.statusCode}');
      print('[KYC] Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('[KYC] Document upload successful');

        if (response.data is Map) {
          final responseData = response.data as Map<String, dynamic>;
          if (responseData['ok'] == true) {
            print('[KYC] Transaction submitted successfully');
            print('[KYC] Status: ${responseData['statusMessage']}');
          }
        }
      } else {
        throw ClientException(
          message: 'Failed to submit KYC documents. Kindly try again.',
        );
      }
    } on DioException catch (e) {
      print('[KYC] DioException: ${e.response?.statusCode} ${e.message}');
      print('[KYC] Error response: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        await _secureStorage.delete(key: 'NEOS_SERVICE_TOKEN');
        throw ClientException(
          message:
              'Authorization failed for document upload. Kindly try again shortly.',
        );
      }

      throw ClientException(
        message:
            'Failed to submit KYC documents. Please check your connection and try again.',
      );
    } catch (e) {
      print('[KYC] Unexpected error during document upload: $e');

      if (e is NetworkException) rethrow;
      if (e is ClientException) rethrow;

      throw ClientException(
        message:
            'Something went wrong while submitting documents. Kindly try again.',
      );
    }
  }

  /// Update user attributes in Keycloak with customerNo

  Future<void> updateUserCustomerNo({
    required String username,
    required String customerNo,
  }) async {
    try {
      print('\n[AUTH] === STARTING UPDATE PROCESS ===');
      print('[AUTH] Target Username: $username');
      print('[AUTH] New CustomerNo: $customerNo');

      final realm = dotenv.env['CC_REALM']!;

      // STEP 1: Fetch Admin Token (using isolated logic)
      print('[AUTH] Step 1: Fetching administrative token...');
      String adminToken;
      try {
        adminToken = await getAdminAuthToken();
        print('[AUTH] ✅ Admin token obtained (Length: ${adminToken.length})');
      } catch (e) {
        print('[AUTH] ❌ Step 1 Failed: Could not get admin token');
        rethrow;
      }

      final bearerAdminToken = 'Bearer $adminToken';

      // STEP 2: Fetch existing User Data
      // We need this to get the internal Keycloak UUID and existing attributes
      print('[AUTH] Step 2: Fetching user details from Keycloak...');
      List<KeycloakUser> users = await _authApiClient.getUsers(
        realm: realm,
        username: username,
        adminToken: bearerAdminToken,
      );

      if (users.isEmpty) {
        print(
          '[AUTH] ❌ Step 2 Failed: No user found with username "$username"',
        );
        throw NetworkException('User not found in Keycloak');
      }

      final user = users.first;
      final userId = user.id; print('[AUTH] ✅ User Found. Keycloak UUID: $userId');
      print('[AUTH] Current Attributes: ${user.attributes}');

      // STEP 3: Merge Attributes
      // Keycloak PUT requests for users are "replacements."
      // If we don't include existing attributes, they might be deleted.
      print('[AUTH] Step 3: Preparing attribute payload...');

      // Copy existing attributes or start fresh if null
      final Map<String, dynamic> updatedAttributes = Map<String, dynamic>.from(
        user.attributes ?? {},
      );

      // Keycloak REQUIRES attributes to be a List of Strings
      updatedAttributes['customerNo'] = [customerNo];

      final updatePayload = {"attributes": updatedAttributes};

      print('[AUTH] Payload prepared: $updatePayload');

      // STEP 4: Send PUT Request to Keycloak
      print('[AUTH] Step 4: Sending update to Keycloak Admin API...');
      try {
        await _authApiClient.updateUserAttributes(
          realm,
          userId,
          updatePayload,
          bearerAdminToken,
        );
        print('[AUTH] ✅ STEP 4 SUCCESS: Keycloak updated successfully');
      } on DioException catch (e) {
        print('[AUTH] ❌ Step 4 Failed: Keycloak rejected the update');
        print('[AUTH] Status Code: ${e.response?.statusCode}');
        print('[AUTH] Error Body: ${e.response?.data}');
        rethrow;
      }

      print('[AUTH] === UPDATE PROCESS COMPLETED SUCCESSFULLY ===\n');
    } catch (e, stack) {
      print('[AUTH] ❌ CRITICAL ERROR in updateUserCustomerNo: $e');
      print('[AUTH] StackTrace: $stack');
      throw NetworkException(
        'Failed to sync customer information with security server.',
      );
    }
  }

  /// Background Sync: Refresh user profile from Keycloak and update local cache
  Future<KeycloakUser?> syncUserProfile() async {
    try {
      final username = _userLocalStorage.getUsername();
      if (username == null) return null;

      final realm = dotenv.env['CC_REALM']!;
      final adminToken = await getAdminAuthToken();

      final users = await _authApiClient.getUsers(
        realm: realm,
        username: username,
        adminToken: 'Bearer $adminToken',
      );

      if (users.isNotEmpty) {
        final freshUser = users.first;
        // SILENTLY update Hive. This ensures the next app launch is up-to-date.
        await _userLocalStorage.saveUser(freshUser);

        // Check for customerNo during sync and update flag
        final attributes = freshUser.attributes ?? {};
        final hasNo =
            attributes.containsKey('customerNo') ||
            attributes.containsKey('CustomerNo');
        await _userLocalStorage.setHasCustomerNo(hasNo);

        return freshUser;
      }
      return null;
    } catch (e) {
      print('[AUTH] Background profile sync failed: $e');
      // We don't throw here so the UI can continue using the cached version
      return _userLocalStorage.getUser();
    }
  }

  /// Modified Logout to clear Hive cache
  Future<void> logout() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken != null) {
        await _authApiClient.logout(
          realm: dotenv.env['CC_REALM']!,
          clientId: dotenv.env['CC_CLIENT_ID']!,
          clientSecret: dotenv.env['CC_CLIENT_SECRET']!,
          refreshToken: refreshToken,
        );
      }
    } catch (_) {
      // Log error if necessary
    }

    // FIX: Instead of deleteAll(), delete only the session tokens
    // This preserves the 'username' key if it was stored in Secure Storage
    await _secureStorage.delete(key: _kAccessToken);
    await _secureStorage.delete(key: _kRefreshToken);

    // FIX: In your UserLocalStorage, ensure clearUserSession()
    // does NOT delete the username key.
    // You should modify that method to only clear 'has_customer_no', 'user_profile', etc.
    await _userLocalStorage.clearUserSession();
  }
  // --- Helper Methods ---

  Future<String?> getAccessToken() => _secureStorage.read(key: _kAccessToken);
  Future<String?> getRefreshToken() => _secureStorage.read(key: _kRefreshToken);

  Future<void> _saveTokens(TokenResponse response) async {
    await _secureStorage.write(key: _kAccessToken, value: response.accessToken);
    if (response.refreshToken != null) {
      await _secureStorage.write(
        key: _kRefreshToken,
        value: response.refreshToken!,
      );
    }
  }

  Future<String> getAdminAuthToken() async {
    try {
      // 1. Construct the FULL URL manually to avoid "No host specified" errors
      // Ensure CC_BASE_URL is "https://sentry.issl.ng" in your .env
      final String keycloakBase =
          dotenv.env['CC_BASE_URL'] ?? 'https://sentry.issl.ng';
      final String realm = dotenv.env['CC_REALM'] ?? 'CandourCrest';

      final String fullUrl =
          '$keycloakBase/auth/realms/$realm/protocol/openid-connect/token';

      // 2. Use a "clean" Dio instance.
      // Using _ref.read(authDioProvider) is dangerous here because it might
      // have interceptors that add your USER token to this ADMIN request.
      final dio = Dio();

      print('[AUTH] Fetching admin token from: $fullUrl');

      final response = await dio.post(
        fullUrl,
        data: {
          'grant_type': 'client_credentials',
          'client_id': dotenv
              .env['CC_ADMIN_CLIENT_ID'], // Ensure this is the ADMIN client, not "bankeasy"
          'client_secret': dotenv.env['ADMIN_CLIENT_SECRET'],
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final tokenResponse = TokenResponse.fromJson(response.data);
      return tokenResponse.accessToken;
    } on DioException catch (e) {
      print('[AUTH] ❌ Admin Auth Failed: ${e.response?.statusCode}');
      print('[AUTH] Error Data: ${e.response?.data}');
      throw ServerException(
        message: 'Failed to authenticate for an administrative task.',
      );
    } catch (e) {
      print('[AUTH] ❌ Unexpected Error: $e');
      throw UnexpectedException();
    }
  }
}
