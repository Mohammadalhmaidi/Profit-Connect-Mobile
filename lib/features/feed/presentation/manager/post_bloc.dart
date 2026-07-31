import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/get_posts_usecase.dart';
import '../../domain/usecases/toggle_like_usecase.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final GetPostsUseCase getPostsUseCase;
  final ToggleLikeUseCase toggleLikeUseCase;
  int _currentPage = 1;
  bool _hasReachedMax = false;
  static const int _limit = 10;

  PostBloc({
    required this.getPostsUseCase,
    required this.toggleLikeUseCase,
  }) : super(PostInitial()) {
    on<GetPostsEvent>(_onGetPosts);
    on<ToggleLikeEvent>(_onToggleLike);
  }

  Future<void> _onGetPosts(
    GetPostsEvent event,
    Emitter<PostState> emit,
  ) async {
    if (event.refresh) {
      _currentPage = 1;
      _hasReachedMax = false;
    }

    if (_hasReachedMax && !event.refresh) return;

    final isLoadMore = state is PostsLoaded && _currentPage > 1;
    if (isLoadMore) {
      emit(PostsLoaded(
        posts: (state as PostsLoaded).posts,
        hasReachedMax: _hasReachedMax,
        currentPage: _currentPage,
      ));
    } else {
      emit(PostsLoading());
    }

    final result = await getPostsUseCase(
      GetPostsParams(page: _currentPage, limit: _limit),
    );

    result.fold(
      (failure) {
        emit(state is PostsLoaded
            ? (state as PostsLoaded)
            : PostsError(failure.message));
      },
      (posts) {
        _hasReachedMax = posts.length < _limit;
        final existingPosts =
            state is PostsLoaded ? (state as PostsLoaded).posts : <PostEntity>[];
        final updatedPosts = event.refresh || _currentPage == 1
            ? posts
            : [...existingPosts, ...posts];
        emit(PostsLoaded(
          posts: updatedPosts,
          hasReachedMax: _hasReachedMax,
          currentPage: _currentPage,
        ));
        _currentPage++;
      },
    );
  }

  Future<void> _onToggleLike(
    ToggleLikeEvent event,
    Emitter<PostState> emit,
  ) async {
    if (state is PostsLoaded) {
      final currentState = state as PostsLoaded;

      // Optimistic update
      emit(PostsLoaded(
        posts: currentState.posts.map((post) {
          if (post.id == event.postId) {
            return post.copyWith(
              isLiked: !post.isLiked,
              likesCount: post.isLiked
                  ? post.likesCount - 1
                  : post.likesCount + 1,
            );
          }
          return post;
        }).toList(),
        hasReachedMax: currentState.hasReachedMax,
        currentPage: currentState.currentPage,
      ));

      // Call API
      final result = await toggleLikeUseCase(event.postId);
      if (result.isLeft()) {
        // Revert on failure
        emit(currentState);
      }
    }
  }
}
