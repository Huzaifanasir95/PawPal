import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../widgets/user_avatar.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/community/presentation/pages/community_page.dart';
import '../../features/chatbot/presentation/pages/chatbot_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle any state changes if needed
      },
      builder: (context, state) {
        return Drawer(
          backgroundColor: AppColors.surface,
          elevation: 16.r,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20.r),
              bottomRight: Radius.circular(20.r),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header with User Profile
                _buildUserProfileHeader(state),
                SizedBox(height: 20.h),
            
                // Menu Items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    children: [
                      // Home Section
                      _buildDrawerSection('Home'),
                      _buildDrawerItem(
                        icon: Icons.home,
                        title: 'Home',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.search,
                        title: 'Search Pets',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to search
                        },
                      ),
            
                      SizedBox(height: 20.h),
            
                      // Pets Section
                      _buildDrawerSection('Pets'),
                      _buildDrawerItem(
                        icon: Icons.pets,
                        title: 'My Pets',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to my pets
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.favorite,
                        title: 'Favorites',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to favorites
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.add_circle_outline,
                        title: 'Add Pet',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to add pet
                        },
                      ),
            
                      SizedBox(height: 20.h),
            
                      // Community Section
                      _buildDrawerSection('Community'),
                      _buildDrawerItem(
                        icon: Icons.group,
                        title: 'Community Forum',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CommunityPage(),
                            ),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.event,
                        title: 'Events',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to events
                        },
                      ),
            
                      SizedBox(height: 20.h),
            
                      // Chatbot Section
                      _buildDrawerSection('Chatbot'),
                      _buildDrawerItem(
                        icon: Icons.chat,
                        title: 'Pet Care Assistant',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChatbotScreen(),
                            ),
                          );
                        },
                      ),
            
                      SizedBox(height: 20.h),
            
                      // Account Section
                      _buildDrawerSection('Account'),
                      
                      _buildDrawerItem(
                        icon: Icons.settings,
                        title: 'Settings',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to settings
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to help
                        },
                      ),
            
                      SizedBox(height: 20.h),
            
                      // Logout
                      _buildDrawerItem(
                        icon: Icons.logout,
                        title: 'Logout',
                        onTap: () {
                          Navigator.pop(context);
                          _showLogoutDialog(context);
                        },
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserProfileHeader(AuthState state) {
    return state.when(
      initial: () => _buildGuestHeader(),
      loading: () => _buildGuestHeader(),
      authenticated: (user) => Container(
        height: 100.h,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.r),
            bottomRight: Radius.circular(20.r),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Row(
          children: [
            // User Avatar - Smaller circle on the left
            UserAvatar(
              imageUrl: user.photoURL,
              size: 50.w,
              showBorder: true,
              borderColor: AppColors.accent.withOpacity(0.2),
              borderWidth: 2.w,
            ),
            SizedBox(width: 16.w),
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // User Name
                  Text(
                    user.displayName ?? user.email.split('@')[0],
                    style: AppTextStyles.onboardingTitle.copyWith(
                      fontSize: 18.sp,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  // User Email
                  Text(
                    user.email,
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.accent.withOpacity(0.8),
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      unauthenticated: () => _buildGuestHeader(),
      error: (message) => _buildGuestHeader(),
      passwordResetSent: () => _buildGuestHeader(),
      accountTypeRequired: (idToken, displayName, photoUrl) => _buildGuestHeader(),
    );
  }

  Widget _buildGuestHeader() {
    return Container(
      height: 100.h,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25.r),
              border: Border.all(
                color: AppColors.accent.withOpacity(0.2),
                width: 2.w,
              ),
            ),
            child: Icon(
              Icons.person,
              color: AppColors.accent,
              size: 25.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Guest User',
                  style: AppTextStyles.onboardingTitle.copyWith(
                    fontSize: 18.sp,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSection(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: AppTextStyles.onboardingBody.copyWith(
          fontSize: 14.sp,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.primary,
          size: 24.sp,
        ),
        title: Text(
          title,
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 16.sp,
            color: isDestructive ? AppColors.error : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        dense: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        hoverColor: AppColors.primary.withOpacity(0.1),
        selectedTileColor: AppColors.primary.withOpacity(0.1),
      ),
    );
  }

  static void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Logout',
            style: AppTextStyles.onboardingTitle.copyWith(
              fontSize: 20.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                // Perform logout
                // context.read<AuthBloc>().add(AuthLogoutRequested());
              },
              child: Text(
                'Logout',
                style: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}