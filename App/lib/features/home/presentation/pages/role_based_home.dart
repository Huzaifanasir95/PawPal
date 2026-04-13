import 'package:flutter/material.dart';
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

  bool _isLoading = true;
  bool _isSwitchingRole = false;
  String? _activeRole;
  List<String> _roles = const [];
  String? _error;

  static const List<String> _supportedRoles = <String>[
    'pet_owner',
    'vet',
    'seller',
    'caregiver',
  ];

  @override
  void initState() {
    super.initState();
    _authRepository = context.read<AuthRepository>();
    _bootstrapRoles();
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
      final roles = await _authRepository.getUserRoles(forceRefresh: true);
      final normalizedRoles = _normalizeRoleList(
        roles,
        fallbackRole: cachedActiveRole,
      );
      final current = _normalizeAccountType(
        await _authRepository.getAccountType(),
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
        _error = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _roles = cachedRoles;
        _activeRole = cachedActiveRole;
        _error = 'Could not sync role data. Showing cached role.';
        _isLoading = false;
      });
    }
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

  String _roleLabel(String role) {
    switch (_normalizeAccountType(role)) {
      case 'vet':
        return 'Veterinary';
      case 'seller':
        return 'Seller';
      case 'caregiver':
        return 'Caregiver';
      default:
        return 'Pet Owner';
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

    return normalized;
  }

  Future<void> _switchRole(String role) async {
    final normalized = _normalizeAccountType(role);
    if (_isSwitchingRole || normalized == _activeRole) return;

    setState(() {
      _isSwitchingRole = true;
      _error = null;
    });

    try {
      await _authRepository.switchRole(normalized);
      final roles = await _authRepository.getUserRoles();
      final normalizedRoles = _normalizeRoleList(
        roles,
        fallbackRole: normalized,
      );
      final resolvedActive =
          normalizedRoles.contains(normalized)
              ? normalized
              : normalizedRoles.first;

      if (!mounted) return;
      setState(() {
        _roles = normalizedRoles;
        _activeRole = resolvedActive;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_error!)));
    } finally {
      if (mounted) {
        setState(() {
          _isSwitchingRole = false;
        });
      }
    }
  }

  Future<void> _addRole(String role) async {
    final normalized = _normalizeAccountType(role);
    if (_roles.contains(normalized)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Role already assigned')));
      return;
    }

    setState(() {
      _isSwitchingRole = true;
      _error = null;
    });

    try {
      await _authRepository.addUserRole(normalized);
      await _authRepository.switchRole(normalized);
      final roles = await _authRepository.getUserRoles();
      final normalizedRoles = _normalizeRoleList(
        roles,
        fallbackRole: normalized,
      );
      final resolvedActive =
          normalizedRoles.contains(normalized)
              ? normalized
              : normalizedRoles.first;

      if (!mounted) return;
      setState(() {
        _roles = normalizedRoles;
        _activeRole = resolvedActive;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_error!)));
    } finally {
      if (mounted) {
        setState(() {
          _isSwitchingRole = false;
        });
      }
    }
  }

  Future<void> _showAddRoleSheet() async {
    final available =
        _supportedRoles.where((role) => !_roles.contains(role)).toList();
    if (available.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All available roles are already assigned'),
        ),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text('Add Role'),
                subtitle: Text('Assign an additional role to this account'),
              ),
              ...available.map(
                (role) => ListTile(
                  leading: const Icon(Icons.person_add_alt_1_rounded),
                  title: Text(_roleLabel(role)),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _addRole(role);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboard(String role) {
    final normalized = _normalizeAccountType(role);
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
  }

  Widget _buildRoleSwitcher() {
    final active = _activeRole ?? 'pet_owner';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          child: PopupMenuButton<String>(
            enabled: !_isSwitchingRole,
            tooltip: 'Switch role',
            onSelected: (value) {
              if (value == 'add') {
                _showAddRoleSheet();
                return;
              }
              _switchRole(value);
            },
            itemBuilder: (context) {
              final items = <PopupMenuEntry<String>>[];

              for (final role in _roles) {
                items.add(
                  PopupMenuItem<String>(
                    value: role,
                    child: Row(
                      children: [
                        Icon(
                          role == active
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(_roleLabel(role)),
                      ],
                    ),
                  ),
                );
              }

              items.add(const PopupMenuDivider());
              items.add(
                const PopupMenuItem<String>(
                  value: 'add',
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline_rounded, size: 18),
                      SizedBox(width: 10),
                      Text('Add role'),
                    ],
                  ),
                ),
              );

              return items;
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD8DEE9)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isSwitchingRole)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    const Icon(Icons.swap_horiz_rounded, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    _roleLabel(active),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final activeRole = _activeRole ?? 'pet_owner';

    return Stack(
      children: [
        Positioned.fill(child: _buildDashboard(activeRole)),
        Positioned(top: 0, right: 0, child: _buildRoleSwitcher()),
        if (_error != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: SafeArea(
              child: Material(
                color: const Color(0xFFB00020),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
