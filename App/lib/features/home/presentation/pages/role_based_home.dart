import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pawpal/core/theme/app_theme_controller.dart';
import 'package:pawpal/features/auth/data/models/auth_user.dart';
import 'package:pawpal/features/auth/data/repositories/auth_repository.dart';
import 'package:pawpal/features/caregiver/presentation/pages/caregiver_home_screen.dart';
import 'package:pawpal/features/home/presentation/pages/pet_owner_dashboard.dart';
import 'package:pawpal/features/marketplace/presentation/pages/seller_dashboard_screen.dart';
import 'package:pawpal/features/vet/presentation/pages/vet_home_screen.dart';
import 'package:provider/provider.dart';

class RoleBasedHome extends StatefulWidget {
  final String? initialAccountType;

  const RoleBasedHome({super.key, this.initialAccountType});

  @override
  State<RoleBasedHome> createState() => _RoleBasedHomeState();
}

class _RoleBasedHomeState extends State<RoleBasedHome> {
  late final AuthRepository _authRepository;
  late final StreamSubscription<AuthUser?> _authSubscription;
  final Map<String, Widget> _dashboardCache = <String, Widget>{};

  bool _isLoading = true;
  String? _activeRole;
  List<String> _roles = const [];

  @override
  void initState() {
    super.initState();
    _authRepository = context.read<AuthRepository>();
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      if (!mounted) return;
      final normalized = _normalizeAccountType(
        user?.accountType ?? _authRepository.activeRole,
      );
      if (normalized.isNotEmpty && normalized != _activeRole) {
        _bootstrapRoles();
      }
    });
    _bootstrapRoles();
  }

  @override
  void didUpdateWidget(covariant RoleBasedHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialAccountType != widget.initialAccountType) {
      _bootstrapRoles();
    }
  }

  Future<void> _bootstrapRoles() async {
    final fallbackRole = _normalizeAccountType(widget.initialAccountType);
    final preferredFallback = fallbackRole.isNotEmpty ? fallbackRole : null;
    final cachedActiveCandidate = _normalizeAccountType(
      _authRepository.activeRole ?? _authRepository.currentUser?.accountType,
    );
    final cachedActiveRole =
        cachedActiveCandidate.isNotEmpty ? cachedActiveCandidate : null;
    final cachedRoles = _normalizeRoleList(
      _authRepository.assignedRoles,
      fallbackRole: cachedActiveRole,
    );

    try {
      final roles = await _authRepository
          .getUserRoles(forceRefresh: true)
          .timeout(const Duration(seconds: 6));
      final normalizedRoles = _normalizeRoleList(
        roles,
        fallbackRole: cachedActiveRole ?? preferredFallback,
      );
      final currentCandidate = _normalizeAccountType(
        await _authRepository.getAccountType().timeout(
          const Duration(seconds: 6),
          onTimeout: () => cachedActiveRole,
        ),
      );
      final current = currentCandidate.isNotEmpty ? currentCandidate : null;

      final activeRole =
          (current != null && normalizedRoles.contains(current))
              ? current
              : (preferredFallback != null &&
                  normalizedRoles.contains(preferredFallback)
              ? preferredFallback
              : (cachedActiveRole != null &&
                      normalizedRoles.contains(cachedActiveRole)
                  ? cachedActiveRole
                  : (normalizedRoles.isNotEmpty
                      ? normalizedRoles.first
                      : (current ??
                          preferredFallback ??
                          cachedActiveRole ??
                          'pet_owner'))));

      final roleOrder =
          normalizedRoles.isNotEmpty ? normalizedRoles : <String>[activeRole];

      if (!mounted) return;
      setState(() {
        _roles = roleOrder;
        _activeRole = activeRole;
        _isLoading = false;
      });
      _syncThemeRole(activeRole);
    } catch (e) {
      final fallbackActive =
          cachedActiveRole ??
          (cachedRoles.isNotEmpty ? cachedRoles.first : 'pet_owner');
      if (!mounted) return;
      setState(() {
        _roles = cachedRoles.isNotEmpty ? cachedRoles : <String>[fallbackActive];
        _activeRole = fallbackActive;
        _isLoading = false;
      });
      _syncThemeRole(fallbackActive);
    }
  }

  void _syncThemeRole(String role) {
    context.read<AppThemeController>().setActiveRole(role);
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  String _normalizeAccountType(String? rawAccountType) {
    final accountType = rawAccountType?.trim().toLowerCase() ?? '';
    switch (accountType) {
      case 'vet':
      case 'veterinarian':
      case 'veterinary':
        return 'vet';
      case 'seller':
      case 'vendor':
      case 'merchant':
      case 'shop_owner':
      case 'shop owner':
      case 'shopowner':
        return 'seller';
      case 'pet_owner':
      case 'petowner':
      case 'pet-owner':
      case 'pet owner':
      case 'owner':
        return 'pet_owner';
      case 'caregiver':
      case 'care_giver':
      case 'pet_caregiver':
        return 'caregiver';
      case 'admin':
        return 'admin';
      default:
        return '';
    }
  }

  List<String> _normalizeRoleList(
    List<String> roles, {
    String? fallbackRole,
  }) {
    final normalized = <String>[];
    for (final role in roles) {
      final value = _normalizeAccountType(role);
      if (value.isNotEmpty && !normalized.contains(value)) {
        normalized.add(value);
      }
    }

    if (normalized.isEmpty) {
      final fallbackValue = _normalizeAccountType(fallbackRole);
      if (fallbackValue.isNotEmpty) {
        normalized.add(fallbackValue);
      }
    }

    return normalized;
  }

  Widget _buildDashboard(String role) {
    final normalized = _normalizeAccountType(role);
    return _dashboardCache.putIfAbsent(normalized, () {
      if (normalized == 'vet') {
        return const VetHomeScreen();
      }
      if (normalized == 'seller') {
        return const SellerDashboardScreen();
      }
      if (normalized == 'caregiver') {
        return const CaregiverHomeScreen();
      }
      return const PetOwnerDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final activeRole = _activeRole ?? 'pet_owner';
    final roleOrder = _normalizeRoleList(_roles, fallbackRole: activeRole);
    final activeIndex = roleOrder.indexOf(activeRole);

    return IndexedStack(
      index: activeIndex < 0 ? 0 : activeIndex,
      children: roleOrder.map(_buildDashboard).toList(),
    );
  }
}
