enum BadgeRarity { common, uncommon, rare, epic, legendary }

class Badge {
  final String id;
  final String name;
  final String description;
  final BadgeRarity rarity;
  final String? iconUrl;
  final DateTime? earnedAt;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    this.iconUrl,
    this.earnedAt,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'].toString(),
      name: json['name'] as String,
      description: json['description'] as String,
      rarity: _parseRarity(json['rarity'] as String),
      iconUrl: json['icon_url'] as String?,
      earnedAt: json['earned_at'] != null
          ? DateTime.parse(json['earned_at'] as String)
          : null,
    );
  }

  static BadgeRarity _parseRarity(String r) {
    switch (r) {
      case 'uncommon':
        return BadgeRarity.uncommon;
      case 'rare':
        return BadgeRarity.rare;
      case 'epic':
        return BadgeRarity.epic;
      case 'legendary':
        return BadgeRarity.legendary;
      default:
        return BadgeRarity.common;
    }
  }
}
