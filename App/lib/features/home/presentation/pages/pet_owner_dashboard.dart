import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/widgets/custom_drawer.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../chat/data/repositories/chat_repository.dart';
import '../../../pets/data/repositories/pet_repository.dart';
import '../../../pets/data/models/pet_model.dart';
import '../../../pets/presentation/pages/add_pet_screen.dart';
import '../../../pets/presentation/pages/my_pets_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../chatbot/presentation/pages/chatbot_screen.dart';

class PetOwnerDashboard extends StatefulWidget {
  const PetOwnerDashboard({super.key});

  @override
  State<PetOwnerDashboard> createState() => _PetOwnerDashboardState();
}

class _PetOwnerDashboardState extends State<PetOwnerDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PetRepository _petRepository = PetRepository();
  
  int _currentIndex = 0;
  String _userName = '';
  String? _userPhoto;
  
  // Real data
  int _unreadMessages = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final chatRepo = getIt<ChatRepository>();
      final chats = await chatRepo.getMyChats();
      
      int unread = 0;
      for (var chat in chats) {
        unread += chat.unreadCountOwner;
      }

      if (mounted) {
        setState(() {
          _unreadMessages = unread;
        });
      }
    } catch (e) {
      // Silently handle chat loading errors
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'Pet Parent';
    return fullName.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        state.maybeWhen(
          authenticated: (user) {
            _userName = user.displayName ?? '';
            _userPhoto = user.photoUrl;
          },
          orElse: () {},
        );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: const Color(0xFFF5F7FA),
            drawer: const CustomDrawer(),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadData,
                color: AppColors.primary,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader()),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 120.h),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildPetCard(),
                          SizedBox(height: 24.h),
                          _buildSectionTitle('Quick Actions'),
                          SizedBox(height: 16.h),
                          _buildQuickActions(),
                          SizedBox(height: 28.h),
                          _buildSectionTitle('Explore'),
                          SizedBox(height: 16.h),
                          _buildExploreCards(),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: _buildBottomNav(),
            floatingActionButton: _buildMessagesFAB(),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.menu_rounded,
                color: AppColors.textPrimary,
                size: 22.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _getFirstName(_userName),
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14.r),
                image: _userPhoto != null
                    ? DecorationImage(
                        image: NetworkImage(_userPhoto!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _userPhoto == null
                  ? Center(
                      child: Text(
                        _getFirstName(_userName).isNotEmpty
                            ? _getFirstName(_userName)[0].toUpperCase()
                            : 'P',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetCard() {
    return StreamBuilder<List<PetModel>>(
      stream: _petRepository.getUserPets(),
      builder: (context, snapshot) {
        final pets = snapshot.data ?? [];
        final petCount = pets.length;

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyPetsScreen()),
          ),
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2C6E69), Color(0xFF1A4F4A)],
              ),
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 64.w,
                  height: 64.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    Icons.pets_rounded,
                    color: Colors.white,
                    size: 32.sp,
                  ),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Pets',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$petCount',
                            style: TextStyle(
                              fontSize: 36.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Padding(
                            padding: EdgeInsets.only(bottom: 4.h),
                            child: Text(
                              petCount == 1 ? 'Pet' : 'Pets',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44.w,
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 22.sp,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _buildActionTile(
          icon: Icons.add_rounded,
          label: 'Add Pet',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPetScreen()),
          ),
        ),
        SizedBox(width: 12.w),
        _buildActionTile(
          icon: Icons.medical_services_outlined,
          label: 'Find Vet',
          onTap: () => AppNavigator.navigateToVetsList(context),
        ),
        SizedBox(width: 12.w),
        _buildActionTile(
          icon: Icons.smart_toy_outlined,
          label: 'AI Chat',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatbotScreen()),
          ),
        ),
        SizedBox(width: 12.w),
        _buildActionTile(
          icon: Icons.shopping_bag_outlined,
          label: 'Shop',
          onTap: () => AppNavigator.navigateToMarketplace(context),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 44.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExploreCards() {
    return Column(
      children: [
        _buildExploreCard(
          icon: Icons.groups_rounded,
          title: 'Community Hub',
          subtitle: 'Connect with other pet parents',
          color: const Color(0xFF6366F1),
          onTap: () => AppNavigator.navigateToCommunityHub(context),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildSmallExploreCard(
                icon: Icons.event_rounded,
                title: 'Events',
                color: const Color(0xFFEC4899),
                onTap: () => AppNavigator.navigateToCommunityHub(context),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildSmallExploreCard(
                icon: Icons.favorite_rounded,
                title: 'Adoption',
                color: const Color(0xFFF59E0B),
                onTap: () => AppNavigator.navigateToCommunityHub(context),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _buildExploreCard(
          icon: Icons.search_rounded,
          title: 'Lost & Found',
          subtitle: 'Help reunite pets with families',
          color: const Color(0xFF10B981),
          onTap: () => AppNavigator.navigateToCommunityHub(context),
        ),
      ],
    );
  }

  Widget _buildExploreCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52.w,
              height: 52.h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: color, size: 26.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallExploreCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, 'Home', 0),
              _buildNavItem(Icons.local_hospital_rounded, 'Vets', 1),
              _buildNavItem(Icons.pets_rounded, 'Pets', 2),
              _buildNavItem(Icons.person_rounded, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        switch (index) {
          case 1:
            AppNavigator.navigateToVetsList(context);
            break;
          case 2:
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MyPetsScreen()));
            break;
          case 3:
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()));
            break;
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            size: 26.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesFAB() {
    return GestureDetector(
      onTap: () => AppNavigator.navigateToChats(context),
      child: Container(
        width: 56.w,
        height: 56.h,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Icon(
                Icons.chat_bubble_rounded,
                color: Colors.white,
                size: 26.sp,
              ),
            ),
            if (_unreadMessages > 0)
              Positioned(
                top: -2.h,
                right: -2.w,
                child: Container(
                  width: 20.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      _unreadMessages > 9 ? '9+' : '$_unreadMessages',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
