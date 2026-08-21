import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../core/utils/follow_toggle.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/presentation/widgets/stagger_entrance.dart';
import '../../../../core/presentation/widgets/shimmer.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../api_service.dart';
import '../widgets/connection_request_card.dart';
import '../widgets/connection_grid_card.dart';
import '../widgets/user_identity_row.dart';

class NetworkPage extends StatefulWidget {
  const NetworkPage({super.key});

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingRequests = false;
  bool _isLoadingConnections = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _connections = [];
  List<Map<String, dynamic>> _suggested = [];
  List<Map<String, dynamic>> _searchResults = [];
  String? _searchError;
  bool _isLoadingSuggested = true;
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingRequests = true;
      _isLoadingConnections = true;
      _isLoadingSuggested = true;
    });
    await Future.wait([
      _loadRequests(showLoader: false),
      _loadConnections(showLoader: false),
      _loadSuggested(showLoader: false),
    ]);
  }

  Future<void> _loadRequests({bool showLoader = true}) async {
    if (showLoader) setState(() => _isLoadingRequests = true);
    try {
      final res = await sl<ApiService>().getNetworkRequests();
      final list = res.data['data'] as List<dynamic>? ?? [];
      if (!mounted) return;
      setState(() {
        _requests = list
            .whereType<Map>()
            .map(Map<String, dynamic>.from)
            .toList();
        _isLoadingRequests = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingRequests = false);
    }
  }

  Future<void> _loadConnections({bool showLoader = true}) async {
    if (showLoader) setState(() => _isLoadingConnections = true);
    try {
      final res = await sl<ApiService>().getMyConnectionsList();
      final list = res.data['data'] as List<dynamic>? ?? [];
      if (!mounted) return;
      setState(() {
        _connections = list
            .whereType<Map>()
            .map(Map<String, dynamic>.from)
            .toList();
        _isLoadingConnections = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingConnections = false);
    }
  }

  Future<void> _loadSuggested({bool showLoader = true}) async {
    if (showLoader) setState(() => _isLoadingSuggested = true);
    try {
      final res = await sl<ApiService>().getDiscoverUsers();
      final list = res.data['data'] as List<dynamic>? ?? [];
      if (!mounted) return;
      setState(() {
        _suggested = list
            .whereType<Map>()
            .map(Map<String, dynamic>.from)
            .toList();
        _isLoadingSuggested = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingSuggested = false);
    }
  }

  void _search(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMilliseconds),
      () => _performSearch(query),
    );
  }

  Future<void> _performSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() {
      _isSearching = true;
      _searchError = null;
    });
    try {
      final res = await sl<ApiService>().searchUsers(q);
      final list = res.data['data'] as List<dynamic>? ?? [];
      if (!mounted) return;
      setState(() {
        _searchResults = list
            .whereType<Map>()
            .map(Map<String, dynamic>.from)
            .toList();
        _isSearching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _searchError = context.tr('network.search_failed');
      });
    }
  }

  Future<void> _onAccept(String requestId) async {
    try {
      await sl<ApiService>().acceptConnectionRequest(requestId);
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('network.request_accepted'),
        isError: false,
      );
      setState(() {
        _requests.removeWhere((r) => r['_id'] == requestId);
      });
    } catch (_) {
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('network.accept_failed'),
      );
    }
  }

  Future<void> _onIgnore(String requestId) async {
    try {
      await sl<ApiService>().rejectConnectionRequest(requestId);
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('network.request_ignored'),
        isError: false,
      );
      setState(() {
        _requests.removeWhere((r) => r['_id'] == requestId);
      });
    } catch (_) {
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('network.ignore_failed'),
      );
    }
  }

  Future<void> _onConnect(Map<String, dynamic> user) async {
    final userId = user['_id'] as String?;
    if (userId == null) return;
    try {
      await sl<ApiService>().sendConnectionRequest(userId);
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('network.request_sent'),
        isError: false,
      );
      setState(() {
        user['connectionStatus'] = 'pending';
      });
    } catch (_) {
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('network.send_failed'),
      );
    }
  }

  void _openProfile(Map<String, dynamic> user) {
    final id = user['_id'] as String?;
    if (id == null) return;
    Navigator.pushNamed(context, AppRouter.profile, arguments: id);
  }

  String _fullName(Map<String, dynamic> user) {
    final profile = user['profile'] as Map<String, dynamic>? ?? {};
    final fullname = profile['fullname'] as String?;
    if (fullname != null && fullname.isNotEmpty) return fullname;
    return '${profile['firstName'] ?? ''} ${profile['lastName'] ?? ''}'.trim();
  }

  String _headline(Map<String, dynamic> user) {
    final profile = user['profile'] as Map<String, dynamic>? ?? {};
    return profile['headline'] as String? ?? context.tr('network.member');
  }

  String _avatarUrl(Map<String, dynamic> user) {
    final profile = user['profile'] as Map<String, dynamic>? ?? {};
    return profile['avatar'] as String? ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.backgroundAlt,
    appBar: AppBar(
      backgroundColor: context.colors.surface,
      elevation: 0,
      title: _isSearchActive
          ? TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _search,
              style: TextStyle(color: context.colors.textPrimary),
              decoration: InputDecoration(
                hintText: context.tr('network.search_hint'),
                hintStyle: TextStyle(
                  color: context.colors.textHint,
                  fontSize: 14.sp,
                ),
                border: InputBorder.none,
              ),
            )
          : Text(
              context.tr('network.my_network'),
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
      actions: [
        IconButton(
          icon: Icon(
            _isSearchActive ? Icons.close : Icons.search,
            color: context.colors.textPrimary,
          ),
          onPressed: () => setState(() {
            _searchDebounce?.cancel();
            _isSearchActive = !_isSearchActive;
            if (!_isSearchActive) {
              _searchController.clear();
              _searchResults = [];
            }
          }),
        ),
      ],
    ),
    body: _isSearchActive ? _buildSearchResults() : _buildTabs(),
  );

  Widget _buildTabs() => DefaultTabController(
    length: 2,
    child: Column(
      children: [
        ColoredBox(
          color: context.colors.surface,
          child: TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: context.colors.textSecondary,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            tabs: [
              Tab(
                text: context.tr('network.requests_count', {
                  'count': '${_requests.length}',
                }),
              ),
              Tab(text: context.tr('network.connections_label')),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            children: [_buildRequestsTab(), _buildConnectionsTab()],
          ),
        ),
      ],
    ),
  );

  Widget _buildRequestsTab() {
    if (_isLoadingRequests) {
      return const ListSkeleton(itemCount: 5);
    }
    if (_requests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.notifications_active_outlined,
        title: context.tr('network.no_requests_title'),
        subtitle: context.tr('network.no_requests_subtitle'),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final request = _requests[index];
        final requester = request['requester'] as Map<String, dynamic>? ?? {};
        return ConnectionRequestCard(
          name: _fullName(requester),
          role: _headline(requester),
          mutualConnections: context.tr('network.new_request'),
          imageUrl: _avatarUrl(requester),
          onAccept: () => _onAccept(request['_id'] as String? ?? ''),
          onIgnore: () => _onIgnore(request['_id'] as String? ?? ''),
        );
      },
    );
  }

  Widget _buildConnectionsTab() {
    // الباك يعيد connectionStatus لكل مقترح — نعتمد عليه وحده
    // (لا حاجة للتقاطع مع قائمة الاتصالات كما كان سابقًا)
    final suggested = _suggested.where((u) {
      final cs = u['connectionStatus'] as String?;
      return cs != 'accepted' && cs != 'pending';
    }).toList();
    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _sectionHeader(context.tr('network.suggestions')),
          ),
          if (_isLoadingSuggested)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (suggested.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                child: Text(
                  context.tr('network.suggestions_empty'),
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildSuggestedRow(suggested[index]),
                childCount: suggested.length,
              ),
            ),
          SliverToBoxAdapter(
            child: _sectionHeader(
              '${context.tr('network.connections_label')} (${_connections.length})',
            ),
          ),
          if (_isLoadingConnections)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (_connections.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                child: Text(
                  context.tr('network.empty_subtitle'),
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.w,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final user = _connections[index];
                  return StaggerEntrance(
                    key: ValueKey('conn-$index-${user['_id']}'),
                    index: index,
                    child: GestureDetector(
                      onTap: () => _openProfile(user),
                      child: ConnectionGridCard(
                        name: _fullName(user),
                        role: _headline(user),
                        imageUrl: _avatarUrl(user),
                      ),
                    ),
                  );
                }, childCount: _connections.length),
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
    child: Text(
      title,
      style: TextStyle(
        color: context.colors.textPrimary,
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _buildSuggestedRow(Map<String, dynamic> user) {
    final isFollowing = user['isFollowing'] == true;
    return InkWell(
      onTap: () => _openProfile(user),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: context.colors.inputBorder),
        ),
        child: UserIdentityRow.fromUserJson(
          user,
          headlineFallback: context.tr('network.member'),
          trailing: FilledButton.icon(
            onPressed: () => _onFollow(user),
            style: FilledButton.styleFrom(
              backgroundColor: isFollowing
                  ? context.colors.surfaceMuted
                  : Theme.of(context).colorScheme.primary,
              foregroundColor: isFollowing
                  ? context.colors.textSecondary
                  : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            ),
            icon: Icon(
              isFollowing ? Icons.check : Icons.person_add_alt,
              size: 16.sp,
            ),
            label: Text(
              isFollowing ? context.tr('following') : context.tr('follow'),
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_searchError != null) {
      return _buildEmptyState(
        icon: Icons.error_outline,
        title: context.tr('network.search_failed_title'),
        subtitle: _searchError!,
      );
    }
    if (_searchResults.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off,
        title: context.tr('network.no_results_msg'),
        subtitle: context.tr('network.no_results_subtitle'),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        final status = user['connectionStatus'] as String? ?? 'none';
        final isFollowing = user['isFollowing'] == true;
        return StaggerEntrance(
          key: ValueKey('sr-$index'),
          index: index,
          child: _buildSearchResultCard(user, status, isFollowing),
        );
      },
    );
  }

  Future<void> _onFollow(Map<String, dynamic> user) async {
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

  String _followersCount(Map<String, dynamic> user) {
    final profile = user['profile'] as Map<String, dynamic>? ?? {};
    final count = (profile['followersCount'] as num?)?.toInt() ?? 0;
    return context.tr('followers_count', {'count': '$count'});
  }

  Widget _buildSearchResultCard(
    Map<String, dynamic> user,
    String status,
    bool isFollowing,
  ) {
    final connected = status == 'accepted';
    final pending = status == 'pending';
    return InkWell(
      onTap: () => _openProfile(user),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: context.colors.inputBorder),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28.r,
              backgroundColor: context.colors.surfaceMuted,
              backgroundImage: _avatarUrl(user).isNotEmpty
                  ? NetworkImage(_avatarUrl(user))
                  : null,
              child: _avatarUrl(user).isEmpty
                  ? const Icon(Icons.person, color: AppColors.primaryDark)
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fullName(user),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _headline(user),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _followersCount(user),
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isFollowing && !connected)
                    Text(
                      context.tr('following'),
                      style: TextStyle(
                        color: AppColors.accentCyan,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (connected)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.successGreen,
                    size: 22.sp,
                  )
                else if (pending)
                  Text(
                    context.tr('pending'),
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  OutlinedButton(
                    onPressed: () => _onConnect(user),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                    ),
                    child: Text(
                      context.tr('connect'),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                SizedBox(height: 8.h),
                if (!connected && !pending)
                  FilledButton.icon(
                    onPressed: () => _onFollow(user),
                    style: FilledButton.styleFrom(
                      backgroundColor: isFollowing
                          ? context.colors.surfaceMuted
                          : Theme.of(context).colorScheme.primary,
                      foregroundColor: isFollowing
                          ? context.colors.textSecondary
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                    ),
                    icon: Icon(
                      isFollowing ? Icons.check : Icons.person_add_alt,
                      size: 16.sp,
                    ),
                    label: Text(
                      isFollowing
                          ? context.tr('following')
                          : context.tr('follow'),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) => Center(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 90.sp, color: context.colors.textHint),
          SizedBox(height: 24.h),
          Text(
            title,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Text(
            subtitle,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 14.sp,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
