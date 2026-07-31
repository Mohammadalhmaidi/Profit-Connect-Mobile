import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/presentation/widgets/failure_display.dart';
import '../../../../core/presentation/widgets/current_user_avatar.dart';
import '../manager/post_bloc.dart';
import '../manager/create_post_cubit.dart';
import '../widgets/post_card.dart';
import '../widgets/story_item.dart';
import 'create_post_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<PostBloc>().add(const GetPostsEvent());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PostBloc>().add(const GetPostsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.w),
            child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRouter.profile),
            child: const CurrentUserAvatar(radius: 18),
          ),
        ),
        title: Container(
          height: 40.h,
          decoration: BoxDecoration(
            color: AppColors.fieldBackground,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14.sp),
              prefixIcon: Icon(Icons.search, color: AppColors.textHint, size: 20.sp),
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
                icon: Icon(Icons.notifications, color: AppColors.primaryDark, size: 24.sp),
                onPressed: () => Navigator.pushNamed(context, AppRouter.notifications),
              ),
              Positioned(
                top: 12.h,
                right: 12.w,
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
          context.read<PostBloc>().add(const GetPostsEvent(page: 1, refresh: true));
        },
        child: BlocConsumer<PostBloc, PostState>(
          listener: (context, state) {
            if (state is PostsError) {
              showFailureSnackBar(
                context,
                ServerFailure(state.message),
              );
            }
          },
          builder: (context, state) {
            if (state is PostInitial || state is PostsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PostsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
                    SizedBox(height: 16.h),
                    Text(state.message, style: const TextStyle(color: AppColors.textSecondary)),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        context.read<PostBloc>().add(
                              const GetPostsEvent(page: 1, refresh: true),
                            );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is PostsLoaded) {
              return ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.posts.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildStoriesSection();
                  }
                  if (index == 1) {
                    return _buildCreatePostCard();
                  }
                  final postIndex = index - 2;
                  if (postIndex < state.posts.length) {
                    final post = state.posts[postIndex];
                    return PostCard(
                      postId: post.id,
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
                      isLiked: post.isLiked,
                      onLike: () {
                        context.read<PostBloc>().add(
                              ToggleLikeEvent(postId: post.id),
                            );
                      },
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
  }

  Widget _buildStoriesSection() {
    return Container(
      height: 110.h,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: const [
          StoryItem(label: 'Your Story', isYourStory: true),
          StoryItem(label: 'Sarah J.', imageUrl: 'https://i.pravatar.cc/150?u=sarah'),
          StoryItem(label: 'David L.', imageUrl: 'https://i.pravatar.cc/150?u=david'),
          StoryItem(label: 'Emily C.', imageUrl: 'https://i.pravatar.cc/150?u=emily'),
          StoryItem(label: 'Marcus J.', imageUrl: 'https://i.pravatar.cc/150?u=marcus'),
        ],
      ),
    );
  }

  Widget _buildCreatePostCard() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          const CurrentUserAvatar(radius: 24),
          SizedBox(width: 12.w),
          Expanded(
            child: InkWell(
              onTap: () => _showCreatePostSheet(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.indicatorInactive),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Text(
                  'What do you want to talk about?',
                  style: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${diff.inDays ~/ 7}w';
  }
}
