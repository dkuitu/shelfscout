class Item {
  final String id;
  final String name;
  final String category;
  final bool active;

  Item({
    required this.id,
    required this.name,
    required this.category,
    required this.active,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'].toString(),
      name: json['name'] as String,
      category: json['category'] as String,
      active: json['active'] as bool? ?? true,
    );
  }
}
