import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hillcrest_finance/app/core/providers/user_local_storage_provider.dart';
import 'package:hillcrest_finance/app/core/router/app_router.dart';
import 'package:hillcrest_finance/features/authentication/presentation/providers/auth_state_provider.dart';

@RoutePage()
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    print("[SPLASH] initState: Scheduling initialization.");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAppAndNavigate();
    });
  }

  Future<void> _initializeAppAndNavigate() async {
    print("[SPLASH] _initializeAppAndNavigate: Starting...");
    try {
      print("[SPLASH] Calling checkInitialStatus...");
      await ref
          .read(authStateProvider.notifier)
          .checkInitialStatus()
          .timeout(const Duration(seconds: 15)); // Added a timeout for safety
      print("[SPLASH] checkInitialStatus COMPLETED successfully.");
    } catch (e) {
      print("[SPLASH] checkInitialStatus FAILED or timed out: $e");
    }

    if (!mounted) {
      print("[SPLASH] Widget unmounted, aborting navigation.");
      return;
    }

    print("[SPLASH] Reading final state for navigation...");
    final storage = ref.read(userLocalStorageProvider);
    final authState = ref.read(authStateProvider);

    print("[SPLASH] Onboarding seen: ${storage.hasSeenOnboarding}");
    print("[SPLASH] Is Authenticated: ${authState.isAuthenticated}");

    if (!storage.hasSeenOnboarding) {
      print("[SPLASH] Navigating to Onboarding.");
      context.router.replaceAll([const WelcomeOnboardingRoute()]);
    } else if (authState.isAuthenticated) {
      print("[SPLASH] Navigating to Dashboard.");
      context.router.replaceAll([const DashboardRoute()]);
    } else {
      print("[SPLASH] Navigating to SignIn.");
      context.router.replaceAll([const SignInRoute()]);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("[SPLASH] build: Showing splash UI.");
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
