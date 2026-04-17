class VetReview {
  final String id;
  final String vetId;
  final String userId;
  final String? userName;
  final String? userAvatar;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const VetReview({
    required this.id,
    required this.vetId,
    required this.userId,
    this.userName,
    this.userAvatar,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory VetReview.fromJson(Map<String, dynamic> json) {
    return VetReview(
      id: json['id'] as String,
      vetId: json['vetId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String?,
      userAvatar: json['userAvatar'] as String?,
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}