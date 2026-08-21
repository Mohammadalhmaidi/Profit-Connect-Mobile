import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import '../routes/app_router.dart';
import '../di/dependency_injection.dart';
import '../../api_service.dart';
import '../../features/jobs/data/models/job_model.dart';
import '../../features/jobs/domain/entities/job_entity.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  void init(BuildContext context) {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        if (!context.mounted) return;
        _handleDeepLink(uri, context);
      },
      onError: (error) {
        debugPrint('DeepLink Error: $error');
      },
    );
  }

  Future<void> _handleDeepLink(Uri uri, BuildContext context) async {
    final segments = uri.pathSegments;
    if (segments.isEmpty) {
      return;
    }

    switch (segments[0]) {
      case 'post':
        if (segments.length >= 2) {
          final postId = segments[1];
          Navigator.pushNamed(
            context,
            AppRouter.postDetails,
            arguments: postId,
          );
        }
      case 'profile':
        if (segments.length >= 2) {
          final userId = segments[1];
          Navigator.pushNamed(context, AppRouter.profile, arguments: userId);
        }
      case 'job':
        if (segments.length >= 2) {
          await _openJobDeepLink(segments[1], context);
        }
      case 'chat':
        if (segments.length >= 2) {
          final conversationId = segments[1];
          Navigator.pushNamed(
            context,
            AppRouter.chat,
            arguments: {'conversationId': conversationId},
          );
        }
      default:
        debugPrint('DeepLink: Unknown path: ${segments[0]}');
    }
  }

  /// رابط الوظيفة يفتح صفحة تفاصيل الوظيفة — نحمّل بياناتها أولاً
  /// لأن صفحة التفاصيل تتوقع JobEntity وليس معرّفًا نصيًا.
  Future<void> _openJobDeepLink(String jobId, BuildContext context) async {
    try {
      final res = await sl<ApiService>().getJobById(jobId);
      final data = res.data;
      final jobJson = data is Map
          ? (data['data'] is Map
                ? data['data'] as Map<String, dynamic>
                : Map<String, dynamic>.from(data))
          : null;
      final job = jobJson != null
          ? JobModel.fromJson(jobJson)
          : JobEntity(id: jobId, title: '', companyId: '');
      if (!context.mounted) return;
      Navigator.pushNamed(context, AppRouter.jobDetails, arguments: job);
    } catch (e) {
      debugPrint('DeepLink: Failed to load job $jobId: $e');
      if (!context.mounted) return;
      // فتح صفحة فارغة بمعرّف الوظيفة أفضل من لا شيء — تبقى الصفحة تعرض التفاصيل عند التحميل
      Navigator.pushNamed(
        context,
        AppRouter.jobDetails,
        arguments: JobEntity(id: jobId, title: '', companyId: ''),
      );
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
