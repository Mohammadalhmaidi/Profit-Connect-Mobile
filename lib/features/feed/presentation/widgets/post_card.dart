import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/theme/app_colors.dart';

class PostCard extends StatefulWidget {
  final String userName;
  final String userRole;
  final String userAvatar;
  final String timeAgo;
  final String content;
  final List<String> hashtags;
  final String? mediaUrl;
  final String likes;
  final String comments;
  final String postId;

  const PostCard({
    super.key,
    required this.userName,
    required this.userRole,
    required this.userAvatar,
    required this.timeAgo,
    required this.content,
    required this.hashtags,
    this.mediaUrl,
    required this.likes,
    required this.comments,
    this.postId = 'post_123',
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLiked = false;
  bool _isCommentActive = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void dispose() {
    _audioPlayer.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _triggerInteractionEffect() async {
    HapticFeedback.mediumImpact();
    try {
      await _audioPlayer.play(AssetSource('sounds/bubble.mp3'));
    } catch (e) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  void _handleLike() {
    setState(() => _isLiked = !_isLiked);
    if (_isLiked) _triggerInteractionEffect();
  }

  void _handleComment() {
    setState(() => _isCommentActive = true);
    _commentFocusNode.requestFocus();
    _triggerInteractionEffect();
  }

  void _generateShareLink() {
    final String deepLink = 'https://profit.app/post/${widget.postId}';
    Clipboard.setData(ClipboardData(text: deepLink));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Link Generated & Copied: $deepLink'),
        backgroundColor: AppColors.primary,
      ),
    );
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
                child: CircleAvatar(radius: 24.r, backgroundImage: NetworkImage(widget.userAvatar)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${widget.userRole} • ${widget.timeAgo}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(widget.content),
          if (widget.mediaUrl != null) ...[
            SizedBox(height: 12.h),
            ClipRRect(borderRadius: BorderRadius.circular(8.r), child: Image.network(widget.mediaUrl!)),
          ],
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ActionButton(
                icon: _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                label: 'Like',
                color: _isLiked ? Colors.blue : AppColors.textSecondary,
                onTap: _handleLike,
              ),
              _ActionButton(
                icon: Icons.comment_outlined,
                label: 'Comment',
                color: _isCommentActive ? Colors.blue : AppColors.textSecondary,
                onTap: _handleComment,
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.r)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        child: Row(children: [Icon(icon, color: color, size: 20.sp), SizedBox(width: 4.w), Text(label, style: TextStyle(color: color))]),
      ),
    );
  }
}
