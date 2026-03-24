import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hillcrest_finance/app/core/network/auth_interceptor.dart';
import 'package:hillcrest_finance/app/core/providers/networking_provider.dart';

// Create a factory function instead of a single instance
AuthInterceptor createAuthInterceptor(Ref ref) {
  return AuthInterceptor(
    secureStorage: ref.read(secureStorageProvider),
  );
}

// Keep this for backward compatibility if needed elsewhere
final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return createAuthInterceptor(ref);
});