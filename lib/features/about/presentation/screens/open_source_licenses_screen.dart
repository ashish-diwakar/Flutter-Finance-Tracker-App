import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/aurora_app_bar.dart';

/// Keeps every registry entry and binding, including entries shared by packages.
class RegistryLicenses {
  RegistryLicenses._(this.packages, this.paragraphs, this.bindings);

  final List<String> packages;
  final List<List<LicenseParagraph>> paragraphs;
  final Map<String, List<int>> bindings;

  static Future<RegistryLicenses> load(Stream<LicenseEntry> entries) async {
    final paragraphs = <List<LicenseParagraph>>[];
    final bindings = <String, List<int>>{};
    await for (final entry in entries) {
      for (final package in entry.packages) {
        bindings.putIfAbsent(package, () => []).add(paragraphs.length);
      }
      paragraphs.add(entry.paragraphs.toList(growable: false));
    }
    final first = bindings.keys.firstOrNull;
    final packages = bindings.keys.toList()
      ..sort((a, b) {
        if (a == b) return 0;
        if (a == first) return -1;
        if (b == first) return 1;
        return a.toLowerCase().compareTo(b.toLowerCase());
      });
    return RegistryLicenses._(packages, paragraphs, bindings);
  }
}

class OpenSourceLicensesScreen extends StatefulWidget {
  const OpenSourceLicensesScreen({super.key, this.licenses, this.packageInfo});

  final Stream<LicenseEntry> Function()? licenses;
  final Future<PackageInfo> Function()? packageInfo;

  @override
  State<OpenSourceLicensesScreen> createState() =>
      _OpenSourceLicensesScreenState();
}

class _OpenSourceLicensesScreenState extends State<OpenSourceLicensesScreen> {
  late Future<RegistryLicenses> _licenses = _load();
  late final Future<PackageInfo> _info =
      (widget.packageInfo ?? PackageInfo.fromPlatform)();

  Future<RegistryLicenses> _load() => RegistryLicenses.load(
    widget.licenses?.call() ?? LicenseRegistry.licenses,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const AuroraAppBar(title: Text('Open Source Licenses')),
    body: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFB6D7CC), Color(0xFFDAEDE5), Color(0xFFF8FCFA)],
          stops: [0, 0.52, 1],
        ),
      ),
      child: SizedBox.expand(
        child: FutureBuilder<RegistryLicenses>(
          future: _licenses,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Unable to load licenses. Please try again.'),
                    TextButton(
                      onPressed: () => setState(() => _licenses = _load()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.viewPaddingOf(context).bottom,
              ),
              itemCount: data.packages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/branding/app_icon.png',
                          width: 56,
                          height: 56,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppConstants.appName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AuroraAppBar.inkColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        FutureBuilder<PackageInfo>(
                          future: _info,
                          builder: (context, info) => Text(
                            info.data?.version.trim().isNotEmpty == true
                                ? 'Version ${info.data!.version.trim()}'
                                : info.connectionState ==
                                      ConnectionState.waiting
                                ? 'Checking version…'
                                : 'Version unavailable',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('Powered by Flutter'),
                        const SizedBox(height: 8),
                        const Text(
                          'Third-party software and its license attributions.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                final package = data.packages[index - 1];
                return Card(
                  color: const Color(0xFFF1F8F2),
                  surfaceTintColor: Colors.transparent,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFA8CFC0)),
                  ),
                  child: ListTile(
                    title: Text(
                      package,
                      style: const TextStyle(
                        color: AuroraAppBar.inkColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      MaterialLocalizations.of(
                        context,
                      ).licensesPackageDetailText(
                        data.bindings[package]!.length,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AuroraAppBar.inkColor,
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            _LicenseDetail(package: package, data: data),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    ),
  );
}

class _LicenseDetail extends StatelessWidget {
  const _LicenseDetail({required this.package, required this.data});
  final String package;
  final RegistryLicenses data;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AuroraAppBar.surfaceColor,
    appBar: const AuroraAppBar(title: Text('License Details')),
    body: SelectionArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          24 + MediaQuery.viewPaddingOf(context).bottom,
        ),
        children: [
          Text(
            package,
            style: const TextStyle(
              color: AuroraAppBar.inkColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            MaterialLocalizations.of(
              context,
            ).licensesPackageDetailText(data.bindings[package]!.length),
          ),
          for (final entry in data.bindings[package]!) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),
            for (final paragraph in data.paragraphs[entry])
              Padding(
                padding: EdgeInsetsDirectional.only(
                  top: 8,
                  start: paragraph.indent < 0 ? 0 : paragraph.indent * 16.0,
                ),
                child: Text(
                  paragraph.text,
                  textAlign: paragraph.indent == LicenseParagraph.centeredIndent
                      ? TextAlign.center
                      : TextAlign.start,
                  style: TextStyle(
                    color: AuroraAppBar.inkColor,
                    fontSize: 14,
                    height: 1.5,
                    fontWeight:
                        paragraph.indent == LicenseParagraph.centeredIndent
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
          ],
        ],
      ),
    ),
  );
}
