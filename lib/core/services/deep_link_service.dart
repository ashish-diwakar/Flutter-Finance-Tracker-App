import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeepLinkService {

  static final AppLinks
      _appLinks = AppLinks();

  static StreamSubscription?
      _subscription;

  static void initialize({
    required GlobalKey<NavigatorState>
        navigatorKey,
  }) {

    _subscription =
        _appLinks.uriLinkStream.listen(
      (uri) async {

        if (uri.scheme ==
                'finance-tracker' &&
            uri.host ==
                'login-callback') {

          await Supabase.instance.client
              .auth
              .refreshSession();

          final context =
              navigatorKey
                  .currentContext;

          if (context != null) {

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              const SnackBar(
                content: Text(
                  'Email verified successfully',
                ),
              ),
            );
          }
        }
      },
    );
  }

  static void dispose() {

    _subscription?.cancel();
  }
}