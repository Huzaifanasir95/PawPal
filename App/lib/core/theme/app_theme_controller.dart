import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePalette {
  final String id;
  final String name;
  final Color primary;

  const ThemePalette({
    required this.id,
    required this.name,
    required this.primary,
  });
}

class AppThemeController extends ChangeNotifier {
  AppThemeController();

  static const String _darkModePrefix = 'ui_dark_mode';
  static const String _roleThemePrefix = 'ui_role_theme';

  static const List<ThemePalette> _palettes = <ThemePalette>[
    ThemePalette(id: 'mint', name: 'Mint Paw', primary: Color(0xFF2C8C7F)),
    ThemePalette(id: 'sunset', name: 'Sunset Paw', primary: Color(0xFFE07A5F)),
    ThemePalette(id: 'ocean', name: 'Ocean Paw', primary: Color(0xFF3F72AF)),
    ThemePalette(id: 'forest', name: 'Forest Paw', primary: Color(0xFF3A7D44)),
  ];

  String? _userId;
  bool _isDarkMode = false;
  String _activeRole = 'pet_owner';
  Map<String, String> _roleThemeByRole = <String, String>{};
  bool _isLoading = false;

  List<ThemePalette> get palettes => _palettes;
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  String get activeRole => _activeRole;

  ThemeData get lightTheme =>
      _buildTheme(Brightness.light, primaryForRole(_activeRole));
  ThemeData get darkTheme =>
      _buildTheme(Brightness.dark, primaryForRole(_activeRole));

  void syncUserContext({required String userId, required String activeRole}) {
    final normalizedRole = _normalizeRole(activeRole);

    if (_activeRole != normalizedRole) {
      _activeRole = normalizedRole;
      notifyListeners();
    }

    if (_userId != userId && !_isLoading) {
      _loadForUser(userId);
    }
  }

  void resetToGuest() {
    _userId = null;
    _activeRole = 'pet_owner';
    _isDarkMode = false;
    _roleThemeByRole = <String, String>{};
    notifyListeners();
  }

  void setActiveRole(String role) {
    final normalized = _normalizeRole(role);
    if (_activeRole == normalized) return;

    _activeRole = normalized;
    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    if (_isDarkMode == enabled) return;

    _isDarkMode = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, enabled);
  }

  String selectedPaletteIdForRole(String role) {
    final normalized = _normalizeRole(role);
    return _roleThemeByRole[normalized] ?? _defaultPaletteForRole(normalized);
  }

  Color primaryForRole(String role) {
    final paletteId = selectedPaletteIdForRole(role);
    final palette = _palettes.firstWhere(
      (item) => item.id == paletteId,
      orElse: () => _palettes.first,
    );
    return palette.primary;
  }

  Future<void> setRoleTheme(String role, String paletteId) async {
    final normalizedRole = _normalizeRole(role);
    final exists = _palettes.any((item) => item.id == paletteId);
    if (!exists) return;

    _roleThemeByRole[normalizedRole] = paletteId;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleThemeKey, jsonEncode(_roleThemeByRole));
  }

  ThemeData _buildTheme(Brightness brightness, Color primary) {
    final onPrimary = _onColor(primary);
    final scaffold =
        brightness == Brightness.dark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF2F5F7);
    final surface = _blend(
      scaffold,
      primary,
      brightness == Brightness.dark ? 0.12 : 0.08,
    );
    final raisedSurface = _blend(
      scaffold,
      primary,
      brightness == Brightness.dark ? 0.2 : 0.13,
    );
    final seededScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    );
    final colorScheme = seededScheme.copyWith(
      primary: primary,
      secondary: primary,
      onPrimary: onPrimary,
      surface: surface,
      surfaceTint: primary,
      outline: _blend(
        seededScheme.outline,
        primary,
        brightness == Brightness.dark ? 0.25 : 0.15,
      ),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: GoogleFonts.mulish().fontFamily,
      colorScheme: colorScheme,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      textTheme: GoogleFonts.mulishTextTheme(base.textTheme),
      primaryTextTheme: GoogleFonts.mulishTextTheme(base.primaryTextTheme),
      scaffoldBackgroundColor: scaffold,
      canvasColor: surface,
      cardColor: raisedSurface,
      splashColor: primary.withValues(alpha: 0.18),
      hoverColor: primary.withValues(alpha: 0.08),
      highlightColor: primary.withValues(alpha: 0.1),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      bottomAppBarTheme: base.bottomAppBarTheme.copyWith(color: raisedSurface),
      dialogTheme: base.dialogTheme.copyWith(backgroundColor: raisedSurface),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: raisedSurface,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primary, width: 1.6),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
      ),
      chipTheme: base.chipTheme.copyWith(
        selectedColor: primary.withValues(alpha: 0.2),
        checkmarkColor: primary,
      ),
      switchTheme: base.switchTheme.copyWith(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return null;
        }),
      ),
    );
  }

  Color _onColor(Color color) {
    return color.computeLuminance() > 0.45 ? Colors.black : Colors.white;
  }

  Color _blend(Color base, Color overlay, double alpha) {
    return Color.alphaBlend(overlay.withValues(alpha: alpha), base);
  }

  Future<void> _loadForUser(String userId) async {
    _isLoading = true;

    final prefs = await SharedPreferences.getInstance();
    _userId = userId;

    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;

    final rawMap = prefs.getString(_roleThemeKey);
    if (rawMap != null && rawMap.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawMap) as Map<String, dynamic>;
        _roleThemeByRole = decoded.map(
          (key, value) => MapEntry(_normalizeRole(key), value.toString()),
        );
      } catch (_) {
        _roleThemeByRole = <String, String>{};
      }
    } else {
      _roleThemeByRole = <String, String>{};
    }

    _isLoading = false;
    notifyListeners();
  }

  String get _darkModeKey => '${_darkModePrefix}_${_userId ?? 'guest'}';
  String get _roleThemeKey => '${_roleThemePrefix}_${_userId ?? 'guest'}';

  String _normalizeRole(String role) {
    switch (role.trim().toLowerCase()) {
      case 'pet_owner':
      case 'petowner':
      case 'pet-owner':
      case 'pet owner':
      case 'owner':
        return 'pet_owner';
      case 'vet':
      case 'veterinary':
      case 'veterinarian':
        return 'vet';
      case 'seller':
      case 'vendor':
      case 'merchant':
      case 'shop_owner':
      case 'shop owner':
      case 'shopowner':
        return 'seller';
      case 'caregiver':
      case 'care_giver':
      case 'pet_caregiver':
        return 'caregiver';
      default:
        return 'pet_owner';
    }
  }

  String _defaultPaletteForRole(String role) {
    switch (_normalizeRole(role)) {
      case 'vet':
        return 'ocean';
      case 'seller':
        return 'sunset';
      case 'caregiver':
        return 'forest';
      default:
        return 'mint';
    }
  }
}
