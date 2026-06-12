import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../reports/presentation/screens/reports_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../transactions/presentation/screens/transaction_list_container_screen.dart';
import '../../../sync/presentation/providers/background_sync_provider.dart';

class MainNavigationScreen
    extends ConsumerStatefulWidget {

  const MainNavigationScreen({
    super.key,
  });

  @override
  ConsumerState<MainNavigationScreen>
      createState() =>
          _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends ConsumerState<MainNavigationScreen> {

  int currentIndex = 0;

  late final List<Widget> screens;

  @override
  void initState() {

    super.initState();

    screens = const [

      DashboardScreen(),

      TransactionListContainerScreen(),

      ReportsScreen(),

      SettingsScreen(),
    ];

    WidgetsBinding.instance
        .addPostFrameCallback((_) async {

      try {

        await ref.read(
          backgroundSyncProvider.future,
        );

      } catch (_) {

        // Ignore initialization failures.
        // Background sync will retry on next app resume.
      }
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      body: IndexedStack(

        index: currentIndex,

        children: screens,
      ),

      bottomNavigationBar:
          NavigationBar(

        backgroundColor:
            const Color.fromRGBO(
          176,
          211,
          245,
          0.498,
        ),

        selectedIndex:
            currentIndex,

        onDestinationSelected:
            (index) {

          setState(() {

            currentIndex = index;
          });
        },

        destinations: const [

          NavigationDestination(

            icon:
                Icon(Icons.home_outlined),

            selectedIcon:
                Icon(Icons.home),

            label: 'Home',
          ),

          NavigationDestination(

            icon: Icon(
              Icons.receipt_long_outlined,
            ),

            selectedIcon:
                Icon(
              Icons.receipt_long,
            ),

            label: 'Transactions',
          ),

          NavigationDestination(

            icon: Icon(
              Icons.bar_chart_outlined,
            ),

            selectedIcon:
                Icon(Icons.bar_chart),

            label: 'Reports',
          ),

          NavigationDestination(

            icon:
                Icon(Icons.settings_outlined),

            selectedIcon:
                Icon(Icons.settings),

            label: 'Settings',
          ),
        ],
      ),
    );
  }
}