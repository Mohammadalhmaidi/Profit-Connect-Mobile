import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../api_service.dart';
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
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _imageFile;
  XFile? _videoFile;
  bool _isImproving = false;

  Future<void> _improveWithAI() async {
    final text = _contentController.text.trim();
    if (text.isEmpty || _isImproving) return;
    setState(() => _isImproving = true);
    try {
      final res = await sl<ApiService>().improve(text);
      final improved = res.data['data']?['improved'] as String?;
      if (improved != null && mounted) {
        setState(() => _contentController.text = improved);
        UIUtils.showSnackBar(
          context: context,
          message: context.tr('feed.ai_improved'),
          isError: false,
        );
      }
    } catch (_) {
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('feed.ai_failed'),
      );
    } finally {
      if (mounted) setState(() => _isImproving = false);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() {
      _imageFile = file;
      _videoFile = null;
    });
  }

  Future<void> _pickVideo() async {
    final file = await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    setState(() {
      _videoFile = file;
      _imageFile = null;
    });
  }

  void _clearMedia() {
    setState(() {
      _imageFile = null;
      _videoFile = null;
    });
  }

  void _submitPost() {
    final content = _contentController.text.trim();
    if (content.isEmpty && _imageFile == null && _videoFile == null) return;

    context.read<CreatePostCubit>().submit(
      content: content,
      imagePath: _imageFile?.path,
      videoPath: _videoFile?.path,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthBloc, UserEntity?>(
      (bloc) =>
          bloc.state is AuthSuccess ? (bloc.state as AuthSuccess).user : null,
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
            color: context.colors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          ),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: context.colors.surfaceMuted,
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
                      icon: Icon(
                        Icons.close,
                        color: context.colors.textPrimary,
                        size: 28.sp,
                      ),
                    ),
                    Text(
                      context.tr('feed.create_post'),
                      style: TextStyle(
                        color: context.colors.textPrimary,
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 8.h,
                        ),
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
                              context.tr('feed.post'),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              Divider(color: context.colors.divider),
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
                                user?.fullName ?? context.tr('common.you'),
                                style: TextStyle(
                                  color: context.colors.textPrimary,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                user?.headline?.isNotEmpty == true
                                    ? user!.headline!
                                    : user?.role.name ?? '',
                                style: TextStyle(
                                  color: context.colors.textSecondary,
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
                        style: TextStyle(
                          fontSize: 20.sp,
                          color: context.colors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: context.tr('feed.what_do_you_want'),
                          hintStyle: TextStyle(
                            color: context.colors.textHint,
                            fontSize: 20.sp,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                      if (_imageFile != null || _videoFile != null) ...[
                        SizedBox(height: 16.h),
                        _buildMediaPreview(),
                      ],
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 8.h,
                      ),
                      child: Row(
                        children: [
                          _buildHashtag('#career'),
                          _buildHashtag('#design'),
                          _buildHashtag('#hiring'),
                          const Spacer(),
                          GestureDetector(
                            onTap: _isImproving ? null : _improveWithAI,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_isImproving)
                                    SizedBox(
                                      width: 12.w,
                                      height: 12.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.auto_awesome,
                                      color: AppColors.primary,
                                      size: 14.sp,
                                    ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    _isImproving
                                        ? context.tr('feed.improving')
                                        : context.tr('feed.improve_ai'),
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    PostToolbar(onPhotoTap: _pickImage, onVideoTap: _pickVideo),
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

  Widget _buildHashtag(String tag) => Padding(
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

  Widget _buildMediaPreview() => Container(
    width: double.infinity,
    height: 220.h,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: context.colors.surfaceMuted,
      borderRadius: BorderRadius.circular(16.r),
    ),
    child: Stack(
      fit: StackFit.expand,
      children: [
        if (_imageFile != null)
          Image.file(File(_imageFile!.path), fit: BoxFit.cover)
        else
          _buildVideoPlaceholder(),
        Positioned(
          top: 8.h,
          right: 8.w,
          child: GestureDetector(
            onTap: _clearMedia,
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildVideoPlaceholder() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.videocam, color: context.colors.textHint, size: 40.sp),
        SizedBox(height: 8.h),
        Text(
          _videoFile?.name ?? context.tr('feed.video_selected'),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 13.sp,
          ),
        ),
      ],
    ),
  );
}

class PostToolbar extends StatelessWidget {
  final VoidCallback? onPhotoTap;
  final VoidCallback? onVideoTap;

  const PostToolbar({super.key, this.onPhotoTap, this.onVideoTap});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
    decoration: BoxDecoration(
      color: context.colors.surfaceMuted,
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    ),
    child: Row(
      children: [
        _ToolbarItem(
          icon: Icons.image_outlined,
          label: context.tr('feed.photo'),
          onTap: onPhotoTap,
        ),
        SizedBox(width: 24.w),
        _ToolbarItem(
          icon: Icons.videocam_outlined,
          label: context.tr('feed.video'),
          onTap: onVideoTap,
        ),
      ],
    ),
  );
}

class _ToolbarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ToolbarItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8.r),
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: context.colors.textSecondary),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    ),
  );
}
