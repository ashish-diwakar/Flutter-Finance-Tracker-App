import 'package:finance_tracker/features/auth/presentation/screens/auth_gate.dart';
//import 'package:finance_tracker/shared/utils/logger_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../core/services/logger_service.dart';
import 'core/config/supabase_config.dart';
import 'core/database/isar_service.dart';
import 'core/services/deep_link_service.dart';
import 'core/services/notification_service.dart';
import 'features/recurring/data/services/recurring_scheduler_service.dart';
import 'features/reports/data/services/budget_alert_checker.dart';
import 'features/reports/data/services/budget_notification_service.dart';


final navigatorKey =
    GlobalKey<NavigatorState>();

Future<void> main() async {

  WidgetsFlutterBinding
      .ensureInitialized();

  try {

    // =====================================================
    // ENVIRONMENT
    // =====================================================

    await dotenv.load(
      fileName: '.env',
    );

    // =====================================================
    // SUPABASE
    // =====================================================

    await Supabase.initialize(

      url:
          SupabaseConfig
              .supabaseUrl,

      anonKey:
          SupabaseConfig
              .supabaseAnonKey,
    );

    // =====================================================
    // NOTIFICATIONS
    // =====================================================

    await NotificationService
    .initialize();

    // =====================================================
    // ISAR
    // =====================================================

    final isar =
    await IsarService
        .openIsar();

    // =====================================================
    // RECURRING TRANSACTIONS
    // =====================================================

    final recurringScheduler =
        RecurringSchedulerService(
      isar,
    );

    await recurringScheduler
        .processRecurringTransactions();


    // =====================================================
    // BUDGET ALERTS
    // =====================================================
    final budgetChecker =
        BudgetAlertChecker(
      isar,
    );

    final alerts =
        await budgetChecker
            .checkAlerts(includeSafe: false);

    await BudgetNotificationService
        .processBudgetAlerts(
      alerts,
    );

    // =====================================================
    // DEEP LINKS
    // =====================================================

    DeepLinkService.initialize(
      navigatorKey:
          navigatorKey,
    );

    LoggerService.info(
      'Application initialized successfully',
    );

    // =====================================================
    // START APP
    // =====================================================

    runApp(

      const ProviderScope(

        child:
            FinanceTrackerApp(),
      ),
    );

    await Future.delayed(
      const Duration(seconds: 1),
    );

    // =====================================================
    // TESTING NOTIFICATIONS
    // =====================================================
    // await NotificationService
    //     .showNotification(

    //   id: 1,

    //   title: 'Finance Tracker',

    //   body:
    //       'Notifications are working successfully.',
    // );

  } catch (e, stack) {

    LoggerService.error('Application startup failed');    
    LoggerService.error('-------------------------------------------------');
    LoggerService.error('Error: $e');
    LoggerService.error('-------------------------------------------------');    
    LoggerService.error('Stack Trace: $stack');
    LoggerService.error('-------------------------------------------------');

    runApp(

      MaterialApp(

        debugShowCheckedModeBanner:
            false,

        home: Scaffold(

          body: Center(

            child: Padding(

              padding:
                  const EdgeInsets.all(
                24,
              ),

              child: Column(

                mainAxisAlignment:
                    MainAxisAlignment
                        .center,

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

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  const Text(

                    'Please restart the application.',

                    textAlign:
                        TextAlign.center,
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  SelectableText(
                    e.toString(),
                    textAlign:
                        TextAlign.center,
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

      debugShowCheckedModeBanner:
          false,

      title:
          'Finance Tracker',

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
                BorderRadius.circular(
              16,
            ),
          ),
        ),

        inputDecorationTheme:
            InputDecorationTheme(

          border:
              OutlineInputBorder(

            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
        ),
      ),

      home: const AuthGate(),
    );
  }
}