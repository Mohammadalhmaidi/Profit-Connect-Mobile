import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_post_usecase.dart';

import 'post_detail_state.dart';

class PostDetailCubit extends Cubit<PostDetailState> {
  final GetPostUseCase getPostUseCase;

  PostDetailCubit({required this.getPostUseCase}) : super(PostDetailInitial());

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

  void reset() => emit(PostDetailInitial());
}
