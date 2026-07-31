import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WsChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;

  WsChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  factory WsChatMessage.fromJson(Map<String, dynamic> json) {
    return WsChatMessage(
      id: (json['_id'] ?? json['id']).toString(),
      senderId: json['senderId'].toString(),
      receiverId: json['receiverId'].toString(),
      message: json['message'] ?? json['content'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'senderId': senderId,
        'receiverId': receiverId,
        'message': message,
      };
}

class ChatWebSocketService {
  WebSocketChannel? _channel;
  final StreamController<WsChatMessage> _messageController =
      StreamController<WsChatMessage>.broadcast();
  bool _isConnected = false;
  String? _currentUserId;
  String _serverUrl = 'ws://127.0.0.1:5000/ws/chat';

  Stream<WsChatMessage> get messages => _messageController.stream;
  bool get isConnected => _isConnected;

  void connect({
    required String userId,
    required String token,
    String? serverUrl,
  }) {
    _currentUserId = userId;
    if (serverUrl != null) _serverUrl = serverUrl;
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(_serverUrl),
        headers: {'Authorization': 'Bearer $token', 'X-User-Id': userId},
      );
      _isConnected = true;

      _channel!.stream.listen(
        (data) {
          try {
            final json = jsonDecode(data as String);
            final message = WsChatMessage.fromJson(json);
            _messageController.add(message);
          } catch (e) {
            debugPrint('ChatWebSocket: Failed to parse message: $e');
          }
        },
        onError: (error) {
          debugPrint('ChatWebSocket: Connection error: $error');
          _isConnected = false;
        },
        onDone: () {
          debugPrint('ChatWebSocket: Connection closed');
          _isConnected = false;
        },
      );
    } catch (e) {
      debugPrint('ChatWebSocket: Failed to connect: $e');
      _isConnected = false;
    }
  }

  void sendMessage({
    required String receiverId,
    required String message,
  }) {
    if (_channel == null || !_isConnected) {
      debugPrint('ChatWebSocket: Not connected');
      return;
    }
    final payload = jsonEncode({
      'senderId': _currentUserId,
      'receiverId': receiverId,
      'message': message,
    });
    _channel!.sink.add(payload);
  }

  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
    _currentUserId = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
