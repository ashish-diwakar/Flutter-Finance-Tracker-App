import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/aurora_app_bar.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(40),

              child: Column(
                children: [
                  Icon(
                    Icons.business_outlined,

                    size: 40,

                    color: theme.colorScheme.primary,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Developed by',

                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    AppConstants.appCompanyName,

                    textAlign: TextAlign.center,

                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
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
          Card(
            child: ListTile(
              leading: Icon(Icons.language, color: theme.colorScheme.primary),

              title: const Text('Company Website'),

              subtitle: Text(AppConstants.appCompanyWebsite),

              trailing: const Icon(Icons.open_in_new),

              onTap: () async {
                final uri = Uri.parse(AppConstants.appCompanyWebsite);

                try {
                  final launched = await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );

                  if (!launched && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unable to open the website.'),
                      ),
                    );
                  }
                } catch (e) {
                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Unable to open the website.'),
                    ),
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 16),

          // =====================================================
          // OPEN SOURCE LICENSES
          // =====================================================
          Card(
            child: ListTile(
              leading: Icon(
                Icons.article_outlined,
                color: theme.colorScheme.primary,
              ),

              title: const Text('Open Source Licenses'),

              subtitle: const Text(
                'View licenses for third-party software used by this app.',
              ),

              trailing: const Icon(Icons.chevron_right),

              onTap: () {
                showLicensePage(
                  context: context,

                  applicationName: AppConstants.appName,

                  applicationVersion: AppConstants.appVersion,

                  applicationIcon: Padding(
                    padding: const EdgeInsets.all(12),

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),

                      child: Image.asset(
                        'assets/branding/app_icon.png',
                        width: 56,
                        height: 56,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          // =====================================================
          // COPYRIGHT
          // =====================================================
          Text(
            '© ${DateTime.now().year} '
            '${AppConstants.appCompanyName}',

            textAlign: TextAlign.center,

            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'All rights reserved.',

            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 60),
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
