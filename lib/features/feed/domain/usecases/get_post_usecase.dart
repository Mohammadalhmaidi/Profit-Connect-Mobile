import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class GetPostUseCase {
  final PostRepository repository;

  const GetPostUseCase(this.repository);

  Future<Either<Failure, PostEntity>> call(String postId) async =>
      repository.getPostById(postId);
}
