// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Otp)
const otpProvider = OtpProvider._();

final class OtpProvider extends $NotifierProvider<Otp, String?> {
  const OtpProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'otpProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$otpHash();

  @$internal
  @override
  Otp create() => Otp();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$otpHash() => r'6813c8cec4c1add2e316de54ea7da7d576801eb5';

abstract class _$Otp extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
