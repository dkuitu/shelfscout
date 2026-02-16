class Store {
  final String id;
  final String name;
  final String address;
  final String? regionId;
  final String? chain;
  final int? distanceMeters;

  Store({
    required this.id,
    required this.name,
    required this.address,
    this.regionId,
    this.chain,
    this.distanceMeters,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'].toString(),
      name: json['name'] as String,
      address: json['address'] as String,
      regionId: json['region_id']?.toString(),
      chain: json['chain'] as String?,
      distanceMeters: json['distance_meters'] != null
          ? (json['distance_meters'] as num).toInt()
          : null,
    );
  }
}
