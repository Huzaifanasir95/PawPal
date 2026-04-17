class TrendingHashtag {
  final String tag;
  final int usageCount;

  const TrendingHashtag({required this.tag, required this.usageCount});

  factory TrendingHashtag.fromJson(Map<String, dynamic> json) {
    return TrendingHashtag(
      tag: json['tag'] as String? ?? '',
      usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class CommunityGroup {
  final String id;
  final String ownerId;
  final String name;
  final String slug;
  final String? description;
  final String? icon;
  final bool isPrivate;
  final int membersCount;
  final int postsCount;
  final bool isMember;
  final String? ownerName;

  const CommunityGroup({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.slug,
    required this.isPrivate,
    required this.membersCount,
    required this.postsCount,
    required this.isMember,
    this.description,
    this.icon,
    this.ownerName,
  });

  factory CommunityGroup.fromJson(Map<String, dynamic> json) {
    return CommunityGroup(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      isPrivate: json['isPrivate'] as bool? ?? false,
      membersCount: (json['membersCount'] as num?)?.toInt() ?? 0,
      postsCount: (json['postsCount'] as num?)?.toInt() ?? 0,
      isMember: json['isMember'] as bool? ?? false,
      ownerName: json['ownerName'] as String?,
    );
  }
}
