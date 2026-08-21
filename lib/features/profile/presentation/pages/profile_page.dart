import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../core/utils/media_url_helper.dart';
import '../../../../core/utils/follow_toggle.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../api_service.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../main_layout/presentation/manager/navigation_cubit.dart';

class ProfilePage extends StatefulWidget {
  final String? userId; // If null, show current user
  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  bool _isUploadingAvatar = false;
  bool _isLoadingOther = false;
  bool _isFollowing = false;
  Map<String, dynamic>? _otherUser;
  String? _myUserId;
  int _myPostsCount = 0;
  int _myFollowersCount = 0;
  int _myFollowingCount = 0;

  TextEditingController? _nameController;
  TextEditingController? _bioController;
  TextEditingController? _titleController;
  TextEditingController? _skillsController;
  List<String> _editableSkills = [];
  String _birthDate = '';
  String? _gender;
  StreamSubscription<int>? _navSubscription;

  @override
  void initState() {
    super.initState();
    _resolveMyId();
    if (widget.userId != null) {
      _loadOtherUser();
    } else {
      _loadMyStats();
      try {
        _navSubscription = context.read<NavigationCubit>().stream.listen((index) {
          if (index == 4 && mounted) _loadMyStats();
        });
      } catch (_) {
        // الصفحة مفتوحة كمسار مستقل دون NavigationCubit
      }
    }
  }

  Future<void> _resolveMyId() async {
    final id = await sl<ApiService>().getCurrentUserId();
    if (!mounted || id == null) return;
    setState(() => _myUserId = id);
  }

  @override
  void dispose() {
    _navSubscription?.cancel();
    _nameController?.dispose();
    _bioController?.dispose();
    _titleController?.dispose();
    _skillsController?.dispose();
    super.dispose();
  }

  Future<void> _loadOtherUser() async {
    final userId = widget.userId;
    if (userId == null) return;
    setState(() => _isLoadingOther = true);
    try {
      final api = sl<ApiService>();
      final profileRes = await api.getUserById(userId);
      final otherData = profileRes.data['data'] as Map<String, dynamic>?;
      final followingRes = await api.getMyFollowing();
      final followingList = followingRes.data['data'] as List<dynamic>? ?? [];
      final isFollowing =
          (otherData?['isFollowing'] as bool?) ??
          followingList.any((u) => u['_id'] == userId);
      if (!mounted) return;
      setState(() {
        _otherUser = otherData;
        _isFollowing = isFollowing;
        _isLoadingOther = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingOther = false);
    }
  }

  Future<void> _loadMyStats() async {
    try {
      final res = await sl<ApiService>().getNetworkStats();
      final data = res.data['data'] as Map<String, dynamic>?;
      if (!mounted || data == null) return;
      setState(() {
        _myPostsCount = (data['postsCount'] as num?)?.toInt() ?? _myPostsCount;
        _myFollowersCount =
            (data['followersCount'] as num?)?.toInt() ?? _myFollowersCount;
        _myFollowingCount =
            (data['followingCount'] as num?)?.toInt() ?? _myFollowingCount;
      });
    } catch (_) {
      // تجاهل — تُعرض الإحصائيات عند توفرها
    }
  }

  Future<void> _toggleFollow() async {
    final userId = widget.userId;
    if (userId == null) return;
    final previous = _isFollowing;
    final prevCount = (_otherUser?['followersCount'] as num?)?.toInt() ?? 0;
    setState(() {
      _isFollowing = !_isFollowing;
      _otherUser?['followersCount'] = prevCount + (_isFollowing ? 1 : -1);
      _myFollowingCount += (_isFollowing ? 1 : -1);
    });
    final result = await FollowToggle(
      sl<ApiService>(),
    ).toggle(userId: userId, isFollowing: previous);
    if (result == FollowToggleResult.success) {
      await _refreshCounts(userId);
      await _loadMyStats();
      return;
    }
    if (!mounted) return;
    setState(() {
      _isFollowing = previous;
      _otherUser?['followersCount'] = prevCount;
      _myFollowingCount += (previous ? 1 : -1);
    });
    if (result == FollowToggleResult.failure) {
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('profile.follow_failed'),
      );
    }
  }

