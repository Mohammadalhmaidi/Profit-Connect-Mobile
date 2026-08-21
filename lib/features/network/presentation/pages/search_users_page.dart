import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../api_service.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../core/utils/follow_toggle.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/user_identity_row.dart';

/// صفحة بحث الأشخاص — اقتراحات حية مع كل حرف (ديباوس 300ms).
class SearchUsersPage extends StatefulWidget {
  const SearchUsersPage({super.key});

  @override
  State<SearchUsersPage> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  bool _hasError = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final q = value.trim();
    if (q.isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }
    if (q.length < 2) {
      setState(() => _hasSearched = false);
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMilliseconds),
      () => _search(q),
    );
  }

  Future<void> _search(String q) async {
    setState(() {
      _isSearching = true;
      _hasError = false;
    });
    try {
      final res = await sl<ApiService>().searchUsers(q);
      final list = res.data is Map ? (res.data as Map)['data'] : null;
      final results = list is List ? list : const [];
      if (!mounted || _controller.text.trim() != q) return;
      setState(() {
        _results = results
            .whereType<Map>()
            .map(Map<String, dynamic>.from)
            .toList();
        _isSearching = false;
        _hasSearched = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _hasError = true;
      });
    }
  }

  Future<void> _toggleFollow(Map<String, dynamic> user) async {
    final userId = user['_id'] as String?;
    if (userId == null) return;
    final isFollowing = user['isFollowing'] == true;
    final profile = user['profile'] as Map<String, dynamic>? ?? {};
    final prevCount = (profile['followersCount'] as num?)?.toInt() ?? 0;
    setState(() {
      user['isFollowing'] = !isFollowing;
      profile['followersCount'] = prevCount + (isFollowing ? -1 : 1);
    });
    final result = await FollowToggle(
      sl<ApiService>(),
    ).toggle(userId: userId, isFollowing: isFollowing);
    if (result == FollowToggleResult.success) return;
    if (!mounted) return;
    setState(() {
      user['isFollowing'] = isFollowing;
      profile['followersCount'] = prevCount;
    });
    if (result == FollowToggleResult.failure) {
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('network.follow_failed'),
      );
    }
  }

  void _openProfile(String userId) {
    Navigator.pushNamed(context, AppRouter.profile, arguments: userId);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.backgroundAlt,
    appBar: AppBar(
      backgroundColor: context.colors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: context.colors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        context.tr('search_people'),
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    ),
    body: Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: context.colors.inputBorder),
            ),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onChanged,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 15.sp,
              ),
              decoration: InputDecoration(
                hintText: context.tr('network.search_hint'),
                hintStyle: TextStyle(
                  color: context.colors.textHint,
                  fontSize: 14.sp,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: context.colors.textSecondary,
                  size: 22.sp,
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close,
                          color: context.colors.textHint,
                          size: 20.sp,
                        ),
                        onPressed: () {
                          _debounce?.cancel();
                          _controller.clear();
                          _onChanged('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15.h),
              ),
            ),
          ),
        ),
        Expanded(child: _buildBody()),
      ],
    ),
  );

  Widget _buildBody() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr('network.search_failed'),
              style: const TextStyle(color: Colors.red),
            ),
            SizedBox(height: 12.h),
            FilledButton(
              onPressed: () => _onChanged(_controller.text),
              child: Text(context.tr('retry')),
            ),
          ],
        ),
      );
    }
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.manage_search,
              size: 56.sp,
              color: context.colors.textHint,
            ),
            SizedBox(height: 12.h),
            Text(
              context.tr('search.type_hint'),
              style: TextStyle(
                fontSize: 14.sp,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 56.sp, color: context.colors.textHint),
            SizedBox(height: 12.h),
            Text(
              context.tr('network.no_results'),
              style: TextStyle(
                fontSize: 14.sp,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      itemCount: _results.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, indent: 76.w, color: context.colors.divider),
      itemBuilder: (context, index) {
        final user = _results[index];
        final userId = user['_id'] as String? ?? '';
        final profile = user['profile'] as Map<String, dynamic>? ?? {};
        final followers = (profile['followersCount'] as num?)?.toInt() ?? 0;
        final isFollowing = user['isFollowing'] == true;
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: UserIdentityRow.fromUserJson(
            user,
            onTap: () => _openProfile(userId),
            subtitle: Text(
              context.tr('followers_count', {'count': '$followers'}),
              style: TextStyle(fontSize: 12.sp, color: context.colors.textHint),
            ),
            trailing: isFollowing
                ? OutlinedButton(
                    onPressed: () => _toggleFollow(user),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.textSecondary,
                      side: BorderSide(color: context.colors.inputBorder),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                    child: Text(
                      context.tr('following'),
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  )
                : FilledButton(
                    onPressed: () => _toggleFollow(user),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 8.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                    child: Text(
                      context.tr('follow'),
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
