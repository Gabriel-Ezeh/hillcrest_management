import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'otp_provider.g.dart';

@Riverpod(keepAlive: true)  // ⭐ ADD THIS
class Otp extends _$Otp {
  @override
  String? build() => null;

  void setOtp(String? value) {
    print('💾 Setting OTP in provider: "$value"');
    state = value;
    print('💾 Provider state after setting: "$state"');
  }

  void clearOtp() {
    print('🗑️ Clearing OTP from provider');
    state = null;
  }
}