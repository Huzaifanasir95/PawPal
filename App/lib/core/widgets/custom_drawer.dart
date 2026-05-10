import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_theme_controller.dart';
import '../widgets/user_avatar.dart';
import '../navigation/app_navigator.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/community/presentation/pages/community_hub_page.dart';
import '../../features/chatbot/presentation/pages/chatbot_screen.dart';
import '../../features/pets/presentation/pages/my_pets_screen.dart';
import '../../features/caregiver/presentation/pages/caregivers_list_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Drawer(
          backgroundColor: colorScheme.surface,
          elevation: 16,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────
                _buildHeader(context, state, colorScheme, isDark),

                // ── Menu Items ──────────────────────────────────────────
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 16.h),
                    children: [
                      _DrawerSection(label: 'Home'),
                      _DrawerItem(
                        icon: Icons.home_rounded,
                        title: 'Home',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                            (route) => false,
                          );
                        },
                      ),

                      SizedBox(height: 8.h),
                      _DrawerSection(label: 'Pets'),
                      _DrawerItem(
                        icon: Icons.pets_rounded,
                        title: 'My Pets',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MyPetsScreen(),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 8.h),
                      _DrawerSection(label: 'Services'),
                      _DrawerItem(
                        icon: Icons.local_hospital_rounded,
                        title: 'Find Vets',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                          AppNavigator.navigateToVetsList(context);
                        },
                      ),
                      _DrawerItem(
                        icon: Icons.storefront_rounded,
                        title: 'Marketplace',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                          AppNavigator.navigateToMarketplace(context);
                        },
                      ),
                      _DrawerItem(
                        icon: Icons.home_work_rounded,
                        title: 'Pet Sitting',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CaregiversListScreen(),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 8.h),
                      _DrawerSection(label: 'Community'),
                      _DrawerItem(
                        icon: Icons.groups_rounded,
                        title: 'Community Hub',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CommunityHubPage(),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 8.h),
                      _DrawerSection(label: 'AI Assistant'),
                      _DrawerItem(
                        icon: Icons.smart_toy_rounded,
                        title: 'Pet Care Assistant',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChatbotScreen(),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 8.h),
                      _DrawerSection(label: 'Account'),
                      _DrawerItem(
                        icon: Icons.settings_rounded,
                        title: 'Settings',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _DrawerItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & Support',
                        colorScheme: colorScheme,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Divider(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),

                      _DrawerItem(
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        colorScheme: colorScheme,
                        isDestructive: true,
                        onTap: () {
                          Navigator.pop(context);
                          _showLogoutDialog(context, colorScheme);
                        },
                      ),
                    ],
                  ),
                ),

                // ── Theme Indicator ─────────────────────────────────────
                _buildThemeFooter(context, colorScheme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AuthState state,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return state.when(
      initial: () => _buildHeaderContent(
        context: context,
        name: 'Guest',
        email: '',
        photoUrl: null,
        colorScheme: colorScheme,
        isDark: isDark,
      ),
      loading: () => _buildHeaderContent(
        context: context,
        name: 'Loading...',
        email: '',
        photoUrl: null,
        colorScheme: colorScheme,
        isDark: isDark,
      ),
      authenticated: (user) => _buildHeaderContent(
        context: context,
        name: user.displayName ?? user.email.split('@')[0],
        email: user.email,
        photoUrl: user.photoURL,
        colorScheme: colorScheme,
        isDark: isDark,
      ),
      unauthenticated: () => _buildHeaderContent(
        context: context,
        name: 'Guest',
        email: '',
        photoUrl: null,
        colorScheme: colorScheme,
        isDark: isDark,
      ),
      error: (_) => _buildHeaderContent(
        context: context,
        name: 'Guest',
        email: '',
        photoUrl: null,
        colorScheme: colorScheme,
        isDark: isDark,
      ),
      passwordResetSent: () => _buildHeaderContent(
        context: context,
        name: 'Guest',
        email: '',
        photoUrl: null,
        colorScheme: colorScheme,
        isDark: isDark,
      ),
      accountTypeRequired: (_, __, ___) => _buildHeaderContent(
        context: context,
        name: 'Guest',
        email: '',
        photoUrl: null,
        colorScheme: colorScheme,
        isDark: isDark,
      ),
    );
  }

  Widget _buildHeaderContent({
    required BuildContext context,
    required String name,
    required String email,
    required String? photoUrl,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          UserAvatar(
            imageUrl: photoUrl,
            size: 60.w,
            showBorder: true,
            borderColor: colorScheme.onPrimary.withValues(alpha: 0.4),
            borderWidth: 2.5,
          ),
          SizedBox(height: 14.h),
          // Name
          Text(
            name,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: colorScheme.onPrimary,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (email.isNotEmpty) ...[
            SizedBox(height: 3.h),
            Text(
              email,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: colorScheme.onPrimary.withValues(alpha: 0.75),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThemeFooter(BuildContext context, ColorScheme colorScheme) {
    final themeController = context.watch<AppThemeController>();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.18),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            themeController.isDarkMode
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 18.sp,
          ),
          SizedBox(width: 10.w),
          Text(
            themeController.isDarkMode ? 'Dark Mode' : 'Light Mode',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Transform.scale(
            scale: 0.85,
            child: Switch.adaptive(
              value: themeController.isDarkMode,
              onChanged: (value) => themeController.setDarkMode(value),
              activeColor: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  static void _showLogoutDialog(BuildContext context, ColorScheme colorScheme) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: 15,
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 15,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Future.microtask(() {
                  if (!context.mounted) return;
                  context.read<AuthBloc>().add(const AuthEvent.signOut());
                });
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

// ── Section Label ──────────────────────────────────────────────────────────────

class _DrawerSection extends StatelessWidget {
  final String label;
  const _DrawerSection({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 12.h, 8.w, 4.h),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w800,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

// ── Drawer Item ────────────────────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final bool isDestructive;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.colorScheme,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final fgColor = isDestructive ? colorScheme.error : colorScheme.onSurface;
    final iconColor =
        isDestructive ? colorScheme.error : colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: (isDestructive ? colorScheme.error : colorScheme.primary)
            .withValues(alpha: 0.10),
        highlightColor: (isDestructive
                ? colorScheme.error
                : colorScheme.primary)
            .withValues(alpha: 0.06),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20.sp),
              SizedBox(width: 14.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}