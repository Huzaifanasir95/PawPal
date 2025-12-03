import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/widgets/custom_drawer.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../pets/presentation/pages/add_pet_screen.dart';
import '../../../pets/presentation/pages/my_pets_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';

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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.authBackground,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: AppColors.accent,
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
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.pets,
                    color: AppColors.primary,
                    size: 16.w,
                  ),
                );
              },
            ),
            SizedBox(width: 12.w),
            Text(
              AppStrings.appName,
              style: AppTextStyles.onboardingTitle.copyWith(
                fontSize: 20.sp,
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Show logout confirmation dialog
              _showLogoutDialog(context);
            },
            icon: Icon(
              Icons.logout,
              color: AppColors.accent,
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
              style: AppTextStyles.onboardingTitle.copyWith(
                fontSize: 32.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            
            SizedBox(height: 8.h),
            
            Text(
              AppStrings.findYourPet,
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 18.sp,
                color: AppColors.textSecondary,
              ),
            ),
            
            SizedBox(height: 30.h),
            
            // Search Bar
            Container(
              height: 56.h,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(28.r),
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(width: 20.w),
                  Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextField(
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 16.sp,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search for pets...',
                        hintStyle: AppTextStyles.onboardingBody.copyWith(
                          fontSize: 16.sp,
                          color: AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.w),
                ],
              ),
            ),
            
            SizedBox(height: 30.h),
            
            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    title: 'Add Pet',
                    icon: Icons.add_circle_outline,
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddPetScreen(),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildQuickActionCard(
                    title: 'My Pets',
                    icon: Icons.pets,
                    color: AppColors.accent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyPetsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 30.h),
            
            // Categories
            Text(
              'Categories',
              style: AppTextStyles.onboardingTitle.copyWith(
                fontSize: 24.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            Row(
              children: [
                Expanded(child: _buildCategoryCard('Dogs', Icons.pets, AppColors.primary)),
                SizedBox(width: 12.w),
                Expanded(child: _buildCategoryCard('Cats', Icons.pets, AppColors.accent)),
              ],
            ),
            
            SizedBox(height: 30.h),
            
            // Featured Pets
            Text(
              'Featured Pets',
              style: AppTextStyles.onboardingTitle.copyWith(
                fontSize: 24.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Pet Cards
            _buildPetCard(
              name: 'Buddy',
              breed: 'Golden Retriever',
              age: '2 years old',
              image: AppImages.onboardingPage1Pet,
              gradient: const LinearGradient(
                begin: Alignment(-0.707, -0.707),
                end: Alignment(0.707, 0.707),
                colors: [
                  Color(0xFFE0CEBB),
                  Color(0x00C2B1B0),
                ],
              ),
            ),
            
            SizedBox(height: 16.h),
            
            _buildPetCard(
              name: 'Whiskers',
              breed: 'Persian Cat',
              age: '1 year old',
              image: AppImages.onboardingPage2Pet,
              gradient: const LinearGradient(
                begin: Alignment(-0.707, -0.707),
                end: Alignment(0.707, 0.707),
                colors: [
                  Color(0xFFAFDCD7),
                  Color(0x00C2B1B0),
                ],
              ),
            ),
            
            SizedBox(height: 30.h),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 3) { // Profile tab
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              color.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 12.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetCard({
    required String name,
    required String breed,
    required String age,
    required String image,
    LinearGradient? gradient,
  }) {
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? AppColors.surface : null,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pet Image
          Container(
            width: 100.w,
            height: 100.h,
            margin: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: AppColors.surfaceContainer,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.surfaceContainer,
                    child: Icon(
                      Icons.pets,
                      color: AppColors.primary,
                      size: 40.sp,
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Pet Info
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.onboardingTitle.copyWith(
                      fontSize: 18.sp,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    breed,
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    age,
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Favorite Button
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Icon(
              Icons.favorite_outline,
              color: AppColors.primary,
              size: 24.sp,
            ),
          ),
        ],
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
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Trigger logout event
                context.read<AuthBloc>().add(const AuthEvent.signOut());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Logout',
                style: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}