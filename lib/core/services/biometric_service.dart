import 'package:local_auth/local_auth.dart';

class BiometricService {

  static final LocalAuthentication
      auth = LocalAuthentication();

  static Future<bool> isBiometricsAvailable() async {
    try {
      final canCheck = await auth.canCheckBiometrics;
      final isSupported = await auth.isDeviceSupported();
      if (!canCheck || !isSupported) return false;
      
      final available = await auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<bool>
      authenticate() async {

    try {
      final isSupported =
          await auth.isDeviceSupported();

      if (!isSupported) {
        return false;
      }

      return await auth.authenticate(
        localizedReason:
            'Unlock Finance Tracker',

        options:
            const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

    } catch (e) {

      print(e);

      return false;
    }
  }
}