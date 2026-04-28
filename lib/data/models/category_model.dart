import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final int iconCode;
  final int colorValue;
  final bool isEnabled;
  final bool isSystem; // To identify default categories that cannot be deleted (optional)
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    this.isEnabled = true,
    this.isSystem = false,
    required this.createdAt,
  });

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCode': iconCode,
      'colorValue': colorValue,
      'isEnabled': isEnabled ? 1 : 0,
      'isSystem': isSystem ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      iconCode: map['iconCode'] as int,
      colorValue: map['colorValue'] as int,
      isEnabled: (map['isEnabled'] as int) == 1,
      isSystem: (map['isSystem'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Category copyWith({
    String? id,
    String? name,
    int? iconCode,
    int? colorValue,
    bool? isEnabled,
    bool? isSystem,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      isEnabled: isEnabled ?? this.isEnabled,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
