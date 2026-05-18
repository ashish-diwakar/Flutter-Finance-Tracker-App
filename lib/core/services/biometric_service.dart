import 'package:local_auth/local_auth.dart';

class BiometricService {

  static final LocalAuthentication
      auth = LocalAuthentication();

  static Future<bool>
      authenticate() async {

    try {

      final canCheck =
          await auth.canCheckBiometrics;

      final isSupported =
          await auth.isDeviceSupported();

      if (!canCheck || !isSupported) {
        return false;
      }

      final available =
          await auth.getAvailableBiometrics();

      if (available.isEmpty) {
        return false;
      }

      return await auth.authenticate(
        localizedReason:
            'Unlock Finance Tracker',

        options:
            const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

    } catch (e) {

      print(e);

      return false;
    }
  }
}