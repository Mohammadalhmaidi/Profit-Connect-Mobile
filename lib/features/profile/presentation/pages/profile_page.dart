import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../core/utils/media_url_helper.dart';
import '../../../../api_service.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class ProfilePage extends StatefulWidget {
  final String? userName; // If null, show current user
  const ProfilePage({super.key, this.userName});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  bool _isSaving = false;

  TextEditingController? _nameController;
  TextEditingController? _bioController;
  TextEditingController? _titleController;

  @override
  void dispose() {
    _nameController?.dispose();
    _bioController?.dispose();
    _titleController?.dispose();
    super.dispose();
  }

  UserEntity? _currentUser(BuildContext context) {
    final state = context.select((AuthBloc b) => b.state);
    return state is AuthSuccess ? state.user : null;
  }

  String _displayName(UserEntity? user) =>
      user?.fullName?.isNotEmpty == true ? user.fullName : 'Guest User';
  String _displayTitle(UserEntity? user) =>
      user?.headline?.isNotEmpty == true ? user.headline : 'Add a professional title';
  String _displayBio(UserEntity? user) =>
      user?.bio?.isNotEmpty == true
          ? user.bio
          : 'No bio yet. Tap "Edit profile" to add one.';
  List<String> _displaySkills(UserEntity? user) {
    final skills = user?.skills?.whereType<String>().where((s) => s.isNotEmpty).toList() ?? [];
    return skills;
  }

  void _toggleEdit() {
    final user = _currentUser(context);
    if (_isEditing) {
      _saveProfile(user);
    } else {
      setState(() {
        _isEditing = true;
        _nameController = TextEditingController(text: user?.fullName ?? '');
        _titleController = TextEditingController(text: user?.headline ?? '');
        _bioController = TextEditingController(text: user?.bio ?? '');
      });
    }
  }

  Future<void> _saveProfile(UserEntity? user) async {
    final name = _nameController?.text.trim() ?? '';
    final title = _titleController?.text.trim() ?? '';
    final bio = _bioController?.text.trim() ?? '';
    final parts = name.split(' ');
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    setState(() => _isSaving = true);
    try {
      await sl<ApiService>().updateProfile({
        if (firstName.isNotEmpty) 'firstName': firstName,
        if (lastName.isNotEmpty) 'lastName': lastName,
        if (title.isNotEmpty) 'headline': title,
        if (bio.isNotEmpty) 'bio': bio,
        'skills': user?.skills ?? [],
      });
      if (!mounted) return;
      setState(() {
        _isEditing = false;
        _isSaving = false;
      });
      UIUtils.showSnackBar(
        context: context,
        message: 'Profile updated successfully!',
        isError: false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      UIUtils.showSnackBar(
        context: context,
        message: 'Failed to update profile: $e',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser(context);
    final isOwnProfile = widget.userName == null;
    final displayName = _displayName(user);
    final displayTitle = _displayTitle(user);
    final displayBio = _displayBio(user);
    final displaySkills = _displaySkills(user);
    final avatarUrl = user?.avatar ?? '';

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: _buildAppBar(context, isOwnProfile),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(user, displayName, displayTitle, avatarUrl, isOwnProfile),
              SizedBox(height: 24.h),
              if (!_isEditing) const _StatsRow(),
              SizedBox(height: 32.h),
              _buildAboutSection(displayBio),
              SizedBox(height: 32.h),
              _buildSkillsSection(displaySkills, isOwnProfile),
              SizedBox(height: 32.h),
              if (!isOwnProfile) _buildActionButtons(),
              if (isOwnProfile && !_isEditing) const _ExperienceSection(),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isOwnProfile) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        _isEditing ? 'Edit Profile' : 'Profile',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (isOwnProfile)
          IconButton(
            icon: Icon(_isEditing ? Icons.check_circle : Icons.edit, color: AppColors.primaryDark),
            onPressed: _toggleEdit,
          ),
        if (isOwnProfile && !_isEditing)
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () => Navigator.pushNamed(context, AppRouter.settings),
          ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildHeader(
    UserEntity? user,
    String displayName,
    String displayTitle,
    String avatarUrl,
    bool isOwnProfile,
  ) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 32.h),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60.r,
            backgroundColor: AppColors.chipUnselected,
            backgroundImage: avatarUrl.isNotEmpty
                ? CachedNetworkImageProvider(MediaUrlHelper.resolve(avatarUrl))
                : null,
            child: avatarUrl.isEmpty
                ? Icon(Icons.person, color: AppColors.primaryDark, size: 48.sp)
                : null,
          ),
          SizedBox(height: 16.h),
          if (_isEditing)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(hintText: 'Full Name'),
                  ),
                  TextField(
                    controller: _titleController,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
                    decoration: const InputDecoration(hintText: 'Professional Title'),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  displayTitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildAboutSection(String bio) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('About'),
          SizedBox(height: 12.h),
          if (_isEditing)
            TextField(
              controller: _bioController,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
              ),
            )
          else
            Text(
              bio,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15.sp,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(List<String> skills, bool isOwnProfile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Top Skills'),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 12.h,
            children: skills.map((skill) => _ProfileSkillChip(label: skill)).toList(),
          ),
          if (isOwnProfile && _isEditing)
            Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Add Skill'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: const Text('Connect', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryDark),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: const Text('Message', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.primaryDark,
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        decoration: BoxDecoration(
          color: AppColors.vibrantPurple,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.vibrantPurple.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStat('42', 'Applied'),
            _buildDivider(),
            _buildStat('15', 'Saved'),
            _buildDivider(),
            _buildStat('8', 'Interviews'),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).scale(curve: Curves.easeOutBack);
  }

  Widget _buildStat(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30.h,
      width: 1.w,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}

class _ProfileSkillChip extends StatelessWidget {
  final String label;
  const _ProfileSkillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.indicatorInactive.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ExperienceSection extends StatelessWidget {
  const _ExperienceSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Experience'),
          SizedBox(height: 16.h),
          const _ExperienceItem(
            company: 'TechCorp',
            role: 'Senior Flutter Developer',
            period: '2022 - Present',
            logoUrl: 'https://i.pravatar.cc/150?u=techcorp',
          ),
          const _ExperienceItem(
            company: 'Innovation Labs',
            role: 'Mobile Developer',
            period: '2020 - 2022',
            logoUrl: 'https://i.pravatar.cc/150?u=innov',
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.primaryDark,
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _ExperienceItem extends StatelessWidget {
  final String company;
  final String role;
  final String period;
  final String logoUrl;

  const _ExperienceItem({
    required this.company,
    required this.role,
    required this.period,
    required this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: CachedNetworkImage(
              imageUrl: logoUrl,
              width: 48.w,
              height: 48.w,
              placeholder: (context, url) => Container(color: AppColors.fieldBackground),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  company,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  period,
                  style: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
