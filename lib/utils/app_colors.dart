import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF5B6EF5);
  static const Color accent = Color(0xFFA4B1FF);
  
  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF5B6EF5),
    Color(0xFFA4B1FF),
  ];
  
  static const List<Color> successGradient = [
    Color(0xFF4CAF50),
    Color(0xFF81C784),
  ];
  
  static const List<Color> errorGradient = [
    Color(0xFFF44336),
    Color(0xFFE57373),
  ];
  
  // Neutral Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color backgroundDark = Color(0xFF1A1A1A);
  
  // Card Colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2D2D2D);
  
  // Glassmorphism
  static Color glassWhite = Colors.white.withOpacity(0.2);
  static Color glassBlack = Colors.black.withOpacity(0.2);
}

