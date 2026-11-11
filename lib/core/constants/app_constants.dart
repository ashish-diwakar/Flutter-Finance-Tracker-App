import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../config/release_configuration.dart';

class AppConstants {
  static final String appName = dotenv.env['APP_NAME'] ?? 'Finance Tracker';

  static final String appCompanyName =
      dotenv.env['APP_COMPANY_NAME'] ?? 'Diwakar Software Solutions';

  static final String appDescription =
      dotenv.env['APP_DESCRIPTION'] ??
      'Finance Tracker is a personal finance management application '
          'that helps users track their expenses, manage budgets, and gain '
          'insights into their financial habits. It provides features such '
          'as expense categorization, budget tracking, and financial '
          'reporting to help users make informed decisions about their '
          'finances.';

  static String get appCompanyWebsite =>
      ReleaseConfiguration.website(dotenv.env['APP_COMPANY_WEBSITE']);

  static String get appCompanyWebsiteFinanceTracker =>
      ReleaseConfiguration.website(
        dotenv.env['APP_COMPANY_WEBSITE_FINANCE_TRACKER'],
      );

  static final String appVersion = dotenv.env['APP_VERSION'] ?? '1.0.0';

  static String get privacyPolicyLastUpdated => ReleaseConfiguration.revision(
    dotenv.env['APP_PRIVACY_POLICY_LAST_UPDATED'],
  );

  static String get appSupportEmail =>
      ReleaseConfiguration.email(dotenv.env['APP_SUPPORT_EMAIL']);
}
