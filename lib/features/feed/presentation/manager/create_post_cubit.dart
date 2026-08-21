import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/create_post_usecase.dart';

class CreatePostState extends Equatable {
  const CreatePostState();

  @override
  List<Object?> get props => [];
}

class CreatePostInitial extends CreatePostState {}

class CreatePostLoading extends CreatePostState {}

class CreatePostSuccess extends CreatePostState {}

class CreatePostFailure extends CreatePostState {
  final String message;

  const CreatePostFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class CreatePostCubit extends Cubit<CreatePostState> {
  final CreatePostUseCase createPostUseCase;

  CreatePostCubit({required this.createPostUseCase})
    : super(CreatePostInitial());

  Future<void> submit({
    required String content,
    List<String> hashtags = const [],
    String? mediaUrl,
    String? videoUrl,
    String? imagePath,
    String? videoPath,
    PostType postType = PostType.normal,
    String? budget,
    String? deadline,
  }) async {
    if (state is CreatePostLoading) return;
    emit(CreatePostLoading());
    final result = await createPostUseCase(
      CreatePostParams(
        content: content,
        hashtags: hashtags,
        mediaUrl: mediaUrl,
        videoUrl: videoUrl,
        imagePath: imagePath,
        videoPath: videoPath,
        postType: postType,
        budget: budget,
        deadline: deadline,
      ),
    );
    result.fold(
      (failure) => emit(CreatePostFailure(failure.message)),
      (_) => emit(CreatePostSuccess()),
    );
  }

  void reset() => emit(CreatePostInitial());
}