  Future<void> _refreshCounts(String userId) async {
    try {
      final res = await sl<ApiService>().getUserById(userId);
      final data = res.data['data'] as Map<String, dynamic>?;
      if (!mounted || data == null) return;
      setState(() {
        _otherUser?['followersCount'] = data['followersCount'];
        _otherUser?['followingCount'] = data['followingCount'];
        _isFollowing = (data['isFollowing'] as bool?) ?? _isFollowing;
      });
    } catch (_) {
      // إبقاء القيم التفاؤلية إذا فشل التحديث
    }
  }

  Future<void> _openFollowList(String mode) async {
    final userId = widget.userId ?? _myUserId;
    if (userId == null) return;
    await Navigator.pushNamed(
      context,
      AppRouter.followList,
      arguments: {'userId': userId, 'mode': mode},
    );
    if (mounted && widget.userId == null) _loadMyStats();
  }

  Future<void> _pickAndUploadAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _isUploadingAvatar = true);
    try {
      await sl<ApiService>().updateAvatar(picked.path);
      if (!mounted) return;
      context.read<AuthBloc>().add(const CheckAuthStatus(forceFetch: true));
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('profile.avatar_updated'),
        isError: false,
      );
    } catch (_) {
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('profile.avatar_failed'),
      );
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  UserEntity? _currentUser(BuildContext context) =>
      context.select<AuthBloc, AuthState>((b) => b.state) is AuthSuccess
      ? (context.select<AuthBloc, AuthState>((b) => b.state) as AuthSuccess)
            .user
      : null;

  String _displayName(UserEntity? user) =>
      user != null && user.fullName.isNotEmpty
      ? user.fullName
      : context.tr('profile.guest');
  String _displayTitle(UserEntity? user) {
    if (user != null && (user.headline?.isNotEmpty ?? false)) {
      return user.headline!;
    }
    return context.tr('profile.add_title');
  }

  String _displayBio(UserEntity? user) {
    if (user != null && (user.bio?.isNotEmpty ?? false)) {
      return user.bio!;
    }
    return context.tr('profile.no_bio');
  }

  List<String> _displaySkills(UserEntity? user) {
    if (user == null) return [];
    return user.skills.where((s) => s.isNotEmpty).toList();
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
        _skillsController = TextEditingController();
        _editableSkills = List.of(user?.skills ?? []);
        _birthDate = user?.birthDate ?? '';
        _gender = user?.gender;
      });
    }
  }

  void _addSkill() {
    final text = _skillsController?.text.trim() ?? '';
    if (text.isEmpty) return;
    setState(() {
      if (!_editableSkills.contains(text)) _editableSkills.add(text);
      _skillsController?.clear();
    });
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = DateTime.tryParse(_birthDate) ?? DateTime(now.year - 25);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null) return;
    final formatted =
        '${picked.year.toString().padLeft(4, '0')}-'
        '${picked.month.toString().padLeft(2, '0')}-'
        '${picked.day.toString().padLeft(2, '0')}';
    setState(() => _birthDate = formatted);
  }

  Future<void> _pickGender() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                context.tr('profile.gender'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.male),
              title: const Text('Male'),
              onTap: () => Navigator.pop(context, 'male'),
            ),
            ListTile(
              leading: const Icon(Icons.female),
              title: const Text('Female'),
              onTap: () => Navigator.pop(context, 'female'),
            ),
          ],
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() => _gender = selected);
  }

  Future<void> _saveProfile(UserEntity? user) async {
    final name = _nameController?.text.trim() ?? '';
    final title = _titleController?.text.trim() ?? '';
    final bio = _bioController?.text.trim() ?? '';
    final parts = name.split(' ');
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    setState(() {});

    try {
      await sl<ApiService>().updateProfile({
        if (firstName.isNotEmpty) 'firstName': firstName,
        if (lastName.isNotEmpty) 'lastName': lastName,
        if (title.isNotEmpty) 'headline': title,
        if (bio.isNotEmpty) 'bio': bio,
        'skills': _editableSkills,
        if (_birthDate.isNotEmpty) 'birthDate': _birthDate,
        if (_gender != null) 'gender': _gender,
      });
      if (!mounted) return;
      setState(() {
        _isEditing = false;
        _nameController?.dispose();
        _bioController?.dispose();
        _titleController?.dispose();
        _skillsController?.dispose();
        _nameController = null;
        _bioController = null;
        _titleController = null;
        _skillsController = null;
        _editableSkills = [];
        _birthDate = '';
        _gender = null;
      });
      context.read<AuthBloc>().add(const CheckAuthStatus(forceFetch: true));
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('profile.updated'),
        isError: false,
      );
    } catch (e) {
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('profile.update_failed', {'error': '$e'}),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwnProfile = widget.userId == null || widget.userId == _myUserId;
    final user = isOwnProfile
        ? _currentUser(context)
        : _userFromMap(_otherUser);
    final displayName = _displayName(user);
    final displayTitle = _displayTitle(user);
    final displayBio = _displayBio(user);
    final displaySkills = _displaySkills(user);
    final avatarUrl = user?.avatar ?? '';
    final otherPosts = isOwnProfile
        ? <Map<String, dynamic>>[]
        : _otherUserPosts();

    return Scaffold(
      backgroundColor: context.colors.backgroundAlt,
      appBar: _buildAppBar(context, isOwnProfile),
      body: SafeArea(
        child: _isLoadingOther
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(
                      user,
                      displayName,
                      displayTitle,
                      avatarUrl,
                      isOwnProfile,
                    ),
                    SizedBox(height: 32.h),
                    _buildAboutSection(displayBio),
                    SizedBox(height: 32.h),
                    _buildSkillsSection(displaySkills),
                    if (!isOwnProfile && otherPosts.isNotEmpty) ...[
                      SizedBox(height: 32.h),
                      _buildPostsSection(otherPosts),
                    ],
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
      ),
    );
  }

  List<Map<String, dynamic>> _otherUserPosts() {
    final posts = _otherUser?['posts'] as List<dynamic>? ?? [];
    return posts.whereType<Map<String, dynamic>>().toList();
  }

  Widget _buildPostsSection(List<Map<String, dynamic>> posts) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 24.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context.tr('posts')),
        SizedBox(height: 16.h),
        for (final post in posts) _buildOtherPostTile(post),
      ],
    ),
  );

  Widget _buildOtherPostTile(Map<String, dynamic> post) {
    final author = post['user'] as Map<String, dynamic>? ?? {};
    final authorProfile = author['profile'] as Map<String, dynamic>? ?? {};
    final authorName =
        authorProfile['fullname'] as String? ??
        '${authorProfile['firstName'] ?? ''} ${authorProfile['lastName'] ?? ''}'
            .trim();
    final authorAvatar = authorProfile['avatar'] as String? ?? '';
    final image = post['image'] as String?;
    final postId = (post['_id'] ?? '').toString();
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        AppRouter.postDetails,
        arguments: postId,
      ),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: context.colors.inputBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: context.colors.surfaceMuted,
                  backgroundImage: authorAvatar.isNotEmpty
                      ? CachedNetworkImageProvider(
                          MediaUrlHelper.resolve(authorAvatar),
                        )
                      : null,
                  child: authorAvatar.isEmpty
                      ? const Icon(Icons.person, size: 18)
                      : null,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    authorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              post['content'] ?? '',
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 14.sp,
                height: 1.4,
              ),
            ),
            if (image != null && image.isNotEmpty) ...[
              SizedBox(height: 10.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  imageUrl: MediaUrlHelper.resolve(image),
                  width: double.infinity,
                  height: 180.h,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 180.h,
                    color: context.colors.surfaceMuted,
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 180.h,
                    color: context.colors.surfaceMuted,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: context.colors.textHint,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  UserEntity? _userFromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    final profile = map['profile'] as Map<String, dynamic>? ?? {};
    final professional = map['professional'] as Map<String, dynamic>? ?? {};
    final skills = professional['skills'] as List<dynamic>? ?? [];
    return UserEntity(
      id: map['id'] as String? ?? '',
      email: map['email'] as String? ?? '',
      fullName:
          profile['fullname'] as String? ??
          '${profile['firstName'] ?? ''} ${profile['lastName'] ?? ''}'.trim(),
      firstName: profile['firstName'] as String? ?? '',
      lastName: profile['lastName'] as String? ?? '',
      avatar: profile['avatar'] as String?,
      headline: profile['headline'] as String?,
      bio: profile['bio'] as String?,
      skills: skills.whereType<String>().toList(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isOwnProfile) =>
      AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        title: Text(
          _isEditing ? context.tr('profile.edit') : context.tr('profile'),
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (isOwnProfile)
            IconButton(
              icon: Icon(
                _isEditing ? Icons.check_circle : Icons.edit,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: _toggleEdit,
            ),
          if (isOwnProfile && !_isEditing)
            IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: context.colors.textPrimary,
              ),
              onPressed: () => Navigator.pushNamed(context, AppRouter.settings),
            ),
          SizedBox(width: 8.w),
        ],
      );

  Widget _buildHeader(
    UserEntity? user,
    String displayName,
    String displayTitle,
    String avatarUrl,
    bool isOwnProfile,
  ) => Container(
    width: double.infinity,
    color: context.colors.surface,
    padding: EdgeInsets.symmetric(vertical: 32.h),
    child: Column(
      children: [
        CircleAvatar(
          radius: 60.r,
          backgroundColor: context.colors.surfaceMuted,
          backgroundImage: avatarUrl.isNotEmpty
              ? CachedNetworkImageProvider(MediaUrlHelper.resolve(avatarUrl))
              : null,
          child: avatarUrl.isEmpty
              ? Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                  size: 48.sp,
                )
              : null,
        ),
        if (isOwnProfile) ...[
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  _isUploadingAvatar
                      ? context.tr('profile.uploading')
                      : context.tr('profile.change_photo'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTappableStat(_myPostsCount, context.tr('posts'), () {}),
              SizedBox(width: 40.w),
              _buildTappableStat(
                _myFollowersCount,
                context.tr('followers'),
                () => _openFollowList('followers'),
              ),
              SizedBox(width: 40.w),
              _buildTappableStat(
                _myFollowingCount,
                context.tr('following'),
                () => _openFollowList('following'),
              ),
            ],
          ),
        ] else ...[
          SizedBox(height: 12.h),
          OutlinedButton.icon(
            onPressed: _toggleFollow,
            style: OutlinedButton.styleFrom(
              foregroundColor: _isFollowing
                  ? context.colors.textSecondary
                  : Colors.white,
              backgroundColor: _isFollowing
                  ? context.colors.surface
                  : Theme.of(context).colorScheme.primary,
              side: BorderSide(
                color: _isFollowing
                    ? context.colors.inputBorder
                    : Theme.of(context).colorScheme.primary,
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
            ),
            icon: Icon(
              _isFollowing ? Icons.check : Icons.person_add_alt,
              size: 18.sp,
            ),
            label: Text(
              _isFollowing ? context.tr('following') : context.tr('follow'),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStat(
                (_otherUser?['postsCount'] as num?)?.toInt() ?? 0,
                context.tr('posts'),
              ),
              SizedBox(width: 40.w),
              _buildTappableStat(
                (_otherUser?['followersCount'] as num?)?.toInt() ?? 0,
                context.tr('followers'),
                () => _openFollowList('followers'),
              ),
              SizedBox(width: 40.w),
              _buildTappableStat(
                (_otherUser?['followingCount'] as num?)?.toInt() ?? 0,
                context.tr('following'),
                () => _openFollowList('following'),
              ),
            ],
          ),
        ],
        SizedBox(height: 16.h),
        if (_isEditing)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: context.tr('profile.full_name'),
                  ),
                ),
                TextField(
                  controller: _titleController,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: context.colors.textSecondary,
                  ),
                  decoration: InputDecoration(
                    hintText: context.tr('profile.professional_title'),
                  ),
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
                  color: context.colors.textPrimary,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                displayTitle,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
      ],
    ),
  ).animate().fadeIn(duration: 600.ms);

  Widget _buildAboutSection(String bio) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 24.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context.tr('profile.about')),
        SizedBox(height: 12.h),
        if (_isEditing)
          TextField(
            controller: _bioController,
            maxLines: 4,
            style: TextStyle(color: context.colors.textPrimary),
            decoration: InputDecoration(
              filled: true,
              fillColor: context.colors.surfaceMuted,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
            ),
          )
        else
          Text(
            bio,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 15.sp,
              height: 1.5,
            ),
          ),
      ],
    ),
  );

  Widget _buildSkillsSection(List<String> skills) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 24.w),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context.tr('profile.top_skills')),
        SizedBox(height: 16.h),
        if (_isEditing) ...[
          Wrap(
            spacing: 10.w,
            runSpacing: 12.h,
            children: [
              for (final skill in _editableSkills)
                InputChip(
                  label: Text(skill),
                  onDeleted: () =>
                      setState(() => _editableSkills.remove(skill)),
                  deleteIconColor: context.colors.textSecondary,
                  backgroundColor: context.colors.surface,
                  side: BorderSide(color: context.colors.inputBorder),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _skillsController,
                  onSubmitted: (_) => _addSkill(),
                  style: TextStyle(color: context.colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: context.tr('onb.skills_search'),
                    filled: true,
                    fillColor: context.colors.surfaceMuted,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              IconButton.filled(
                onPressed: _addSkill,
                icon: const Icon(Icons.add),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildSectionHeader(context.tr('profile.birth_date')),
          SizedBox(height: 10.h),
          InkWell(
            onTap: _pickBirthDate,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: context.colors.surfaceMuted,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.cake_outlined,
                    color: context.colors.textSecondary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    _birthDate.isEmpty
                        ? context.tr('profile.pick_birth_date')
                        : _birthDate,
                    style: TextStyle(
                      color: _birthDate.isEmpty
                          ? context.colors.textSecondary
                          : context.colors.textPrimary,
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          _buildSectionHeader(context.tr('profile.gender')),
          SizedBox(height: 10.h),
          InkWell(
            onTap: _pickGender,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: context.colors.surfaceMuted,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    _gender == 'male'
                        ? Icons.male
                        : _gender == 'female'
                        ? Icons.female
                        : Icons.wc_outlined,
                    color: context.colors.textSecondary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    _gender == null
                        ? context.tr('profile.pick_gender')
                        : _gender == 'male'
                        ? 'Male'
                        : 'Female',
                    style: TextStyle(
                      color: _gender == null
                          ? context.colors.textSecondary
                          : context.colors.textPrimary,
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else
          Wrap(
            spacing: 10.w,
            runSpacing: 12.h,
            children: skills
                .map((skill) => _ProfileSkillChip(label: skill))
                .toList(),
          ),
      ],
    ),
  );

  Widget _buildSectionHeader(String title) => Text(
    title,
    style: TextStyle(
      color: Theme.of(context).colorScheme.primary,
      fontSize: 18.sp,
      fontWeight: FontWeight.bold,
    ),
  );

  Widget _buildStat(int value, String label) => Column(
    children: [
      Text(
        '$value',
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 2.h),
      Text(
        label,
        style: TextStyle(color: context.colors.textSecondary, fontSize: 12.sp),
      ),
    ],
  );

  Widget _buildTappableStat(int value, String label, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          child: Column(
            children: [
              Text(
                '$value',
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                label,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      );
}

class _ProfileSkillChip extends StatelessWidget {
  final String label;
  const _ProfileSkillChip({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: context.colors.inputBorder),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: context.colors.textPrimary,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
