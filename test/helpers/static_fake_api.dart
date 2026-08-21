import 'package:dio/dio.dart';
import 'package:profit_connect_mobile/api_service.dart';

class StaticFakeApi extends ApiService {
  Map<String, dynamic> requestsData;
  Map<String, dynamic> connectionsData;
  Map<String, dynamic> discoverData;
  Map<String, dynamic> Function(String q) searchCallback;
  Map<String, dynamic> Function() convosCallback;
  Map<String, dynamic> Function(String q) convosSearchCallback;
  Map<String, dynamic> Function(String userId) followersCallback;
  Map<String, dynamic> Function(String userId) followingCallback;
  Map<String, dynamic> Function() myFollowingCallback;
  String? Function() userIdCallback;

  StaticFakeApi({
    this.requestsData = const {},
    this.connectionsData = const {},
    this.discoverData = const {},
    Map<String, dynamic> Function(String q)? searchCallback,
    Map<String, dynamic> Function()? convosCallback,
    Map<String, dynamic> Function(String q)? convosSearchCallback,
    Map<String, dynamic> Function(String userId)? followersCallback,
    Map<String, dynamic> Function(String userId)? followingCallback,
    Map<String, dynamic> Function()? myFollowingCallback,
    String? Function()? userIdCallback,
  }) : searchCallback = searchCallback ?? ((_) => const {}),
       convosCallback = convosCallback ?? (() => const {}),
       convosSearchCallback = convosSearchCallback ?? ((_) => const {}),
       followersCallback = followersCallback ?? ((_) => const {}),
       followingCallback = followingCallback ?? ((_) => const {}),
       myFollowingCallback = myFollowingCallback ?? (() => const {}),
       userIdCallback = userIdCallback ?? (() => 'me');

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
  Future<Response> getNetworkRequests() async => _ok(requestsData);

  @override
  Future<Response> getMyConnectionsList() async => _ok(connectionsData);

  @override
  Future<Response> getDiscoverUsers({int limit = 10}) async =>
      _ok(discoverData);

  @override
  Future<Response> searchUsers(String query, {int limit = 20}) async =>
      _ok(searchCallback(query));

  @override
  Future<Response> getConversations({
    int page = 1,
    int limit = 20,
    String? q,
  }) async {
    if (q != null && q.trim().isNotEmpty) return _ok(convosSearchCallback(q));
    return _ok(convosCallback());
  }

  @override
  Future<Response> getUserFollowers(String userId) async =>
      _ok(followersCallback(userId));

  @override
  Future<Response> getUserFollowing(String userId) async =>
      _ok(followingCallback(userId));

  @override
  Future<Response> getMyFollowing() async => _ok(myFollowingCallback());

  @override
  Future<String?> getCurrentUserId() async => userIdCallback();

  @override
  Future<Response> acceptConnectionRequest(String requestId) async {
    acceptCalls++;
    return _ok({'success': true});
  }

  @override
  Future<Response> rejectConnectionRequest(String requestId) async {
    rejectCalls++;
    return _ok({'success': true});
  }

  @override
  Future<Response> followUser(String userId) async {
    followCalls++;
    return _ok({'success': true, 'following': true});
  }

  @override
  Future<Response> unfollowUser(String userId) async {
    unfollowCalls++;
    return _ok({'success': true, 'following': false});
  }

  @override
  Future<Response> sendConnectionRequest(String userId) async {
    sendConnectionCalls++;
    return _ok({'success': true});
  }
}

Map<String, dynamic> makeUser(
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

Map<String, dynamic> makeDiscover(
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

Map<String, dynamic> makeConvo(
  String id,
  Map<String, dynamic> peer,
  String lastContent,
  String peerId,
) => {
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
