import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../api_service.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/presentation/widgets/app_empty_state.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/media_url_helper.dart';
import '../../../../l10n/app_localizations.dart';

/// شاشة لوحة المتصدرين — أفضل المستخدمين حسب نقاط السمعة من الباك.
class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  final _api = sl<ApiService>();
  late final TabController _tabController;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _managers = [];
  bool _isLoading = true;
  bool _managersFailed = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _managersFailed = false;
    });
    try {
      final res = await _api.getTopUsers(limit: 20);
      final body = res.data is Map ? Map<String, dynamic>.from(res.data) : null;
      final list = body?['data'] as List<dynamic>? ?? [];
      final users = list
          .map((json) => Map<String, dynamic>.from(json as Map))
          .toList();
      if (!mounted) return;
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = context.tr('error');
        _isLoading = false;
      });
    }

    try {
      final res = await _api.getTopManagers();
      final body = res.data is Map ? Map<String, dynamic>.from(res.data) : null;
      final list = body?['data'] as List<dynamic>? ?? [];
      final managers = list
          .map((json) => Map<String, dynamic>.from(json as Map))
          .toList();
      if (!mounted) return;
      setState(() => _managers = managers);
    } catch (_) {
      if (!mounted) return;
      setState(() => _managersFailed = true);
    }
  }

  String _userName(Map<String, dynamic> user) {
    final profile = user['profile'] as Map<String, dynamic>? ?? {};
    final fullName = profile['fullname'] as String? ?? '';
    if (fullName.isNotEmpty) return fullName;
    final first = profile['firstName'] as String? ?? '';
    final last = profile['lastName'] as String? ?? '';
    return '$first $last'.trim().isNotEmpty
        ? '$first $last'.trim()
        : (user['username'] as String? ?? '?');
  }

  double _rScore(Map<String, dynamic> user) {
    final profile = user['profile'] as Map<String, dynamic>? ?? {};
    return (profile['rScore'] as num?)?.toDouble() ?? 0;
  }

  String? _avatarUrl(Map<String, dynamic> user) {
    final profile = user['profile'] as Map<String, dynamic>? ?? {};
    final raw = profile['avatar'] as String?;
    return raw == null || raw.isEmpty ? null : MediaUrlHelper.resolve(raw);
  }

  String? _industry(Map<String, dynamic> user) {
    final professional = user['professional'] as Map<String, dynamic>?;
    return professional?['industry'] as String?;
  }

  String _managerName(Map<String, dynamic> entry) {
    final manager = entry['manager'] as Map<String, dynamic>? ?? {};
    final profile = manager['profile'] as Map<String, dynamic>? ?? {};
    final fullName = profile['fullname'] as String? ?? '';
    if (fullName.isNotEmpty) return fullName;
    final first = profile['firstName'] as String? ?? '';
    final last = profile['lastName'] as String? ?? '';
    return '$first $last'.trim().isNotEmpty
        ? '$first $last'.trim()
        : (manager['username'] as String? ?? '?');
  }

  String? _managerAvatarUrl(Map<String, dynamic> entry) {
    final manager = entry['manager'] as Map<String, dynamic>? ?? {};
    final profile = manager['profile'] as Map<String, dynamic>? ?? {};
    final raw = profile['avatar'] as String?;
    return raw == null || raw.isEmpty ? null : MediaUrlHelper.resolve(raw);
  }

  String? _managerId(Map<String, dynamic> entry) {
    final manager = entry['manager'] as Map<String, dynamic>?;
    return manager?['_id'] as String?;
  }

  int _companiesCount(Map<String, dynamic> entry) =>
      (entry['companiesCount'] as num?)?.toInt() ?? 0;

  double _averageRating(Map<String, dynamic> entry) =>
      (entry['averageCompanyRating'] as num?)?.toDouble() ?? 0;

  int _totalFollowers(Map<String, dynamic> entry) =>
      (entry['totalFollowers'] as num?)?.toInt() ?? 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.tr('leaderboard_title')),
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      bottom: _isLoading || _error != null
          ? null
          : TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: context.tr('leaderboard_top_users')),
                Tab(text: context.tr('leaderboard_top_managers')),
              ],
            ),
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
        : TabBarView(
            controller: _tabController,
            children: [
              if (_users.isEmpty)
                AppEmptyState(
                  icon: Icons.emoji_events_outlined,
                  title: context.tr('leaderboard_empty'),
                )
              else
                RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    itemCount: _users.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return _buildUserTile(index, user);
                    },
                  ),
                ),
              _buildManagersList(),
            ],
          ),
  );

  Widget _buildManagersList() {
    if (_managersFailed) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr('leaderboard_managers_unavailable'),
              style: const TextStyle(color: Colors.red),
            ),
            SizedBox(height: 12.h),
            FilledButton(onPressed: _load, child: Text(context.tr('retry'))),
          ],
        ),
      );
    }
    if (_managers.isEmpty) {
      return AppEmptyState(
        icon: Icons.emoji_events_outlined,
        title: context.tr('leaderboard_empty'),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        itemCount: _managers.length,
        separatorBuilder: (_, __) => SizedBox(height: 8.h),
        itemBuilder: (context, index) {
          final entry = _managers[index];
          return _buildManagerTile(index, entry);
        },
      ),
    );
  }

  Widget _buildManagerTile(int rank, Map<String, dynamic> entry) {
    final avatar = _managerAvatarUrl(entry);
    final name = _managerName(entry);
    final companiesCount = _companiesCount(entry);
    final rating = _averageRating(entry);
    final followers = _totalFollowers(entry);
    return InkWell(
      onTap: () {
        final id = _managerId(entry);
        if (id != null) {
          Navigator.pushNamed(context, AppRouter.profile, arguments: id);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: rank < 3
              ? context.colors.chipUnselected
              : context.colors.surface,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            _buildRankBadge(rank),
            SizedBox(width: 16.w),
            ClipOval(
              child: avatar != null
                  ? CachedNetworkImage(
                      imageUrl: avatar,
                      width: 48.w,
                      height: 48.w,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          const _DefaultAvatar(radius: 24),
                      placeholder: (_, __) => const _DefaultAvatar(radius: 24),
                    )
                  : const _DefaultAvatar(radius: 24),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    context.tr('leaderboard_manager_companies', {
                      'count': '$companiesCount',
                    }),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  rating.toStringAsFixed(1),
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$followers ${context.tr('leaderboard_followers')}',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTile(int rank, Map<String, dynamic> user) {
    final isPodium = rank < 3;
    final avatar = _avatarUrl(user);
    final score = _rScore(user);
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        AppRouter.profile,
        arguments: user['_id'] as String?,
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isPodium
              ? context.colors.chipUnselected
              : context.colors.surface,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            _buildRankBadge(rank),
            SizedBox(width: 16.w),
            ClipOval(
              child: avatar != null
                  ? CachedNetworkImage(
                      imageUrl: avatar,
                      width: 48.w,
                      height: 48.w,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          const _DefaultAvatar(radius: 24),
                      placeholder: (_, __) => const _DefaultAvatar(radius: 24),
                    )
                  : const _DefaultAvatar(radius: 24),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userName(user),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_industry(user) != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      _industry(user)!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                isPodium
                    ? '${score.toStringAsFixed(0)} ${context.tr('leaderboard_points')}'
                    : score.toStringAsFixed(0),
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    if (rank == 0) {
      return const Icon(Icons.emoji_events, color: Color(0xFFFFC107), size: 32);
    }
    if (rank == 1) {
      return const Icon(Icons.emoji_events, color: Color(0xFFB0BEC5), size: 30);
    }
    if (rank == 2) {
      return const Icon(Icons.emoji_events, color: Color(0xFFCD7F32), size: 28);
    }
    return Text(
      '${rank + 1}',
      style: TextStyle(
        color: context.colors.textSecondary,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: radius * 2,
    height: radius * 2,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      gradient: AppColors.backgroundGradient,
    ),
    child: const Icon(Icons.person, color: Colors.white),
  );
}
