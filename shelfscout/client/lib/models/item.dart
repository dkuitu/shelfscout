import 'package:flutter/material.dart';

class Item {
  final String id;
  final String name;
  final String? unit;
  final String status;
  final String? createdBy;
  final String? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;

  Item({
    required this.id,
    required this.name,
    this.unit,
    this.status = 'active',
    this.createdBy,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'].toString(),
      name: json['name'] as String,
      unit: json['unit'] as String?,
      status: json['status'] as String? ?? 'active',
      createdBy: json['created_by']?.toString(),
      categoryId: json['category_id']?.toString(),
      categoryName: json['category_name'] as String?,
      categoryIcon: json['category_icon'] as String?,
      categoryColor: json['category_color'] as String?,
    );
  }

  bool get isPending => status == 'pending';

  String get displayName => unit != null ? '$name ($unit)' : name;

  Color get catColor {
    if (categoryColor == null) return Colors.white54;
    final hex = categoryColor!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  IconData get catIcon {
    switch (categoryIcon) {
      case 'water_drop':
        return Icons.water_drop;
      case 'bakery_dining':
        return Icons.bakery_dining;
      case 'eco':
        return Icons.eco;
      case 'restaurant':
        return Icons.restaurant;
      case 'shopping_basket':
        return Icons.shopping_basket;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'cookie':
        return Icons.cookie;
      default:
        return Icons.category;
    }
  }
}
