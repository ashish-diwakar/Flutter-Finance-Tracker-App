import 'package:finance_tracker/shared/utils/provider_refresh_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../reports/presentation/screens/reports_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../transactions/presentation/screens/transaction_list_container_screen.dart';

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

    // WidgetsBinding.instance
    //     .addPostFrameCallback((_) async {
    // });
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

          // =====================================================
          // REFRESH REPORTS WHEN REPORTS TAB IS OPENED
          // =====================================================
          if (index == 2) {
            
            DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
            ProviderRefreshHelper.refreshReportsData(ref, selectedMonth);
           
            /*
              // TEST POPUP
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;

                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text(
                        'Reports Opened',
                      ),
                      content: const Text(
                        'Test popup: Reports screen has been opened.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              });
              */
          }

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