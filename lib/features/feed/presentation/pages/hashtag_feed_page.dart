import '../../../../core/utils/time_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/presentation/widgets/stagger_entrance.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../api_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/models/post_model.dart';
import '../widgets/post_card.dart';

class HashtagFeedPage extends StatefulWidget {
  final String tag;

  const HashtagFeedPage({required this.tag, super.key});

  @override
  State<HashtagFeedPage> createState() => _HashtagFeedPageState();
}

class _HashtagFeedPageState extends State<HashtagFeedPage> {
  List<PostModel> _posts = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final api = sl<ApiService>();
      final res = await api.getPosts(limit: 30, hashtag: widget.tag);
      final list = (res.data['data'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map(
            (e) => PostModel.fromJson(
              Map<String, dynamic>.from(e),
              currentUserId: _myUserId(),
            ),
          )
          .toList();
      if (!mounted) return;
      setState(() {
        _posts = list;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  String? _myUserId() {
    final state = context.read<AuthBloc>().state;
    return state is AuthSuccess ? state.user.id : null;
  }

  String _formatTimeAgo(DateTime dateTime) => formatTimeAgo(context, dateTime);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.backgroundAlt,
    appBar: AppBar(
      backgroundColor: context.colors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: context.colors.textPrimary,
          size: 20.sp,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        '#${widget.tag}',
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    ),
    body: _isLoading && _posts.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : _hasError
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 56.sp,
                  color: context.colors.textHint,
                ),
                SizedBox(height: 12.h),
                Text(
                  context.tr('error'),
                  style: TextStyle(color: context.colors.textSecondary),
                ),
                SizedBox(height: 16.h),
                FilledButton(
                  onPressed: _load,
                  child: Text(context.tr('retry')),
                ),
              ],
            ),
          )
        : _posts.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.tag, size: 56.sp, color: context.colors.textHint),
                SizedBox(height: 12.h),
                Text(
                  context.tr('feed.hashtag_empty'),
                  style: TextStyle(color: context.colors.textSecondary),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(12.w),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return StaggerEntrance(
                  key: ValueKey('hashtag-post-${post.id}'),
                  index: index,
                  child: PostCard(
                    postId: post.id,
                    userId: post.userId,
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
                    shares: post.shareCount,
                    isLiked: post.isLiked,
                    isSaved: post.isSaved,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRouter.postDetails,
                      arguments: post.id,
                    ),
                  ),
                );
              },
            ),
          ),
  );
}
