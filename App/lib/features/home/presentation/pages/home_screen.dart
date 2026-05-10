import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/widgets/custom_drawer.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../pets/presentation/pages/add_pet_screen.dart';
import '../../../pets/presentation/pages/my_pets_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../caregiver/presentation/pages/caregivers_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.menu_rounded,
            color: colorScheme.onPrimary,
            size: 24.sp,
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Row(
          children: [
            Image.asset(
              AppImages.primaryLogo,
              width: 32.w,
              height: 32.h,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.pets,
                    color: colorScheme.onPrimary,
                    size: 16.w,
                  ),
                );
              },
            ),
            SizedBox(width: 12.w),
            Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 20.sp,
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showLogoutDialog(context),
            icon: Icon(
              Icons.logout_rounded,
              color: colorScheme.onPrimary,
              size: 24.sp,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),

            // Welcome Message
            Text(
              AppStrings.welcome,
              style: TextStyle(
                fontSize: 32.sp,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              AppStrings.findYourPet,
              style: TextStyle(
                fontSize: 16.sp,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w400,
              ),
            ),

            SizedBox(height: 24.h),

            // Search Bar
            Container(
              height: 52.h,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(width: 16.w),
                  Icon(
                    Icons.search_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextField(
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search for pets...',
                        hintStyle: TextStyle(
                          fontSize: 15.sp,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                ],
              ),
            ),

            SizedBox(height: 28.h),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    context: context,
                    title: 'Add Pet',
                    icon: Icons.add_circle_outline_rounded,
                    color: colorScheme.primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddPetScreen(),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildQuickActionCard(
                    context: context,
                    title: 'My Pets',
                    icon: Icons.pets_rounded,
                    color: colorScheme.secondary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyPetsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    context: context,
                    title: 'Browse Vets',
                    icon: Icons.local_hospital_outlined,
                    color: const Color(0xFF4CAF50),
                    onTap: () => AppNavigator.navigateToVetsList(context),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildQuickActionCard(
                    context: context,
                    title: 'My Chats',
                    icon: Icons.chat_bubble_outline_rounded,
                    color: const Color(0xFF2196F3),
                    onTap: () => AppNavigator.navigateToChats(context),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    context: context,
                    title: 'Pet Shop',
                    icon: Icons.shopping_bag_outlined,
                    color: const Color(0xFF8D6E63),
                    onTap: () => AppNavigator.navigateToMarketplace(context),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildQuickActionCard(
                    context: context,
                    title: 'My Orders',
                    icon: Icons.receipt_long_outlined,
                    color: const Color(0xFF5C6BC0),
                    onTap: () => AppNavigator.navigateToOrders(context),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    context: context,
                    title: 'Community',
                    icon: Icons.groups_outlined,
                    color: const Color(0xFF2C6E69),
                    onTap: () => AppNavigator.navigateToCommunityHub(context),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildQuickActionCard(
                    context: context,
                    title: 'Pet Sitting',
                    icon: Icons.home_work_outlined,
                    color: const Color(0xFFFF6F00),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CaregiversListScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 32.h),

            // Categories
            Text(
              'Categories',
              style: TextStyle(
                fontSize: 22.sp,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),

            SizedBox(height: 14.h),

            Row(
              children: [
                Expanded(
                  child: _buildCategoryCard(
                    context,
                    'Dogs',
                    Icons.pets_rounded,
                    colorScheme.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildCategoryCard(
                    context,
                    'Cats',
                    Icons.pets_rounded,
                    colorScheme.secondary,
                  ),
                ),
              ],
            ),

            SizedBox(height: 32.h),

            // Featured Pets
            Text(
              'Featured Pets',
              style: TextStyle(
                fontSize: 22.sp,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),

            SizedBox(height: 14.h),

            _buildPetCard(
              context: context,
              name: 'Buddy',
              breed: 'Golden Retriever',
              age: '2 years old',
              image: AppImages.onboardingPage1Pet,
              accentColor: colorScheme.primary,
            ),

            SizedBox(height: 14.h),

            _buildPetCard(
              context: context,
              name: 'Whiskers',
              breed: 'Persian Cat',
              age: '1 year old',
              image: AppImages.onboardingPage2Pet,
              accentColor: colorScheme.secondary,
            ),

            SizedBox(height: 32.h),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        currentIndex: _currentIndex,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
        ),
        onTap: (index) {
          switch (index) {
            case 0:
              setState(() => _currentIndex = 0);
              break;
            case 1:
              AppNavigator.navigateToVetsList(context);
              break;
            case 2:
              AppNavigator.navigateToChats(context);
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital_outlined),
            activeIcon: Icon(Icons.local_hospital_rounded),
            label: 'Vets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            activeIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Ink(
          height: 96.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withValues(alpha: 0.72)],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.28),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 76.h,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22.sp),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetCard({
    required BuildContext context,
    required String name,
    required String breed,
    required String age,
    required String image,
    required Color accentColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 110.h,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pet Image
          Container(
            width: 90.w,
            height: double.infinity,
            margin: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: accentColor.withValues(alpha: 0.12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(
                    Icons.pets_rounded,
                    color: accentColor,
                    size: 36.sp,
                  ),
                ),
              ),
            ),
          ),

          // Pet Info
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 17.sp,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    breed,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      age,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Favourite
          Padding(
            padding: EdgeInsets.only(right: 14.w),
            child: Icon(
              Icons.favorite_outline_rounded,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 22.sp,
            ),
          ),
        ],
      ),
    );
  }

  static void _showLogoutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
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