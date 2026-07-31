import '../../../../core/utils/media_url_helper.dart';
import '../../domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.userRole,
    required super.userAvatar,
    required super.content,
    super.hashtags,
    super.mediaUrl,
    super.videoUrl,
    super.likesCount,
    super.commentsCount,
    super.isLiked,
    required super.createdAt,
    super.postType,
    super.budget,
    super.deadline,
    super.companyId,
  });

  factory PostModel.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final user = json['user'] as Map<String, dynamic>?;
    final userProfile = user?['profile'] as Map<String, dynamic>?;

    final likes = json['likes'] as List<dynamic>? ?? [];
    final comments = json['comments'] as List<dynamic>? ?? [];

    final postTypeStr = json['postType'] as String? ?? json['type'] as String?;

    return PostModel(
      id: (json['_id'] ?? json['id']).toString(),
      userId: user?['_id']?.toString() ?? json['userId']?.toString() ?? '',
      userName: userProfile?['fullname'] as String? ??
          user?['profile']?['fullname'] as String? ??
          user?['username'] as String? ??
          'Unknown',
      userRole: user?['role'] as String? ?? '',
      userAvatar: MediaUrlHelper.resolve(userProfile?['avatar'] as String? ??
          user?['profile']?['avatar'] as String?),
      content: json['content'] ?? '',
      hashtags: (json['hashtags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      mediaUrl: MediaUrlHelper.resolve(json['image'] as String? ?? json['mediaUrl'] as String?),
      videoUrl: MediaUrlHelper.resolve(json['video'] as String? ?? json['videoUrl'] as String?),
      likesCount: likes.length,
      commentsCount: comments.length,
      isLiked: currentUserId != null && likes.any((id) => id.toString() == currentUserId),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      postType: postTypeStr != null
          ? PostType.values.firstWhere(
              (t) => t.name == postTypeStr,
              orElse: () => PostType.normal,
            )
          : PostType.normal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'image': mediaUrl,
      'video': videoUrl,
      'visibility': 'public',
    };
  }
}