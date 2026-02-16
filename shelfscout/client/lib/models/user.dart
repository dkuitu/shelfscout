class User {
  final String id;
  final String email;
  final String username;
  final String? regionId;
  final String? regionName;
  final double trustScore;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.regionId,
    this.regionName,
    required this.trustScore,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'] as String,
      username: json['username'] as String,
      regionId: json['region_id']?.toString(),
      regionName: json['region_name'] as String?,
      trustScore: (json['trust_score'] as num?)?.toDouble() ?? 50.0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
