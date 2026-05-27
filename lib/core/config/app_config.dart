import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {

  static String get companyName {

    return dotenv.env[
            'APP_COMPANY_NAME'] ??
        'Finance Tracker';
  }

  static String get appName {

    return dotenv.env[
            'APP_NAME'] ??
        'Finance Tracker';
  }
}