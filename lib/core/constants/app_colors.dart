import 'package:flutter/material.dart';

/// Application color palette
/// Soft and accessible colors for a user-friendly experience
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF4A90A4); // Soft Teal Blue
  static const Color primaryLight = Color(0xFF7BB8C9);
  static const Color primaryDark = Color(0xFF2D6B7D);

  // Secondary/Accent Colors
  static const Color accent = Color(0xFFFF9F43); // Light Orange
  static const Color accentLight = Color(0xFFFFBE7D);
  static const Color accentDark = Color(0xFFE67E22);

  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textHint = Color(0xFFB2BEC3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Semantic Colors
  static const Color income = Color(0xFF27AE60); // Green - Money received
  static const Color expense = Color(0xFFE74C3C); // Red - Expense/Udhar Lena
  static const Color udharDena = Color(0xFF3498DB); // Blue - Money given
  static const Color udharLena = Color(0xFFE74C3C); // Red - Money taken

  // Account Type Colors
  static const Color cash = Color(0xFF27AE60);
  static const Color bank = Color(0xFF3498DB);

  // Status Colors
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // Divider & Border
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFDFE6E9);

  // Shadow
  static const Color shadow = Color(0x1A000000);

  // Category Colors
  static const Color categoryFood = Color(0xFFE74C3C);
  static const Color categoryTravel = Color(0xFF3498DB);
  static const Color categoryRent = Color(0xFF9B59B6);
  static const Color categoryShopping = Color(0xFFF39C12);
  static const Color categoryOther = Color(0xFF95A5A6);
}
