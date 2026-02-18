import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String icon;
  final String color;
  final int sortOrder;
  final bool isDefault;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.sortOrder,
    required this.isDefault,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Color get colorValue {
    final hex = color.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  IconData get iconData {
    switch (icon) {
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
