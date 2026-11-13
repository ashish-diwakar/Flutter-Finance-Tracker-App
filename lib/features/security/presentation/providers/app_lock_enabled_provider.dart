import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/app_settings_service.dart';
import '../../../../core/services/logger_service.dart';

/// Shared launch decision and read-only Settings status for this app session.
final appLockEnabledProvider = FutureProvider<bool>((ref) async {
  try {
    return await AppSettingsService.loadAppLockEnabled();
  } catch (_) {
    LoggerService.error(
      'Unable to resolve app lock setting; requiring authentication.',
    );
    return true;
  }
});
