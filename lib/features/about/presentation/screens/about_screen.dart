import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/aurora_app_bar.dart';
import '../../../support/presentation/support_contact_actions.dart';
import 'open_source_licenses_screen.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  static const _lowerTitle = TextStyle(
    color: Color(0xFF315F53),
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  static const _lowerText = TextStyle(
    color: Color(0xFF416157),
    fontSize: 14,
    height: 1.35,
  );

  Widget _lowerCard(Widget child) => SizedBox(
    width: double.infinity,
    child: Card(
      color: const Color(0xFFF1F8F2),
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFA8CFC0)),
      ),
      child: child,
    ),
  );

  Widget _sectionIcon(IconData icon) => Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      color: const Color(0xFFE2F0E8),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: const Color(0xFF17664F), size: 22),
  );

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String description,
    required IconData trailing,
    required VoidCallback? onTap,
  }) => _lowerCard(
    ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      horizontalTitleGap: 12,
      leading: _sectionIcon(icon),
      title: Text(title, style: _lowerTitle),
      subtitle: Text(description, style: _lowerText),
      trailing: onTap == null
          ? null
          : Icon(trailing, color: const Color(0xFF315F53), size: 20),
      onTap: onTap,
    ),
  );

  void _openLicenses() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const OpenSourceLicensesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          const SizedBox(height: 12),

          // =====================================================
          // APP ICON
          // =====================================================
          ClipRRect(
            borderRadius: BorderRadius.circular(24),

            child: Image.asset(
              'assets/branding/app_icon.png',
              width: 110,
              height: 110,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 16),

          // =====================================================
          // APP NAME
          // =====================================================
          Text(
            AppConstants.appName,

            textAlign: TextAlign.center,

            style: const TextStyle(
              color: Color(0xFF315F53),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          // =====================================================
          // VERSION
          // =====================================================
          FutureBuilder<PackageInfo>(
            future: _packageInfo,
            builder: (context, snapshot) {
              final version = snapshot.data?.version.trim() ?? '';
              final build = snapshot.data?.buildNumber.trim() ?? '';
              final label = version.isEmpty
                  ? snapshot.connectionState == ConnectionState.waiting
                        ? 'Checking version…'
                        : 'Version unavailable'
                  : 'Version $version${build.isEmpty ? '' : ' (Build $build)'}';
              return Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF416157), fontSize: 14),
              );
            },
          ),

          const SizedBox(height: 22),

          // =====================================================
          // DESCRIPTION
          // =====================================================
          Card(
            color: const Color(0xFFF1F8F2),
            surfaceTintColor: Colors.transparent,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: Color(0xFFA8CFC0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    'About ${AppConstants.appName}',

                    style: const TextStyle(
                      color: Color(0xFF315F53),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    AppConstants.appDescription,

                    style: const TextStyle(
                      color: Color(0xFF344B42),
                      fontSize: 15,
                      height: 1.45,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // =====================================================
          // DEVELOPER
          // =====================================================
          _lowerCard(
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _sectionIcon(Icons.business_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Developed by', style: _lowerText),
                        const SizedBox(height: 3),
                        Text(AppConstants.appCompanyName, style: _lowerTitle),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // =====================================================
          // COMPANY WEBSITE
          // =====================================================
          _actionCard(
            icon: Icons.language,
            title: 'Company Website',
            description: AppConstants.appCompanyWebsite.isEmpty
                ? 'Company website unavailable'
                : AppConstants.appCompanyWebsite,
            trailing: Icons.open_in_new,
            onTap: AppConstants.appCompanyWebsite.isEmpty
                ? null
                : () => SupportContactActions(
                    supportEmail: AppConstants.appSupportEmail,
                    companyWebsite: AppConstants.appCompanyWebsite,
                  ).openCompanyWebsite(context),
          ),

          const SizedBox(height: 16),

          // =====================================================
          // OPEN SOURCE LICENSES
          // =====================================================
          _actionCard(
            icon: Icons.article_outlined,
            title: 'Open Source Licenses',
            description:
                'View licenses for third-party software used by this app.',
            trailing: Icons.chevron_right,
            onTap: _openLicenses,
          ),

          const SizedBox(height: 20),

          // =====================================================
          // COPYRIGHT
          // =====================================================
          Text(
            '© ${DateTime.now().year} '
            '${AppConstants.appCompanyName}',

            textAlign: TextAlign.center,

            style: _lowerText,
          ),

          const SizedBox(height: 4),

          const Text(
            'All rights reserved.',
            textAlign: TextAlign.center,
            style: _lowerText,
          ),

          SizedBox(height: 16 + MediaQuery.viewPaddingOf(context).bottom),
        ],
      ),
    );

    return Scaffold(
      appBar: const AuroraAppBar(title: Text('About')),
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
          content,
        ],
      ),
    );
  }
}
