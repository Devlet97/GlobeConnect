import 'package:cloud_firestore/cloud_firestore.dart';
import 'country.dart';

class ArticleDraft {
  final String? id;
  final String? title;
  final String? description;
  final String? content;
  final String? coverImageBase64;
  final List<String> categories;
  final List<String> countries;
  final DateTime createdAt;
  final String userId;
  final int likesCount;
  final List<String> likedByUsers;

  ArticleDraft({
    this.id,
    this.title,
    this.description,
    this.content,
    this.coverImageBase64,
    required this.categories,
    required this.countries,
    required this.createdAt,
    required this.userId,
    this.likesCount = 0,
    this.likedByUsers = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'coverImageBase64': coverImageBase64,
      'categories': categories,
      'countries': countries,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
      'likesCount': likesCount,
      'likedByUsers': likedByUsers,
    };
  }

  factory ArticleDraft.fromMap(Map<String, dynamic> map, String id) {
    return ArticleDraft(
      id: id,
      title: map['title'],
      description: map['description'],
      content: map['content'],
      coverImageBase64: map['coverImageBase64'],
      categories: List<String>.from(map['categories'] ?? []),
      countries: List<String>.from(map['countries'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      userId: map['userId'],
      likesCount: map['likesCount'] ?? 0,
      likedByUsers: List<String>.from(map['likedByUsers'] ?? []),
    );
  }

  ArticleDraft copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? coverImageBase64,
    List<String>? categories,
    List<String>? countries,
    DateTime? createdAt,
    String? userId,
    int? likesCount,
    List<String>? likedByUsers,
  }) {
    return ArticleDraft(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      coverImageBase64: coverImageBase64 ?? this.coverImageBase64,
      categories: categories ?? this.categories,
      countries: countries ?? this.countries,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      likesCount: likesCount ?? this.likesCount,
      likedByUsers: likedByUsers ?? this.likedByUsers,
    );
  }
}
