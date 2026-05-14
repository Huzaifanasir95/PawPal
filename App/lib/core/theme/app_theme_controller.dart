import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    final isDark = brightness == Brightness.dark;
    final onPrimary = _onColor(primary);

    // ── Surface stack ───────────────────────────────────────────────────────
    final scaffold =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF2F5F7);
    final surface = _blend(scaffold, primary, isDark ? 0.12 : 0.08);
    final raisedSurface = _blend(scaffold, primary, isDark ? 0.20 : 0.13);
    final onSurface = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1A202C);
    final onSurfaceVariant =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    // ── Seeded colour scheme ────────────────────────────────────────────────
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
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: _blend(
        seededScheme.outline,
        primary,
        isDark ? 0.25 : 0.15,
      ),
      error: const Color(0xFFE53E3E),
      onError: Colors.white,
    );

    // ── Text theme ──────────────────────────────────────────────────────────
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: GoogleFonts.mulish().fontFamily,
      colorScheme: colorScheme,
    );

    final textTheme = GoogleFonts.mulishTextTheme(base.textTheme).apply(
      bodyColor: onSurface,
      displayColor: onSurface,
    );

    // ── Status bar ──────────────────────────────────────────────────────────
    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryTextTheme: GoogleFonts.mulishTextTheme(base.primaryTextTheme),
      scaffoldBackgroundColor: scaffold,
      canvasColor: surface,
      cardColor: raisedSurface,
      splashColor: primary.withValues(alpha: 0.18),
      hoverColor: primary.withValues(alpha: 0.08),
      highlightColor: primary.withValues(alpha: 0.10),

      // ── AppBar ──────────────────────────────────────────────────────────
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: overlayStyle,
        titleTextStyle: GoogleFonts.mulish(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: onPrimary,
        ),
        iconTheme: IconThemeData(color: onPrimary, size: 24),
        actionsIconTheme: IconThemeData(color: onPrimary, size: 24),
      ),

      // ── Bottom App Bar / Navigation ─────────────────────────────────────
      bottomAppBarTheme: base.bottomAppBarTheme.copyWith(
        color: raisedSurface,
        elevation: 8,
        surfaceTintColor: Colors.transparent,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: raisedSurface,
        selectedItemColor: primary,
        unselectedItemColor: onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.mulish(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.mulish(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: raisedSurface,
        indicatorColor: primary.withValues(alpha: 0.18),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primary, size: 24);
          }
          return IconThemeData(color: onSurfaceVariant, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.mulish(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: primary,
            );
          }
          return GoogleFonts.mulish(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: onSurfaceVariant,
          );
        }),
      ),

      // ── Cards & Surfaces ─────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: raisedSurface,
        elevation: isDark ? 2 : 1,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      ),

      // ── Dialogs & Sheets ─────────────────────────────────────────────────
      dialogTheme: base.dialogTheme.copyWith(
        backgroundColor: raisedSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: GoogleFonts.mulish(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        contentTextStyle: GoogleFonts.mulish(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: onSurfaceVariant,
          height: 1.5,
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: raisedSurface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: raisedSurface,
        elevation: 12,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        dragHandleColor: onSurfaceVariant.withValues(alpha: 0.4),
      ),

      // ── Inputs ───────────────────────────────────────────────────────────
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: raisedSurface.withOpacity(isDark ? 0.4 : 0.6),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: onSurfaceVariant.withOpacity(0.2),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: onSurfaceVariant.withOpacity(0.2),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primary, width: 1.5),
          borderRadius: BorderRadius.circular(12.r),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFE53E3E)),
          borderRadius: BorderRadius.circular(12.r),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFE53E3E), width: 1.5),
          borderRadius: BorderRadius.circular(12.r),
        ),
        hintStyle: GoogleFonts.mulish(
          fontSize: 15,
          color: onSurfaceVariant,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: GoogleFonts.mulish(
          fontSize: 14,
          color: onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        errorStyle: GoogleFonts.mulish(
          fontSize: 12,
          color: const Color(0xFFE53E3E),
        ),
        prefixIconColor: onSurfaceVariant,
        suffixIconColor: onSurfaceVariant,
      ),

      // ── Buttons ──────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size(double.infinity, 54),
          textStyle: GoogleFonts.mulish(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary.withValues(alpha: 0.6)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          minimumSize: const Size(double.infinity, 54),
          textStyle: GoogleFonts.mulish(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.mulish(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      // ── FAB ──────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ── Chips ────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: raisedSurface,
        selectedColor: primary.withValues(alpha: 0.18),
        checkmarkColor: primary,
        disabledColor: onSurfaceVariant.withValues(alpha: 0.12),
        labelStyle: GoogleFonts.mulish(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: onSurface,
        ),
        secondaryLabelStyle: GoogleFonts.mulish(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        side: BorderSide(
          color: onSurfaceVariant.withValues(alpha: 0.3),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),

      // ── Tab Bar ──────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: onSurfaceVariant,
        indicatorColor: primary,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.mulish(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.mulish(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primary, width: 2.5),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
        ),
        overlayColor: WidgetStateProperty.all(
          primary.withValues(alpha: 0.08),
        ),
      ),

      // ── List Tiles ───────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        tileColor: Colors.transparent,
        selectedTileColor: primary.withValues(alpha: 0.10),
        selectedColor: primary,
        iconColor: onSurfaceVariant,
        textColor: onSurface,
        titleTextStyle: GoogleFonts.mulish(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        subtitleTextStyle: GoogleFonts.mulish(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),

      // ── Dividers ─────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: onSurfaceVariant.withValues(alpha: isDark ? 0.15 : 0.12),
        thickness: 1,
        space: 1,
      ),

      // ── Icons ────────────────────────────────────────────────────────────
      iconTheme: IconThemeData(
        color: onSurface,
        size: 24,
      ),

      // ── Switches ─────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withValues(alpha: 0.45);
          }
          return isDark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ── Checkboxes ───────────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(onPrimary),
        side: BorderSide(
          color: onSurfaceVariant.withValues(alpha: 0.6),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        overlayColor: WidgetStateProperty.all(
          primary.withValues(alpha: 0.12),
        ),
      ),

      // ── Radio ────────────────────────────────────────────────────────────
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return onSurfaceVariant;
        }),
        overlayColor: WidgetStateProperty.all(
          primary.withValues(alpha: 0.12),
        ),
      ),

      // ── Progress / Slider ────────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: primary.withValues(alpha: 0.18),
        circularTrackColor: primary.withValues(alpha: 0.18),
        linearMinHeight: 4,
        borderRadius: const BorderRadius.all(Radius.circular(99)),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: primary.withValues(alpha: 0.18),
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.18),
        valueIndicatorColor: primary,
        valueIndicatorTextStyle: GoogleFonts.mulish(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: onPrimary,
        ),
      ),

      // ── SnackBar ─────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            isDark ? const Color(0xFF1E293B) : const Color(0xFF1A202C),
        contentTextStyle: GoogleFonts.mulish(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        actionTextColor: primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        width: null,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // ── Drawer ───────────────────────────────────────────────────────────
      drawerTheme: DrawerThemeData(
        backgroundColor: raisedSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 16,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),

      // ── Tooltip ──────────────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF334155)
              : const Color(0xFF1A202C).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.mulish(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ── Popup Menu ───────────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: raisedSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.mulish(
          fontSize: 14,
          color: onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

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
