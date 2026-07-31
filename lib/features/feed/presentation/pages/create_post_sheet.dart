import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/widgets/current_user_avatar.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../manager/post_bloc.dart';
import '../manager/create_post_cubit.dart';

class CreatePostSheet extends StatefulWidget {
  const CreatePostSheet({super.key});

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _submitPost() {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;

    context.read<CreatePostCubit>().submit(content: content);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthBloc, UserEntity?>(
      (bloc) => bloc.state is AuthSuccess ? (bloc.state as AuthSuccess).user : null,
    );

    return BlocConsumer<CreatePostCubit, CreatePostState>(
      listener: (context, state) {
        if (state is CreatePostSuccess) {
          context.read<PostBloc>().add(const GetPostsEvent(refresh: true));
          Navigator.pop(context);
        } else if (state is CreatePostFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
          context.read<CreatePostCubit>().reset();
        }
      },
      builder: (context, state) {
        final isSubmitting = state is CreatePostLoading;
        return Container(
          height: 0.9.sh,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.indicatorInactive,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: AppColors.textPrimary, size: 28.sp),
                    ),
                    Text(
                      'Create Post',
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isSubmitting ? null : _submitPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentCyan,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Post',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              Divider(color: AppColors.indicatorInactive.withValues(alpha: 0.5)),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          const CurrentUserAvatar(radius: 28),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.fullName ?? 'You',
                                style: TextStyle(
                                  color: AppColors.primaryDark,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                user?.headline?.isNotEmpty == true
                                    ? user!.headline!
                                    : user?.role.name ?? '',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      TextField(
                        controller: _contentController,
                        maxLines: null,
                        autofocus: true,
                        style: TextStyle(fontSize: 20.sp, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'What do you want to talk about?',
                          hintStyle: TextStyle(
                            color: AppColors.textHint.withValues(alpha: 0.8),
                            fontSize: 20.sp,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                      child: Row(
                        children: [
                          _buildHashtag('#career'),
                          _buildHashtag('#design'),
                          _buildHashtag('#hiring'),
                        ],
                      ),
                    ),
                    const PostToolbar(),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHashtag(String tag) {
    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: Text(
        tag,
        style: TextStyle(
          color: AppColors.accentCyan,
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class PostToolbar extends StatelessWidget {
  const PostToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Row(
        children: [
          _ToolbarItem(icon: Icons.image_outlined, label: 'Photo'),
          SizedBox(width: 24.w),
          _ToolbarItem(icon: Icons.videocam_outlined, label: 'Video'),
          SizedBox(width: 24.w),
          _ToolbarItem(icon: Icons.article_outlined, label: 'Article'),
          const Spacer(),
          _ToolbarItem(icon: Icons.more_horiz, label: 'More'),
        ],
      ),
    );
  }
}

class _ToolbarItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ToolbarItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: AppColors.textSecondary),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}
