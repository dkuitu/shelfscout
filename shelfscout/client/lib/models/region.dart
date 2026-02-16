class Region {
  final String id;
  final String name;
  final String country;

  Region({
    required this.id,
    required this.name,
    required this.country,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'].toString(),
      name: json['name'] as String,
      country: json['country'] as String,
    );
  }
}
