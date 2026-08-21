import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_comment_usecase.dart';
import '../../domain/usecases/get_post_usecase.dart';
import '../../domain/usecases/toggle_like_usecase.dart';

import 'post_detail_state.dart';

class PostDetailCubit extends Cubit<PostDetailState> {
  final GetPostUseCase getPostUseCase;
  final AddCommentUseCase addCommentUseCase;
  final ToggleLikeUseCase toggleLikeUseCase;

  PostDetailCubit({
    required this.getPostUseCase,
    required this.addCommentUseCase,
    required this.toggleLikeUseCase,
  }) : super(PostDetailInitial());

  Future<void> fetch(String postId) async {
    if (postId.isEmpty) {
      emit(const PostDetailError('Post not found'));
      return;
    }
    emit(PostDetailLoading());
    final result = await getPostUseCase(postId);
    result.fold(
      (failure) => emit(PostDetailError(failure.message)),
      (post) => emit(PostDetailLoaded(post)),
    );
  }

  Future<bool> addComment({
    required String postId,
    required String comment,
  }) async {
    if (comment.trim().isEmpty) return false;
    final result = await addCommentUseCase(
      postId: postId,
      comment: comment.trim(),
    );
    return result.fold((failure) => false, (_) => true);
  }

  Future<void> toggleLike(String postId) async {
    if (state is! PostDetailLoaded) return;
    final loaded = state as PostDetailLoaded;
    final wasLiked = loaded.post.isLiked;
    emit(
      PostDetailLoaded(
        loaded.post.copyWith(
          isLiked: !wasLiked,
          likesCount: wasLiked
              ? (loaded.post.likesCount - 1).clamp(0, 1 << 63)
              : loaded.post.likesCount + 1,
        ),
      ),
    );
    final result = await toggleLikeUseCase(postId);
    if (result.isLeft()) {
      emit(loaded);
    }
  }

  Future<void> refresh(String postId) async {
    final result = await getPostUseCase(postId);
    result.fold((failure) {
      // keep current loaded state on refresh failure
    }, (post) => emit(PostDetailLoaded(post)));
  }

  void reset() => emit(PostDetailInitial());
}
