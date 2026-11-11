/// Shared, side-effect-free rules for runtime contact actions and preflight.
class ReleaseConfiguration {
  static const requiredKeys = [
    'APP_SUPPORT_EMAIL',
    'APP_COMPANY_WEBSITE',
    'APP_COMPANY_WEBSITE_FINANCE_TRACKER',
    'APP_PRIVACY_POLICY_LAST_UPDATED',
  ];

  static bool _hasControls(String value) =>
      RegExp(r'[\x00-\x1f\x7f]').hasMatch(value);

  static bool _validHost(String host) {
    if (host.length > 253 || !host.contains('.')) return false;
    final labels = host.split('.');
    if (labels.any(
      (label) =>
          label.isEmpty ||
          label.length > 63 ||
          !RegExp(
            r'^[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?$',
          ).hasMatch(label),
    )) {
      return false;
    }
    if (RegExp(r'^[0-9.]+$').hasMatch(host)) {
      return labels.length == 4 &&
          labels.every((label) => int.parse(label) <= 255);
    }
    return RegExp(r'^[a-zA-Z]{2,}$').hasMatch(labels.last);
  }

  static String email(String? raw) {
    if (raw == null || _hasControls(raw)) return '';
    final value = raw.trim();
    if (value.length > 254 || RegExp(r'\s').hasMatch(value)) return '';
    final parts = value.split('@');
    if (parts.length != 2 || !_validHost(parts.last)) return '';
    final local = parts.first;
    if (local.isEmpty ||
        local.length > 64 ||
        local.startsWith('.') ||
        local.endsWith('.') ||
        local.contains('..')) {
      return '';
    }
    // Practical dot-atom mailboxes; no recipient lists or URI delimiters.
    if (!RegExp(r"^[a-zA-Z0-9.!$&'*+/=_^`{|}~-]+$").hasMatch(local)) return '';
    return value;
  }

  static String website(String? raw) {
    if (raw == null || _hasControls(raw)) return '';
    final value = raw.trim();
    if (value.isEmpty ||
        RegExp(r'\s').hasMatch(value) ||
        value.contains('\\')) {
      return '';
    }
    try {
      final uri = Uri.tryParse(value);
      if (uri == null ||
          uri.scheme != 'https' ||
          !uri.hasAuthority ||
          uri.userInfo.isNotEmpty ||
          !_validHost(uri.host) ||
          (uri.hasPort && (uri.port < 1 || uri.port > 65535))) {
        return '';
      }
      return value;
    } on FormatException {
      return '';
    }
  }

  static String revision(String? raw) {
    if (raw == null || _hasControls(raw)) return '';
    final value = raw.trim();
    final match = RegExp(
      r'^([1-9]|[12][0-9]|3[01]) ([A-Z][a-z]+) ([0-9]{4})$',
    ).firstMatch(value);
    if (match == null) return '';
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final month = months.indexOf(match[2]!) + 1;
    final day = int.parse(match[1]!);
    final year = int.parse(match[3]!);
    if (month == 0 || year == 0) return '';
    final date = DateTime.utc(year, month, day);
    return date.year == year && date.month == month && date.day == day
        ? value
        : '';
  }

  static String? errorFor(String key, String? value) {
    final normalized = switch (key) {
      'APP_SUPPORT_EMAIL' => email(value),
      'APP_PRIVACY_POLICY_LAST_UPDATED' => revision(value),
      _ => website(value),
    };
    if (normalized.isNotEmpty) return null;
    return switch (key) {
      'APP_SUPPORT_EMAIL' =>
        'requires one valid mailbox without URI delimiters or controls',
      'APP_PRIVACY_POLICY_LAST_UPDATED' =>
        'requires a real date in d MMMM yyyy format',
      _ => 'requires an absolute HTTPS URL with a valid host and no userinfo',
    };
  }
}
