import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/presentation/widgets/pressable.dart';
import '../../../../core/presentation/widgets/memory_safe_video_player.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/deep_linking/deep_link_builder.dart';
import '../../../../core/interaction/post_interactions.dart';
import '../../../../core/image/image_optimization.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../api_service.dart';

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
  final int shares;
  final String postId;
  final String? userId;
  final bool isLiked;
  final bool isSaved;
  final VoidCallback? onLike;
  final VoidCallback? onTap;
  final VoidCallback? onCommentTap;
  final VoidCallback? onSaveChanged;

  const PostCard({
    required this.userName,
    required this.userRole,
    required this.userAvatar,
    required this.timeAgo,
    required this.content,
    required this.hashtags,
    required this.likes,
    required this.comments,
    required this.postId,
    super.key,
    this.shares = 0,
    this.mediaUrl,
    this.videoUrl,
    this.userId,
    this.isLiked = false,
    this.isSaved = false,
    this.onLike,
    this.onTap,
    this.onCommentTap,
    this.onSaveChanged,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool _isSaved;
  late int _shares;
  bool _isTranslating = false;
  String? _translatedContent;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.isSaved;
    _shares = widget.shares;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onCommentPressed() {
    if (widget.onCommentTap != null) {
      widget.onCommentTap!();
    } else {
      Navigator.pushNamed(
        context,
        AppRouter.postDetails,
        arguments: widget.postId,
      );
    }
  }

  Future<void> _toggleSave() async {
    final api = sl<ApiService>();
    final previous = _isSaved;
    setState(() => _isSaved = !_isSaved);
    try {
      if (_isSaved) {
        await api.savePost(widget.postId);
      } else {
        await api.unsavePost(widget.postId);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaved = previous);
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('feed.save_failed'),
      );
      return;
    }
    widget.onSaveChanged?.call();
  }

  Future<void> _toggleTranslate() async {
    if (_isTranslating) return;
    if (_translatedContent != null) {
      setState(() => _translatedContent = null);
      return;
    }
    setState(() => _isTranslating = true);
    final translated = await PostInteractions.translateContent(widget.content);
    if (!mounted) return;
    setState(() {
      _isTranslating = false;
      _translatedContent = translated ?? widget.content;
    });
    if (translated == null) {
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('feed.translate_failed'),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: 8.h),
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: context.colors.inputBorder),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12.r,
          offset: Offset(0, 4.r),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                final authorId = widget.userId;
                if (authorId == null || authorId.isEmpty) return;
                Navigator.pushNamed(
                  context,
                  AppRouter.profile,
                  arguments: authorId,
                );
              },
              child: Container(
                padding: EdgeInsets.all(2.r),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.vibrantPurple, AppColors.accentCyan],
                  ),
                ),
                child: CircleAvatar(
                  radius: 22.r,
                  backgroundColor: context.colors.surfaceMuted,
                  backgroundImage: widget.userAvatar.isNotEmpty
                      ? ResizeImage(
                          CachedNetworkImageProvider(widget.userAvatar),
                          width: ImageOptimization.maxWidthCache,
                          height: ImageOptimization.maxWidthCache,
                        )
                      : null,
                  child: widget.userAvatar.isEmpty
                      ? Icon(
                          Icons.person,
                          color: context.colors.textHint,
                          size: 22.sp,
                        )
                      : null,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      final authorId = widget.userId;
                      if (authorId == null || authorId.isEmpty) return;
                      Navigator.pushNamed(
                        context,
                        AppRouter.profile,
                        arguments: authorId,
                      );
                    },
                    child: Text(
                      widget.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${widget.userRole} \u2022 ${widget.timeAgo}',
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_horiz,
                color: context.colors.textSecondary,
                size: 20.sp,
              ),
              color: context.colors.surface,
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'copy',
                  child: Text(
                    context.tr('copy'),
                    style: TextStyle(color: context.colors.textPrimary),
                  ),
                ),
                PopupMenuItem(
                  value: 'share',
                  child: Text(
                    context.tr('share'),
                    style: TextStyle(color: context.colors.textPrimary),
                  ),
                ),
                PopupMenuItem(
                  value: 'save',
                  child: Text(
                    _isSaved ? context.tr('saved') : context.tr('save'),
                    style: TextStyle(color: context.colors.textPrimary),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _translatedContent ?? widget.content,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: context.colors.textPrimary,
                ),
              ),
              if (widget.hashtags.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: widget.hashtags
                      .map(
                        (tag) => GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRouter.hashtagFeed,
                            arguments: tag.replaceFirst('#', ''),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentCyan.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              tag.startsWith('#') ? tag : '#$tag',
                              style: TextStyle(
                                color: AppColors.accentCyan,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              if (widget.mediaUrl != null && widget.mediaUrl!.isNotEmpty) ...[
                SizedBox(height: 12.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: CachedNetworkImage(
                    imageUrl: widget.mediaUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    memCacheWidth: ImageOptimization.maxWidthCache,
                    placeholder: (context, url) => Container(
                      height: 200.h,
                      color: context.colors.surfaceMuted,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200.h,
                      color: context.colors.surfaceMuted,
                      child: const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),
              ],
              if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) ...[
                SizedBox(height: 12.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: MemorySafeVideoPlayer(
                    videoUrl: widget.videoUrl!,
                    autoPlay: false,
                  ),
                ),
              ],
            ],
          ),
        ),
        const Divider(),
        Container(
          margin: EdgeInsets.only(top: 4.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ActionButton(
                icon: widget.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                label: widget.likes,
                isActive: widget.isLiked,
                activeColor: Theme.of(context).colorScheme.secondary,
                inactiveColor: context.colors.textSecondary,
                onTap: () => widget.onLike?.call(),
              ),
              _ActionButton(
                icon: Icons.comment_outlined,
                label: widget.comments,
                inactiveColor: context.colors.textSecondary,
                onTap: _onCommentPressed,
              ),
              _ActionButton(
                icon: Icons.share_outlined,
                label: '$_shares',
                inactiveColor: context.colors.textSecondary,
                onTap: _generateShareLink,
              ),
              _ActionButton(
                icon: _isSaved ? Icons.bookmark : Icons.bookmark_outline,
                label: _isSaved ? context.tr('saved') : context.tr('save'),
                isActive: _isSaved,
                activeColor: AppColors.primaryDark,
                inactiveColor: context.colors.textSecondary,
                onTap: _toggleSave,
              ),
              IconButton(
                onPressed: _isTranslating ? null : _toggleTranslate,
                tooltip: context.tr('translate'),
                icon: _isTranslating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Icon(
                        Icons.translate,
                        color: _translatedContent != null
                            ? AppColors.primaryDark
                            : context.colors.textSecondary,
                        size: 18.sp,
                      ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  void _handleMenuAction(String value) {
    switch (value) {
      case 'copy':
        PostInteractions.copyPostLink(context, widget.postId);
      case 'share':
        _generateShareLink();
      case 'save':
        _toggleSave();
    }
  }

  Future<void> _generateShareLink() async {
    final deepLink = DeepLinkBuilder.post(widget.postId);
    await Clipboard.setData(ClipboardData(text: deepLink));
    try {
      final res = await sl<ApiService>().sharePost(widget.postId);
      if (!mounted) return;
      final map = res.data;
      if (map is Map) {
        final count = map['shareCount'] as num?;
        if (count != null) {
          setState(() => _shares = count.toInt());
        }
        final already = map['alreadyShared'] == true;
        if (already) return; // محاولة مكررة: لا ننسخ الرابط مرة أخرى
      }
    } catch (_) {
      // مشاركة دون اتصال: لا نغيّر العداد لأن الخادم لم يسجّلها
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('feed.copied', {'url': deepLink})),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color? activeColor;
  final Color? inactiveColor;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _labelSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 1.28,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.28,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
    ]).animate(_controller);
    _labelSlide = Tween<double>(
      begin: 8,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant _ActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive
        ? (widget.activeColor ?? context.colors.textSecondary)
        : (widget.inactiveColor ?? context.colors.textSecondary);
    return PressableScale(
      onTap: widget.onTap,
      pressedScale: 0.9,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) =>
                  Transform.scale(scale: _scale.value, child: child),
              child: Icon(widget.icon, color: color, size: 18.sp),
            ),
            SizedBox(width: 4.w),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, _labelSlide.value),
                  child: child,
                ),
                child: Text(
                  widget.label,
                  style: TextStyle(color: color, fontSize: 13.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
