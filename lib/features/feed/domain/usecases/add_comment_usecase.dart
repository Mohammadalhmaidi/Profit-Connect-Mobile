import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/post_repository.dart';

class AddCommentUseCase {
  final PostRepository repository;

  AddCommentUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String postId,
    required String comment,
  }) async => repository.addComment(postId: postId, comment: comment);
}
