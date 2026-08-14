import 'package:finance_tracker/core/constants/app_constants.dart';
import 'package:local_auth/local_auth.dart';

class AppLockService {

  static final LocalAuthentication _auth =
      LocalAuthentication();

  static Future<bool> unlock() async {

    return await _auth.authenticate(

      localizedReason:
          'Authenticate to access ${AppConstants.appName}',

      options: const AuthenticationOptions(

        biometricOnly: false,

        stickyAuth: true,
      ),
    );
  }
}