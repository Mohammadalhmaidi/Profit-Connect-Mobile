import 'dart:async';
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
  Completer<void>? _refreshCompleter;

  PostBloc({required this.getPostsUseCase, required this.toggleLikeUseCase})
    : super(PostInitial()) {
    on<GetPostsEvent>(_onGetPosts);
    on<ToggleLikeEvent>(_onToggleLike);
  }

  /// Pull-to-refresh: awaits until the refresh fetch completes.
  Future<void> refresh() {
    final completer = Completer<void>();
    _refreshCompleter = completer;
    add(const GetPostsEvent(refresh: true));
    return completer.future;
  }

  Future<void> _onGetPosts(GetPostsEvent event, Emitter<PostState> emit) async {
    if (event.refresh) {
      _currentPage = 1;
      _hasReachedMax = false;
    }

    if (_hasReachedMax && !event.refresh) return;

    final isLoadMore = state is PostsLoaded && _currentPage > 1;
    // Keep the existing list visible on pull-to-refresh instead of flashing a skeleton.
    if (isLoadMore || (event.refresh && state is PostsLoaded)) {
      emit(state as PostsLoaded);
    } else {
      emit(const PostsLoading());
    }

    final result = await getPostsUseCase(GetPostsParams(page: _currentPage));

    result.fold(
      (failure) {
        emit(
          state is PostsLoaded
              ? (state as PostsLoaded)
              : PostsError(failure.message),
        );
      },
      (posts) {
        _hasReachedMax = posts.length < _limit;
        final existingPosts = state is PostsLoaded
            ? (state as PostsLoaded).posts
            : <PostEntity>[];
        final updatedPosts = event.refresh || _currentPage == 1
            ? posts
            : [...existingPosts, ...posts];
        emit(
          PostsLoaded(
            posts: updatedPosts,
            hasReachedMax: _hasReachedMax,
            currentPage: _currentPage,
          ),
        );
        _currentPage++;
      },
    );
    _refreshCompleter?.complete();
    _refreshCompleter = null;
  }

  Future<void> _onToggleLike(
    ToggleLikeEvent event,
    Emitter<PostState> emit,
  ) async {
    if (state is PostsLoaded) {
      final currentState = state as PostsLoaded;

      // Optimistic update
      emit(
        PostsLoaded(
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
        ),
      );

      // Call API
      final result = await toggleLikeUseCase(event.postId);
      if (result.isLeft()) {
        // Restore the pre-toggle copy of the affected post, but merge it
        // into the latest list so a concurrent refresh isn't clobbered.
        final preToggle = currentState.posts
            .where((post) => post.id == event.postId)
            .toList();
        if (preToggle.isEmpty) {
          emit(currentState);
          return;
        }
        final latest = state is PostsLoaded ? (state as PostsLoaded) : null;
        if (latest == null) return;
        final reverted = latest.posts.map((post) {
          if (post.id == event.postId) {
            return preToggle.first;
          }
          return post;
        }).toList();
        emit(
          PostsLoaded(
            posts: reverted,
            hasReachedMax: latest.hasReachedMax,
            currentPage: latest.currentPage,
          ),
        );
      }
    }
  }
}
