import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../manager/post_detail_cubit.dart';
import '../widgets/post_card.dart';

class PostDetailsPage extends StatelessWidget {
  final String postId;

  const PostDetailsPage({super.key, required this.postId});

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${diff.inDays ~/ 7}w';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PostDetailCubit>()..fetch(postId),
      child: Scaffold(
        backgroundColor: AppColors.backgroundAlt,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Post',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<PostDetailCubit, PostDetailState>(
          builder: (context, state) {
            if (state is PostDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is PostDetailError) {
              return Center(
                child: Text(
                  state.message,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
                  textAlign: TextAlign.center,
                ),
              );
            }
            if (state is PostDetailLoaded) {
              final post = state.post;
              return SingleChildScrollView(
                child: PostCard(
                  userName: post.userName,
                  userRole: post.userRole,
                  userAvatar: post.userAvatar,
                  timeAgo: _formatTimeAgo(post.createdAt),
                  content: post.content,
                  hashtags: post.hashtags,
                  mediaUrl: post.mediaUrl,
                  videoUrl: post.videoUrl,
                  likes: post.likesCount.toString(),
                  comments: post.commentsCount.toString(),
                  postId: post.id,
                  isLiked: post.isLiked,
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
