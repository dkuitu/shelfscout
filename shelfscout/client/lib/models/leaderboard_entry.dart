class LeaderboardEntry {
  final int rank;
  final String userId;
  final String username;
  final int crownCount;
  final int submissionCount;
  final double? trustScore;
  final int? verifiedSubmissions;
  final double? bestPrice;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.crownCount,
    required this.submissionCount,
    this.trustScore,
    this.verifiedSubmissions,
    this.bestPrice,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json, int index) {
    return LeaderboardEntry(
      rank: index + 1,
      userId: json['id'].toString(),
      username: json['username'] as String,
      crownCount: (json['crown_count'] as num?)?.toInt() ?? 0,
      submissionCount: (json['submission_count'] as num?)?.toInt() ?? 0,
      trustScore: (json['trust_score'] as num?)?.toDouble(),
      verifiedSubmissions: (json['verified_submissions'] as num?)?.toInt(),
      bestPrice: (json['best_price'] as num?)?.toDouble(),
    );
  }
}
