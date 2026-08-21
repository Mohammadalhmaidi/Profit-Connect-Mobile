import 'package:dio/dio.dart';
import 'package:profit_connect_mobile/api_service.dart';

/// واجهة مزيفة لكل واجهة ApiService — يعيد بيانات جاهزة دون شبكة،
/// ويسمح بمحاكاة الفشل لعرض حالات الخطأ.
class FakeApiService extends ApiService {
  Map<String, dynamic> Function() onGetNetworkRequests = () => {};
  Map<String, dynamic> Function() onGetMyConnectionsList = () => {};
  Map<String, dynamic> Function() onGetDiscoverUsers = () => {};
  Map<String, dynamic> Function(String q) onSearchUsers = (_) => {};
  Map<String, dynamic> Function() onGetMyFollowing = () => {};
  Map<String, dynamic> Function(String userId) onGetUserFollowers = (_) => {};
  Map<String, dynamic> Function(String userId) onGetUserFollowing = (_) => {};
  Map<String, dynamic> Function() onGetConversations = () => {};
  Map<String, dynamic> Function(String q) onGetConversationsByQuery = (_) => {};
  String? Function() onGetCurrentUserId = () => 'me_user_id';

  int acceptCalls = 0;
  int rejectCalls = 0;
  int followCalls = 0;
  int unfollowCalls = 0;
  int sendConnectionCalls = 0;

  Response _ok(Map<String, dynamic> data) => Response(
    requestOptions: RequestOptions(path: '/'),
    statusCode: 200,
    data: data,
  );

  @override
  Future<Response> getNetworkRequests() async => _ok(onGetNetworkRequests());

  @override
  Future<Response> getMyConnectionsList() async =>
      _ok(onGetMyConnectionsList());

  @override
  Future<Response> getDiscoverUsers({int limit = 10}) async =>
      _ok(onGetDiscoverUsers());

  @override
  Future<Response> searchUsers(String query, {int limit = 20}) async =>
      _ok(onSearchUsers(query));

  @override
  Future<Response> getMyFollowing() async => _ok(onGetMyFollowing());

  @override
  Future<Response> getUserFollowers(String userId) async =>
      _ok(onGetUserFollowers(userId));

  @override
  Future<Response> getUserFollowing(String userId) async =>
      _ok(onGetUserFollowing(userId));

  @override
  Future<Response> acceptConnectionRequest(String requestId) async {
    acceptCalls += 1;
    return _ok({'success': true});
  }

  @override
  Future<Response> rejectConnectionRequest(String requestId) async {
    rejectCalls += 1;
    return _ok({'success': true});
  }

  @override
  Future<Response> followUser(String userId) async {
    followCalls += 1;
    return _ok({'success': true, 'following': true});
  }

  @override
  Future<Response> unfollowUser(String userId) async {
    unfollowCalls += 1;
    return _ok({'success': true, 'following': false});
  }

  @override
  Future<Response> sendConnectionRequest(String userId) async {
    sendConnectionCalls += 1;
    return _ok({'success': true});
  }

  @override
  Future<Response> getConversations({
    int page = 1,
    int limit = 20,
    String? q,
  }) async {
    if (q != null && q.trim().isNotEmpty) {
      return _ok(onGetConversationsByQuery(q));
    }
    return _ok(onGetConversations());
  }

  @override
  Future<String?> getCurrentUserId() async => onGetCurrentUserId();
}

/// بنّاءات بيانات جاهزة للاستخدام في الاختبارات
Map<String, dynamic> userJson(
  String id,
  String firstName,
  String lastName, {
  String headline = '',
}) => {
  '_id': id,
  'username': 'user_$id',
  'role': 'JobSeeker',
  'profile': {
    'firstName': firstName,
    'lastName': lastName,
    'fullname': '$firstName $lastName',
    'headline': headline,
    'avatar': 'https://test.example/a.png',
    'followersCount': 3,
  },
};

Map<String, dynamic> conversationJson(
  String id,
  Map<String, dynamic> peer,
  String lastContent, {
  String peerId = 'peer_1',
}) => {
  '_id': id,
  'lastMessageAt': '2026-01-01T10:00:00.000Z',
  'lastMessage': {
    'content': lastContent,
    'createdAt': '2026-01-01T10:00:00.000Z',
  },
  'participants': [
    {
      '_id': 'me_user_id',
      'profile': {'firstName': 'أنا', 'lastName': 'المستخدم'},
    },
    {...peer, '_id': peerId},
  ],
};

Map<String, dynamic> discoverSuggestion(
  Map<String, dynamic> user, {
  String connectionStatus = 'none',
  bool isFollowing = false,
}) => {
  '_id': user['_id'],
  'username': 'user_${user['_id']}',
  'role': 'JobSeeker',
  'profile': user['profile'],
  'isFollowing': isFollowing,
  'connectionStatus': connectionStatus,
};
