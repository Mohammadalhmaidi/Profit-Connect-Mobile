import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class GetPostsUseCase {
  final PostRepository repository;

  GetPostsUseCase(this.repository);

  Future<Either<Failure, List<PostEntity>>> call(GetPostsParams params) async =>
      repository.getPosts(page: params.page, limit: params.limit);
}

class GetPostsParams extends Equatable {
  final int page;
  final int limit;

  const GetPostsParams({this.page = 1, this.limit = 10});

  @override
  List<Object> get props => [page, limit];
}
