import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likesCount;
  final List<String> likedByUsers;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.likesCount = 0,
    required this.likedByUsers,
  });

  factory Comment.fromMap(Map<String, dynamic> map, String commentId) {
    return Comment(
      id: commentId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonim',
      userPhotoUrl: map['userPhotoUrl'],
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      likesCount: map['likesCount'] ?? 0,
      likedByUsers: List<String>.from(map['likedByUsers'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'likesCount': likesCount,
      'likedByUsers': likedByUsers,
    };
  }
}
