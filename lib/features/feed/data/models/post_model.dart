import '../../../../core/utils/media_url_helper.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/post_entity.dart';
import 'comment_model.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.userRole,
    required super.userAvatar,
    required super.content,
    required super.createdAt,
    super.hashtags,
    super.mediaUrl,
    super.videoUrl,
    super.likesCount,
    super.commentsCount,
    super.isLiked,
    super.isSaved,
    super.shareCount,
    super.postType,
    super.budget,
    super.deadline,
    super.companyId,
    super.comments,
  });

  factory PostModel.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final user = json['user'] as Map<String, dynamic>?;
    final userProfile = user?['profile'] as Map<String, dynamic>?;

    final likes = json['likes'] as List<dynamic>? ?? [];
    final comments = json['comments'] as List<dynamic>? ?? [];

    final parsedComments = comments
        .map(
          (c) => c is Map
              ? CommentModel.fromJson(
                  Map<String, dynamic>.from(c),
                  currentUserId: currentUserId,
                )
              : null,
        )
        .whereType<CommentEntity>()
        .toList();

    final postTypeStr = json['postType'] as String? ?? json['type'] as String?;

    final fullName = userProfile?['fullname'] as String?;
    final firstName = userProfile?['firstName'] as String? ?? '';
    final lastName = userProfile?['lastName'] as String? ?? '';
    final fallbackName = [
      firstName,
      lastName,
    ].where((s) => s.isNotEmpty).join(' ');

    return PostModel(
      id: (json['_id'] ?? json['id']).toString(),
      userId: user?['_id']?.toString() ?? json['userId']?.toString() ?? '',
      userName: (fullName?.isNotEmpty == true)
          ? fullName!
          : fallbackName.isNotEmpty
          ? fallbackName
          : user?['username'] as String? ?? 'Unknown',
      userRole: user?['role'] as String? ?? '',
      userAvatar: MediaUrlHelper.resolve(userProfile?['avatar'] as String?),
      content: json['content'] ?? '',
      hashtags:
          (json['hashtags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      mediaUrl: MediaUrlHelper.resolve(
        json['image'] as String? ?? json['mediaUrl'] as String?,
      ),
      videoUrl: MediaUrlHelper.resolve(
        json['video'] as String? ?? json['videoUrl'] as String?,
      ),
      likesCount: likes.length,
      commentsCount: comments.length,
      comments: parsedComments,
      isLiked:
          currentUserId != null &&
          likes.any((id) => id.toString() == currentUserId),
      isSaved: json['isSaved'] == true,
      shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      postType: postTypeStr != null
          ? PostType.values.firstWhere(
              (t) => t.name == postTypeStr,
              orElse: () => PostType.normal,
            )
          : PostType.normal,
    );
  }

  Map<String, dynamic> toJson() => {
    'content': content,
    'image': mediaUrl,
    'video': videoUrl,
    'visibility': 'public',
  };
}
