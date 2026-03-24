class ApiConstants {
  // --- KEYCLOAK OPENID CONNECT (FOR LOGIN/LOGOUT) ---
  static const String keycloakTokenEndpoint = '/auth/realms/{realm}/protocol/openid-connect/token';
  static const String keycloakLogoutEndpoint = '/auth/realms/{realm}/protocol/openid-connect/logout';
  static const String keycloakUserInfoEndpoint = '/auth/realms/{realm}/protocol/openid-connect/userinfo'; // ADDED

  // --- KEYCLOAK ADMIN API (FOR USER MANAGEMENT) ---
  static const String keycloakGetUsers = '/auth/admin/realms/{realm}/users';
  static const String keycloakCreateUser = '/auth/admin/realms/{realm}/users';
  static const String keycloakUpdateUser = '/auth/admin/realms/{realm}/users/{userId}';

  // --- ONBOARDING BACKEND API ---
  static const String initiateOnboarding = '/onboarding-api/1.0/newcustomer2/1/{firstName}/{lastName}';

  // --- .ENV KEY NAMES ---
  static const String onboardingApiKeyName = 'ONBOARDING_API_KEY';
}
