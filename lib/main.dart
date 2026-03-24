import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:overlay_support/overlay_support.dart'; // Import the package

import 'package:hillcrest_finance/app/core/theme/light_theme.dart';
import 'app/core/router/app_router.dart';

// Create router once to avoid recreation on rebuilds
final _appRouter = AppRouter();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  // Debug: Print to verify Neos vars are loaded
  print('NEOS_REALM: ${dotenv.env['NEOS_REALM']}');
  print('NEOS_CLIENT_ID: ${dotenv.env['NEOS_CLIENT_ID']}');
  print('NEOS_USERNAME: ${dotenv.env['NEOS_USERNAME']}');


  await Hive.initFlutter();

  // Make sure the box name matches what your providers expect (e.g. 'appData')
  await Hive.openBox('appData');

  runApp(const ProviderScope(child: HillCrestApp()));
}

class HillCrestApp extends ConsumerWidget {
  const HillCrestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Wrap the MaterialApp with OverlaySupport
    return OverlaySupport.global(
      child: MaterialApp.router(
        title: 'HillCrest Finance',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _appRouter.config(),
      ),
    );
  }
}
