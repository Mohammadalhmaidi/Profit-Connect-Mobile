import 'package:equatable/equatable.dart';
import '../../domain/entities/post_entity.dart';

abstract class PostDetailState extends Equatable {
  const PostDetailState();

  @override
  List<Object?> get props => [];
}

class PostDetailInitial extends PostDetailState {}

class PostDetailLoading extends PostDetailState {}

class PostDetailLoaded extends PostDetailState {
  final PostEntity post;

  const PostDetailLoaded(this.post);

  @override
  List<Object?> get props => [post];
}

class PostDetailError extends PostDetailState {
  final String message;

  const PostDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
