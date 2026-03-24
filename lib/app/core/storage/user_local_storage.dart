import 'package:hive_flutter/hive_flutter.dart';
import 'package:hillcrest_finance/features/authentication/data/models/keycloak_user.dart';

class UserLocalStorage {
  final Box _box;

  UserLocalStorage(this._box);

  static const String _kHasSeenOnboarding = 'hasSeenOnboarding';
  static const String _kLastUsedUsername = 'lastUsedUsername';
  static const String _kHasCustomerNo = 'hasCustomerNo';
  static const String _kPendingOtp = 'pendingOtp';
  static const String _kPendingCustomerNo = 'pendingCustomerNo';
  static const String _kCurrentUser = 'currentUser';
  static const String _kAccessToken = 'accessToken';
  static const String _kRefreshToken = 'refreshToken';

  // --- Keycloak User Object Persistence ---

  Future<void> saveUser(KeycloakUser user) async {
    await _box.put(_kCurrentUser, user);
  }

  KeycloakUser? getUser() {
    return _box.get(_kCurrentUser) as KeycloakUser?;
  }

  // --- Onboarding Status ---
  bool get hasSeenOnboarding {
    return _box.get(_kHasSeenOnboarding, defaultValue: false) as bool;
  }

  Future<void> markOnboardingAsSeen() async {
    await _box.put(_kHasSeenOnboarding, true);
  }

  // --- Username Methods ---

  String? get lastUsedUsername {
    return _box.get(_kLastUsedUsername) as String?;
  }

  /// Added to resolve 'undefined_method' in providers
  String? getUsername() {
    return lastUsedUsername;
  }

  Future<void> saveUsername(String username) async {
    await _box.put(_kLastUsedUsername, username);
  }

  /// Added to resolve 'undefined_method' in providers
  Future<void> clearUsername() async {
    await _box.delete(_kLastUsedUsername);
  }

  // --- Customer Number Status ---
  bool get hasCustomerNo {
    return _box.get(_kHasCustomerNo, defaultValue: false) as bool;
  }

  Future<void> setHasCustomerNo(bool hasNo) async {
    await _box.put(_kHasCustomerNo, hasNo);
  }

  // --- Pending Customer Number ---
  Future<void> savePendingCustomerNo(String customerNo) async {
    await _box.put(_kPendingCustomerNo, customerNo);
  }

  String? getPendingCustomerNo() {
    return _box.get(_kPendingCustomerNo) as String?;
  }

  /// Get the stored customer number
  String? getCustomerNo() {
    return _box.get(_kPendingCustomerNo) as String?;
  }

  Future<void> clearPendingCustomerNo() async {
    await _box.delete(_kPendingCustomerNo);
  }

  // --- OTP Storage ---
  Future<void> saveOtp(String otp) async {
    await _box.put(_kPendingOtp, otp);
    print('💾 OTP saved to Hive: "$otp"');
  }

  String? getOtp() {
    final otp = _box.get(_kPendingOtp) as String?;
    print('📥 OTP retrieved from Hive: "$otp"');
    return otp;
  }

  Future<void> clearOtp() async {
    await _box.delete(_kPendingOtp);
    print('🗑️ OTP cleared from Hive');
  }

  // --- Token & Credential Methods ---

  Future<void> saveCredentials(String username, String email) async {
    await _box.put(_kLastUsedUsername, username);
  }

  Future<void> clearCredentials() async {
    await _box.delete(_kLastUsedUsername);
  }

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _box.put(_kAccessToken, accessToken);
    await _box.put(_kRefreshToken, refreshToken);
  }

  Future<String?> getAccessToken() async {
    return _box.get(_kAccessToken) as String?;
  }

  Future<String?> getRefreshToken() async {
    return _box.get(_kRefreshToken) as String?;
  }

  Future<void> clearTokens() async {
    await _box.delete(_kAccessToken);
    await _box.delete(_kRefreshToken);
  }

  /// Wipe session-specific data but keep settings like Onboarding
  Future<void> clearUserSession() async {
    await _box.delete(_kCurrentUser);
    await _box.delete(_kHasCustomerNo);
    await _box.delete(_kPendingCustomerNo);
    await _box.delete(_kPendingOtp);
    await clearUsername();
    await clearTokens();
  }
}