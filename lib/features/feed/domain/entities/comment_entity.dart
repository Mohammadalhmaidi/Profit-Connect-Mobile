import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String userRole;
  final String userAvatar;
  final String content;
  final DateTime createdAt;
  final int likesCount;
  final bool isLiked;

  const CommentEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.userAvatar,
    required this.content,
    required this.createdAt,
    this.likesCount = 0,
    this.isLiked = false,
  });

  CommentEntity copyWith({int? likesCount, bool? isLiked}) => CommentEntity(
    id: id,
    userId: userId,
    userName: userName,
    userRole: userRole,
    userAvatar: userAvatar,
    content: content,
    createdAt: createdAt,
    likesCount: likesCount ?? this.likesCount,
    isLiked: isLiked ?? this.isLiked,
  );

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    userRole,
    userAvatar,
    content,
    createdAt,
    likesCount,
    isLiked,
  ];
}
