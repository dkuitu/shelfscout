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
      crownCount: int.tryParse(json['crown_count'].toString()) ?? 0,
      submissionCount: int.tryParse(json['submission_count'].toString()) ?? 0,
      trustScore: json['trust_score'] != null ? double.tryParse(json['trust_score'].toString()) : null,
      verifiedSubmissions: json['verified_submissions'] != null ? int.tryParse(json['verified_submissions'].toString()) : null,
      bestPrice: json['best_price'] != null ? double.tryParse(json['best_price'].toString()) : null,
    );
  }
}
