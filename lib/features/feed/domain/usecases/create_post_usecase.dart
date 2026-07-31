import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class CreatePostUseCase {
  final PostRepository repository;

  CreatePostUseCase(this.repository);

  Future<Either<Failure, PostEntity>> call(CreatePostParams params) async {
    return await repository.createPost(
      content: params.content,
      hashtags: params.hashtags,
      mediaUrl: params.mediaUrl,
      videoUrl: params.videoUrl,
      postType: params.postType,
      budget: params.budget,
      deadline: params.deadline,
    );
  }
}

class CreatePostParams extends Equatable {
  final String content;
  final List<String> hashtags;
  final String? mediaUrl;
  final String? videoUrl;
  final PostType postType;
  final String? budget;
  final String? deadline;

  const CreatePostParams({
    required this.content,
    this.hashtags = const [],
    this.mediaUrl,
    this.videoUrl,
    this.postType = PostType.normal,
    this.budget,
    this.deadline,
  });

  @override
  List<Object?> get props =>
      [content, hashtags, mediaUrl, videoUrl, postType, budget, deadline];
}
