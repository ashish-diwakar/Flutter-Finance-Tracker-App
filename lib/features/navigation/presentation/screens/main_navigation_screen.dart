import 'package:flutter/material.dart';

import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../reports/presentation/screens/reports_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../transactions/presentation/screens/transaction_list_container_screen.dart';

class MainNavigationScreen
    extends StatefulWidget {

  const MainNavigationScreen({
    super.key,
  });

  @override
  State<MainNavigationScreen>
      createState() =>
          _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {

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
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: IndexedStack(

        index: currentIndex,

        children: screens,
      
      ),

      bottomNavigationBar:
          NavigationBar(
        
        backgroundColor: Color.fromRGBO(176, 211, 245, 0.498), // Theme.of(context).scaffoldBackgroundColor,

        selectedIndex:
            currentIndex,

        onDestinationSelected:
            (index) {

          setState(() {

            currentIndex =
                index;
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