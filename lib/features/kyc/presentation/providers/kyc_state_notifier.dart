import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. The State
class KycState {
  final String? customerNo;
  final bool isLoading;

  const KycState({
    this.customerNo,
    this.isLoading = false,
  });

  KycState copyWith({
    String? customerNo,
    bool? isLoading,
  }) {
    return KycState(
      customerNo: customerNo ?? this.customerNo,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// 2. The Notifier
class KycStateNotifier extends Notifier<KycState> {
  @override
  KycState build() {
    return const KycState();
  }

  void setCustomerNo(String customerNo) {
    state = state.copyWith(customerNo: customerNo);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void clear() {
    state = const KycState();
  }
}

// 3. The Provider
final kycStateProvider = NotifierProvider<KycStateNotifier, KycState>(
  KycStateNotifier.new,
);
