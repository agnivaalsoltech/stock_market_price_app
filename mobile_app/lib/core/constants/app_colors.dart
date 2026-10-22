import 'package:flutter/material.dart';

/// MarketPulse Futuristic Brand Color System
/// Supports Obsidian Dark Mode and Crisp Snow Light Mode
class AppColors {
  // Dark Theme Tokens (Primary aesthetic)
  static const Color darkBg = Color(0xFF070B12);          // Deep Obsidian Space
  static const Color darkCard = Color(0xFF101726);        // Frosted Glass Slate
  static const Color darkCardElevated = Color(0xFF162035);
  static const Color darkBorder = Color(0x1FFFFFFF);      // 12% translucent hairline stroke
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Crisp Platinum White
  static const Color darkTextMuted = Color(0xFF94A3B8);   // Slate 400

  // Light Theme Tokens
  static const Color lightBg = Color(0xFFF8FAFC);         // Crisp Snow
  static const Color lightCard = Color(0xFFFFFFFF);       // Pure White
  static const Color lightCardElevated = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);     // Light Divider
  static const Color lightTextPrimary = Color(0xFF0F172A);// Dark Charcoal Slate
  static const Color lightTextMuted = Color(0xFF64748B);  // Slate 500

  // Common Brand Accents
  static const Color primary = Color(0xFF0F172A);         // Deep Navy
  static const Color primaryLight = Color(0xFF1E293B);
  static const Color secondary = Color(0xFF2563EB);       // Electric Cobalt
  static const Color secondaryLight = Color(0xFF3B82F6);  // Vibrant Cyan-Blue
  static const Color accentNeon = Color(0xFF06B6D4);      // Cyber Cyan

  // Financial Semantics (High contrast & readability)
  static const Color positive = Color(0xFF10B981);        // Cyber Emerald (Gains)
  static const Color positiveGlow = Color(0x3310B981);
  static const Color positiveBg = Color(0x1F10B981);
  
  static const Color negative = Color(0xFFF43F5E);        // Cyber Crimson / Rose (Losses)
  static const Color negativeGlow = Color(0x33F43F5E);
  static const Color negativeBg = Color(0x1FF43F5E);

  static const Color warning = Color(0xFFF59E0B);         // Radiant Amber
  static const Color proGold = Color(0xFFF59E0B);         // Pro Badge Gold

  // Backward compatibility static fallbacks
  static const Color background = darkBg;
  static const Color card = darkCard;
  static const Color border = darkBorder;
  static const Color textPrimary = darkTextPrimary;
  static const Color textMuted = darkTextMuted;

  // Context-Aware Dynamic Helpers
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color bg(BuildContext context) => isDark(context) ? darkBg : lightBg;
  static Color surface(BuildContext context) => isDark(context) ? darkCard : lightCard;
  static Color surfaceElevated(BuildContext context) => isDark(context) ? darkCardElevated : lightCardElevated;
  static Color borderC(BuildContext context) => isDark(context) ? darkBorder : lightBorder;
  static Color text(BuildContext context) => isDark(context) ? darkTextPrimary : lightTextPrimary;
  static Color subtext(BuildContext context) => isDark(context) ? darkTextMuted : lightTextMuted;
}
