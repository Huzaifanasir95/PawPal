import 'package:flutter/material.dart';
import 'package:pawpawl/core/theme/app_theme_controller.dart';
import 'package:pawpawl/features/auth/data/repositories/auth_repository.dart';
import 'package:pawpawl/features/caregiver/presentation/pages/caregiver_home_screen.dart';
import 'package:pawpawl/features/home/presentation/pages/pet_owner_dashboard.dart';
import 'package:pawpawl/features/marketplace/presentation/pages/seller_dashboard_screen.dart';
import 'package:pawpawl/features/vet/presentation/pages/vet_home_screen.dart';
import 'package:provider/provider.dart';

class RoleBasedHome extends StatefulWidget {
  final String? initialAccountType;

  const RoleBasedHome({super.key, this.initialAccountType});

  @override
  State<RoleBasedHome> createState() => _RoleBasedHomeState();
}

class _RoleBasedHomeState extends State<RoleBasedHome> {
  late final AuthRepository _authRepository;
  final Map<String, Widget> _dashboardCache = <String, Widget>{};

  bool _isLoading = true;
  String? _activeRole;
  List<String> _roles = const [];

  @override
  void initState() {
    super.initState();
    _authRepository = context.read<AuthRepository>();
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
    final cachedActiveRole = _normalizeAccountType(
      _authRepository.activeRole ??
          _authRepository.currentUser?.accountType ??
          fallbackRole,
    );
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
        fallbackRole: cachedActiveRole,
      );
      final current = _normalizeAccountType(
        await _authRepository.getAccountType().timeout(
          const Duration(seconds: 6),
          onTimeout: () => cachedActiveRole,
        ),
      );

      final activeRole =
          normalizedRoles.contains(current)
              ? current
              : (normalizedRoles.contains(fallbackRole)
                  ? fallbackRole
                  : cachedActiveRole);

      if (!mounted) return;
      setState(() {
        _roles = normalizedRoles;
        _activeRole = activeRole;
        _isLoading = false;
      });
      _syncThemeRole(activeRole);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _roles = cachedRoles;
        _activeRole = cachedActiveRole;
        _isLoading = false;
      });
      _syncThemeRole(cachedActiveRole);
    }
  }

  void _syncThemeRole(String role) {
    context.read<AppThemeController>().setActiveRole(role);
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
        return 'pet_owner';
    }
  }

  List<String> _normalizeRoleList(
    List<String> roles, {
    required String fallbackRole,
  }) {
    final normalized = <String>[];
    for (final role in roles) {
      final value = _normalizeAccountType(role);
      if (!normalized.contains(value)) {
        normalized.add(value);
      }
    }

    if (normalized.isEmpty) {
      normalized.add(_normalizeAccountType(fallbackRole));
    }

    if (!normalized.contains('pet_owner')) {
      // Always keep pet owner eligible and discoverable in role management flows.
      normalized.add('pet_owner');
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
