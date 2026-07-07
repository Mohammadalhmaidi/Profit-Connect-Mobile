import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/get_posts_usecase.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final GetPostsUseCase getPostsUseCase;

  PostBloc({required this.getPostsUseCase}) : super(PostInitial()) {
    on<GetPostsEvent>(_onGetPosts);
  }

  Future<void> _onGetPosts(GetPostsEvent event, Emitter<PostState> emit) async {
    emit(PostsLoading());
    
    final result = await getPostsUseCase();
    
    result.fold(
      (failure) {
        debugPrint('❌ PostBloc Error: ${failure.message}');
        emit(PostsError(failure.message));
      },
      (posts) {
        debugPrint('✅ PostBloc Success: Received ${posts.length} posts from server');
        emit(PostsLoaded(posts));
      },
    );
  }
}
