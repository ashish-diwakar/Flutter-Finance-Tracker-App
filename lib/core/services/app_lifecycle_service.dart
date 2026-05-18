import 'package:flutter/widgets.dart';

class AppLifecycleService
    extends WidgetsBindingObserver {

  final Future<void> Function()
      onResume;

  AppLifecycleService({
    required this.onResume,
  });

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {

    if (state ==
        AppLifecycleState.resumed) {

      onResume();
    }
  }
}