import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hillcrest_finance/app/core/providers/networking_provider.dart';
import 'package:hillcrest_finance/app/core/providers/user_local_storage_provider.dart';
import 'package:hillcrest_finance/features/authentication/presentation/providers/auth_state_provider.dart';

import '../../data/models/token_response.dart';
import '../../data/models/keycloak_user.dart';
import 'auth_state.dart';

class AuthStateNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => AuthState.initial();

  Future<void> checkInitialStatus() async {
    // 1. Set loading to true immediately so the UI shows a splash/loader
    // instead of defaulting to the Login screen for a split second.
    state = state.copyWith(isLoading: true);

    try {
      final storage = ref.read(userLocalStorageProvider);
      final refreshToken = await storage.getRefreshToken();
      final savedUsername = await storage.getUsername();

      if (refreshToken == null) {
        state = AuthState.initial().copyWith(isLoading: false);
        return;
      }

      final token = await ref
          .read(authRepositoryProvider)
          .refreshAccessToken(refreshToken);

      await storage.saveTokens(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken ?? refreshToken,
      );

      KeycloakUser? user;
      bool hasCustomerNo = false;
      String? accountType;
      String? customerNo;

      if (savedUsername != null) {
        // We await this strictly before the state update
        final onboarding = await ref
            .read(authRepositoryProvider)
            .getUserOnboardingStatus(savedUsername);
        user = onboarding['user'] as KeycloakUser?;
        hasCustomerNo = onboarding['hasCustomerNo'] as bool? ?? false;
        accountType = onboarding['accountType'] as String?;
        customerNo = onboarding['customerNo'] as String?;

        // ✅ SAVE CUSTOMER NUMBER TO HIVE
        if (customerNo != null && customerNo.isNotEmpty) {
          await ref
              .read(userLocalStorageProvider)
              .savePendingCustomerNo(customerNo);
          print('[AUTH_NOTIFIER] ✅ CustomerNo saved to Hive: $customerNo');

          // Verify it was saved correctly
          final verifyCustomerNo = ref
              .read(userLocalStorageProvider)
              .getCustomerNo();
          print(
            '[AUTH_NOTIFIER] 🔍 Verification - CustomerNo from Hive: $verifyCustomerNo',
          );
        } else {
          print('[AUTH_NOTIFIER] ⚠️ No customerNo to save');
        }
      }

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false, // Turn off loading only after everything is ready
        token: token,
        user: user,
        hasCustomerNo: hasCustomerNo,
        accountType: accountType,
      );
    } catch (_) {
      await ref.read(userLocalStorageProvider).clearTokens();
      state = AuthState.initial().copyWith(isLoading: false);
    }
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(authRepositoryProvider).forgotPassword(email);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshUserData() async {
    try {
      final storage = ref.read(userLocalStorageProvider);
      final savedUsername = await storage.getUsername();

      if (savedUsername == null) return;

      final onboarding = await ref
          .read(authRepositoryProvider)
          .getUserOnboardingStatus(savedUsername);

      final bool hasCustomerNo = onboarding['hasCustomerNo'] as bool? ?? false;
      final String? accountType = onboarding['accountType'] as String?;
      final String? customerNo = onboarding['customerNo'] as String?;
      final KeycloakUser? user = onboarding['user'] as KeycloakUser?;

      await storage.setHasCustomerNo(hasCustomerNo);

      // ✅ SAVE CUSTOMER NUMBER TO HIVE
      if (customerNo != null && customerNo.isNotEmpty) {
        await storage.savePendingCustomerNo(customerNo);
        print(
          '[AUTH_NOTIFIER] ✅ CustomerNo saved to Hive in refreshUserData: $customerNo',
        );
      }

      state = state.copyWith(
        user: user,
        hasCustomerNo: hasCustomerNo,
        accountType: accountType,
      );
    } catch (e) {
      debugPrint('Error refreshing user data: $e');
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true);

    try {
      final token = await ref
          .read(authRepositoryProvider)
          .login(username, password);

      // Save/update the username in storage every time a successful login happens
      await ref.read(userLocalStorageProvider).saveUsername(username);

      await _onLoginSuccess(token, username);
    } catch (_) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> _onLoginSuccess(TokenResponse token, String username) async {
    final storage = ref.read(userLocalStorageProvider);
    final onboarding = await ref
        .read(authRepositoryProvider)
        .getUserOnboardingStatus(username);

    final bool hasCustomerNo = onboarding['hasCustomerNo'] as bool? ?? false;
    final String? accountType = onboarding['accountType'] as String?;
    final String? customerNo = onboarding['customerNo'] as String?;
    final KeycloakUser? user = onboarding['user'] as KeycloakUser?;

    await storage.setHasCustomerNo(hasCustomerNo);

    // ✅ SAVE CUSTOMER NUMBER TO HIVE
    if (customerNo != null && customerNo.isNotEmpty) {
      await storage.savePendingCustomerNo(customerNo);
      print(
        '[AUTH_NOTIFIER] ✅ CustomerNo saved to Hive after login: $customerNo',
      );
    }

    await storage.saveTokens(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken ?? "",
    );

    state = state.copyWith(
      isAuthenticated: true,
      isLoading: false,
      token: token,
      user: user,
      hasCustomerNo: hasCustomerNo,
      accountType: accountType,
    );
  }

  Future<void> markKycCompleted(String customerNo) async {
    final storage = ref.read(userLocalStorageProvider);

    await storage.setHasCustomerNo(true);
    await storage.savePendingCustomerNo(customerNo);

    state = state.copyWith(hasCustomerNo: true);

    debugPrint(
      '[AUTH_NOTIFIER] KYC marked complete locally. customerNo=$customerNo',
    );
  }

  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {
      // Log error but proceed
    } finally {
      final storage = ref.read(userLocalStorageProvider);

      // CRITICAL CHANGE: We only clear security tokens and onboarding flags.
      // We DO NOT call storage.clearUsername() here.
      await storage.clearTokens();
      await storage.setHasCustomerNo(false);

      state = AuthState.initial();
    }
  }
}
