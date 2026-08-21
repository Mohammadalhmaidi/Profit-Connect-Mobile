import '../../../../core/utils/time_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/presentation/widgets/failure_display.dart';
import '../../../../core/presentation/widgets/current_user_avatar.dart';
import '../../../../core/presentation/widgets/app_empty_state.dart';
import '../../../../core/presentation/widgets/stagger_entrance.dart';
import '../../../../core/presentation/widgets/shimmer.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../api_service.dart';
import '../../../main_layout/presentation/manager/navigation_cubit.dart';
import '../manager/post_bloc.dart';
import '../manager/create_post_cubit.dart';
import '../widgets/post_card.dart';
import 'create_post_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _showNotificationDot = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _refreshNotificationDot();
    context.read<PostBloc>().add(const GetPostsEvent());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshNotificationDot() async {
    try {
      final res = await sl<ApiService>().getNotifications();
      final body = res.data is Map ? Map<String, dynamic>.from(res.data) : null;
      final list = body?['data'] as List<dynamic>? ?? [];
      final hasUnread = list.any((e) => e is Map && e['read'] != true);
      if (mounted) setState(() => _showNotificationDot = hasUnread);
    } catch (_) {
      // Keep dot state as-is when the request fails
    }
  }

  Future<void> _openNotifications() async {
    await Navigator.pushNamed(context, AppRouter.notifications);
    await _refreshNotificationDot();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PostBloc>().add(const GetPostsEvent());
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.backgroundAlt,
    appBar: AppBar(
      leading: Padding(
        padding: EdgeInsetsDirectional.only(start: 16.w),
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRouter.profile),
          child: const CurrentUserAvatar(radius: 18),
        ),
      ),
      title: Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: context.colors.surfaceMuted,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: TextField(
          readOnly: true,
          onTap: () => Navigator.pushNamed(context, AppRouter.searchUsers),
          style: TextStyle(color: context.colors.textPrimary),
          decoration: InputDecoration(
            hintText: context.tr('search'),
            hintStyle: TextStyle(
              color: context.colors.textHint,
              fontSize: 14.sp,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: context.colors.textHint,
              size: 20.sp,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 8.h),
          ),
        ),
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications,
                color: context.colors.textPrimary,
                size: 24.sp,
              ),
              onPressed: _openNotifications,
            ),
            if (_showNotificationDot)
              PositionedDirectional(
                top: 12.h,
                end: 12.w,
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: AppColors.accentCyan,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(width: 8.w),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: () async {
        final bloc = context.read<PostBloc>();
        await _refreshNotificationDot();
        await bloc.refresh();
      },
      child: BlocConsumer<PostBloc, PostState>(
        listener: (context, state) {
          if (state is PostsError) {
            showFailureSnackBar(context, ServerFailure(state.message));
          }
        },
        builder: (context, state) {
          if (state is PostInitial || state is PostsLoading) {
            return const ListSkeleton(itemCount: 6);
          }

          if (state is PostsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: AppColors.error,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    state.message,
                    style: TextStyle(color: context.colors.textSecondary),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PostBloc>().add(
                        const GetPostsEvent(refresh: true),
                      );
                    },
                    child: Text(context.tr('retry')),
                  ),
                ],
              ),
            );
          }

          if (state is PostsLoaded) {
            return ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.posts.isEmpty ? 2 : state.posts.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return StaggerEntrance(
                    index: 0,
                    child: _buildCreatePostCard(),
                  );
                }
                if (state.posts.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.article_outlined,
                    title: context.tr('feed.empty_title'),
                    subtitle: context.tr('feed.empty_subtitle'),
                    action: FilledButton.icon(
                      onPressed: () =>
                          context.read<NavigationCubit>().setIndex(1),
                      icon: const Icon(Icons.people_outline),
                      label: Text(context.tr('feed.find_people')),
                    ),
                  );
                }
                final postIndex = index - 1;
                if (postIndex < state.posts.length) {
                  final post = state.posts[postIndex];
                  return StaggerEntrance(
                    key: ValueKey('post-${post.id}'),
                    index: postIndex,
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
                      onLike: () {
                        context.read<PostBloc>().add(
                          ToggleLikeEvent(postId: post.id),
                        );
                      },
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRouter.postDetails,
                        arguments: post.id,
                      ),
                    ),
                  );
                }
                if (state.hasReachedMax) {
                  return const SizedBox.shrink();
                }
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    ),
  );

  Widget _buildCreatePostCard() => Container(
    color: context.colors.surface,
    padding: EdgeInsets.all(16.w),
    margin: EdgeInsets.only(bottom: 8.h),
    child: Row(
      children: [
        const CurrentUserAvatar(radius: 24),
        SizedBox(width: 12.w),
        Expanded(
          child: InkWell(
            onTap: _showCreatePostSheet,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                border: Border.all(color: context.colors.inputBorder),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Text(
                context.tr('feed.what_do_you_want'),
                style: TextStyle(
                  color: context.colors.textHint,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  void _showCreatePostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => sl<CreatePostCubit>(),
        child: const CreatePostSheet(),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) => formatTimeAgo(context, dateTime);
}
