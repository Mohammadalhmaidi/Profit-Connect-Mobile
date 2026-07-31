import 'package:equatable/equatable.dart';

enum PostType { normal, business, project, job }

class PostEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String userRole;
  final String userAvatar;
  final String content;
  final List<String> hashtags;
  final String? mediaUrl;
  final String? videoUrl;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final DateTime createdAt;
  final PostType postType;
  final String? budget;
  final String? deadline;
  final String? companyId;

  const PostEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.userAvatar,
    required this.content,
    this.hashtags = const [],
    this.mediaUrl,
    this.videoUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    required this.createdAt,
    this.postType = PostType.normal,
    this.budget,
    this.deadline,
    this.companyId,
  });

  PostEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userRole,
    String? userAvatar,
    String? content,
    List<String>? hashtags,
    String? mediaUrl,
    String? videoUrl,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    DateTime? createdAt,
    PostType? postType,
    String? budget,
    String? deadline,
    String? companyId,
  }) {
    return PostEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      hashtags: hashtags ?? this.hashtags,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      postType: postType ?? this.postType,
      budget: budget ?? this.budget,
      deadline: deadline ?? this.deadline,
      companyId: companyId ?? this.companyId,
    );
  }

  @override
  List<Object?> get props => [
        id, userId, userName, userRole, userAvatar,
        content, hashtags, mediaUrl, videoUrl,
        likesCount, commentsCount, isLiked, createdAt,
        postType, budget, deadline, companyId,
      ];
}
