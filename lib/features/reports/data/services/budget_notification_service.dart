import '../../../../core/constants/notification_constants.dart';
import '../../../../core/services/notification_service.dart';

import '../../domain/models/budget_alert_model.dart';

class BudgetNotificationService {

  static Future<void>
      processBudgetAlerts(

    List<BudgetAlertModel>
        alerts,
  ) async {

    for (final alert
        in alerts) {

      // ===================================
      // EXCEEDED
      // ===================================

      if (alert.type ==
          BudgetAlertType
              .exceeded) {

        await NotificationService
            .showNotification(

          id:
              NotificationIds
                      .budgetExceeded +
                  alert.category
                      .hashCode,

          title:
              'Budget Exceeded',

          body:
              '${alert.category} exceeded budget limit',
        );
      }

      // ===================================
      // WARNING
      // ===================================

      else if (alert.type ==
          BudgetAlertType
              .warning) {

        await NotificationService
            .showNotification(

          id:
              NotificationIds
                      .budgetWarning +
                  alert.category
                      .hashCode,

          title:
              'Budget Warning',

          body:
              '${alert.category} reached ${(alert.percentage * 100).toStringAsFixed(0)}% of budget',
        );
      }
    }
  }
}