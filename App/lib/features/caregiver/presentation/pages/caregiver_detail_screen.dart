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
        padding: EdgeInsets.all(16.w),
        color: AppColors.background,
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
                              style: AppTextStyles.headlineLarge,
                            ),
                          ),
                          if (_caregiver!.isVerified) ...[
                            SizedBox(width: 8.w),
                            Icon(Icons.verified, color: Colors.blue, size: 24.w),
                          ],
                        ],
                      ),
                      if (_caregiver!.headline != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          _caregiver!.headline!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                _buildStatItem(
                  Icons.star,
                  Colors.amber,
                  _caregiver!.averageRating.toStringAsFixed(1),
                  '${_caregiver!.totalReviews} reviews',
                ),
                SizedBox(width: 24.w),
                _buildStatItem(
                  Icons.check_circle,
                  Colors.green,
                  '${_caregiver!.totalBookings}',
                  'bookings',
                ),
                SizedBox(width: 24.w),
                _buildStatItem(
                  Icons.location_on,
                  AppColors.primary,
                  _caregiver!.city ?? '-',
                  'location',
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                if (_caregiver!.acceptedPetTypes.contains('dog')) _buildPetChip('🐕 Dogs'),
                if (_caregiver!.acceptedPetTypes.contains('cat')) _buildPetChip('🐈 Cats'),
                if (_caregiver!.acceptedPetTypes.any((t) => t != 'dog' && t != 'cat')) _buildPetChip('🐾 Other'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, Color color, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20.w),
        SizedBox(width: 4.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPetChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium,
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeEnvironment() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Home Environment', style: AppTextStyles.titleMedium),
          SizedBox(height: 12.h),
          _buildEnvironmentRow(Icons.yard, 'Fenced Yard', _caregiver!.hasFencedYard ? 'Yes' : 'No'),
          _buildEnvironmentRow(Icons.directions_car, 'Own Transport', _caregiver!.hasOwnTransport ? 'Yes' : 'No'),
          _buildEnvironmentRow(Icons.pets, 'Has Pets', _caregiver!.hasOtherPets ? 'Yes' : 'No'),
          _buildEnvironmentRow(Icons.child_care, 'Children at Home', _caregiver!.hasChildren ? 'Yes' : 'No'),
          _buildEnvironmentRow(Icons.smoke_free, 'Smoke-Free Home', _caregiver!.smokeFreeHome ? 'Yes' : 'No'),
        ],
      ),
    );
  }

  Widget _buildEnvironmentRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 20.w, color: AppColors.textSecondary),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Availability', style: AppTextStyles.titleMedium),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.asMap().entries.map((entry) {
              final dayAvailability = _availability.where(
                (a) => a.dayOfWeek == entry.key && a.isAvailable,
              );
              final isAvailable = dayAvailability.isNotEmpty;
              
              return Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: isAvailable 
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.textSecondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    entry.value,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isAvailable ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isAvailable ? FontWeight.w600 : FontWeight.normal,
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
        child: Text(
          'No services available',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final service = _services[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      service.serviceTypeDisplayName ?? service.serviceTypeId,
                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '${service.currency} ${service.rateAmount.toStringAsFixed(0)}',
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
              if (service.description != null) ...[
                SizedBox(height: 8.h),
                Text(
                  service.description!,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.schedule, size: 14.w, color: AppColors.textSecondary),
                  SizedBox(width: 4.w),
                  Text(
                    'Duration: ${service.durationMinutes} mins',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                  ),
                  SizedBox(width: 16.w),
                  Icon(Icons.pets, size: 14.w, color: AppColors.textSecondary),
                  SizedBox(width: 4.w),
                  Text(
                    'Max ${_caregiver!.maxPetsAtOnce} pets',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              if (service.additionalPetRate > 0) ...[
                SizedBox(height: 4.h),
                Text(
                  '+${service.currency} ${service.additionalPetRate.toStringAsFixed(0)} per additional pet',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildGalleryTab() {
    if (_gallery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, size: 64.w, color: AppColors.textSecondary),
            SizedBox(height: 16.h),
            Text(
              'No photos yet',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
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
            Icon(Icons.rate_review, size: 64.w, color: AppColors.textSecondary),
            SizedBox(height: 16.h),
            Text(
              'No reviews yet',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
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
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      'P',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pet Owner',
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Row(
                          children: [
                            ...List.generate(5, (i) {
                              return Icon(
                                i < (review.ownerRating ?? 0) ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 16.w,
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatReviewDate(review.ownerReviewAt),
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              if (review.ownerReview != null) ...[
                SizedBox(height: 12.h),
                Text(
                  review.ownerReview!,
                  style: AppTextStyles.bodyMedium,
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
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
            backgroundColor: AppColors.primary,
            minimumSize: Size(double.infinity, 48.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: const Text(
            'Book Now',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

