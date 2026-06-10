import 'package:finance_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_tracker/features/sync/presentation/providers/sync_provider.dart';
import 'package:finance_tracker/shared/providers/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class LogoutAppHelper {

  static Future<void>
      processLogout(
    WidgetRef ref,
  ) async {
    
      final auth =
                  ref.read(
                authServiceProvider,
              );

              await auth.signOut();
              ref.invalidate(isarProvider);
              ref.invalidate(syncServiceProvider);

  }
}


