import '../../../../core/utils/time_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../core/presentation/widgets/stagger_entrance.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/comment_entity.dart';
import '../manager/post_detail_cubit.dart';
import '../manager/post_detail_state.dart';
import '../widgets/comment_tile.dart';
import '../widgets/post_card.dart';

class PostDetailsPage extends StatefulWidget {
  final String postId;

  const PostDetailsPage({required this.postId, super.key});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  String _formatTimeAgo(BuildContext context, DateTime dateTime) =>
      formatTimeAgo(context, dateTime);

  void _scrollToComments() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: 400.ms,
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _submitComment(PostDetailCubit cubit) async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    final ok = await cubit.addComment(postId: widget.postId, comment: text);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (ok) {
      _commentController.clear();
      _commentFocusNode.unfocus();
      await cubit.refresh(widget.postId);
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: 350.ms,
          curve: Curves.easeOut,
        );
      }
    } else {
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('feed.comment_failed'),
      );
    }
  }

  Widget _buildCommentSection(List<CommentEntity> comments) => Padding(
    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.forum_outlined,
              color: context.colors.textSecondary,
              size: 16.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              context.tr('feed.comments_title'),
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              '(${comments.length})',
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        if (comments.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 28.h),
            decoration: BoxDecoration(
              color: context.colors.surfaceMuted,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: context.colors.textHint,
                  size: 32.sp,
                ),
                SizedBox(height: 8.h),
                Text(
                  context.tr('feed.no_comments'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          )
        else
          ...comments.asMap().entries.map(
            (entry) => StaggerEntrance(
              key: ValueKey('comment-${entry.value.id}'),
              index: entry.key,
              child: CommentTile(
                comment: entry.value,
                index: entry.key,
                postId: widget.postId,
              ),
            ),
          ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<PostDetailCubit>()..fetch(widget.postId),
    child: Scaffold(
      backgroundColor: context.colors.backgroundAlt,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('feed.post_detail'),
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<PostDetailCubit, PostDetailState>(
              builder: (context, state) {
                if (state is PostDetailLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is PostDetailError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Text(
                        state.message,
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 14.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                if (state is PostDetailLoaded) {
                  final post = state.post;
                  return ListView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 12.h),
                    children: [
                      PostCard(
                        postId: post.id,
                        userId: post.userId,
                        userName: post.userName,
                        userRole: post.userRole,
                        userAvatar: post.userAvatar,
                        timeAgo: _formatTimeAgo(context, post.createdAt),
                        content: post.content,
                        hashtags: post.hashtags,
                        mediaUrl: post.mediaUrl,
                        videoUrl: post.videoUrl,
                        likes: post.likesCount.toString(),
                        comments: post.commentsCount.toString(),
                        shares: post.shareCount,
                        isLiked: post.isLiked,
                        isSaved: post.isSaved,
                        onCommentTap: _scrollToComments,
                        onLike: () =>
                            context.read<PostDetailCubit>().toggleLike(post.id),
                      ),
                      SizedBox(height: 12.h),
                      _buildCommentSection(post.comments),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          _buildComposer(),
        ],
      ),
    ),
  );

  Widget _buildComposer() => Builder(
    builder: (context) {
      final cubit = context.read<PostDetailCubit>();
      return SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
          decoration: BoxDecoration(
            color: context.colors.surface,
            border: Border(top: BorderSide(color: context.colors.divider)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  focusNode: _commentFocusNode,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submitComment(cubit),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: context.tr('feed.write_comment'),
                    isDense: true,
                    hintStyle: TextStyle(color: context.colors.textHint),
                    filled: true,
                    fillColor: context.colors.surfaceMuted,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 11.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                onPressed: _isSubmitting ? null : () => _submitComment(cubit),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
              ),
            ],
          ),
        ),
      );
    },
  );
}
