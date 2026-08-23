import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static final String appName =
      dotenv.env['APP_NAME'] ??
      'Finance Tracker';

  static final String appCompanyName =
      dotenv.env['APP_COMPANY_NAME'] ??
      'Diwakar Software Solutions';

  static final String appDescription =
      dotenv.env['APP_DESCRIPTION'] ??
      'Finance Tracker is a personal finance management application '
      'that helps users track their expenses, manage budgets, and gain '
      'insights into their financial habits. It provides features such '
      'as expense categorization, budget tracking, and financial '
      'reporting to help users make informed decisions about their '
      'finances.';

  static final String appCompanyWebsite =
      dotenv.env['APP_COMPANY_WEBSITE'] ??
      'https://www.diwakarsoftwaresolutions.com';

  static final String appVersion =
      dotenv.env['APP_VERSION'] ??
      '1.0.0';

  static final String appSupportEmail =
    dotenv.env['APP_SUPPORT_EMAIL'] ??
    'support4financetracker@diwakarsoftwaresolutions.com';
}