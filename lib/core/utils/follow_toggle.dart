import '../../api_service.dart';

enum FollowToggleResult { success, failure, self }

/// تنفيذ موحد لمتابعة/إلغاء متابعة مع فحص الذات والتحقق من الفشل —
/// يُستخدم من كل الصفحات لتوحيد السلوك والتراجع الآمن.
class FollowToggle {
  final ApiService api;

  const FollowToggle(this.api);

  Future<FollowToggleResult> toggle({
    required String userId,
    required bool isFollowing,
  }) async {
    try {
      final myId = await api.getCurrentUserId();
      if (userId == myId) return FollowToggleResult.self;
      if (isFollowing) {
        await api.unfollowUser(userId);
      } else {
        await api.followUser(userId);
      }
      return FollowToggleResult.success;
    } catch (_) {
      return FollowToggleResult.failure;
    }
  }
}
