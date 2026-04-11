import 'package:flutter/material.dart';
import 'package:pawpawl/features/auth/data/repositories/auth_repository.dart';
import 'package:pawpawl/features/home/presentation/pages/pet_owner_dashboard.dart';
import 'package:pawpawl/features/marketplace/presentation/pages/seller_dashboard_screen.dart';
import 'package:pawpawl/features/vet/presentation/pages/vet_home_screen.dart';
import 'package:pawpawl/core/di/service_locator.dart';

/// Wrapper widget that displays appropriate home screen based on user role
/// - Shows VetHomeScreen for users with 'vet' role
/// - Shows SellerDashboardScreen for users with 'seller' role
/// - Shows regular HomeScreen for 'pet_owner' role
class RoleBasedHome extends StatefulWidget {
  const RoleBasedHome({super.key});

  @override
  State<RoleBasedHome> createState() => _RoleBasedHomeState();
}

class _RoleBasedHomeState extends State<RoleBasedHome> {
  late Future<String?> _accountTypeFuture;

  @override
  void initState() {
    super.initState();
    _accountTypeFuture = _getAccountType();
  }

  Future<String?> _getAccountType() async {
    try {
      final authRepo = getIt<AuthRepository>();
      return await authRepo.getAccountType();
    } catch (e) {
      // If error fetching account type, default to pet_owner
      debugPrint('Error fetching account type: $e');
      return 'pet_owner';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _accountTypeFuture,
      builder: (context, snapshot) {
        // Show loading while fetching account type
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Check account type and show appropriate screen
        // Normalize account type (backend may return "petowner" or "pet_owner")
        final accountType = snapshot.data?.toLowerCase();

        if (accountType == 'vet') {
          return const VetHomeScreen();
        }

        if (accountType == 'seller') {
          return const SellerDashboardScreen();
        } else {
          // Default to new dashboard for pet owners or unknown roles
          return const PetOwnerDashboard();
        }
      },
    );
  }
}
