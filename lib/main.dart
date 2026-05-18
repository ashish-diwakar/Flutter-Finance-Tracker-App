import 'package:finance_tracker/features/auth/presentation/screens/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

import 'core/config/supabase_config.dart';
// import 'features/dashboard/presentation/dashboard_screen.dart';

final logger = Logger();

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(
    fileName: '.env'
  );

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: FinanceTrackerApp(),
    ),
  );
}

class FinanceTrackerApp
  extends StatelessWidget {

  const FinanceTrackerApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Finance Tracker',

      theme: ThemeData(
        useMaterial3: true,
      ),

      // home: const DashboardScreen(),
      home: const AuthGate(),
    );
  }
}