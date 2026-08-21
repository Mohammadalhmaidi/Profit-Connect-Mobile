import '../../../../core/utils/time_formatter.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/presentation/widgets/stagger_entrance.dart';
import '../../../../core/presentation/widgets/shimmer.dart';
import '../../../../core/utils/media_url_helper.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../api_service.dart';
import '../widgets/message_list_tile.dart';

class ConversationSummary {
  final String id;
  final String peerId;
  final String peerName;
  final String peerAvatar;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final bool isUnread;

  ConversationSummary({
    required this.id,
    required this.peerId,
    required this.peerName,
    required this.peerAvatar,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.isUnread,
  });
}

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  String _searchQuery = '';
  bool _loading = true;
  bool _searching = false;
  String? _error;
  String _currentUserId = '';
  List<ConversationSummary> _conversations = [];
  List<ConversationSummary> _allConversations = [];
  List<Map<String, dynamic>> _peopleResults = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  List<ConversationSummary> _parseConversations(List<dynamic> rawList) =>
      rawList.whereType<Map>().map((json) {
        final convo = Map<String, dynamic>.from(json);
        final participants = (convo['participants'] as List<dynamic>? ?? [])
            .whereType<Map>()
            .map(Map<String, dynamic>.from)
            .toList();
        final peer = participants.firstWhere(
          (p) => (p['_id'] ?? p['id']).toString() != _currentUserId,
          orElse: () => participants.isNotEmpty
              ? participants.first
              : const <String, dynamic>{},
        );
        final profile = peer['profile'] as Map<String, dynamic>?;
        final peerName = [
          profile?['firstName'],
          profile?['lastName'],
        ].whereType<String>().where((s) => s.isNotEmpty).join(' ');
        final peerAvatar = MediaUrlHelper.resolve(
          profile?['avatar'] as String?,
        );
        final lastMessage = convo['lastMessage'] as Map<String, dynamic>?;
        final lastMessageAtRaw =
            lastMessage?['createdAt'] ?? convo['lastMessageAt'];
        DateTime? lastMessageAt;
        if (lastMessageAtRaw is String) {
          lastMessageAt = DateTime.tryParse(lastMessageAtRaw);
        }
        return ConversationSummary(
          id: (convo['_id'] ?? convo['id']).toString(),
          peerId: (peer['_id'] ?? peer['id']).toString(),
          peerName: peerName.isNotEmpty
              ? peerName
              : (peer['name'] as String? ?? context.tr('messages.unknown')),
          peerAvatar: peerAvatar,
          lastMessage: lastMessage?['content'] as String? ?? '',
          lastMessageAt: lastMessageAt,
          isUnread: false,
        );
      }).toList();

  Future<void> _loadConversations() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _currentUserId = (await sl<ApiService>().getCurrentUserId()) ?? '';
      final response = await sl<ApiService>().getConversations();
      final data = response.data;
      final map = data is Map
          ? Map<String, dynamic>.from(data)
          : const <String, dynamic>{};
      final rawList = (map['data'] as List<dynamic>?) ?? [];
      final parsed = _parseConversations(rawList);
      setState(() {
        _conversations = parsed;
        _allConversations = parsed;
      });
    } catch (e) {
      setState(() => _error = context.tr('messages.load_failed'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _searching = false;
    });
    _debounce?.cancel();
    final q = value.trim();
    if (q.isEmpty) {
      setState(() {
        _conversations = List.of(_allConversations);
        _peopleResults = [];
      });
      return;
    }
    if (q.length < 2) return;
    _debounce = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMilliseconds),
      () => _searchServer(q),
    );
  }

  Future<void> _searchServer(String q) async {
    setState(() => _searching = true);
    try {
      final results = await Future.wait([
        sl<ApiService>().getConversations(q: q),
        sl<ApiService>().searchUsers(q, limit: 10),
      ]);
      if (!mounted || _searchQuery.trim() != q) return;
      final convoData = results[0].data is Map
          ? Map<String, dynamic>.from(results[0].data as Map)
          : const <String, dynamic>{};
      final parsed = _parseConversations(
        (convoData['data'] as List<dynamic>?) ?? [],
      );
      final peopleData = results[1].data is Map
          ? Map<String, dynamic>.from(results[1].data as Map)
          : const <String, dynamic>{};
      final people = ((peopleData['data'] as List<dynamic>?) ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      setState(() {
        _conversations = parsed;
        _peopleResults = people;
        _searching = false;
      });
    } catch (_) {
      if (!mounted || _searchQuery.trim() != q) return;
      // الإبقاء على النتائج المحلية عند فشل البحث
      setState(() => _searching = false);
    }
  }

  // نتائج الخادم جاهزة فعلًا (بدون إعادة فلترة بالاسم حتى لا تُحذف
  // المحادثات المطابقة بمحتواها فقط)
  List<ConversationSummary> get _filtered => _conversations;

  Future<void> _startChat(String userId, String name, String avatar) async {
    try {
      final res = await sl<ApiService>().getOrCreateConversation(userId);
      final data = res.data is Map
          ? Map<String, dynamic>.from(res.data as Map)['data']
                as Map<String, dynamic>?
          : null;
      final convId = (data?['_id'] ?? data?['id'] ?? '').toString();
      if (convId.isEmpty) throw Exception('no conversation');
      if (!mounted) return;
      await Navigator.pushNamed(
        context,
        AppRouter.chat,
        arguments: {'conversationId': convId, 'name': name, 'avatar': avatar},
      );
      if (!mounted) return;
      _onSearchChanged('');
      _loadConversations();
    } catch (_) {
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('network.send_failed'),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.background,
    appBar: AppBar(
      backgroundColor: context.colors.background,
      elevation: 0,
      leadingWidth: 64.w,
      leading: Padding(
        padding: EdgeInsetsDirectional.only(start: 16.w),
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRouter.profile),
          child: CircleAvatar(
            radius: 20.r,
            backgroundColor: context.colors.surfaceMuted,
            child: Icon(
              Icons.person,
              color: context.colors.textPrimary,
              size: 24.sp,
            ),
          ),
        ),
      ),
      title: Text(
        context.tr('messages'),
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.settings,
            color: context.colors.textPrimary,
            size: 28.sp,
          ),
          onPressed: () => Navigator.pushNamed(context, AppRouter.settings),
        ),
        SizedBox(width: 8.w),
      ],
    ),
    body: Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: context.colors.inputBorder),
            ),
            child: TextField(
              onChanged: _onSearchChanged,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 15.sp,
              ),
              decoration: InputDecoration(
                hintText: context.tr('messages.search_hint'),
                hintStyle: TextStyle(
                  color: context.colors.textHint,
                  fontSize: 14.sp,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: context.colors.textSecondary,
                  size: 22.sp,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close,
                          color: context.colors.textHint,
                          size: 20.sp,
                        ),
                        onPressed: () {
                          _debounce?.cancel();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15.h),
              ),
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? const ListSkeleton(itemCount: 8)
              : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 14.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : _buildResults(),
        ),
        if (_filtered.isNotEmpty) ...[
          SizedBox(height: 8.h),
          TextButton(
            onPressed: () => UIUtils.showSnackBar(
              context: context,
              message: context.tr('messages.compose_soon'),
              isError: false,
            ),
            child: Text(
              context.tr('messages.new_message'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    ),
  );

  Widget _buildResults() {
    final q = _searchQuery.trim();
    if (q.isEmpty || q.length < 2) {
      return _buildConversationList();
    }
    return _buildSearchResults(q);
  }

  Widget _buildConversationList() {
    if (_filtered.isEmpty) {
      return Center(
        child: Text(
          context.tr('messages.no_conversations'),
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 14.sp,
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: ListView.builder(
        itemCount: _filtered.length,
        itemBuilder: (context, index) {
          final convo = _filtered[index];
          return StaggerEntrance(
            key: ValueKey('convo-${convo.id}'),
            index: index,
            child: MessageListTile(
              name: convo.peerName,
              message: convo.lastMessage,
              time: _formatTime(context, convo.lastMessageAt),
              imageUrl: convo.peerAvatar,
              isUnread: convo.isUnread,
              onTap: () => Navigator.pushNamed(
                context,
                AppRouter.chat,
                arguments: {
                  'conversationId': convo.id,
                  'name': convo.peerName,
                  'avatar': convo.peerAvatar,
                },
              ),
              onProfileTap: () => Navigator.pushNamed(
                context,
                AppRouter.profile,
                arguments: convo.peerId,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(String q) {
    final people = _peopleResults;
    final convos = _filtered;
    if (people.isEmpty && convos.isEmpty && !_searching) {
      return Center(
        child: Text(
          context.tr('messages.search_no_results', {'q': q}),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 14.sp,
          ),
        ),
      );
    }
    return Column(
      children: [
        if (_searching) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: ListView(
            padding: EdgeInsets.only(bottom: 16.h),
            children: [
              if (people.isNotEmpty) ...[
                _sectionHeader(context.tr('messages.search_people')),
                for (final user in people) _buildPeopleRow(user),
              ],
              if (convos.isNotEmpty) ...[
                _sectionHeader(context.tr('messages')),
                for (final convo in convos)
                  MessageListTile(
                    name: convo.peerName,
                    message: convo.lastMessage,
                    time: _formatTime(context, convo.lastMessageAt),
                    imageUrl: convo.peerAvatar,
                    isUnread: convo.isUnread,
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRouter.chat,
                      arguments: {
                        'conversationId': convo.id,
                        'name': convo.peerName,
                        'avatar': convo.peerAvatar,
                      },
                    ),
                    onProfileTap: () => Navigator.pushNamed(
                      context,
                      AppRouter.profile,
                      arguments: convo.peerId,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
    child: Text(
      title,
      style: TextStyle(
        color: context.colors.textPrimary,
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _buildPeopleRow(Map<String, dynamic> user) {
    final profile = user['profile'] as Map<String, dynamic>? ?? {};
    final name = [
      profile['firstName'],
      profile['lastName'],
    ].whereType<String>().where((s) => s.isNotEmpty).join(' ');
    final headline = profile['headline'] as String? ?? '';
    final avatar = MediaUrlHelper.resolve((profile['avatar'] as String?) ?? '');
    final userId = (user['_id'] ?? '').toString();
    return ListTile(
      onTap: () => _startChat(userId, name, avatar),
      leading: CircleAvatar(
        radius: 22.r,
        backgroundColor: context.colors.surfaceMuted,
        backgroundImage: avatar.isNotEmpty
            ? CachedNetworkImageProvider(avatar)
            : null,
        child: avatar.isEmpty
            ? Icon(Icons.person, color: context.colors.textHint, size: 22.sp)
            : null,
      ),
      title: Text(
        name.isEmpty ? context.tr('network.member') : name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        headline,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: context.colors.textSecondary, fontSize: 13.sp),
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.chat_bubble_outline,
          color: Theme.of(context).colorScheme.primary,
          size: 22.sp,
        ),
        tooltip: context.tr('messages'),
        onPressed: () => _startChat(userId, name, avatar),
      ),
    );
  }

  String _formatTime(BuildContext context, DateTime? dt) =>
      formatTimeAgo(context, dt);
}
