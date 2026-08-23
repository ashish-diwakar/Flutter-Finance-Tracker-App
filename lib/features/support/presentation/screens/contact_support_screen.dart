import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:finance_tracker/core/constants/app_constants.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({
    super.key,
  });

  String get supportEmail =>
      AppConstants.appSupportEmail;

  String get companyName =>
      AppConstants.appCompanyName;

  String get companyWebsite =>
      AppConstants.appCompanyWebsite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contact & Support',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // =====================================================
            // HEADER
            // =====================================================

            Center(
              child: Icon(
                Icons.support_agent_outlined,
                size: 80,
                color:
                    theme.colorScheme.primary,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Center(
              child: Text(
                'Need Help?',
                style: theme
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Center(
              child: Text(
                'If you experience a problem, '
                'find a bug, or have a question '
                'about ${AppConstants.appName ?? 'Finance Tracker'}, '
                'please contact us.',
                textAlign:
                    TextAlign.center,
                style: theme
                    .textTheme
                    .bodyLarge,
              ),
            ),

            const SizedBox(
              height: 28,
            ),

            // =====================================================
            // EMAIL SUPPORT
            // =====================================================

            Card(
              child: ListTile(
                leading: Icon(
                  Icons.email_outlined,
                  color:
                      theme.colorScheme.primary,
                ),

                title: const Text(
                  'Email Support',
                ),

                subtitle: Text(
                  supportEmail.isEmpty
                      ? 'Support email not configured'
                      : supportEmail,
                ),

                trailing: supportEmail.isEmpty
                    ? null
                    : const Icon(
                        Icons.copy_outlined,
                      ),

                onTap: supportEmail.isEmpty
                    ? null
                    : () async {
                        await Clipboard.setData(
                          ClipboardData(
                            text: supportEmail,
                          ),
                        );

                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Support email copied',
                            ),
                          ),
                        );
                      },
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // =====================================================
            // EMAIL BUTTON
            // =====================================================

            if (supportEmail.isNotEmpty)
              SizedBox(
                width: double.infinity,

                child: FilledButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(
                        text: supportEmail,
                      ),
                    );

                    if (!context.mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Support email copied. '
                          'Open your email application to contact support.',
                        ),
                      ),
                    );
                  },

                  icon: const Icon(
                    Icons.email,
                  ),

                  label: const Text(
                    'Contact Support',
                  ),
                ),
              ),

            const SizedBox(
              height: 28,
            ),

            // =====================================================
            // INFORMATION TO INCLUDE
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
                      'When contacting support',
                      style: theme
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    const _SupportItem(
                      icon:
                          Icons.bug_report_outlined,
                      text:
                          'Describe the problem clearly.',
                    ),

                    const _SupportItem(
                      icon:
                          Icons.smartphone_outlined,
                      text:
                          'Mention your device model.',
                    ),

                    const _SupportItem(
                      icon:
                          Icons.android_outlined,
                      text:
                          'Include your Android version.',
                    ),

                    const _SupportItem(
                      icon:
                          Icons.info_outline,
                      text:
                          'Include the app version.',
                    ),

                    const _SupportItem(
                      icon:
                          Icons.format_list_bulleted,
                      text:
                          'Explain the steps that caused the issue.',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // =====================================================
            // COMPANY
            // =====================================================

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(20),

                child: Column(
                  children: [
                    Icon(
                      Icons.business_outlined,
                      size: 40,
                      color:
                          theme.colorScheme.primary,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Text(
                      companyName,
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

                    if (companyWebsite
                        .isNotEmpty) ...[
                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        companyWebsite,
                        textAlign:
                            TextAlign.center,
                        style: theme
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          color: theme
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 32,
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SupportItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            size: 22,
            color:
                theme.colorScheme.primary,
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Text(
              text,
              style: theme
                  .textTheme
                  .bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}