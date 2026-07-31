import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/post_entity.dart';

abstract class PostRepository {
  Future<Either<Failure, List<PostEntity>>> getPosts({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, PostEntity>> getPostById(String postId);

  Future<Either<Failure, PostEntity>> createPost({
    required String content,
    List<String> hashtags = const [],
    String? mediaUrl,
    String? videoUrl,
    PostType postType = PostType.normal,
    String? budget,
    String? deadline,
  });

  Future<Either<Failure, void>> toggleLike(String postId);

  Future<Either<Failure, Map<String, dynamic>>> addComment({
    required String postId,
    required String comment,
  });
}
