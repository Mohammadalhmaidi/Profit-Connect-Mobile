import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../core/utils/media_url_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../api_service.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CompanyProfilePage extends StatefulWidget {
  final String companyId;

  const CompanyProfilePage({required this.companyId, super.key});
  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  bool _isLoading = true;
  bool _isFollowing = false;
  Map<String, dynamic>? _company;
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _followers = [];
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
      final api = sl<ApiService>();
      final res = await api.getCompanyById(widget.companyId);
      final data = res.data['data'] as Map<String, dynamic>?;
      final followersRes = await api.getCompanyFollowers(widget.companyId);
      var followers = <Map<String, dynamic>>[];
      try {
        followers = (followersRes.data['data'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } catch (_) {}
      Map<String, dynamic>? stats;
      try {
        final statsRes = await api.getCompanyStats(widget.companyId);
        stats = statsRes.data['data'] as Map<String, dynamic>?;
      } catch (_) {
        // 403 for non-members - stats stay hidden
      }
      if (!mounted) return;
      setState(() {
        _company = data;
        _followers = followers;
        _stats = stats;
        _isFollowing = _viewerIsFollowing(data);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = context.tr('company.load_failed');
      });
    }
  }

  bool _viewerIsFollowing(Map<String, dynamic>? data) {
    if (data == null) return false;
    final me = _currentUser();
    if (me == null) return false;
    final followersList = data['followers'] as List<dynamic>? ?? [];
    return followersList.any((f) {
      final user = (f is Map && f['user'] is Map)
          ? (f['user'] as Map)['_id']
          : (f is Map ? f['_id'] : null);
      return user?.toString() == me.id;
    });
  }

  UserEntity? _currentUser() {
    final state = context.read<AuthBloc>().state;
    return state is AuthSuccess ? state.user : null;
  }

  bool get _isOwner =>
      _company != null &&
      _currentUser() != null &&
      _company!['owner']?['_id']?.toString() == _currentUser()!.id;

  Future<void> _toggleFollow() async {
    final previous = _isFollowing;
    final previousCount = _company?['followersCount'] as num? ?? 0;
    setState(() {
      _isFollowing = !_isFollowing;
      _company?['followersCount'] = previousCount + (_isFollowing ? 1 : -1);
    });
    try {
      final res = await sl<ApiService>().toggleFollowCompany(widget.companyId);
      if (!mounted) return;
      setState(() {
        _isFollowing = res.data['isFollowing'] == true;
        _company?['followersCount'] =
            (res.data['followersCount'] as num?) ?? previousCount;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isFollowing = previous;
        _company?['followersCount'] = previousCount;
      });
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('company.follow_failed'),
      );
    }
  }

  Future<void> _addAdmin() async {
    final userIdController = TextEditingController();
    final userId = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('company.add_admin')),
        content: TextField(
          controller: userIdController,
          decoration: InputDecoration(
            hintText: context.tr('company.admin_id_hint'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('cancel')),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, userIdController.text.trim()),
            child: Text(context.tr('common.add')),
          ),
        ],
      ),
    );
    if (userId == null || userId.isEmpty) return;
    try {
      await sl<ApiService>().addCompanyAdmin(widget.companyId, userId);
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('company.admin_added'),
        isError: false,
      );
    } catch (_) {
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('company.admin_add_failed'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final company = _company;
    return Scaffold(
      backgroundColor: context.colors.backgroundAlt,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          company?['name'] ?? context.tr('company.title'),
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : _buildBody(company),
    );
  }

  Widget _buildError() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.business_outlined,
          size: 80.sp,
          color: context.colors.textHint,
        ),
        SizedBox(height: 16.h),
        Text(
          _error ?? context.tr('error'),
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 15.sp,
          ),
        ),
        SizedBox(height: 16.h),
        OutlinedButton(onPressed: _load, child: Text(context.tr('retry'))),
      ],
    ),
  );

  Widget _buildBody(Map<String, dynamic>? company) {
    if (company == null) {
      return const SizedBox.shrink();
    }
    final profile = company['profile'] as Map<String, dynamic>? ?? {};
    final logo = MediaUrlHelper.resolve(
      (company['logo'] as String?) ?? (profile['logo'] as String?) ?? '',
    );
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCompanyHeader(company, logo),
          SizedBox(height: 16.h),
          if (_isOwner)
            OutlinedButton.icon(
              onPressed: _addAdmin,
              icon: const Icon(Icons.admin_panel_settings_outlined),
              label: Text(context.tr('company.add_admin')),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          if (_stats != null) ...[
            SizedBox(height: 16.h),
            _buildStatsCard(company),
          ],
          if (_followers.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildFollowersSection(company),
          ],
          if ((company['recentJobs'] as List<dynamic>?)?.isNotEmpty ??
              false) ...[
            SizedBox(height: 16.h),
            _buildRecentJobs(company['recentJobs'] as List<dynamic>),
          ],
        ],
      ),
    );
  }

  Widget _buildCompanyHeader(Map<String, dynamic> company, String logo) =>
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40.r,
              backgroundColor: context.colors.chipUnselected,
              backgroundImage: logo.isNotEmpty ? NetworkImage(logo) : null,
              child: logo.isEmpty
                  ? Icon(
                      Icons.business,
                      color: Theme.of(context).colorScheme.primary,
                      size: 36.sp,
                    )
                  : null,
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    company['name'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (company['isVerified'] == true) ...[
                  SizedBox(width: 6.w),
                  Icon(
                    Icons.verified,
                    color: AppColors.accentCyan,
                    size: 18.sp,
                  ),
                ],
              ],
            ),
            if ((company['industry'] as String?)?.isNotEmpty ?? false) ...[
              SizedBox(height: 6.h),
              Text(
                company['industry'] as String,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
            ],
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  color: context.colors.textHint,
                  size: 16.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  context.tr('company.followers_count', {
                    'count': '${company['followersCount'] ?? 0}',
                  }),
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13.sp,
                  ),
                ),
                if ((company['averageRating'] ?? 0) > 0) ...[
                  SizedBox(width: 16.w),
                  Icon(Icons.star, color: Colors.amber, size: 16.sp),
                  SizedBox(width: 4.w),
                  Text(
                    (company['averageRating'] as num).toStringAsFixed(1),
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 16.h),
            OutlinedButton.icon(
              onPressed: _toggleFollow,
              style: OutlinedButton.styleFrom(
                foregroundColor: _isFollowing
                    ? context.colors.textSecondary
                    : context.colors.textOnPrimary,
                backgroundColor: _isFollowing
                    ? context.colors.surface
                    : Theme.of(context).colorScheme.primary,
                side: BorderSide(
                  color: _isFollowing
                      ? context.colors.inputBorder
                      : Theme.of(context).colorScheme.primary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              ),
              icon: Icon(_isFollowing ? Icons.check : Icons.add, size: 18.sp),
              label: Text(
                _isFollowing ? context.tr('following') : context.tr('follow'),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
            if ((company['description'] as String?)?.isNotEmpty ?? false) ...[
              SizedBox(height: 16.h),
              Text(
                company['description'] as String,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 14.sp,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );

  Widget _buildStatsCard(Map<String, dynamic> company) {
    final jobs = _stats?['jobs'] as Map<String, dynamic>? ?? {};
    final ratings = _stats?['ratings'] as Map<String, dynamic>? ?? {};
    final followers = _stats?['followers'] as Map<String, dynamic>? ?? {};
    final applicants = _stats?['applicants'] as Map<String, dynamic>? ?? {};
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('company.overview'),
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                '${jobs['total'] ?? 0}',
                context.tr('company.total_jobs'),
              ),
              _buildStatItem(
                '${jobs['open'] ?? 0}',
                context.tr('company.stat_open'),
              ),
              _buildStatItem(
                '${applicants['total'] ?? 0}',
                context.tr('company.stat_applicants'),
              ),
              _buildStatItem(
                '${followers['total'] ?? 0}',
                context.tr('company.stat_followers'),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                (ratings['averageRating'] ?? 0).toStringAsFixed(1),
                context.tr('company.stat_rating'),
              ),
              _buildStatItem(
                '${followers['today'] ?? 0}',
                context.tr('company.stat_today'),
              ),
              _buildStatItem(
                '${followers['thisWeek'] ?? 0}',
                context.tr('company.stat_week'),
              ),
              _buildStatItem(
                '${followers['monthlyGrowthRate'] ?? 0}%',
                context.tr('company.stat_growth'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) => Column(
    children: [
      Text(
        value,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 4.h),
      Text(
        label,
        style: TextStyle(color: context.colors.textSecondary, fontSize: 12.sp),
      ),
    ],
  );

  Widget _buildFollowersSection(Map<String, dynamic> company) {
    final people = _followers
        .map(
          (f) => f['user'] is Map
              ? Map<String, dynamic>.from(f['user'] as Map)
              : null,
        )
        .whereType<Map<String, dynamic>>()
        .toList();
    if (people.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('company.followers_title', {
              'count': '${people.length}',
            }),
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 100.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: people.length,
              separatorBuilder: (_, __) => SizedBox(width: 16.w),
              itemBuilder: (context, index) {
                final person = people[index];
                final profile =
                    person['profile'] as Map<String, dynamic>? ?? {};
                final name =
                    '${profile['firstName'] ?? ''} ${profile['lastName'] ?? ''}'
                        .trim();
                final avatar = MediaUrlHelper.resolve(
                  profile['avatar'] as String? ?? '',
                );
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/profile',
                    arguments: person['_id']?.toString(),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 30.r,
                        backgroundColor: context.colors.chipUnselected,
                        backgroundImage: avatar.isNotEmpty
                            ? NetworkImage(avatar)
                            : null,
                        child: avatar.isEmpty
                            ? const Icon(
                                Icons.person,
                                color: AppColors.primaryDark,
                              )
                            : null,
                      ),
                      SizedBox(height: 6.h),
                      SizedBox(
                        width: 70.w,
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentJobs(List<dynamic> jobs) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(20.w),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(16.r),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('company.recent_jobs'),
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        ...jobs.map((job) {
          final j = job as Map;
          final salary = j['salary'] as Map?;
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        j['title']?.toString() ?? '',
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${j['type'] ?? ''} \u2022 ${j['workPlace'] ?? ''}',
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                if (salary != null)
                  Text(
                    '${salary['min'] ?? ''}-${salary['max'] ?? ''}',
                    style: TextStyle(
                      color: AppColors.accentCyan,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    ),
  );
}
