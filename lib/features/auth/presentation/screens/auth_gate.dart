import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_screen.dart';
import '../../../security/presentation/screens/biometric_lock_screen.dart';

class AuthGate
    extends ConsumerWidget {

  const AuthGate({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    return StreamBuilder<AuthState>(

      stream: Supabase.instance.client.auth
          .onAuthStateChange,

      builder: (
        context,
        snapshot,
      ) {

        final session =
            Supabase.instance.client.auth
                .currentSession;

        if (session != null) {

          return const BiometricLockScreen();
        }

        return const LoginScreen();
      },
    );
  }
}