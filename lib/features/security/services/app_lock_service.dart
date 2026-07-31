import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AppLockService {

  AppLockService();

  final LocalAuthentication _auth =
      LocalAuthentication();

  /// Checks whether this device supports local authentication.
  Future<bool> isDeviceSupported() async {

    try {

      return await _auth.isDeviceSupported();

    } on PlatformException {

      return false;
    }
  }

  /// Returns true if biometric hardware exists and
  /// at least one biometric is enrolled.
  Future<bool> canCheckBiometrics() async {

    try {

      return await _auth.canCheckBiometrics;

    } on PlatformException {

      return false;
    }
  }

  /// Returns all enrolled biometric types.
  Future<List<BiometricType>>
      availableBiometrics() async {

    try {

      return await _auth.getAvailableBiometrics();

    } on PlatformException {

      return [];
    }
  }

  /// Authenticate using biometrics or device credentials.
  Future<bool> authenticate() async {

    try {

      return await _auth.authenticate(

        localizedReason:
            'Authenticate to access Finance Tracker',

        options:
            const AuthenticationOptions(

          biometricOnly: false,

          stickyAuth: true,

          sensitiveTransaction: false,
        ),
      );

    } on PlatformException {

      return false;
    }
  }

  Future<void> cancelAuthentication() async {

    try {

      await _auth.stopAuthentication();

    } on PlatformException {
      // Ignore
    }
  }
}