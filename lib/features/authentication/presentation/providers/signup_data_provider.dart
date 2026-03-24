import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpData {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String password;
  final String accountType;
  final String phoneNumber;

  SignUpData({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.password,
    required this.accountType,
    required this.phoneNumber,
  });
}

class SignUpDataNotifier extends Notifier<SignUpData?> {
  @override
  SignUpData? build() => null;

  void setSignUpData(SignUpData data) {
    state = data;
  }

  void clearSignUpData() {
    state = null;
  }
}

final signUpDataProvider = NotifierProvider<SignUpDataNotifier, SignUpData?>(
  () => SignUpDataNotifier(),
);
