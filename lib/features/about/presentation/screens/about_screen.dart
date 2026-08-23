import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center,

          children: [
            const SizedBox(
              height: 20,
            ),

            // =====================================================
            // APP ICON
            // =====================================================

            ClipRRect(
              borderRadius:
                  BorderRadius.circular(24),

              child: Image.asset(
                'assets/branding/app_icon.png',
                width: 110,
                height: 110,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // =====================================================
            // APP NAME
            // =====================================================

            Text(
              AppConstants.appName,

              textAlign:
                  TextAlign.center,

              style: theme
                  .textTheme
                  .headlineMedium
                  ?.copyWith(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            // =====================================================
            // VERSION
            // =====================================================

            Text(
              'Version ${AppConstants.appVersion}',

              style: theme
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(
              height: 28,
            ),

            // =====================================================
            // DESCRIPTION
            // =====================================================

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      'About ${AppConstants.appName}',

                      style: theme
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Text(
                      AppConstants
                          .appDescription,

                      style: theme
                          .textTheme
                          .bodyLarge,

                      textAlign:
                          TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // =====================================================
            // DEVELOPER
            // =====================================================

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(40),

                child: Column(
                  children: [
                    Icon(
                      Icons.business_outlined,

                      size: 40,

                      color: theme
                          .colorScheme
                          .primary,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Text(
                      'Developed by',

                      style: theme
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color: theme
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      AppConstants
                          .appCompanyName,

                      textAlign:
                          TextAlign.center,

                      style: theme
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

          // =====================================================
          // COMPANY WEBSITE
          // =====================================================

          Card(
            child: ListTile(
              leading: Icon(
                Icons.language,
                color: theme.colorScheme.primary,
              ),

              title: const Text(
                'Company Website',
              ),

              subtitle: Text(
                AppConstants.appCompanyWebsite,
              ),

              trailing: const Icon(
                Icons.open_in_new,
              ),

              onTap: () async {
                final uri = Uri.parse(
                  AppConstants.appCompanyWebsite,
                );

                try {
                  final launched = await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );

                  if (!launched && context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Unable to open the website.',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Unable to open the website.',
                      ),
                    ),
                  );
                }
              },
            ),
          ),

            const SizedBox(
              height: 16,
            ),

            // =====================================================
            // OPEN SOURCE LICENSES
            // =====================================================

            Card(
              child: ListTile(
                leading: Icon(
                  Icons.article_outlined,
                  color: theme
                      .colorScheme
                      .primary,
                ),

                title: const Text(
                  'Open Source Licenses',
                ),

                subtitle: const Text(
                  'View licenses for third-party software used by this app.',
                ),

                trailing: const Icon(
                  Icons.chevron_right,
                ),

                onTap: () {
                  showLicensePage(
                    context: context,

                    applicationName:
                        AppConstants.appName,

                    applicationVersion:
                        AppConstants.appVersion,

                    applicationIcon:
                        Padding(
                      padding:
                          const EdgeInsets.all(
                        12,
                      ),

                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),

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

            const SizedBox(
              height: 32,
            ),

            // =====================================================
            // COPYRIGHT
            // =====================================================

            Text(
              '© ${DateTime.now().year} '
              '${AppConstants.appCompanyName}',

              textAlign:
                  TextAlign.center,

              style: theme
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'All rights reserved.',

              style: theme
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(
              height: 60,
            ),
          ],
        ),
      ),
    );
  }
}