part of 'post_bloc.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

class GetPostsEvent extends PostEvent {
  final int page;
  final int limit;
  final bool refresh;

  const GetPostsEvent({this.page = 1, this.limit = 10, this.refresh = false});

  @override
  List<Object?> get props => [page, limit, refresh];
}

class ToggleLikeEvent extends PostEvent {
  final String postId;

  const ToggleLikeEvent({required this.postId});

  @override
  List<Object?> get props => [postId];
}
