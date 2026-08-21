import '../../../../core/utils/time_formatter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../api_service.dart';
import '../../domain/entities/comment_entity.dart';

class CommentTile extends StatefulWidget {
  final CommentEntity comment;
  final int index;
  final String postId;

  const CommentTile({
    required this.comment,
    required this.index,
    required this.postId,
    super.key,
  });

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  late int _likesCount;
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.comment.likesCount;
    _isLiked = widget.comment.isLiked;
  }

  @override
  void didUpdateWidget(covariant CommentTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.comment.likesCount != widget.comment.likesCount ||
        oldWidget.comment.isLiked != widget.comment.isLiked) {
      _likesCount = widget.comment.likesCount;
      _isLiked = widget.comment.isLiked;
    }
  }

  String _formatTimeAgo(BuildContext context, DateTime dateTime) =>
      formatTimeAgo(context, dateTime);

  Future<void> _toggleLike() async {
    final api = sl<ApiService>();
    final previousLiked = _isLiked;
    final previousCount = _likesCount;
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
    try {
      final res = await api.likeComment(widget.postId, widget.comment.id);
      final map = res.data is Map ? Map<String, dynamic>.from(res.data) : null;
      if (!mounted) return;
      setState(() {
        _isLiked = map?['isLiked'] as bool? ?? _isLiked;
        _likesCount = (map?['likesCount'] as num?)?.toInt() ?? _likesCount;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLiked = previousLiked;
        _likesCount = previousCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tile = Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              '/profile',
              arguments: widget.comment.userId,
            ),
            child: Container(
              padding: EdgeInsets.all(1.5.r),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.vibrantPurple, AppColors.accentCyan],
                ),
              ),
              child: CircleAvatar(
                radius: 17.r,
                backgroundColor: context.colors.surfaceMuted,
                backgroundImage: widget.comment.userAvatar.isNotEmpty
                    ? CachedNetworkImageProvider(widget.comment.userAvatar)
                    : null,
                child: widget.comment.userAvatar.isEmpty
                    ? Text(
                        widget.comment.userName.isNotEmpty
                            ? widget.comment.userName.characters.first
                                  .toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 6.h),
              decoration: BoxDecoration(
                color: context.colors.surfaceMuted,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            final commentUserId = widget.comment.userId;
                            if (commentUserId.isEmpty) {
                              return;
                            }
                            Navigator.pushNamed(
                              context,
                              '/profile',
                              arguments: commentUserId,
                            );
                          },
                          child: Text(
                            widget.comment.userName,
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (widget.comment.userRole.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentCyan.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            widget.comment.userRole,
                            style: TextStyle(
                              color: AppColors.accentCyan,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                      ],
                      Text(
                        _formatTimeAgo(context, widget.comment.createdAt),
                        style: TextStyle(
                          color: context.colors.textHint,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    widget.comment.content,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 13.sp,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      InkWell(
                        onTap: _toggleLike,
                        borderRadius: BorderRadius.circular(8.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 4.h,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isLiked
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_outlined,
                                size: 14.sp,
                                color: _isLiked
                                    ? Theme.of(context).colorScheme.secondary
                                    : context.colors.textSecondary,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '$_likesCount',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: _isLiked
                                      ? Theme.of(context).colorScheme.secondary
                                      : context.colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final delay = ((widget.index % 8) * 40).ms;
    return tile
        .animate()
        .fadeIn(duration: 300.ms, delay: delay)
        .slideY(begin: 0.08, end: 0, duration: 300.ms, delay: delay);
  }
}
