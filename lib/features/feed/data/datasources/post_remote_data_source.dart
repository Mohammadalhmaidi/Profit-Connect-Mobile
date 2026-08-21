import '../../../../api_service.dart';
import '../models/post_model.dart';
import '../../domain/entities/post_entity.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getPosts({int page = 1, int limit = 10});

  Future<PostModel> getPostById(String postId);

  Future<PostModel> createPost({
    required String content,
    List<String> hashtags = const [],
    String? mediaUrl,
    String? videoUrl,
    String? imagePath,
    String? videoPath,
    PostType postType = PostType.normal,
    String? budget,
    String? deadline,
  });

  Future<void> toggleLike(String postId);

  Future<Map<String, dynamic>> addComment({
    required String postId,
    required String comment,
  });
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final ApiService _apiService;

  PostRemoteDataSourceImpl(this._apiService);

  @override
  Future<List<PostModel>> getPosts({int page = 1, int limit = 10}) async {
    final response = await _apiService.getPosts(page: page, limit: limit);
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>? ?? [];
    final currentUserId = await _apiService.getCurrentUserId();
    return data
        .map(
          (json) => PostModel.fromJson(
            json as Map<String, dynamic>,
            currentUserId: currentUserId,
          ),
        )
        .toList();
  }

  @override
  Future<PostModel> getPostById(String postId) async {
    final response = await _apiService.getPostById(postId);
    final body = response.data as Map<String, dynamic>;
    final postJson = body['data'] as Map<String, dynamic>;
    final currentUserId = await _apiService.getCurrentUserId();
    return PostModel.fromJson(postJson, currentUserId: currentUserId);
  }

  @override
  Future<PostModel> createPost({
    required String content,
    List<String> hashtags = const [],
    String? mediaUrl,
    String? videoUrl,
    String? imagePath,
    String? videoPath,
    PostType postType = PostType.normal,
    String? budget,
    String? deadline,
  }) async {
    final response = await _apiService.createPostMultipart(
      {'content': content},
      imagePath: imagePath,
      videoPath: videoPath,
    );
    final body = response.data as Map<String, dynamic>;
    final postJson = body['data'] as Map<String, dynamic>;
    final currentUserId = await _apiService.getCurrentUserId();
    return PostModel.fromJson(postJson, currentUserId: currentUserId);
  }

  @override
  Future<void> toggleLike(String postId) async {
    await _apiService.post('/api/posts/$postId/like');
  }

  @override
  Future<Map<String, dynamic>> addComment({
    required String postId,
    required String comment,
  }) async {
    final response = await _apiService.post(
      '/api/posts/$postId/comments',
      data: {'content': comment},
    );
    return response.data as Map<String, dynamic>;
  }
}
