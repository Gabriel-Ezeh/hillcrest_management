import 'package:hillcrest_finance/features/authentication/data/models/keycloak_user.dart';
import '../../data/models/token_response.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final TokenResponse? token;
  final KeycloakUser? user;
  final bool hasCustomerNo;
  final String? accountType;

  AuthState({
    required this.isAuthenticated,
    required this.isLoading,
    this.token,
    this.user,
    this.hasCustomerNo = false,
    this.accountType,
  });

  // Getter to resolve the undefined_getter error in the UI
  String? get firstName => user?.firstName;

  factory AuthState.initial() {
    return AuthState(
      isAuthenticated: false,
      isLoading: false,
      hasCustomerNo: false,
    );
  }

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    TokenResponse? token,
    KeycloakUser? user,
    bool? hasCustomerNo,
    String? accountType,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      user: user ?? this.user,
      hasCustomerNo: hasCustomerNo ?? this.hasCustomerNo,
      accountType: accountType ?? this.accountType,
    );
  }
}