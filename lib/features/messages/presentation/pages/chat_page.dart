import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../api_service.dart';
import '../../data/services/chat_rest_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String userName;
  final String peerAvatar;

  const ChatPage({
    required this.conversationId,
    required this.userName,
    super.key,
    this.peerAvatar = '',
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatRestService _chatService;
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;
  String _currentUserId = '';
  final List<ChatMessage> _messages = [];
  final Set<int> _lastInGroupIndices = {};

  @override
  void initState() {
    super.initState();
    _chatService = sl<ChatRestService>();
    _init();
  }

  Future<void> _init() async {
    _currentUserId = (await sl<ApiService>().getCurrentUserId()) ?? '';
    if (!mounted) return;
    _chatService.startPolling(
      conversationId: widget.conversationId,
      userId: _currentUserId,
    );
    _messagesSubscription = _chatService.messages.listen((messages) {
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(messages);
        _rebuildGroupIndices();
      });
    });
  }

  /// حساب فهارس "أول رسالة في المجموعة" مسبقًا (O(n)) بدل
  /// lastIndexWhere داخل itemBuilder (O(n²) عند كل استطلاع).
  /// الرسائل تأتي من الباك مرتبة من الأحدث للأقدم، والقائمة معكوسة
  /// (reverse: true) فأحدث رسالة في المجموعة تظهر أسفلها وعليها الذيل/الصورة.
  void _rebuildGroupIndices() {
    _lastInGroupIndices.clear();
    for (var i = 0; i < _messages.length; i++) {
      final isFirstInGroup =
          i == 0 || _messages[i].senderId != _messages[i - 1].senderId;
      if (isFirstInGroup) _lastInGroupIndices.add(i);
    }
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    _chatService.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String content) async {
    if (widget.conversationId.isEmpty) return;
    try {
      await _chatService.sendMessage(widget.conversationId, content);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('messages.send_failed', {'error': '$e'})),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.surface,
    appBar: AppBar(
      backgroundColor: context.colors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: context.colors.surfaceMuted,
            backgroundImage: widget.peerAvatar.isNotEmpty
                ? NetworkImage(widget.peerAvatar)
                : null,
            child: widget.peerAvatar.isEmpty
                ? Icon(Icons.person, color: AppColors.primaryDark, size: 24.sp)
                : null,
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.userName,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                context.tr('messages.online'),
                style: TextStyle(
                  color: context.colors.textHint,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    body: Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 20.h,
                  ),
                  reverse: true,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isSender = message.senderId == _currentUserId;
                    return ChatBubble(
                      message: message.content,
                      time: DateFormat.jm().format(message.createdAt),
                      isSender: isSender,
                      isLastInGroup: _lastInGroupIndices.contains(index),
                      avatarUrl: isSender ? null : widget.peerAvatar,
                    );
                  },
                ),
        ),
        ChatInputBar(onSend: _sendMessage),
      ],
    ),
  );

  Widget _buildEmptyState() => Center(
    child: Text(
      context.tr('messages.empty_chat'),
      style: TextStyle(color: context.colors.textSecondary, fontSize: 14.sp),
    ),
  );
}
