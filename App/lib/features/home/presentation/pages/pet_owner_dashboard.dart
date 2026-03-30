import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../chatbot/presentation/pages/chatbot_screen.dart';
import '../../../home/presentation/pages/all_categories_page.dart';
import '../../../marketplace/data/repositories/marketplace_repository.dart';
import '../../../pets/presentation/pages/add_pet_screen.dart';
import '../../../pets/presentation/pages/pet_identification_scan_screen.dart';
import '../../../pets/presentation/pages/my_pets_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';

class PetOwnerDashboard extends StatefulWidget {
  const PetOwnerDashboard({super.key});

  @override
  State<PetOwnerDashboard> createState() => _PetOwnerDashboardState();
}

class _PetOwnerDashboardState extends State<PetOwnerDashboard> {
  int _currentIndex = 0;
  String _userName = '';
  final ScrollController _categoryScrollController = ScrollController();
  Timer? _categoryAutoScrollTimer;
  bool _isCategoryTouching = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCategoryAutoScroll();
    });
  }

  @override
  void dispose() {
    _categoryAutoScrollTimer?.cancel();
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _startCategoryAutoScroll() {
    _categoryAutoScrollTimer?.cancel();
    _categoryAutoScrollTimer = Timer.periodic(const Duration(milliseconds: 28),
        (_) {
      if (!mounted ||
          !_categoryScrollController.hasClients ||
          _isCategoryTouching) {
        return;
      }

      final position = _categoryScrollController.position;
      final nextOffset = _categoryScrollController.offset + 0.7;
      final loopPoint = position.maxScrollExtent / 2;

      if (loopPoint > 0 && nextOffset >= loopPoint) {
        _categoryScrollController.jumpTo(nextOffset - loopPoint);
      } else {
        _categoryScrollController.jumpTo(nextOffset);
      }
    });
  }

  Future<void> _loadData() async {
    // Reserved for future dashboard refresh hooks.
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
          authenticated: (user) => _userName = user.displayName ?? '',
          orElse: () {},
        );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFFECEFF3),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadData,
                color: AppColors.primary,
                child: ListView(
                  padding: EdgeInsets.zero,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    _buildTopHero(),
                    Transform.translate(
                      offset: Offset(0, -28.h),
                      child: _buildContentSheet(),
                    ),
                    SizedBox(height: 96.h),
                  ],
                ),
              ),
            ),
            floatingActionButton: _buildCenterFab(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: _buildBottomBar(),
          ),
        );
      },
    );
  }

  Widget _buildTopHero() {
    return Container(
      height: 300.h,
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 36.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF4E9F9A),
            const Color(0xFF2F6E72),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 42.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello ${_getFirstName(_userName)}!',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      width: 198.w,
                      child: Text(
                        '${_getGreeting()}. Keep your pets healthy, happy, and safe.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.35,
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              AppNavigator.navigateToMarketplace(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 9.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(18.r),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.42),
                              ),
                            ),
                            child: Text(
                              'Explore App',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddPetScreen(),
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 9.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                            child: Text(
                              'Add Pet',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                width: 118.w,
                height: 134.h,
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: const Color(0xFFDDE2E7)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: const _InteractivePixelCatWidget(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentSheet() {
    final categories = <_CategoryItem>[
      _CategoryItem('Community', Icons.groups_rounded, () {
        AppNavigator.navigateToCommunityHub(context);
      }),
      _CategoryItem('Lost & Found', Icons.pets_rounded, () {
        AppNavigator.navigateToCommunityHub(context);
      }),
      _CategoryItem('AI Chatbot', Icons.smart_toy_outlined, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatbotScreen()),
        );
      }),
      _CategoryItem('Marketplace', Icons.storefront_rounded, () {
        AppNavigator.navigateToMarketplace(context);
      }),
      _CategoryItem('Adoption', Icons.volunteer_activism_rounded, () {
        AppNavigator.navigateToCommunityHub(context);
      }),
      _CategoryItem('Events', Icons.event_available_rounded, () {
        AppNavigator.navigateToCommunityHub(context);
      }),
      _CategoryItem('Diet Plans', Icons.restaurant_menu_rounded, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatbotScreen()),
        );
      }),
      _CategoryItem('Pet Journals', Icons.edit_note_rounded, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyPetsScreen()),
        );
      }),
    ];
    final loopedCategories = [...categories, ...categories];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFDCE5EB),
            Color(0xFFD5E0E7),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPromoCard(),
            SizedBox(height: 12.h),
            Row(
              children: [
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 25.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllCategoriesPage(),
                    ),
                  ),
                  child: Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            SizedBox(
              height: 102.h,
              child: Listener(
                onPointerDown: (_) => _isCategoryTouching = true,
                onPointerUp: (_) => _isCategoryTouching = false,
                onPointerCancel: (_) => _isCategoryTouching = false,
                child: ListView.separated(
                  controller: _categoryScrollController,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: loopedCategories.length,
                  separatorBuilder: (_, __) => SizedBox(width: 12.w),
                  itemBuilder: (context, index) =>
                      _buildCategoryChip(
                        loopedCategories[index % categories.length],
                      ),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'Most Popular',
              style: TextStyle(
                fontSize: 24.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 12.h),
            _buildMostPopularCard(
              title: 'Book a Vet Consultation',
              subtitle: 'Chat with verified vets in minutes',
              icon: Icons.local_hospital_outlined,
              onTap: () => AppNavigator.navigateToVetsList(context),
            ),
            SizedBox(height: 10.h),
            _buildMostPopularCard(
              title: 'Manage Your Pets',
              subtitle: 'Update profiles, records, and reminders',
              icon: Icons.pets_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyPetsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCard() {
    return Container(
      height: 158.h,
      transform: Matrix4.translationValues(0, -1.5, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF1F6F8),
            const Color(0xFFDDE9EE),
          ],
        ),
        border: Border.all(color: const Color(0xFFB9CBD4), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 18,
            spreadRadius: 0.5,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius:
                  BorderRadius.horizontal(left: Radius.circular(18.r)),
              child: Container(
                color: AppColors.primary.withOpacity(0.14),
                child: Center(
                  child: const _PromoShopPreviewWidget(),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PET CARE WEEK',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Save on food, toys & grooming.',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  GestureDetector(
                    onTap: () => AppNavigator.navigateToMarketplace(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Text(
                        'Shop Now',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(_CategoryItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: SizedBox(
        width: 90.w,
        child: Column(
          children: [
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Icon(item.icon, size: 27.sp, color: AppColors.primary),
            ),
            SizedBox(height: 8.h),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5.sp,
                height: 1.15,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMostPopularCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 22.sp, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 8,
      child: SizedBox(
        height: 70.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_rounded, 'Home', 0),
            _buildNavItem(Icons.pets_rounded, 'Add Pet', 1),
            SizedBox(width: 44.w),
            _buildNavItem(Icons.chat_bubble_outline_rounded, 'Messages', 2),
            _buildNavItem(Icons.person_outline_rounded, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final selected = _currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _currentIndex = index);
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPetScreen()),
          );
        } else if (index == 2) {
          AppNavigator.navigateToChats(context);
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22.sp,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterFab() {
    return FloatingActionButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PetIdentificationScanScreen()),
      ),
      backgroundColor: AppColors.primary,
      elevation: 4,
      tooltip: 'Pet Identification',
      child: Icon(
        Icons.document_scanner_rounded,
        color: Colors.white,
        size: 28.sp,
      ),
    );
  }
}

class _InteractivePixelCatWidget extends StatefulWidget {
  const _InteractivePixelCatWidget();

  @override
  State<_InteractivePixelCatWidget> createState() =>
      _InteractivePixelCatWidgetState();
}

class _InteractivePixelCatWidgetState extends State<_InteractivePixelCatWidget> {
  int _spriteIndex = 0;
  Timer? _runTimer;

  static const List<List<String>> _sprites = [
    // Frame 1: front legs forward, back legs back
    [
      '..................',
      '..................',
      '.KK.KK............',
      '.KKKKK............',
      'K.KKKK............',
      'KKKKKKKKKKKKKK....',
      '.KKKKKKKKKKKKKK...',
      '..KKKKKKKKKKKKK...',
      '..KKKKKKKKKKKKKK..',
      '..KK...KK....KKK..',
      '.K.....K......KK..',
      'K......K..........',
      '..................',
      '..................',
    ],
    // Frame 2: legs crossing mid-stride
    [
      '..................',
      '..................',
      '.KK.KK............',
      '.KKKKK............',
      'K.KKKK............',
      'KKKKKKKKKKKKKK....',
      '.KKKKKKKKKKKKKK...',
      '..KKKKKKKKKKKKK...',
      '..KKKKKKKKKKKKKK..',
      '...KK..KK.....KK..',
      '....KK..KK....KK..',
      '..................',
      '..................',
      '..................',
    ],
    // Frame 3: front legs back, back legs forward
    [
      '..................',
      '..................',
      '.KK.KK............',
      '.KKKKK............',
      'K.KKKK............',
      'KKKKKKKKKKKKKK....',
      '.KKKKKKKKKKKKKK...',
      '..KKKKKKKKKKKKK...',
      '..KKKKKKKKKKKKKK..',
      '...KK...KK....KKK.',
      '....K....K.....KK.',
      '....K....K........',
      '..................',
      '..................',
    ],
    // Frame 4: legs together (bounce)
    [
      '..................',
      '.KK.KK............',
      '.KKKKK............',
      'K.KKKK............',
      'KKKKKKKKKKKKKK....',
      '.KKKKKKKKKKKKKK...',
      '..KKKKKKKKKKKKK...',
      '..KKKKKKKKKKKKKK..',
      '...KKKKKKKKKKKKK..',
      '....KK..KK....KK..',
      '....KK..KK....KK..',
      '..................',
      '..................',
      '..................',
    ],
  ];

  @override
  void initState() {
    super.initState();
    _runTimer = Timer.periodic(const Duration(milliseconds: 140), (_) {
      if (!mounted) return;
      setState(() {
        _spriteIndex = (_spriteIndex + 1) % _sprites.length;
      });
    });
  }

  @override
  void dispose() {
    _runTimer?.cancel();
    super.dispose();
  }

  Color? _pixelColor(String value) {
    switch (value) {
      case 'K':
        return const Color(0xFF121212);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sprite = _sprites[_spriteIndex];

    return Container(
      color: Colors.white,
      child: Center(
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          offset: _spriteIndex.isEven
              ? const Offset(-0.03, 0)
              : const Offset(0.03, 0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 100),
            switchInCurve: Curves.linear,
            switchOutCurve: Curves.linear,
            child: _PixelSprite(
              key: ValueKey<int>(_spriteIndex),
              sprite: sprite,
              pixelColor: _pixelColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _PromoShopPreviewWidget extends StatefulWidget {
  const _PromoShopPreviewWidget();

  @override
  State<_PromoShopPreviewWidget> createState() =>
      _PromoShopPreviewWidgetState();
}

class _PromoShopPreviewWidgetState extends State<_PromoShopPreviewWidget> {
  final MarketplaceRepository _marketplaceRepository =
      MarketplaceRepository.instance;
  final List<String> _imageUrls = [];
  Timer? _rotationTimer;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadShopImages();
  }

  Future<void> _loadShopImages() async {
    try {
      final products = await _marketplaceRepository.getProducts(limit: 10);
      final urls = products
          .map((product) => product.firstImage)
          .where((url) => url.trim().isNotEmpty)
          .toSet()
          .toList();

      if (!mounted) return;

      setState(() {
        _imageUrls
          ..clear()
          ..addAll(urls);
      });

      _startRotation();
    } catch (_) {
      // Keep fallback icon if loading marketplace previews fails.
    }
  }

  void _startRotation() {
    _rotationTimer?.cancel();
    if (_imageUrls.length < 2) return;

    _rotationTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (!mounted) return;
      setState(() {
        _activeIndex = (_activeIndex + 1) % _imageUrls.length;
      });
    });
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_imageUrls.isEmpty) {
      return Icon(
        Icons.pets_rounded,
        size: 72.sp,
        color: AppColors.primary,
      );
    }

    final imageUrl = _imageUrls[_activeIndex];

    return Padding(
      padding: EdgeInsets.all(8.w),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: ClipRRect(
          key: ValueKey<String>(imageUrl),
          borderRadius: BorderRadius.circular(14.r),
          child: SizedBox.expand(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  color: Colors.white.withOpacity(0.6),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.textSecondary,
                    size: 30.sp,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PixelSprite extends StatelessWidget {
  const _PixelSprite({
    super.key,
    required this.sprite,
    required this.pixelColor,
  });

  final List<String> sprite;
  final Color? Function(String) pixelColor;

  @override
  Widget build(BuildContext context) {
    final rows = sprite.length;
    final columns = sprite.first.length;
    const pixel = 4.2;

    return SizedBox(
      width: columns * pixel,
      height: rows * pixel,
      child: GridView.builder(
        padding: EdgeInsets.zero,
        itemCount: rows * columns,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
        ),
        itemBuilder: (context, index) {
          final x = index % columns;
          final y = index ~/ columns;
          final pixelValue = sprite[y][x];

          return Container(
            margin: const EdgeInsets.all(0.35),
            decoration: BoxDecoration(
              color: pixelColor(pixelValue),
              borderRadius: BorderRadius.circular(0.8),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  _CategoryItem(this.title, this.icon, this.onTap);
}
