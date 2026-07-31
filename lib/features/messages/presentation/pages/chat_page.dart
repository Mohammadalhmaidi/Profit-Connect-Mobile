import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../api_service.dart';
import '../data/services/chat_rest_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String userName;
  final String peerAvatar;

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.userName,
    this.peerAvatar = '',
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatRestService _chatService;
  String _currentUserId = '';
  final List<ChatMessage> _messages = [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _chatService = sl<ChatRestService>();
    _init();
  }

  Future<void> _init() async {
    _currentUserId = (await sl<ApiService>().getCurrentUserId()) ?? '';
    _chatService.startPolling(
      conversationId: widget.conversationId,
      userId: _currentUserId,
    );
    _chatService.messages.listen((messages) {
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(messages);
      });
    });
    _initialized = true;
  }

  @override
  void dispose() {
    _chatService.stopPolling();
    super.dispose();
  }

  Future<void> _sendMessage(String content) async {
    if (widget.conversationId.isEmpty) return;
    try {
      await _chatService.sendMessage(widget.conversationId, content);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundImage:
                  widget.peerAvatar.isNotEmpty ? NetworkImage(widget.peerAvatar) : null,
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
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'SENIOR PRODUCT DESIGNER',
                  style: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black),
            onPressed: () {},
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isSender = message.senderId == _currentUserId;
                      return ChatBubble(
                        message: message.content,
                        time: DateFormat.jm().format(message.createdAt),
                        isSender: isSender,
                        isLastInGroup: index == _messages.lastIndexWhere((m) => m.senderId == message.senderId),
                        avatarUrl: isSender ? null : widget.peerAvatar,
                      );
                    },
                  ),
          ),
          ChatInputBar(onSend: _sendMessage),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No messages yet. Say hello!',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
      ),
    );
  }
}
