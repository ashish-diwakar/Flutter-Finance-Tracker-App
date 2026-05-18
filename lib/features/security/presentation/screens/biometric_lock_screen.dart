import 'package:finance_tracker/main.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/biometric_service.dart';
import '../../../dashboard/presentation/dashboard_screen.dart';

class BiometricLockScreen
    extends StatefulWidget {

  const BiometricLockScreen({
    super.key,
  });

  @override
  State<BiometricLockScreen>
      createState() =>
          _BiometricLockScreenState();
}

class _BiometricLockScreenState
    extends State<BiometricLockScreen> {

  bool loading = false;

  Future<void> authenticate()
      async {

    setState(() {
      loading = true;
    });

    final success =
        await BiometricService
            .authenticate();

    logger.d('BIOMETRIC RESULT: $success');

    if (success && mounted) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const DashboardScreen(),
        ),
      );
    }

    if (mounted) {

      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {

    super.initState();

    authenticate();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Center(

        child: loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed:
                    authenticate,

                child: const Text(
                  'Unlock',
                ),
              ),
      ),
    );
  }
}