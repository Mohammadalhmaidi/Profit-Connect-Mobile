import '../../../../core/utils/time_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../api_service.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/presentation/widgets/app_empty_state.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/post_model.dart';
import '../widgets/post_card.dart';

/// شاشة المنشورات المحفوظة — تعرض المنشورات المحفوظة من الباك.
class SavedPostsPage extends StatefulWidget {
  const SavedPostsPage({super.key});

  @override
  State<SavedPostsPage> createState() => _SavedPostsPageState();
}

class _SavedPostsPageState extends State<SavedPostsPage> {
  final _api = sl<ApiService>();
  List<PostModel> _posts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await _api.getSavedPosts();
      final body = res.data is Map ? Map<String, dynamic>.from(res.data) : null;
      final list = body?['data'] as List<dynamic>? ?? [];
      final currentUserId = await _api.getCurrentUserId();
      final posts = list
          .map(
            (json) => PostModel.fromJson(
              Map<String, dynamic>.from(json as Map),
              currentUserId: currentUserId,
            ),
          )
          .toList();
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = context.tr('error');
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleLike(PostModel post) async {
    try {
      await _api.likePost(post.id);
    } catch (_) {
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('network.follow_failed'),
      );
    }
    await _load();
  }

  String _formatTimeAgo(DateTime? createdAt) =>
      formatTimeAgo(context, createdAt);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.tr('saved_posts_title')),
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, style: const TextStyle(color: Colors.red)),
                SizedBox(height: 12.h),
                FilledButton(
                  onPressed: _load,
                  child: Text(context.tr('retry')),
                ),
              ],
            ),
          )
        : _posts.isEmpty
        ? AppEmptyState(
            icon: Icons.bookmark_outline,
            title: context.tr('saved_posts_empty'),
            subtitle: context.tr('saved_posts_empty_hint'),
          )
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 24.h),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return PostCard(
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
                  onLike: () => _toggleLike(post),
                  onSaveChanged: _load,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRouter.postDetails,
                    arguments: post.id,
                  ),
                );
              },
            ),
          ),
  );
}
