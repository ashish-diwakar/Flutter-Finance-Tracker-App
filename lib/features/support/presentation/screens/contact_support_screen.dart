import 'package:flutter/material.dart';
import 'package:finance_tracker/core/constants/app_constants.dart';
import 'package:finance_tracker/core/widgets/aurora_app_bar.dart';
import 'package:finance_tracker/features/support/presentation/support_contact_actions.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  String get supportEmail => AppConstants.appSupportEmail;

  String get companyName => AppConstants.appCompanyName;

  String get companyWebsite => AppConstants.appCompanyWebsiteFinanceTracker;

  SupportContactActions get _contactActions => SupportContactActions(
    supportEmail: supportEmail,
    companyWebsite: companyWebsite,
  );

  Widget _sectionCard(Widget child) => SizedBox(
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

  @override
  Widget build(BuildContext context) {
    final canCopy = supportEmail.isNotEmpty;
    final emailCard = Card(
      margin: EdgeInsets.zero,
      color: const Color(0xFFF1F8F2),
      surfaceTintColor: Colors.transparent,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFA8CFC0)),
      ),
      child: InkWell(
        onTap: canCopy ? () => _contactActions.copySupportEmail(context) : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F0E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFF17664F),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Email Support',
                      style: TextStyle(
                        color: Color(0xFF315F53),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      canCopy ? supportEmail : 'Support email not configured',
                      style: const TextStyle(
                        color: Color(0xFF416157),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (canCopy)
                const SizedBox.square(
                  dimension: 48,
                  child: Icon(Icons.copy_outlined, color: Color(0xFF17664F)),
                ),
            ],
          ),
        ),
      ),
    );

    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // =====================================================
          // HEADER
          // =====================================================

          const Center(
            child: Icon(
              Icons.support_agent_outlined,
              size: 68,
              color: Color(0xFF17664F),
            ),
          ),

          const SizedBox(height: 16),

          const Center(
            child: Text(
              'Need Help?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF315F53),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Center(
            child: Text(
              'If you experience a problem, '
              'find a bug, or have a question '
              'about ${AppConstants.appName}, '
              'please contact us.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF416157),
                fontSize: 15,
                height: 1.45,
              ),
            ),
          ),

          const SizedBox(height: 22),

          // =====================================================
          // EMAIL SUPPORT
          // =====================================================
          if (canCopy)
            Tooltip(
              message: 'Copy support email address',
              excludeFromSemantics: true,
              child: Semantics(
                label: 'Copy support email address',
                button: true,
                child: emailCard,
              ),
            )
          else
            emailCard,

          const SizedBox(height: 16),

          // =====================================================
          // EMAIL BUTTON
          // =====================================================
          if (canCopy)
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
                onPressed: () => _contactActions.openSupportEmail(context),
                icon: const Icon(Icons.email_outlined),
                label: const Text('Email Support', textAlign: TextAlign.center),
              ),
            ),

          const SizedBox(height: 28),

          // =====================================================
          // INFORMATION TO INCLUDE
          // =====================================================
          _sectionCard(
            const Padding(
              padding: EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    'When contacting support',
                    style: TextStyle(
                      color: Color(0xFF315F53),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 16),

                  _SupportItem(
                    icon: Icons.bug_report_outlined,
                    text: 'Describe the problem clearly.',
                  ),

                  _SupportItem(
                    icon: Icons.smartphone_outlined,
                    text: 'Mention your device model.',
                  ),

                  _SupportItem(
                    icon: Icons.android_outlined,
                    text: 'Include your Android version.',
                  ),

                  _SupportItem(
                    icon: Icons.info_outline,
                    text: 'Include the app version.',
                  ),

                  _SupportItem(
                    icon: Icons.format_list_bulleted,
                    text: 'Explain the steps that caused the issue.',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // =====================================================
          // COMPANY
          // =====================================================
          _sectionCard(
            Semantics(
              label: 'Open company website: $companyWebsite',
              link: true,
              child: InkWell(
                onTap: companyWebsite.isNotEmpty
                    ? () => _contactActions.openCompanyWebsite(context)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2F0E8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.business_outlined,
                          color: Color(0xFF17664F),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              companyName,
                              style: const TextStyle(
                                color: Color(0xFF315F53),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (companyWebsite.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                companyWebsite,
                                style: const TextStyle(
                                  color: Color(0xFF416157),
                                  fontSize: 14,
                                  height: 1.4,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (companyWebsite.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.open_in_new,
                          color: Color(0xFF315F53),
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 16 + MediaQuery.viewPaddingOf(context).bottom),
        ],
      ),
    );

    return Scaffold(
      appBar: const AuroraAppBar(title: Text('Contact & Support')),
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

class _SupportItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SupportItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 20, color: const Color(0xFF17664F)),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF416157),
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
