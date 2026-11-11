import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// User-initiated contact actions shared by support and policy screens.
class SupportContactActions {
  const SupportContactActions({
    required this.supportEmail,
    required this.companyWebsite,
  });

  final String supportEmail;
  final String companyWebsite;

  Future<void> copySupportEmail(BuildContext context) async {
    var message = 'Support email copied';
    try {
      await Clipboard.setData(ClipboardData(text: supportEmail));
    } on Exception {
      message = 'Unable to copy the support email.';
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> openSupportEmail(BuildContext context) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
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
    try {
      if (await launchUrl(
        Uri.parse(companyWebsite),
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
}
