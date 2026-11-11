import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/aurora_app_bar.dart';
import '../../../support/presentation/support_contact_actions.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();
  SupportContactActions get _contactActions => SupportContactActions(
    supportEmail: AppConstants.appSupportEmail,
    companyWebsite: AppConstants.appCompanyWebsiteFinanceTracker,
  );

  Widget _infoCard(Widget child) => SizedBox(
    width: double.infinity,
    child: Card(
      margin: EdgeInsets.zero,
      color: const Color(0xFFF1F8F2),
      surfaceTintColor: Colors.transparent,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFA8CFC0)),
      ),
      child: child,
    ),
  );

  Widget _infoIcon(IconData icon) => Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      color: const Color(0xFFE2F0E8),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: const Color(0xFF17664F), size: 22),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuroraAppBar(title: Text('Privacy Policy')),

      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFB6D7CC),
                  Color(0xFFDAEDE5),
                  Color(0xFFF8FCFA),
                ],
                stops: [0.0, 0.52, 1.0],
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: Color(0xFF315F53),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                FutureBuilder<PackageInfo>(
                  future: _packageInfo,
                  builder: (context, snapshot) {
                    final version = snapshot.data?.version.trim() ?? '';
                    final versionLabel = version.isEmpty
                        ? snapshot.connectionState == ConnectionState.waiting
                              ? 'Checking app version…'
                              : 'App version unavailable'
                        : 'App version $version';
                    return Text(
                      '${AppConstants.appName} • $versionLabel',
                      style: const TextStyle(
                        color: Color(0xFF416157),
                        fontSize: 14,
                        height: 1.35,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                _PolicySection(
                  title: '1. Introduction',
                  content:
                      '${AppConstants.appName} is a personal finance '
                      'management application developed by '
                      '${AppConstants.appCompanyName}. '
                      'This Privacy Policy explains how information '
                      'is handled when you use the application.',
                ),

                const _PolicySection(
                  title: '2. Financial Information',
                  content:
                      'The application allows you to enter and manage '
                      'financial information such as income, expenses, '
                      'accounts, categories, budgets, financial goals, '
                      'investments, and recurring transactions. '
                      'This information is stored locally on your device '
                      'for use within the application.',
                ),

                _PolicySection(
                  title: '3. Local Storage',
                  content:
                      'Financial information is stored locally on your '
                      'device using the application database. '
                      '${AppConstants.appCompanyName} does not currently '
                      'operate a cloud synchronization service for this '
                      'information and the application does not require '
                      'an account or login to use its core functionality.',
                ),

                _PolicySection(
                  title: '4. Device Authentication',
                  content:
                      '${AppConstants.appName} may use your device\'s '
                      'biometric authentication or device passcode to '
                      'protect access to the application. '
                      'The application does not receive or store your '
                      'fingerprint, face data, PIN, password, or other '
                      'biometric credentials. Authentication is handled '
                      'by the operating system.',
                ),

                const _PolicySection(
                  title: '5. Notifications',
                  content:
                      'The application may create local notifications '
                      'for features such as financial reminders, '
                      'recurring transactions, and budget alerts. '
                      'These notifications are generated by the '
                      'application on your device.',
                ),

                _PolicySection(
                  title: '6. Backup, Export and Sharing',
                  content:
                      '${AppConstants.appName} provides user-initiated '
                      'backup and export functionality. Depending on '
                      'the feature used, financial information may be '
                      'exported to files such as JSON, CSV, or PDF. '
                      'When you choose to share an exported file using '
                      'your device\'s sharing functionality, the file '
                      'may be transferred to an application or service '
                      'you select. The handling of that information is '
                      'then subject to the privacy policy of the '
                      'selected third-party application or service.\n\n'
                      'Exporting or sharing financial information may create temporary or cached files on your device. '
                      'Files saved or shared with other applications or services may remain outside Finance Tracker\'s control. '
                      'Finance Tracker does not currently add its own password protection or encryption to exported files.',
                ),

                const _PolicySection(
                  title: '7. Network Connectivity',
                  content:
                      'The application may check the device\'s network '
                      'connectivity status to determine whether the '
                      'device is connected to a network. This information '
                      'is used for application functionality and does '
                      'not mean that your financial records are uploaded '
                      'to our servers.',
                ),

                _PolicySection(
                  title: '8. Data Sharing',
                  content:
                      '${AppConstants.appName} does not currently '
                      'require users to upload their financial records '
                      'to ${AppConstants.appCompanyName} servers. '
                      'The application does not currently provide cloud '
                      'synchronization of financial records.',
                ),

                const _PolicySection(
                  title: '9. Data Security',
                  content:
                      'We aim to protect information stored by the '
                      'application through the security mechanisms '
                      'provided by the device and the application. '
                      'Users should also protect their device using a '
                      'secure screen lock and should avoid sharing '
                      'exported backup files with untrusted parties.',
                ),

                const _PolicySection(
                  title: '10. Data Retention and Deletion',
                  content:
                      'Financial information is primarily stored in the application\'s local database. '
                      'Some deletion actions may mark records as deleted or hide them from normal views without immediately removing them from the database. '
                      'Deleted or archived records may also be included in exported backups.\n\n'
                      'Files previously exported or shared are separate from the application\'s database and may remain where they were saved or shared. '
                      'Clearing application data or uninstalling the application does not necessarily remove those external copies or copies retained by operating-system backup services.\n\n'
                      'Active recurring schedules may continue generating new financial records until they are disabled or deleted.',
                ),

                _PolicySection(
                  title: '11. Children\'s Privacy',
                  content:
                      '${AppConstants.appName} is intended for general '
                      'personal financial management and is not designed '
                      'specifically for children. We do not knowingly '
                      'collect personal information from children through '
                      'a server-based account system.',
                ),

                const _PolicySection(
                  title: '12. Changes to This Privacy Policy',
                  content:
                      'This Privacy Policy may be updated when the '
                      'application\'s functionality, data handling, or '
                      'services change. The latest version will be made '
                      'available through the application or the relevant '
                      'company website.',
                ),

                _PolicySection(
                  title: '13. Contact Us',
                  content:
                      'If you have questions, concerns, or need support '
                      'regarding privacy or the application, please '
                      'contact ${AppConstants.appCompanyName}.',
                ),

                const SizedBox(height: 8),

                if (AppConstants.appSupportEmail.isNotEmpty) ...[
                  Tooltip(
                    message: 'Copy support email address',
                    excludeFromSemantics: true,
                    child: Semantics(
                      label: 'Copy support email address',
                      button: true,
                      child: _infoCard(
                        InkWell(
                          onTap: () =>
                              _contactActions.copySupportEmail(context),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _infoIcon(Icons.email_outlined),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Support Email',
                                        style: TextStyle(
                                          color: Color(0xFF315F53),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        AppConstants.appSupportEmail,
                                        softWrap: true,
                                        style: const TextStyle(
                                          color: Color(0xFF416157),
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox.square(
                                  dimension: 48,
                                  child: Icon(
                                    Icons.copy_outlined,
                                    color: Color(0xFF17664F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF17664F),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () =>
                          _contactActions.openSupportEmail(context),
                      icon: const Icon(Icons.email_outlined),
                      label: const Text('Email Support'),
                    ),
                  ),
                ] else
                  _infoCard(
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Support email unavailable'),
                    ),
                  ),

                const SizedBox(height: 16),

                _infoCard(
                  Semantics(
                    label: AppConstants.appCompanyWebsiteFinanceTracker.isEmpty
                        ? 'Company website unavailable'
                        : 'Open company website: ${AppConstants.appCompanyWebsiteFinanceTracker}',
                    link:
                        AppConstants.appCompanyWebsiteFinanceTracker.isNotEmpty,
                    child: InkWell(
                      onTap:
                          AppConstants
                              .appCompanyWebsiteFinanceTracker
                              .isNotEmpty
                          ? () => _contactActions.openCompanyWebsite(context)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _infoIcon(Icons.business_outlined),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    AppConstants.appCompanyName,
                                    style: const TextStyle(
                                      color: Color(0xFF315F53),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (AppConstants
                                    .appCompanyWebsiteFinanceTracker
                                    .isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.open_in_new,
                                    color: Color(0xFF315F53),
                                    size: 20,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppConstants
                                      .appCompanyWebsiteFinanceTracker
                                      .isEmpty
                                  ? 'Company website unavailable'
                                  : AppConstants
                                        .appCompanyWebsiteFinanceTracker,
                              softWrap: true,
                              style: TextStyle(
                                color: const Color(0xFF416157),
                                fontSize: 14,
                                height: 1.4,
                                decoration:
                                    AppConstants
                                        .appCompanyWebsiteFinanceTracker
                                        .isEmpty
                                    ? null
                                    : TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: Text(
                    'Last updated: ${AppConstants.privacyPolicyLastUpdated.isEmpty ? 'unavailable' : AppConstants.privacyPolicyLastUpdated}',
                    style: const TextStyle(
                      color: Color(0xFF416157),
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ),

                SizedBox(height: 24 + MediaQuery.viewPaddingOf(context).bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;

  const _PolicySection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF315F53),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            content,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Color(0xFF344B42),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
