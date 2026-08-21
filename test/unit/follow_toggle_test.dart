import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profit_connect_mobile/api_service.dart';
import 'package:profit_connect_mobile/core/utils/follow_toggle.dart';

Response _ok() => Response(
  requestOptions: RequestOptions(path: '/'),
  statusCode: 200,
  data: {'success': true},
);

class _FollowFake extends ApiService {
  bool throwOnApi = false;
  int followCalls = 0;
  int unfollowCalls = 0;
  String? myId = 'me';

  @override
  Future<String?> getCurrentUserId() async => myId;

  @override
  Future<Response> followUser(String userId) async {
    followCalls++;
    if (throwOnApi) {
      throw DioException(requestOptions: RequestOptions(path: '/'));
    }
    return _ok();
  }

  @override
  Future<Response> unfollowUser(String userId) async {
    unfollowCalls++;
    if (throwOnApi) {
      throw DioException(requestOptions: RequestOptions(path: '/'));
    }
    return _ok();
  }
}

void main() {
  group('FollowToggle', () {
    test('متابعة ناجحة تستدعي followUser', () async {
      final api = _FollowFake();
      final result = await FollowToggle(
        api,
      ).toggle(userId: 'other', isFollowing: false);
      expect(result, FollowToggleResult.success);
      expect(api.followCalls, 1);
      expect(api.unfollowCalls, 0);
    });

    test('إلغاء متابعة ناجح يستدعي unfollowUser', () async {
      final api = _FollowFake();
      final result = await FollowToggle(
        api,
      ).toggle(userId: 'other', isFollowing: true);
      expect(result, FollowToggleResult.success);
      expect(api.unfollowCalls, 1);
      expect(api.followCalls, 0);
    });

    test('يمنع متابعة النفس ويعيد self', () async {
      final api = _FollowFake();
      final result = await FollowToggle(
        api,
      ).toggle(userId: 'me', isFollowing: false);
      expect(result, FollowToggleResult.self);
      expect(api.followCalls, 0);
      expect(api.unfollowCalls, 0);
    });

    test('فشل الشبكة يعيد failure دون انهيار', () async {
      final api = _FollowFake()..throwOnApi = true;
      final result = await FollowToggle(
        api,
      ).toggle(userId: 'other', isFollowing: false);
      expect(result, FollowToggleResult.failure);
    });

    test('إلغاء متابعة النفس يعيد self أيضًا', () async {
      final api = _FollowFake()..myId = 'u1';
      final result = await FollowToggle(
        api,
      ).toggle(userId: 'u1', isFollowing: true);
      expect(result, FollowToggleResult.self);
      expect(api.unfollowCalls, 0);
    });
  });
}
