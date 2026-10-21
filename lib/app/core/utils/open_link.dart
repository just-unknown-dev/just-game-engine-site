import 'package:auto_route/auto_route.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [url]: a path starting with `/` navigates inside the site, anything
/// else opens in a new tab.
Future<void> openLink(BuildContext context, String url) async {
  if (url.startsWith('/')) {
    await context.router.navigatePath(url);
    return;
  }
  try {
    FirebaseAnalytics.instance.logEvent(
      name: 'outbound_link',
      parameters: {'url': url},
    );
  } catch (_) {
    // Analytics is best-effort.
  }
  await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
}

/// Whether [url] leaves the site.
bool isExternal(String url) => !url.startsWith('/');
