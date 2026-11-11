import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/release_configuration.dart';

/// User-initiated contact actions shared by support and policy screens.
class SupportContactActions {
  const SupportContactActions({
    required this.supportEmail,
    required this.companyWebsite,
  });

  final String supportEmail;
  final String companyWebsite;

  Future<void> copySupportEmail(BuildContext context) async {
    final email = ReleaseConfiguration.email(supportEmail);
    if (email.isEmpty) {
      _showUnavailable(context, 'Support email unavailable');
      return;
    }
    var message = 'Support email copied';
    try {
      await Clipboard.setData(ClipboardData(text: email));
    } on Exception {
      message = 'Unable to copy the support email.';
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> openSupportEmail(BuildContext context) async {
    final email = ReleaseConfiguration.email(supportEmail);
    if (email.isEmpty) {
      _showUnavailable(context, 'Support email unavailable');
      return;
    }
    final emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query:
          'subject=${Uri.encodeComponent('Finance Tracker - Support Request')}',
    );
    try {
      if (await launchUrl(emailUri, mode: LaunchMode.externalApplication)) {
        return;
      }
    } on Exception {
      // A missing or failing handler uses the same explicit copy fallback.
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'No email app available. You can copy the address.',
        ),
        action: SnackBarAction(
          label: 'Copy Email Address',
          onPressed: () => copySupportEmail(context),
        ),
      ),
    );
  }

  Future<void> openCompanyWebsite(BuildContext context) async {
    final website = ReleaseConfiguration.website(companyWebsite);
    if (website.isEmpty) {
      _showUnavailable(context, 'Company website unavailable');
      return;
    }
    try {
      if (await launchUrl(
        Uri.parse(website),
        mode: LaunchMode.externalApplication,
      )) {
        return;
      }
    } on Exception {
      // A missing or failing handler uses the same visible feedback.
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open the website.')),
    );
  }

  void _showUnavailable(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
