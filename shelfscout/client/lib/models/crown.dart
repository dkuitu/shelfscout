enum CrownStatus { active, contested, archived }

class Crown {
  final String id;
  final String itemId;
  final String? itemName;
  final String regionId;
  final String? regionName;
  final String holderId;
  final String? holderUsername;
  final double lowestPrice;
  final CrownStatus status;
  final String? cycleId;
  final DateTime claimedAt;

  Crown({
    required this.id,
    required this.itemId,
    this.itemName,
    required this.regionId,
    this.regionName,
    required this.holderId,
    this.holderUsername,
    required this.lowestPrice,
    required this.status,
    this.cycleId,
    required this.claimedAt,
  });

  factory Crown.fromJson(Map<String, dynamic> json) {
    return Crown(
      id: json['id'].toString(),
      itemId: json['item_id'].toString(),
      itemName: json['item_name'] as String?,
      regionId: json['region_id'].toString(),
      regionName: json['region_name'] as String?,
      holderId: json['holder_id'].toString(),
      holderUsername: json['holder_username'] as String?,
      lowestPrice: (json['lowest_price'] as num).toDouble(),
      status: _parseStatus(json['status'] as String),
      cycleId: json['cycle_id']?.toString(),
      claimedAt: DateTime.parse(json['claimed_at'] as String),
    );
  }

  static CrownStatus _parseStatus(String s) {
    switch (s) {
      case 'contested':
        return CrownStatus.contested;
      case 'archived':
        return CrownStatus.archived;
      default:
        return CrownStatus.active;
    }
  }
}
