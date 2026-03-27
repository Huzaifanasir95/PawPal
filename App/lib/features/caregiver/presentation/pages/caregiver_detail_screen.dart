import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/repositories/caregiver_repository.dart';
import '../../data/models/caregiver_models.dart';
import '../../data/models/booking_models.dart';
import 'create_booking_screen.dart';

class CaregiverDetailScreen extends StatefulWidget {
  final String caregiverId;

  const CaregiverDetailScreen({
    super.key,
    required this.caregiverId,
  });

  @override
  State<CaregiverDetailScreen> createState() => _CaregiverDetailScreenState();
}

class _CaregiverDetailScreenState extends State<CaregiverDetailScreen>
    with SingleTickerProviderStateMixin {
  late CaregiverRepository _repository;
  late TabController _tabController;

  CaregiverProfile? _caregiver;
  List<CaregiverService> _services = [];
  List<CaregiverAvailability> _availability = [];
  List<CaregiverGalleryItem> _gallery = [];
  List<ServiceReview> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = getIt<CaregiverRepository>();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _repository.getCaregiverById(widget.caregiverId),
        _repository.getCaregiverReviews(widget.caregiverId),
      ]);

      final caregiverData = results[0] as ({
        CaregiverProfile profile,
        List<CaregiverService> services,
        List<CaregiverAvailability>? availability,
        List<CaregiverGalleryItem>? gallery,
        List<CaregiverBlockedDate>? blockedDates,
      });
      final reviewsData = results[1] as ({
        List<ServiceReview> reviews,
        int total,
        int page,
        int limit,
      });

      setState(() {
        _caregiver = caregiverData.profile;
        _services = caregiverData.services;
        _availability = caregiverData.availability ?? [];
        _gallery = caregiverData.gallery ?? [];
        _reviews = reviewsData.reviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        CustomSnackbar.showError(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _caregiver == null
              ? const Center(child: Text('Caregiver not found'))
              : NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      _buildSliverAppBar(),
                      _buildProfileHeader(),
                      SliverToBoxAdapter(
                        child: TabBar(
                          controller: _tabController,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.textSecondary,
                          indicatorColor: AppColors.primary,
                          tabs: const [
                            Tab(text: 'About'),
                            Tab(text: 'Services'),
                            Tab(text: 'Gallery'),
                            Tab(text: 'Reviews'),
                          ],
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAboutTab(),
                      _buildServicesTab(),
                      _buildGalleryTab(),
                      _buildReviewsTab(),
                    ],
                  ),
                ),
      bottomNavigationBar: _caregiver != null ? _buildBookButton() : null,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.h,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _caregiver!.userAvatar != null
            ? Image.network(
                _caregiver!.userAvatar!,
                fit: BoxFit.cover,
              )
            : Container(
                color: AppColors.primary.withOpacity(0.3),
                child: Center(
                  child: Text(
                    (_caregiver!.userName ?? 'C')[0].toUpperCase(),
                    style: AppTextStyles.displayLarge.copyWith(
                      color: Colors.white,
                      fontSize: 72.sp,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  SliverToBoxAdapter _buildProfileHeader() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.05),
              AppColors.background,
            ],
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                _caregiver!.userName ?? 'Caregiver',
                                style: AppTextStyles.headlineLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 28.sp,
                                ),
                              ),
                            ),
                            if (_caregiver!.isVerified) ...[
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.verified,
                                  color: Colors.blue,
                                  size: 20.w,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (_caregiver!.headline != null) ...[
                          SizedBox(height: 6.h),
                          Text(
                            _caregiver!.headline!,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      Icons.star_rounded,
                      Colors.amber,
                      _caregiver!.averageRating.toStringAsFixed(1),
                      '${_caregiver!.totalReviews} reviews',
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatCard(
                      Icons.check_circle_rounded,
                      Colors.green,
                      '${_caregiver!.totalBookings}',
                      'bookings',
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatCard(
                      Icons.location_on_rounded,
                      const Color(0xFFE91E63),
                      _caregiver!.city ?? '-',
                      'location',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: [
                  if (_caregiver!.acceptedPetTypes.contains('dog'))
                    _buildPetChip('🐕 Dogs', const Color(0xFF2196F3)),
                  if (_caregiver!.acceptedPetTypes.contains('cat'))
                    _buildPetChip('🐈 Cats', const Color(0xFF9C27B0)),
                  if (_caregiver!.acceptedPetTypes.any((t) => t != 'dog' && t != 'cat'))
                    _buildPetChip('🐾 Other', const Color(0xFF4CAF50)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, Color color, String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20.w),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPetChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAboutTab() {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        _buildSection(
          'About Me',
          _caregiver!.bio ?? 'No bio provided.',
        ),
        SizedBox(height: 16.h),
        _buildSection(
          'Experience',
          '${_caregiver!.yearsOfExperience} years of experience with pets',
        ),
        SizedBox(height: 16.h),
        _buildHomeEnvironment(),
        SizedBox(height: 16.h),
        _buildAvailabilitySection(),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 20.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeEnvironment() {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 20.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Home Environment',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildEnvironmentRow(
            Icons.yard_rounded,
            'Fenced Yard',
            _caregiver!.hasFencedYard,
            const Color(0xFF4CAF50),
          ),
          _buildEnvironmentRow(
            Icons.directions_car_rounded,
            'Own Transport',
            _caregiver!.hasOwnTransport,
            const Color(0xFF2196F3),
          ),
          _buildEnvironmentRow(
            Icons.pets_rounded,
            'Has Pets',
            _caregiver!.hasOtherPets,
            const Color(0xFFFF9800),
          ),
          _buildEnvironmentRow(
            Icons.child_care_rounded,
            'Children at Home',
            _caregiver!.hasChildren,
            const Color(0xFF9C27B0),
          ),
          _buildEnvironmentRow(
            Icons.smoke_free_rounded,
            'Smoke-Free Home',
            _caregiver!.smokeFreeHome,
            const Color(0xFF00BCD4),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentRow(IconData icon, String label, bool value, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 20.w, color: color),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: value
                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                  : AppColors.textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: value
                    ? const Color(0xFF4CAF50).withOpacity(0.3)
                    : AppColors.textSecondary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  value ? Icons.check_circle : Icons.cancel,
                  size: 16.w,
                  color: value ? const Color(0xFF4CAF50) : AppColors.textSecondary,
                ),
                SizedBox(width: 4.w),
                Text(
                  value ? 'Yes' : 'No',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: value ? const Color(0xFF4CAF50) : AppColors.textSecondary,
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

  Widget _buildAvailabilitySection() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 20.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Availability',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.asMap().entries.map((entry) {
              final dayAvailability = _availability.where(
                (a) => a.dayOfWeek == entry.key && a.isAvailable,
              );
              final isAvailable = dayAvailability.isNotEmpty;
              
              return Container(
                width: 42.w,
                height: 42.h,
                decoration: BoxDecoration(
                  gradient: isAvailable
                      ? LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isAvailable ? null : AppColors.textSecondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  boxShadow: isAvailable
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    entry.value,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isAvailable ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    if (_services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pets_rounded,
                size: 48.w,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'No services available',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final service = _services[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.pets_rounded,
                        color: AppColors.primary,
                        size: 24.w,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        service.serviceTypeDisplayName ?? service.serviceTypeId,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF6A1B9A)],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${service.currency} ${service.rateAmount.toStringAsFixed(0)}',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (service.description != null) ...[
                      Text(
                        service.description!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                    Row(
                      children: [
                        _buildServiceInfoChip(
                          Icons.schedule_rounded,
                          '${service.durationMinutes} mins',
                          const Color(0xFF2196F3),
                        ),
                        SizedBox(width: 8.w),
                        _buildServiceInfoChip(
                          Icons.pets_rounded,
                          'Max ${_caregiver!.maxPetsAtOnce} pets',
                          const Color(0xFFFF9800),
                        ),
                      ],
                    ),
                    if (service.additionalPetRate > 0) ...[
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_circle_outline_rounded,
                              size: 16.w,
                              color: const Color(0xFF4CAF50),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '+${service.currency} ${service.additionalPetRate.toStringAsFixed(0)} per additional pet',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: const Color(0xFF4CAF50),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServiceInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.w, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryTab() {
    if (_gallery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.photo_library_rounded,
                size: 48.w,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'No photos yet',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Gallery photos will appear here',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      itemCount: _gallery.length,
      itemBuilder: (context, index) {
        final item = _gallery[index];
        return GestureDetector(
          onTap: () => _showGalleryItem(index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.textSecondary.withOpacity(0.1),
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showGalleryItem(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: _gallery.length,
            itemBuilder: (context, index) {
              final item = _gallery[index];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: InteractiveViewer(
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  if (item.caption != null)
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                        item.caption!,
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsTab() {
    if (_reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.rate_review_rounded,
                size: 48.w,
                color: Colors.amber,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'No reviews yet',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Be the first to book and review!',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        final review = _reviews[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 24.r,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        'P',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pet Owner',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            ...List.generate(5, (i) {
                              return Icon(
                                i < (review.ownerRating ?? 0)
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: Colors.amber,
                                size: 18.w,
                              );
                            }),
                            SizedBox(width: 8.w),
                            Text(
                              '${review.ownerRating ?? 0}.0',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.amber,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      _formatReviewDate(review.ownerReviewAt),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (review.ownerReview != null) ...[
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    review.ownerReview!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      height: 1.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatReviewDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays < 1) return 'Today';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  Widget _buildBookButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CreateBookingScreen(
                    caregiver: _caregiver!,
                    services: _services,
                    availability: _availability,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              minimumSize: Size(double.infinity, 54.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white,
                  size: 20.w,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Book Now',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
