// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'networking_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(secureStorage)
const secureStorageProvider = SecureStorageProvider._();

final class SecureStorageProvider
    extends
        $FunctionalProvider<
          FlutterSecureStorage,
          FlutterSecureStorage,
          FlutterSecureStorage
        >
    with $Provider<FlutterSecureStorage> {
  const SecureStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureStorageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureStorageHash();

  @$internal
  @override
  $ProviderElement<FlutterSecureStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FlutterSecureStorage create(Ref ref) {
    return secureStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlutterSecureStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlutterSecureStorage>(value),
    );
  }
}

String _$secureStorageHash() => r'273dc403a965c1f24962aaf4d40776611a26f8b8';

@ProviderFor(authDio)
const authDioProvider = AuthDioProvider._();

final class AuthDioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  const AuthDioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authDioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authDioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return authDio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$authDioHash() => r'2204f375985c05f28bf60e4887390e746e7e728e';

@ProviderFor(onboardingDio)
const onboardingDioProvider = OnboardingDioProvider._();

final class OnboardingDioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  const OnboardingDioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingDioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingDioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return onboardingDio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$onboardingDioHash() => r'1a6c54e8df37f43ee79e3e53bdf4c2e73910ee2d';

@ProviderFor(otpDio)
const otpDioProvider = OtpDioProvider._();

final class OtpDioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  const OtpDioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'otpDioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$otpDioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return otpDio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$otpDioHash() => r'f944eb8afd95543604ba646f5e8efc8e32515cab';

@ProviderFor(dio)
const dioProvider = DioProvider._();

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  const DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'3c5843e06b2ae2b00d5743b553d41ddf0ec0f2dd';

@ProviderFor(kycDio)
const kycDioProvider = KycDioProvider._();

final class KycDioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  const KycDioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kycDioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kycDioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return kycDio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$kycDioHash() => r'a98be713eac395248130ffa8aa3ce539ee89164c';

@ProviderFor(dummyDio)
const dummyDioProvider = DummyDioProvider._();

final class DummyDioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  const DummyDioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dummyDioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dummyDioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dummyDio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dummyDioHash() => r'75cf90cbfef4a5d4323d9c61d7edd28f17a31dec';

@ProviderFor(authApiClient)
const authApiClientProvider = AuthApiClientProvider._();

final class AuthApiClientProvider
    extends $FunctionalProvider<AuthApiClient, AuthApiClient, AuthApiClient>
    with $Provider<AuthApiClient> {
  const AuthApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authApiClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authApiClientHash();

  @$internal
  @override
  $ProviderElement<AuthApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthApiClient create(Ref ref) {
    return authApiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthApiClient>(value),
    );
  }
}

String _$authApiClientHash() => r'0b996e145002a2dda5504dbebfd3017cbe75d0cf';

@ProviderFor(onboardingApiClient)
const onboardingApiClientProvider = OnboardingApiClientProvider._();

final class OnboardingApiClientProvider
    extends
        $FunctionalProvider<
          OnboardingApiClient,
          OnboardingApiClient,
          OnboardingApiClient
        >
    with $Provider<OnboardingApiClient> {
  const OnboardingApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingApiClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingApiClientHash();

  @$internal
  @override
  $ProviderElement<OnboardingApiClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OnboardingApiClient create(Ref ref) {
    return onboardingApiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingApiClient>(value),
    );
  }
}

String _$onboardingApiClientHash() =>
    r'53db5797d59f5264cc10384402af07721beaf4ae';

@ProviderFor(otpApiClient)
const otpApiClientProvider = OtpApiClientProvider._();

final class OtpApiClientProvider
    extends $FunctionalProvider<OtpApiClient, OtpApiClient, OtpApiClient>
    with $Provider<OtpApiClient> {
  const OtpApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'otpApiClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$otpApiClientHash();

  @$internal
  @override
  $ProviderElement<OtpApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OtpApiClient create(Ref ref) {
    return otpApiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OtpApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OtpApiClient>(value),
    );
  }
}

String _$otpApiClientHash() => r'14070e9441f303a33827de9a402191c4c4eb3368';

@ProviderFor(kycApiClient)
const kycApiClientProvider = KycApiClientProvider._();

final class KycApiClientProvider
    extends $FunctionalProvider<KycApiClient, KycApiClient, KycApiClient>
    with $Provider<KycApiClient> {
  const KycApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kycApiClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kycApiClientHash();

  @$internal
  @override
  $ProviderElement<KycApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KycApiClient create(Ref ref) {
    return kycApiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KycApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KycApiClient>(value),
    );
  }
}

String _$kycApiClientHash() => r'7b71a65ba065f15605a7d506f2552e9df58a1609';

@ProviderFor(investmentApiClient)
const investmentApiClientProvider = InvestmentApiClientProvider._();

final class InvestmentApiClientProvider
    extends
        $FunctionalProvider<
          InvestmentApiClient,
          InvestmentApiClient,
          InvestmentApiClient
        >
    with $Provider<InvestmentApiClient> {
  const InvestmentApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'investmentApiClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$investmentApiClientHash();

  @$internal
  @override
  $ProviderElement<InvestmentApiClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InvestmentApiClient create(Ref ref) {
    return investmentApiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InvestmentApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InvestmentApiClient>(value),
    );
  }
}

String _$investmentApiClientHash() =>
    r'fea7c28c71418c55d1d8163db19fa8ef93e96c40';

@ProviderFor(authRepository)
const authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  const AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'ec63a58cc733927e2b9c8fdea677f2e89d3aa85e';

@ProviderFor(investmentRepository)
const investmentRepositoryProvider = InvestmentRepositoryProvider._();

final class InvestmentRepositoryProvider
    extends
        $FunctionalProvider<
          InvestmentRepository,
          InvestmentRepository,
          InvestmentRepository
        >
    with $Provider<InvestmentRepository> {
  const InvestmentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'investmentRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$investmentRepositoryHash();

  @$internal
  @override
  $ProviderElement<InvestmentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InvestmentRepository create(Ref ref) {
    return investmentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InvestmentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InvestmentRepository>(value),
    );
  }
}

String _$investmentRepositoryHash() =>
    r'cce929786e930b3221e09a8c777f40cd3fb8797e';
