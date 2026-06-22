import 'package:flutter/material.dart';

class AppColors {
  // Upgraded Design System Colors
  static const Color primary = Color(0xFF0052FF); // Premium Electric Blue
  static const Color secondary = Color(0xFF06B6D4); // Cyan Explorer Accent
  static const Color accent = Color(0xFFFFB020); // Warning Amber
  static const Color error = Color(0xFFEF4444); // Error Red

  // Dark Mode Theme (Carbon/Steel Black & Slate Grey)
  static const Color darkBg = Color(0xFF0B0F19); // Premium Black background
  static const Color darkCard = Color(0xFF131B2E); // Metallic Slate card surface
  static const Color darkSurface = Color(0xFF1E293B); // Input field/Overlay surface
  static const Color darkBorder = Color(0xFF2E3E5C); // Steel Blue borders
  
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Soft White
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Muted slate grey

  // Light Mode Theme (Premium Clean Ice)
  static const Color lightBg = Color(0xFFF1F5F9); // Cold Grey background
  static const Color lightCard = Color(0xFFFFFFFF); // Clean White card
  static const Color lightSurface = Color(0xFFE2E8F0); // Input/Inner surface
  static const Color lightBorder = Color(0xFFCBD5E1); // Muted ice border

  static const Color lightTextPrimary = Color(0xFF0F172A); // Dark Slate Grey text
  static const Color lightTextSecondary = Color(0xFF64748B); // Muted Slate Grey text

  // Glassmorphic / Gradient tokens
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient carbonGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFB020), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient sosGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
