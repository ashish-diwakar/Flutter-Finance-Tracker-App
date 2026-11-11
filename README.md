# finance_tracker

## Release configuration

Before building an Android APK or AAB, create the Git-ignored `.env` from
`.env.example` and set all four required keys to approved public values:
`APP_SUPPORT_EMAIL`, `APP_COMPANY_WEBSITE`,
`APP_COMPANY_WEBSITE_FINANCE_TRACKER`, and
`APP_PRIVACY_POLICY_LAST_UPDATED` (`d MMMM yyyy`). Do this in developer setup
or the release pipeline before `flutter build apk --release` or
`flutter build appbundle --release`.

Run `dart run tool/check_release_config.dart` from the project root before the
build. It reports key names and validation reasons without printing values.
`.env` is listed as a Flutter asset in `pubspec.yaml` and is packaged in the
client APK/AAB. Do not put secrets in it. The policy revision date is an
approved publication date; the installed app version comes from package
metadata and is independent of this key. The repository does not include a CI
release workflow, so any external release job must provision and check `.env`.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
"# Flutter-Finance-Tracker-App" 
