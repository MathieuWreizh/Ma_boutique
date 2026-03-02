import 'package:flutter/material.dart';

extension AppColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // ── Backgrounds ─────────────────────────────────────────────
  Color get scaffoldBg  => isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
  Color get cardBg      => isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get containerBg => isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
  Color get inputFill   => isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);

  // ── Textes ───────────────────────────────────────────────────
  Color get textPrimary   => isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
  Color get textSecondary => isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get textHint      => isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

  // ── Bordures & séparateurs ───────────────────────────────────
  Color get borderColor  => isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  Color get dividerColor => isDark ? const Color(0xFF475569) : const Color(0xFFF1F5F9);
  Color get chevronColor => isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1);
}
