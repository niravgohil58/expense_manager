import 'package:flutter/material.dart';

/// Icons shown when adding/editing a category ([AddCategoryScreen]).
/// Persisted in DB as [IconData.codePoint]; resolved via [categoryIconForCodePoint]
/// so release builds can tree-shake Material icons (no runtime `IconData(codePoint, …)`).
const List<IconData> kCategoryPickerIcons = [
  Icons.restaurant,
  Icons.directions_car,
  Icons.home,
  Icons.shopping_bag,
  Icons.more_horiz,
  Icons.fitness_center,
  Icons.local_hospital,
  Icons.school,
  Icons.work,
  Icons.flight,
  Icons.pets,
  Icons.local_cafe,
  Icons.movie,
  Icons.music_note,
  Icons.sports_esports,
  Icons.phone_android,
  Icons.wifi,
  Icons.paid,
];

/// Maps a stored code point to a const Material icon from [kCategoryPickerIcons].
IconData categoryIconForCodePoint(int codePoint) {
  for (final icon in kCategoryPickerIcons) {
    if (icon.codePoint == codePoint) return icon;
  }
  return Icons.more_horiz;
}
