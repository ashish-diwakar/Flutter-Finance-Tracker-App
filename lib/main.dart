import 'package:finance_tracker/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/isar_service.dart';
import 'core/services/logger_service.dart';
import 'features/security/presentation/screens/app_lock_screen.dart';

final navigatorKey =
    GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // =====================================================
    // ENVIRONMENT
    // =====================================================

    await dotenv.load(
      fileName: '.env',
    );

    // =====================================================
    // ISAR
    // =====================================================

    await IsarService.openIsar();

    // =====================================================
    // START APP
    // =====================================================

    runApp(
      const ProviderScope(
        child: FinanceTrackerApp(),
      ),
    );
  } catch (e, stack) {
    LoggerService.exception(
      'Application Startup Failed',
      e,
      stack,
    );

    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 72,
                    color: Colors.red,
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  const Text(
                    'Application failed to start',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  const Text(
                    'Please restart the application.',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  SelectableText(
                    e.toString(),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FinanceTrackerApp
    extends StatelessWidget {
  const FinanceTrackerApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title:
          AppConstants.appName,

      navigatorKey:
          navigatorKey,

      theme: ThemeData(
        useMaterial3: true,

        colorSchemeSeed:
            Colors.green,

        brightness:
            Brightness.light,

        scaffoldBackgroundColor:
            Colors.grey.shade50,

        appBarTheme:
            const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),

        cardTheme:
            CardThemeData(
          elevation: 1,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
        ),

        inputDecorationTheme:
            InputDecorationTheme(
          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      ),

      home:
          const AppLockScreen(),
    );
  }
}