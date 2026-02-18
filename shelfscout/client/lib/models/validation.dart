enum ValidationVote { confirm, flag }

class ValidationItem {
  final String id;
  final String userId;
  final String storeId;
  final String itemId;
  final double price;
  final String? photoUrl;
  final String status;
  final double? gpsLat;
  final double? gpsLng;
  final DateTime submittedAt;
  final String? itemName;
  final String? storeName;
  final String? categoryName;

  ValidationItem({
    required this.id,
    required this.userId,
    required this.storeId,
    required this.itemId,
    required this.price,
    this.photoUrl,
    required this.status,
    this.gpsLat,
    this.gpsLng,
    required this.submittedAt,
    this.itemName,
    this.storeName,
    this.categoryName,
  });

  factory ValidationItem.fromJson(Map<String, dynamic> json) {
    return ValidationItem(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      storeId: json['store_id'].toString(),
      itemId: json['item_id'].toString(),
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      photoUrl: json['photo_url'] as String?,
      status: json['status'] as String,
      gpsLat: json['gps_lat'] != null ? double.tryParse(json['gps_lat'].toString()) : null,
      gpsLng: json['gps_lng'] != null ? double.tryParse(json['gps_lng'].toString()) : null,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      itemName: json['item_name'] as String?,
      storeName: json['store_name'] as String?,
      categoryName: json['category_name'] as String?,
    );
  }
}
