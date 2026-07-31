import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/media_url_helper.dart';
import '../../../../core/utils/ui_utils.dart';
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
  String? _error;
  String _currentUserId = '';
  List<ConversationSummary> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _currentUserId = (await sl<ApiService>().getCurrentUserId()) ?? '';
      final response = await sl<ApiService>().getConversations();
      final data = response.data;
      final map = data is Map ? Map<String, dynamic>.from(data) : const <String, dynamic>{};
      final rawList = (map['data'] as List<dynamic>?) ?? [];
      final parsed = rawList.whereType<Map>().map((json) {
        final convo = Map<String, dynamic>.from(json);
        final participants = (convo['participants'] as List<dynamic>? ?? [])
            .whereType<Map>()
            .map((p) => Map<String, dynamic>.from(p))
            .toList();
        final peer = participants.firstWhere(
          (p) => (p['_id'] ?? p['id']).toString() != _currentUserId,
          orElse: () => participants.isNotEmpty ? participants.first : const <String, dynamic>{},
        );
        final profile = peer['profile'] as Map<String, dynamic>?;
        final peerName = [profile?['firstName'], profile?['lastName']]
            .whereType<String>()
            .where((s) => s.isNotEmpty)
            .join(' ');
        final peerAvatar = MediaUrlHelper.resolve(profile?['avatar'] as String?);
        final lastMessage = convo['lastMessage'] as Map<String, dynamic>?;
        final lastMessageAtRaw = lastMessage?['createdAt'] ?? convo['lastMessageAt'];
        DateTime? lastMessageAt;
        if (lastMessageAtRaw is String) {
          lastMessageAt = DateTime.tryParse(lastMessageAtRaw);
        }
        return ConversationSummary(
          id: (convo['_id'] ?? convo['id']).toString(),
          peerId: (peer['_id'] ?? peer['id']).toString(),
          peerName: peerName.isNotEmpty ? peerName : (peer['name'] as String? ?? 'Unknown'),
          peerAvatar: peerAvatar,
          lastMessage: lastMessage?['content'] as String? ?? '',
          lastMessageAt: lastMessageAt,
          isUnread: false,
        );
      }).toList();
      setState(() => _conversations = parsed);
    } catch (e) {
      setState(() => _error = 'Failed to load conversations');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<ConversationSummary> get _filtered => _searchQuery.isEmpty
      ? _conversations
      : _conversations.where((c) => c.peerName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leadingWidth: 64.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRouter.profile),
            child: CircleAvatar(
              radius: 20.r,
              backgroundColor: const Color(0xFFF3E5D8),
              child: Icon(Icons.person, color: Colors.white, size: 24.sp),
            ),
          ),
        ),
        title: Text(
          'Messages',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: AppColors.primaryDark, size: 28.sp),
            onPressed: () => Navigator.pushNamed(context, AppRouter.settings),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F5),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search messages...',
                  hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14.sp),
                  prefixIcon: Icon(Icons.search, color: AppColors.textHint, size: 22.sp),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Text(
                          _error!,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : _filtered.isEmpty
                        ? Center(
                            child: Text(
                              'No conversations yet',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadConversations,
                            child: ListView.builder(
                              itemCount: _filtered.length,
                              itemBuilder: (context, index) {
                                final convo = _filtered[index];
                                return MessageListTile(
                                  name: convo.peerName,
                                  message: convo.lastMessage,
                                  time: _formatTime(convo.lastMessageAt),
                                  imageUrl: convo.peerAvatar,
                                  isUnread: convo.isUnread,
                                  isOnline: false,
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
                                    arguments: convo.peerName,
                                  ),
                                );
                              },
                            ),
                          ),
          ),
          if (_filtered.isNotEmpty) ...[
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () => UIUtils.showSnackBar(
                context: context,
                message: 'Compose is coming soon',
                isError: false,
              ),
              child: Text(
                'New message',
                style: TextStyle(color: AppColors.primaryDark, fontSize: 12.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.month}/${dt.day}';
  }
}
