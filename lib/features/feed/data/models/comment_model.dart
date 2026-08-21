import '../../../../core/utils/media_url_helper.dart';
import '../../domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.userRole,
    required super.userAvatar,
    required super.content,
    required super.createdAt,
    super.likesCount,
    super.isLiked,
  });

  factory CommentModel.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final user = json['user'] as Map<String, dynamic>?;
    final profile = user?['profile'] as Map<String, dynamic>?;

    final fullName = profile?['fullname'] as String?;
    final firstName = profile?['firstName'] as String? ?? '';
    final lastName = profile?['lastName'] as String? ?? '';
    final fallbackName = [
      firstName,
      lastName,
    ].where((s) => s.isNotEmpty).join(' ');

    final likes = json['likes'] as List<dynamic>? ?? [];

    return CommentModel(
      id: (json['_id'] ?? json['id']).toString(),
      userId: user?['_id']?.toString() ?? json['userId']?.toString() ?? '',
      userName: (fullName?.isNotEmpty == true)
          ? fullName!
          : fallbackName.isNotEmpty
          ? fallbackName
          : user?['username'] as String? ?? 'Unknown',
      userRole: user?['role'] as String? ?? '',
      userAvatar: MediaUrlHelper.resolve(profile?['avatar'] as String?),
      content: json['content'] ?? '',
      likesCount: likes.length,
      isLiked:
          currentUserId != null &&
          likes.any((id) => id.toString() == currentUserId),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
