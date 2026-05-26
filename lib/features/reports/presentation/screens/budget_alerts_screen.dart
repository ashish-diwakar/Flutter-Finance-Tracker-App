import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/budget_alerts_provider.dart';
import '../widgets/budget_alerts_section.dart';

class BudgetAlertsScreen
    extends ConsumerWidget {

  const BudgetAlertsScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    final alertsAsync =
        ref.watch(
      budgetAlertsProvider,
    );

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'Budget Alerts',
        ),
      ),

      body: alertsAsync.when(

        data: (alerts) {

          if (alerts.isEmpty) {

            return const Center(

              child: Text(
                'No budget alerts available',
              ),
            );
          }

          return SafeArea(

            child: SingleChildScrollView(

              padding:
                  const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                40,
              ),

              child: BudgetAlertsSection(
                alerts: alerts,
              ),
            ),
          );
        },

        error: (_, __) =>

            const Center(

              child: Text(
                'Unable to load alerts',
              ),
            ),

        loading: () =>

            const Center(
              child:
                  CircularProgressIndicator(),
            ),
      ),
    );
  }
}