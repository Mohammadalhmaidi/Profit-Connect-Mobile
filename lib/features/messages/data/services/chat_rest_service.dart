import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../api_service.dart';
import '../../../../core/constants/app_constants.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>?;
    return ChatMessage(
      id: (json['_id'] ?? json['id']).toString(),
      senderId:
          sender?['_id']?.toString() ?? json['senderId']?.toString() ?? '',
      content: json['content'] ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }
}

class ChatRestService {
  final ApiService _apiService;
  Timer? _pollTimer;
  String? _currentConversationId;
  bool _isPolling = false;
  final StreamController<List<ChatMessage>> _messageController =
      StreamController<List<ChatMessage>>.broadcast();
  bool _isClosed = false;

  Stream<List<ChatMessage>> get messages => _messageController.stream;

  ChatRestService(this._apiService);

  void startPolling({
    required String conversationId,
    required String userId,
    Duration interval = const Duration(
      seconds: AppConstants.chatPollingIntervalSeconds,
    ),
  }) {
    _pollTimer?.cancel();
    _currentConversationId = conversationId;
    _pollMessages();
    if (_isClosed) return;
    _pollTimer = Timer.periodic(interval, (_) {
      if (!_isClosed) _pollMessages();
    });
  }

  Future<void> _pollMessages() async {
    if (_currentConversationId == null || _isClosed || _isPolling) return;
    final conversationId = _currentConversationId!;
    _isPolling = true;
    try {
      final response = await _apiService.getMessages(conversationId);
      if (_isClosed || _currentConversationId != conversationId) return;
      final body = response.data;
      final map = body is Map
          ? Map<String, dynamic>.from(body)
          : const <String, dynamic>{};
      final messagesJson = (map['data'] as List<dynamic>?) ?? [];
      final messages = messagesJson
          .whereType<Map>()
          .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      if (!_messageController.isClosed) {
        _messageController.add(messages);
      }
    } catch (e) {
      debugPrint('ChatPoll: Error fetching messages: $e');
    } finally {
      _isPolling = false;
    }
  }

  Future<void> sendMessage(String conversationId, String content) async {
    await _apiService.sendMessage(conversationId, content);
    await _pollMessages();
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _currentConversationId = null;
  }

  void dispose() {
    _isClosed = true;
    stopPolling();
    _messageController.close();
  }
}
