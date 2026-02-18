class Store {
  final String id;
  final String name;
  final String address;
  final String? regionId;
  final String? chain;
  final int? distanceMeters;
  final double? latitude;
  final double? longitude;

  Store({
    required this.id,
    required this.name,
    required this.address,
    this.regionId,
    this.chain,
    this.distanceMeters,
    this.latitude,
    this.longitude,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'].toString(),
      name: json['name'] as String,
      address: json['address'] as String,
      regionId: json['region_id']?.toString(),
      chain: json['chain'] as String?,
      distanceMeters: json['distance_meters'] != null
          ? int.tryParse(json['distance_meters'].toString())
          : null,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
    );
  }
}
