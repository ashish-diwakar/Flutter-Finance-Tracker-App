import 'package:finance_tracker/shared/utils/provider_refresh_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../reports/presentation/screens/reports_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../transactions/presentation/screens/transaction_list_container_screen.dart';
import '../../../borrow_lend/presentation/screens/borrow_lend_screen.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../transactions/presentation/screens/transaction_details_screen.dart';
import '../../../borrow_lend/presentation/providers/borrow_lend_provider.dart';

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


  bool _handlingPendingNotification = false;

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();

    screens = const [
      DashboardScreen(),
      TransactionListContainerScreen(),
      BorrowLendScreen(),
      ReportsScreen(),
      SettingsScreen(),
    ];

    NotificationService.setPendingPayloadHandler(
      () {
        _handlePendingNotification();
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handlePendingNotification();
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    final borrowLendOverviewAsync =
        ref.watch(
      borrowLendOverviewProvider,
    );

    final borrowLendActionableCount =
        borrowLendOverviewAsync.maybeWhen(
      data: (overview) =>
          overview.actionableCount,
      orElse: () => 0,
    );

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

        labelBehavior:
            NavigationDestinationLabelBehavior
                .onlyShowSelected,

        selectedIndex:
            currentIndex,

        onDestinationSelected:
          (index) {

          // =====================================================
          // REFRESH REPORTS WHEN REPORTS TAB IS OPENED
          // =====================================================
          if (index == 3) {
            
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

        // destinations: const [

        //   NavigationDestination(

        //     icon:
        //         Icon(Icons.home_outlined),

        //     selectedIcon:
        //         Icon(Icons.home),

        //     label: 'Home',
        //   ),

        //   NavigationDestination(

        //     icon: Icon(
        //       Icons.receipt_long_outlined,
        //     ),

        //     selectedIcon:
        //         Icon(
        //       Icons.receipt_long,
        //     ),

        //     label: 'Transactions',
        //   ),

        //   NavigationDestination(

        //     icon: Icon(
        //       Icons.bar_chart_outlined,
        //     ),

        //     selectedIcon:
        //         Icon(Icons.bar_chart),

        //     label: 'Reports',
        //   ),

        //   NavigationDestination(

        //     icon:
        //         Icon(Icons.settings_outlined),

        //     selectedIcon:
        //         Icon(Icons.settings),

        //     label: 'Settings',
        //   ),
        // ],
        destinations: [
          const NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),

          const NavigationDestination(
            icon: Icon(
              Icons.receipt_long_outlined,
            ),
            selectedIcon: Icon(
              Icons.receipt_long,
            ),
            label: 'Transactions',
          ),

          NavigationDestination(
            icon: Badge(
              isLabelVisible:
                  borrowLendActionableCount > 0,
              label: Text(
                borrowLendActionableCount > 99
                    ? '99+'
                    : '$borrowLendActionableCount',
              ),
              child: const Icon(
                Icons.handshake_outlined,
              ),
            ),
            selectedIcon: Badge(
              isLabelVisible:
                  borrowLendActionableCount > 0,
              label: Text(
                borrowLendActionableCount > 99
                    ? '99+'
                    : '$borrowLendActionableCount',
              ),
              child: const Icon(
                Icons.handshake,
              ),
            ),
            label: 'Borrow/Lend',
          ),

          const NavigationDestination(
            icon: Icon(
              Icons.bar_chart_outlined,
            ),
            selectedIcon: Icon(
              Icons.bar_chart,
            ),
            label: 'Reports',
          ),

          const NavigationDestination(
            icon: Icon(
              Icons.settings_outlined,
            ),
            selectedIcon: Icon(
              Icons.settings,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Future<void> _handlePendingNotification() async {
    if (_handlingPendingNotification ||
        !mounted) {
      return;
    }

    final payload =
        NotificationService.takePendingPayload();

    if (payload == null) {
      return;
    }

    const prefix = 'borrow_lend:';

    if (!payload.startsWith(prefix)) {
      return;
    }

    final transactionUuid =
        payload
            .substring(prefix.length)
            .trim();

    if (transactionUuid.isEmpty) {
      return;
    }

    _handlingPendingNotification = true;

    try {
      final transactions =
          await ref.read(
        transactionsStreamProvider.future,
      );

      if (!mounted) {
        return;
      }

      final matchingTransactions =
          transactions.where(
        (transaction) =>
            !transaction.isDeleted &&
            transaction.uuid ==
                transactionUuid &&
            (transaction.type == 'borrowed' ||
                transaction.type == 'lent'),
      );

      if (matchingTransactions.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'This Borrow/Lend transaction is no longer available.',
            ),
          ),
        );

        return;
      }

      final transaction =
          matchingTransactions.first;

      setState(() {
        currentIndex = 2;
      });

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              TransactionDetailsScreen(
            transaction: transaction,
          ),
        ),
      );
    } catch (e, stackTrace) {
      LoggerService.exception(
        'Unable to open Borrow/Lend notification',
        e,
        stackTrace,
      );

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to open the reminder.',
            ),
          ),
        );
      }
    } finally {
      _handlingPendingNotification = false;
    }
  }

  @override
  void dispose() {
    NotificationService
        .setPendingPayloadHandler(
      null,
    );

    super.dispose();
  }

}