import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
class Post with _$Post {
  const factory Post({
    required String id,
    required String userId,
    required String title,
    required String content,
    @Default('general') String category,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    String? userName,
    String? userAvatar,
    List<String>? imageUrls,
    @Default(0) int likesCount,
    @Default(0) int commentsCount,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}

/// Available post categories
class PostCategory {
  static const String all = 'all';
  static const String general = 'general';
  static const String dogs = 'dogs';
  static const String cats = 'cats';
  static const String health = 'health';
  static const String training = 'training';
  static const String nutrition = 'nutrition';
  static const String funny = 'funny';
  static const String questions = 'questions';

  static const List<String> values = [
    all, general, dogs, cats, health, training, nutrition, funny, questions
  ];

  static const Map<String, String> labels = {
    all: '🌐 All',
    general: '💬 General',
    dogs: '🐕 Dogs',
    cats: '🐈 Cats',
    health: '🏥 Health',
    training: '🎓 Training',
    nutrition: '🍖 Nutrition',
    funny: '😂 Funny',
    questions: '❓ Questions',
  };

  static String getLabel(String category) => labels[category] ?? category;
}