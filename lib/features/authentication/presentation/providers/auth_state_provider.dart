import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_state_notifier.dart';
import 'auth_state.dart';

// Modern syntax: NotifierProvider instead of StateNotifierProvider
final authStateProvider = NotifierProvider<AuthStateNotifier, AuthState>(() {
  return AuthStateNotifier();
});

class OtpVerificationState {
  final bool isEmailVerified;
  final bool isSmsVerified;

  OtpVerificationState({
    required this.isEmailVerified,
    required this.isSmsVerified,
  });

  bool get bothVerified => isEmailVerified && isSmsVerified;

  OtpVerificationState copyWith({bool? isEmailVerified, bool? isSmsVerified}) {
    return OtpVerificationState(
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isSmsVerified: isSmsVerified ?? this.isSmsVerified,
    );
  }
}

// Modern syntax: NotifierProvider with a Notifier class
class OtpVerificationNotifier extends Notifier<OtpVerificationState> {
  @override
  OtpVerificationState build() {
    return OtpVerificationState(isEmailVerified: false, isSmsVerified: false);
  }

  void setEmailVerified(bool value) {
    state = state.copyWith(isEmailVerified: value);
  }

  void setSmsVerified(bool value) {
    state = state.copyWith(isSmsVerified: value);
  }

  void reset() {
    state = OtpVerificationState(isEmailVerified: false, isSmsVerified: false);
  }
}

final otpVerificationStateProvider = NotifierProvider<OtpVerificationNotifier, OtpVerificationState>(() {
  return OtpVerificationNotifier();
});