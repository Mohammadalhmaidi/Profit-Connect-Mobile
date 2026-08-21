import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../api_service.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../core/utils/follow_toggle.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../features/network/presentation/widgets/user_identity_row.dart';

/// قائمة المتابعين / المتابَعين للحساب المعروض (نمط إنستغرام):
/// تبديل بين القائمتين من الأعلى مع العدد، وزر متابعة/إلغاء لكل صف.
class FollowersPage extends StatefulWidget {
  final String userId;
  final String mode; // 'followers' | 'following'

  const FollowersPage({required this.userId, required this.mode, super.key});

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  late String _mode = widget.mode;
  List<Map<String, dynamic>> _followers = [];
  List<Map<String, dynamic>> _following = [];
  Set<String> _myFollowingIds = {};
  String? _myUserId;
  bool _isLoading = true;
  bool _hasError = false;

  int _followersCount = 0;
  int _followingCount = 0;

  bool get _isFollowers => _mode == 'followers';
  bool get _isSelf => _myUserId != null && _myUserId == widget.userId;

  List<Map<String, dynamic>> get _current =>
      _isFollowers ? _followers : _following;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _myUserId = await sl<ApiService>().getCurrentUserId();
    await Future.wait([_loadMyFollowing(), _load()]);
  }

  Future<void> _loadMyFollowing() async {
    try {
      final res = await sl<ApiService>().getMyFollowing();
      final list = res.data['data'] as List<dynamic>? ?? [];
      if (!mounted) return;
      setState(() {
        _myFollowingIds = list
            .map((e) => (e as Map)['_id']?.toString())
            .whereType<String>()
            .toSet();
      });
    } catch (_) {
      // تجاهل — تعتبر كل الحسابات غير متابعة
    }
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final api = sl<ApiService>();
      final res = _isFollowers
          ? await api.getUserFollowers(widget.userId)
          : await api.getUserFollowing(widget.userId);
      final data = res.data is Map ? (res.data as Map)['data'] : null;
      final list = data is List ? data : const [];
      final count =
          (res.data is Map ? (res.data as Map)['count'] : null) as num?;
      if (!mounted) return;
      setState(() {
        final users = list
            .whereType<Map>()
            .map(Map<String, dynamic>.from)
            .toList();
        if (_isFollowers) {
          _followers = users;
          if (count != null) _followersCount = count.toInt();
        } else {
          _following = users;
          if (count != null) _followingCount = count.toInt();
        }
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _switchMode(String mode) async {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _isLoading = true;
      _hasError = false;
    });
    await _load();
  }

  void _openProfile(String userId) {
    Navigator.pushNamed(context, AppRouter.profile, arguments: userId);
  }

  Future<void> _onFollowTap(Map<String, dynamic> user) async {
    final userId = user['_id']?.toString();
    if (userId == null) return;
    final isFollowing = _myFollowingIds.contains(userId);
    final profile = user['profile'] as Map<String, dynamic>? ?? {};
    final prevCount = (profile['followersCount'] as num?)?.toInt() ?? 0;
    setState(() {
      if (isFollowing) {
        _myFollowingIds.remove(userId);
      } else {
        _myFollowingIds.add(userId);
      }
      profile['followersCount'] = prevCount + (isFollowing ? -1 : 1);
      if (_isSelf && _isFollowers && !isFollowing) {
        _followersCount += 1;
      }
      if (_isSelf && !_isFollowers && isFollowing) {
        _current.removeWhere((u) => u['_id'] == userId);
        _followingCount -= 1;
      }
    });
    final result = await FollowToggle(
      sl<ApiService>(),
    ).toggle(userId: userId, isFollowing: isFollowing);
    if (result == FollowToggleResult.success) return;
    if (!mounted) return;
    setState(() {
      if (isFollowing) {
        _myFollowingIds.add(userId);
      } else {
        _myFollowingIds.remove(userId);
      }
      profile['followersCount'] = prevCount;
      if (_isSelf && _isFollowers && !isFollowing) {
        _followersCount -= 1;
      }
    });
    if (_isSelf && !_isFollowers && isFollowing) {
      _load();
    }
    if (result == FollowToggleResult.failure) {
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('network.follow_failed'),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        _isFollowers ? context.tr('followers') : context.tr('following'),
        style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
      ),
      backgroundColor: context.colors.surface,
      foregroundColor: context.colors.textPrimary,
      elevation: 0,
    ),
    body: Column(
      children: [
        _buildToggleHeader(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _hasError
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.tr('error'),
                        style: TextStyle(color: context.colors.textSecondary),
                      ),
                      SizedBox(height: 12.h),
                      FilledButton(
                        onPressed: _load,
                        child: Text(context.tr('retry')),
                      ),
                    ],
                  ),
                )
              : _current.isEmpty
              ? RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 120.h),
                      Icon(
                        Icons.people_outline,
                        size: 64.sp,
                        color: context.colors.textHint,
                      ),
                      SizedBox(height: 16.h),
                      Center(
                        child: Text(
                          _isFollowers
                              ? context.tr('followers.empty')
                              : context.tr('followers.empty_following'),
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    itemCount: _current.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 76.w,
                      color: context.colors.divider,
                    ),
                    itemBuilder: (context, index) {
                      final user = _current[index];
                      return _buildUserRow(user);
                    },
                  ),
                ),
        ),
      ],
    ),
  );

  Widget _buildToggleHeader() {
    final labels = {
      'followers': '${context.tr('followers')} ($_followersCount)',
      'following': '${context.tr('following')} ($_followingCount)',
    };
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ['followers', 'following'].map((mode) {
          final active = _mode == mode;
          return Expanded(
            child: InkWell(
              onTap: () => _switchMode(mode),
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Column(
                  children: [
                    Text(
                      labels[mode]!.split(' ').last,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      labels[mode]!.split(' ').first,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: active
                            ? Theme.of(context).colorScheme.primary
                            : context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserRow(Map<String, dynamic> user) {
    final userId = user['_id']?.toString() ?? '';
    final isFollowing = _myFollowingIds.contains(userId);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: UserIdentityRow.fromUserJson(
        user,
        onTap: () => _openProfile(userId),
        trailing: _isSelf ? null : _buildFollowButton(isFollowing, userId),
      ),
    );
  }

  Widget _buildFollowButton(bool isFollowing, String userId) => OutlinedButton(
    onPressed: () => _onFollowTap(
      _current.firstWhere((u) => u['_id']?.toString() == userId),
    ),
    style: OutlinedButton.styleFrom(
      foregroundColor: isFollowing
          ? context.colors.textSecondary
          : Theme.of(context).colorScheme.primary,
      backgroundColor: isFollowing
          ? context.colors.surfaceMuted
          : context.colors.surface,
      side: isFollowing
          ? BorderSide.none
          : BorderSide(color: Theme.of(context).colorScheme.primary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
    ),
    child: Text(
      isFollowing ? context.tr('following') : context.tr('follow'),
      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
    ),
  );
}
