import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import '../routes/app_router.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  void init(BuildContext context) {
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri, context);
    }, onError: (error) {
      debugPrint('DeepLink Error: $error');
    });
  }

  void _handleDeepLink(Uri uri, BuildContext context) {
    final segments = uri.pathSegments;
    if (segments.isEmpty) return;

    switch (segments[0]) {
      case 'post':
        if (segments.length >= 2) {
          final postId = segments[1];
          Navigator.pushNamed(context, AppRouter.postDetails, arguments: postId);
        }
        break;
      case 'profile':
        if (segments.length >= 2) {
          final userId = segments[1];
          Navigator.pushNamed(context, AppRouter.profile, arguments: userId);
        }
        break;
      case 'job':
        if (segments.length >= 2) {
          final jobId = segments[1];
          Navigator.pushNamed(context, AppRouter.jobDetails, arguments: jobId);
        }
        break;
      case 'chat':
        if (segments.length >= 2) {
          final conversationId = segments[1];
          Navigator.pushNamed(context, AppRouter.chat, arguments: conversationId);
        }
        break;
      default:
        debugPrint('DeepLink: Unknown path: ${segments[0]}');
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
