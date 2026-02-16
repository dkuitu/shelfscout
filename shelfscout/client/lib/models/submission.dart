enum SubmissionStatus { pending, verified, rejected }

class Submission {
  final String id;
  final String userId;
  final String storeId;
  final String itemId;
  final String? cycleId;
  final double price;
  final String? photoUrl;
  final SubmissionStatus status;
  final double? gpsLat;
  final double? gpsLng;
  final DateTime submittedAt;
  final DateTime? verifiedAt;

  Submission({
    required this.id,
    required this.userId,
    required this.storeId,
    required this.itemId,
    this.cycleId,
    required this.price,
    this.photoUrl,
    required this.status,
    this.gpsLat,
    this.gpsLng,
    required this.submittedAt,
    this.verifiedAt,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      storeId: json['store_id'].toString(),
      itemId: json['item_id'].toString(),
      cycleId: json['cycle_id']?.toString(),
      price: (json['price'] as num).toDouble(),
      photoUrl: json['photo_url'] as String?,
      status: _parseStatus(json['status'] as String),
      gpsLat: (json['gps_lat'] as num?)?.toDouble(),
      gpsLng: (json['gps_lng'] as num?)?.toDouble(),
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
    );
  }

  static SubmissionStatus _parseStatus(String s) {
    switch (s) {
      case 'verified':
        return SubmissionStatus.verified;
      case 'rejected':
        return SubmissionStatus.rejected;
      default:
        return SubmissionStatus.pending;
    }
  }
}
