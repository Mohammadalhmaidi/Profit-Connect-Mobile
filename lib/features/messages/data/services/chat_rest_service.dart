import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../api_service.dart';

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
      senderId: sender?['_id']?.toString() ?? json['senderId']?.toString() ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }
}

class ChatRestService {
  final ApiService _apiService;
  Timer? _pollTimer;
  String? _currentConversationId;
  final StreamController<List<ChatMessage>> _messageController =
      StreamController<List<ChatMessage>>.broadcast();
  final Map<String, List<ChatMessage>> _cache = {};
  final Map<String, DateTime> _cacheTimes = {};
  static const Duration _cacheTTL = Duration(minutes: 2);
  String? _currentUserId;
  bool _isClosed = false;

  Stream<List<ChatMessage>> get messages => _messageController.stream;
  List<ChatMessage> get cachedMessages => _cachedMessages;
  List<ChatMessage> _cachedMessages = [];

  ChatRestService(this._apiService);

  void startPolling({
    required String conversationId,
    required String userId,
    Duration interval = const Duration(seconds: 3),
  }) {
    _pollTimer?.cancel();
    _currentConversationId = conversationId;
    _currentUserId = userId;
    _pollMessages();
    _pollTimer = Timer.periodic(interval, (_) {
      if (!_isClosed) _pollMessages();
    });
  }

  Future<void> _pollMessages() async {
    if (_currentConversationId == null || _isClosed) return;
    final cacheKey = _currentConversationId!;
    final cached = _cache[cacheKey];
    final cachedTime = _cacheTimes[cacheKey];
    if (cached != null && cachedTime != null && DateTime.now().difference(cachedTime) < _cacheTTL) {
      _cachedMessages = cached;
      if (!_messageController.isClosed) {
        _messageController.add(cached);
      }
      return;
    }
    try {
      final response = await _apiService.getMessages(_currentConversationId!);
      final body = response.data;
      final map = body is Map ? Map<String, dynamic>.from(body) : const <String, dynamic>{};
      final messagesJson = (map['data'] as List<dynamic>?) ?? [];
      final messages = messagesJson
          .whereType<Map>()
          .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      _cachedMessages = messages;
      _cache[cacheKey] = messages;
      _cacheTimes[cacheKey] = DateTime.now();
      if (!_messageController.isClosed) {
        _messageController.add(messages);
      }
    } catch (e) {
      debugPrint('ChatPoll: Error fetching messages: $e');
    }
  }

  Future<void> sendMessage(String conversationId, String content) async {
    try {
      await _apiService.sendMessage(conversationId, content);
      _cache.remove(conversationId);
      await _pollMessages();
    } catch (e) {
      debugPrint('ChatPoll: Error sending message: $e');
    }
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _currentConversationId = null;
    _currentUserId = null;
  }

  void clearCacheFor(String conversationId) {
    _cache.remove(conversationId);
    _cacheTimes.remove(conversationId);
  }

  void dispose() {
    _isClosed = true;
    stopPolling();
    _messageController.close();
    _cache.clear();
    _cacheTimes.clear();
  }
}
