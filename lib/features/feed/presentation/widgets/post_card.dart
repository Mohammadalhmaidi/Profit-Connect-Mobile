import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/widgets/memory_safe_video_player.dart';

class PostCard extends StatefulWidget {
  final String userName;
  final String userRole;
  final String userAvatar;
  final String timeAgo;
  final String content;
  final List<String> hashtags;
  final String? mediaUrl;
  final String? videoUrl;
  final String likes;
  final String comments;
  final String postId;
  final bool isLiked;
  final VoidCallback? onLike;

  const PostCard({
    super.key,
    required this.userName,
    required this.userRole,
    required this.userAvatar,
    required this.timeAgo,
    required this.content,
    required this.hashtags,
    this.mediaUrl,
    this.videoUrl,
    required this.likes,
    required this.comments,
    this.postId = 'post_123',
    this.isLiked = false,
    this.onLike,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isCommentActive = false;
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void dispose() {
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(16.w),
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile', arguments: widget.userName),
child: CircleAvatar(
                  radius: 24.r,
                  backgroundImage: CachedNetworkImageProvider(widget.userAvatar),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${widget.userRole} \u2022 ${widget.timeAgo}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(widget.content, style: TextStyle(fontSize: 14.sp)),
          if (widget.hashtags.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              children: widget.hashtags.map((tag) {
                return Text(
                  tag,
                  style: TextStyle(
                    color: AppColors.accentCyan,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
          ],
          if (widget.mediaUrl != null) ...[
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: widget.mediaUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Container(
                  height: 200.h,
                  color: AppColors.fieldBackground,
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200.h,
                  color: AppColors.fieldBackground,
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
              ),
            ),
          ],
          if (widget.videoUrl != null) ...[
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: MemorySafeVideoPlayer(
                videoUrl: widget.videoUrl!,
                autoPlay: false,
              ),
            ),
          ],
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ActionButton(
                icon: widget.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                label: widget.likes,
                color: widget.isLiked ? Colors.blue : AppColors.textSecondary,
                onTap: () => widget.onLike?.call(),
              ),
              _ActionButton(
                icon: Icons.comment_outlined,
                label: widget.comments,
                color: _isCommentActive ? Colors.blue : AppColors.textSecondary,
                onTap: () {
                  setState(() => _isCommentActive = !_isCommentActive);
                },
              ),
              _ActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                color: AppColors.textSecondary,
                onTap: _generateShareLink,
              ),
            ],
          ),
          if (_isCommentActive)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: TextField(
                focusNode: _commentFocusNode,
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _generateShareLink() {
    final String deepLink = 'https://profit.app/post/${widget.postId}';
    Clipboard.setData(ClipboardData(text: deepLink));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Link copied: $deepLink'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18.sp),
            SizedBox(width: 4.w),
            Text(label, style: TextStyle(color: color, fontSize: 13.sp)),
          ],
        ),
      ),
    );
  }
}
