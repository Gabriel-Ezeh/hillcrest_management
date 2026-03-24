import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hillcrest_finance/features/authentication/data/models/token_response.dart';
import 'package:hillcrest_finance/features/authentication/data/sources/auth_api_client.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.secureStorage,
    Dio? dio,
  }) : _dio = dio;

  final FlutterSecureStorage secureStorage;
  Dio? _dio;

  static const _kAccessToken = 'ACCESS_TOKEN';
  static const _kRefreshToken = 'REFRESH_TOKEN';
  static const _retryKey = 'auth_retry_attempt';
  static const _isUserTokenKey = 'is_user_token';

  /// Must be called immediately after Dio creation
  void setDio(Dio dio) {
    _dio = dio;
  }
  void _logAccessTokenDetails(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        print('[AUTH_INTERCEPTOR] Invalid JWT format');
        return;
      }

      final payload = utf8.decode(
        base64Url.decode(
          base64Url.normalize(parts[1]),
        ),
      );

      print('[AUTH_INTERCEPTOR] Access Token Payload:');
      print(payload);
    } catch (e) {
      print('[AUTH_INTERCEPTOR] Failed to decode access token: $e');
    }
  }

  // =========================
  // REQUEST
  // =========================
  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    if (options.path.contains('token')) {
      return handler.next(options);
    }

    // SKIP adding user token if an Authorization header already exists
    // (This allows service-to-service calls using Neos token to pass through)
    if (options.headers.containsKey('Authorization')) {
      print('[AUTH_INTERCEPTOR] Authorization header already present, skipping user token injection');
      return handler.next(options);
    }

    final token = await secureStorage.read(key: _kAccessToken);

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      options.extra[_isUserTokenKey] = true; // Mark this as a user-token request

      print('[AUTH_INTERCEPTOR] Authorization header added');
      _logAccessTokenDetails(token); 
    } else {
      print('[AUTH_INTERCEPTOR] WARNING: No token found in secure storage');
    }

    handler.next(options);
  }


  // =========================
  // ERROR (401 HANDLING)
  // =========================
  @override
  Future<void> onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    final statusCode = err.response?.statusCode;

    // Already retried → do not loop
    if (err.requestOptions.extra[_retryKey] == true) {
      return handler.next(err);
    }

    // ONLY attempt refresh if it was a 401 AND it was a request we authorized with a user token
    if (statusCode != 401 || err.requestOptions.extra[_isUserTokenKey] != true) {
      return handler.next(err);
    }

    try {
      print('[AUTH_INTERCEPTOR] 401 detected for user token. Attempting refresh...');
      final newTokens = await _refreshToken();
      if (newTokens == null) {
        return handler.next(err);
      }

      // Persist new tokens
      await secureStorage.write(
        key: _kAccessToken,
        value: newTokens.accessToken,
      );

      if (newTokens.refreshToken != null) {
        await secureStorage.write(
          key: _kRefreshToken,
          value: newTokens.refreshToken!,
        );
      }

      // Clone request safely
      final retryOptions = _cloneRequestOptions(err.requestOptions);

      retryOptions.extra[_retryKey] = true;
      retryOptions.headers['Authorization'] =
      'Bearer ${newTokens.accessToken}';

      if (_dio == null) {
        return handler.next(err);
      }

      final response = await _dio!.fetch(retryOptions);
      handler.resolve(response);
    } catch (_) {
      handler.next(err);
    }
  }

  // =========================
  // REQUEST CLONING (CRITICAL)
  // =========================
  RequestOptions _cloneRequestOptions(RequestOptions options) {
    final cloned = RequestOptions(
      method: options.method,
      path: options.path,
      baseUrl: options.baseUrl,
      queryParameters: Map<String, dynamic>.from(options.queryParameters),
      headers: Map<String, dynamic>.from(options.headers),
      extra: Map<String, dynamic>.from(options.extra)..remove(_retryKey),
      responseType: options.responseType,
      contentType: options.contentType,
      followRedirects: options.followRedirects,
      validateStatus: options.validateStatus,
      receiveDataWhenStatusError: options.receiveDataWhenStatusError,
    );

    if (options.data is FormData) {
      final old = options.data as FormData;
      final fresh = FormData();

      for (final field in old.fields) {
        fresh.fields.add(MapEntry(field.key, field.value));
      }

      for (final file in old.files) {
        fresh.files.add(MapEntry(file.key, file.value));
      }

      cloned.data = fresh;
    } else {
      cloned.data = options.data;
    }

    return cloned;
  }

  // =========================
  // TOKEN REFRESH
  // =========================
  Future<TokenResponse?> _refreshToken() async {
    final refreshToken = await secureStorage.read(key: _kRefreshToken);
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    final dio = Dio();

    final authApi = AuthApiClient(
      dio,
      baseUrl: dotenv.env['KEYCLOAK_BASE_URL']!,
    );

    try {
      return await authApi.refreshToken(
        realm: dotenv.env['CC_REALM']!,
        grantType: 'refresh_token',
        clientId: 'bankeasy',
        clientSecret: dotenv.env['CC_CLIENT_SECRET']!,
        refreshToken: refreshToken,
      );
    } catch (_) {
      await secureStorage.delete(key: _kAccessToken);
      await secureStorage.delete(key: _kRefreshToken);
      return null;
    }
  }
}
