part of 'post_bloc.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

class PostInitial extends PostState {}

class PostsLoading extends PostState {
  final bool isLoadMore;
  const PostsLoading({this.isLoadMore = false});

  @override
  List<Object?> get props => [isLoadMore];
}

class PostsLoaded extends PostState {
  final List<PostEntity> posts;
  final bool hasReachedMax;
  final int currentPage;

  const PostsLoaded({
    required this.posts,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  PostsLoaded copyWith({
    List<PostEntity>? posts,
    bool? hasReachedMax,
    int? currentPage,
  }) => PostsLoaded(
    posts: posts ?? this.posts,
    hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    currentPage: currentPage ?? this.currentPage,
  );

  @override
  List<Object?> get props => [posts, hasReachedMax, currentPage];
}

class PostsError extends PostState {
  final String message;

  const PostsError(this.message);

  @override
  List<Object?> get props => [message];
}
