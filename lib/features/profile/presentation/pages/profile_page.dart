import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class ProfilePage extends StatefulWidget {
  final String? userName; // If null, show current user
  const ProfilePage({super.key, this.userName});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  
  // Controllers for editing
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _titleController;
  
  String _currentName = 'Mohammad Al-Hmaidi';
  String _currentBio = 'Passionate Software Engineer focused on building high-quality mobile experiences with Flutter and BLoC.';
  String _currentTitle = 'Senior Flutter Developer';
  List<String> _skills = ['Flutter', 'Dart', 'Firebase', 'Clean Architecture', 'BLoC'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _currentName);
    _bioController = TextEditingController(text: _currentBio);
    _titleController = TextEditingController(text: _currentTitle);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (_isEditing) {
      // Save logic
      setState(() {
        _currentName = _nameController.text;
        _currentBio = _bioController.text;
        _currentTitle = _titleController.text;
        _isEditing = false;
      });
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: AppColors.successGreen),
      );
    } else {
      setState(() {
        _isEditing = true;
      });
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isOwnProfile = widget.userName == null;

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: _buildAppBar(context, isOwnProfile),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              SizedBox(height: 24.h),
              if (!_isEditing) const _StatsRow(),
              SizedBox(height: 32.h),
              _buildAboutSection(),
              SizedBox(height: 32.h),
              _buildSkillsSection(),
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 32.h),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60.r,
            backgroundColor: AppColors.chipUnselected,
            backgroundImage: const CachedNetworkImageProvider(
              'https://i.pravatar.cc/300?u=mohammad',
            ),
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
                  _currentName,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _currentTitle,
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

  Widget _buildAboutSection() {
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
              _currentBio,
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

  Widget _buildSkillsSection() {
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
            children: _skills.map((skill) => _ProfileSkillChip(label: skill)).toList(),
          ),
          if (_isEditing)
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
