import 'dart:io';
import 'package:flutter/foundation.dart';

String getCurrentDevice() {

  if (kIsWeb) {
    return 'Web';
  }

  if (Platform.isAndroid) {
    return 'Android';
  }

  if (Platform.isIOS) {
    return 'iOS';
  }

  if (Platform.isWindows) {
    return 'Windows';
  }

  if (Platform.isMacOS) {
    return 'macOS';
  }

  if (Platform.isLinux) {
    return 'Linux';
  }

  return 'Unknown';
}