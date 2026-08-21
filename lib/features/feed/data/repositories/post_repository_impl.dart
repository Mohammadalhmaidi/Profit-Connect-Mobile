import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/api_call_helper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_data_source.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PostRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<PostEntity>>> getPosts({
    int page = 1,
    int limit = 10,
  }) async => safeApiCallWithNetworkCheck(
    networkInfo: networkInfo,
    call: () => remoteDataSource.getPosts(page: page, limit: limit),
  );

  @override
  Future<Either<Failure, PostEntity>> getPostById(String postId) async =>
      safeApiCallWithNetworkCheck(
        networkInfo: networkInfo,
        call: () => remoteDataSource.getPostById(postId),
      );

  @override
  @override
  Future<Either<Failure, PostEntity>> createPost({
    required String content,
    List<String> hashtags = const [],
    String? mediaUrl,
    String? videoUrl,
    String? imagePath,
    String? videoPath,
    PostType postType = PostType.normal,
    String? budget,
    String? deadline,
  }) async => safeApiCallWithNetworkCheck(
    networkInfo: networkInfo,
    call: () => remoteDataSource.createPost(
      content: content,
      hashtags: hashtags,
      mediaUrl: mediaUrl,
      videoUrl: videoUrl,
      imagePath: imagePath,
      videoPath: videoPath,
      postType: postType,
      budget: budget,
      deadline: deadline,
    ),
  );

  @override
  Future<Either<Failure, void>> toggleLike(String postId) async =>
      safeApiCallWithNetworkCheck(
        networkInfo: networkInfo,
        call: () => remoteDataSource.toggleLike(postId),
      );

  @override
  Future<Either<Failure, Map<String, dynamic>>> addComment({
    required String postId,
    required String comment,
  }) async => safeApiCallWithNetworkCheck(
    networkInfo: networkInfo,
    call: () => remoteDataSource.addComment(postId: postId, comment: comment),
  );
}
