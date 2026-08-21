class NotificationEntity {
  final String id;
  final String type;
  final String message;
  final bool read;
  final String? postId;
  final String? senderId;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.message,
    required this.read,
    required this.createdAt,
    this.postId,
    this.senderId,
  });

  factory NotificationEntity.fromJson(Map<String, dynamic> json) =>
      NotificationEntity(
        id: (json['_id'] ?? json['id']).toString(),
        type: json['type']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        read: json['read'] == true,
        postId: json['postId']?.toString(),
        senderId: json['senderId']?.toString(),
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
}
