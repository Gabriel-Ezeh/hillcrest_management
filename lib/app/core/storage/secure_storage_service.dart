import 'package:flutter_secure_storage/flutter_secure_storage.dart';


/*To Be Implemnted Later*/
/// Service for handling sensitive data like JWT tokens using
/// iOS Keychain and Android Keystore.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  static const String _kAccessToken = 'access_token';
  static const String _kRefreshToken = 'refresh_token';

  /// Save both tokens securely
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _kAccessToken, value: accessToken);
    await _storage.write(key: _kRefreshToken, value: refreshToken);
  }

  /// Retrieve the Access Token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _kAccessToken);
  }

  /// Retrieve the Refresh Token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _kRefreshToken);
  }

  /// Delete all tokens (use during logout)
  Future<void> deleteAllTokens() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
  }

  /// Check if the user has a stored session
  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}