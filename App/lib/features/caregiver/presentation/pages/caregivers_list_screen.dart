import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/repositories/caregiver_repository.dart';
import '../../data/models/caregiver_models.dart';
import 'caregiver_detail_screen.dart';

class CaregiversListScreen extends StatefulWidget {
  const CaregiversListScreen({super.key});

  @override
  State<CaregiversListScreen> createState() => _CaregiversListScreenState();
}

class _CaregiversListScreenState extends State<CaregiversListScreen> {
  late CaregiverRepository _repository;
  List<CaregiverProfile> _caregivers = [];
  List<CaregiverServiceType> _serviceTypes = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;

  // Filters
  String? _selectedServiceType;
  double? _maxDistance;
  double? _minRating;
  String _sortBy = 'rating';
  int _page = 1;
  bool _hasMore = true;

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _repository = getIt<CaregiverRepository>();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) {
        _loadMoreCaregivers();
      }
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final serviceTypes = await _repository.getServiceTypes();
      final caregivers = await _searchCaregivers();
      
      setState(() {
        _serviceTypes = serviceTypes;
        _caregivers = caregivers;
        _isLoading = false;
        _hasMore = caregivers.length >= 20;
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

  Future<List<CaregiverProfile>> _searchCaregivers() async {
    final result = await _repository.searchCaregivers(
      serviceType: _selectedServiceType,
      minRating: _minRating,
      page: _page,
    );
    return result.caregivers;
  }

  Future<void> _loadMoreCaregivers() async {
    if (_isLoadingMore) return;
    
    setState(() => _isLoadingMore = true);
    try {
      _page++;
      final newCaregivers = await _searchCaregivers();
      setState(() {
        _caregivers.addAll(newCaregivers);
        _hasMore = newCaregivers.length >= 20;
        _isLoadingMore = false;
      });
    } catch (e) {
      _page--;
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _applyFilters() async {
    _page = 1;
    setState(() => _isLoading = true);
    try {
      final caregivers = await _searchCaregivers();
      setState(() {
        _caregivers = caregivers;
        _isLoading = false;
        _hasMore = caregivers.length >= 20;
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
      backgroundColor: const Color(0xFFECEFF3),
      appBar: AppBar(
        title: Text(
          'Find Caregivers',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textPrimary),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary,
                  Color(0xFFA9DCD7),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24.r),
                bottomRight: Radius.circular(24.r),
              ),
            ),
            child: Column(
              children: [
                _buildSearchBar(),
                _buildServiceTypeFilter(),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _caregivers.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadInitialData,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
                          itemCount: _caregivers.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= _caregivers.length) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.h),
                                  child: const CircularProgressIndicator(),
                                ),
                              );
                            }
                            return _buildCaregiverCard(_caregivers[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name or location...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary.withOpacity(0.6),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.primary,
            size: 22.w,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: AppColors.textSecondary, size: 20.w),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18.r),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        ),
        onSubmitted: (value) => _applyFilters(),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildServiceTypeFilter() {
    return Container(
      height: 48.h,
      margin: EdgeInsets.only(bottom: 14.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _serviceTypes.length + 1,
        itemBuilder: (context, index) {
          final isSelected = index == 0 
              ? _selectedServiceType == null 
              : _selectedServiceType == _serviceTypes[index - 1].name;
          final label = index == 0 ? 'All' : _serviceTypes[index - 1].displayName;
          
          return Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedServiceType = index == 0 ? null : _serviceTypes[index - 1].name;
                });
                _applyFilters();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.darkTeal : AppColors.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.darkTeal
                        : AppColors.textSecondary.withOpacity(0.18),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isSelected ? 0.14 : 0.05),
                      blurRadius: isSelected ? 10 : 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 80.w,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'No caregivers found',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'Try adjusting your filters or search criteria\nto find the perfect caregiver',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedServiceType = null;
                  _maxDistance = null;
                  _minRating = null;
                  _searchController.clear();
                });
                _applyFilters();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaregiverCard(CaregiverProfile caregiver) {
    // Calculate starting price from services
    double? startingPrice;
    if (caregiver.services.isNotEmpty) {
      startingPrice = caregiver.services.map((s) => s.rateAmount).reduce((a, b) => a < b ? a : b);
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CaregiverDetailScreen(caregiverId: caregiver.id),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: const Color(0xFFDAE2E8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Avatar and Name
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.22),
                      AppColors.primary.withOpacity(0.08),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 32.r,
                          backgroundImage: caregiver.userAvatar != null
                              ? NetworkImage(caregiver.userAvatar!)
                              : null,
                          backgroundColor: AppColors.primary,
                          child: caregiver.userAvatar == null
                              ? Text(
                                  (caregiver.userName ?? 'C')[0].toUpperCase(),
                                  style: AppTextStyles.headlineMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        if (caregiver.isVerified)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.surface, width: 2),
                              ),
                              child: Icon(Icons.verified, color: Colors.white, size: 12.w),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  caregiver.userName ?? 'Caregiver',
                                  style: AppTextStyles.titleLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              // Rating
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star, color: Colors.amber.shade700, size: 14.w),
                                    SizedBox(width: 3.w),
                                    Text(
                                      caregiver.averageRating.toStringAsFixed(1),
                                      style: AppTextStyles.labelMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              // Total bookings
                              if (caregiver.totalBookings > 0)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.green.shade700, size: 14.w),
                                      SizedBox(width: 3.w),
                                      Text(
                                        '${caregiver.totalBookings}',
                                        style: AppTextStyles.labelMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Starting price
                    if (startingPrice != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'From',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontSize: 9.sp,
                              ),
                            ),
                            Text(
                              'Rs ${startingPrice.toInt()}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Headline
                    if (caregiver.headline != null) ...[
                      Text(
                        caregiver.headline!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 12.h),
                    ],
                    
                    // Key features row
                    Row(
                      children: [
                        // Location
                        Expanded(
                          child: _buildFeatureItem(
                            Icons.location_on_outlined,
                            caregiver.city ?? 'Unknown',
                            Colors.red.shade400,
                          ),
                        ),
                        // Experience
                        if (caregiver.yearsOfExperience > 0)
                          Expanded(
                            child: _buildFeatureItem(
                              Icons.workspace_premium_outlined,
                              '${caregiver.yearsOfExperience} yrs',
                              Colors.purple.shade400,
                            ),
                          ),
                        // Max pets
                        Expanded(
                          child: _buildFeatureItem(
                            Icons.pets_outlined,
                            'Max ${caregiver.maxPetsAtOnce}',
                            Colors.orange.shade400,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 12.h),
                    
                    // Pet types and special features
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: [
                        if (caregiver.acceptedPetTypes.contains('dog'))
                          _buildPetChip('🐕', 'Dogs', Colors.blue.shade50, Colors.blue.shade700),
                        if (caregiver.acceptedPetTypes.contains('cat'))
                          _buildPetChip('🐈', 'Cats', Colors.purple.shade50, Colors.purple.shade700),
                        if (caregiver.hasFencedYard)
                          _buildFeatureChip(Icons.fence_outlined, 'Fenced Yard', Colors.green.shade50, Colors.green.shade700),
                        if (caregiver.hasOwnTransport)
                          _buildFeatureChip(Icons.directions_car_outlined, 'Transport', Colors.teal.shade50, Colors.teal.shade700),
                        if (caregiver.petFirstAidCertified)
                          _buildFeatureChip(Icons.medical_services_outlined, 'First Aid', Colors.red.shade50, Colors.red.shade700),
                        if (caregiver.smokeFreeHome)
                          _buildFeatureChip(Icons.smoke_free_outlined, 'Smoke Free', Colors.cyan.shade50, Colors.cyan.shade700),
                      ],
                    ),
                    
                    // Response time and completion rate (if good stats)
                    if (caregiver.totalBookings > 5 && caregiver.completionRate > 90) ...[
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 14.w, color: AppColors.textSecondary),
                          SizedBox(width: 4.w),
                          Text(
                            'Responds in ${caregiver.responseTimeHours}h',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                          ),
                          SizedBox(width: 12.w),
                          Icon(Icons.trending_up, size: 14.w, color: Colors.green),
                          SizedBox(width: 4.w),
                          Text(
                            '${caregiver.completionRate.toInt()}% completion',
                            style: AppTextStyles.labelSmall.copyWith(color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.w, color: color),
        SizedBox(width: 4.w),
        Flexible(
          child: Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String label, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.w, color: textColor),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetChip(String emoji, String label, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: 12.sp)),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: AppTextStyles.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      setSheetState(() {
                        _maxDistance = null;
                        _minRating = null;
                        _sortBy = 'rating';
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Text('Maximum Distance (km)', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              Slider(
                value: _maxDistance ?? 50,
                min: 1,
                max: 100,
                divisions: 20,
                label: '${(_maxDistance ?? 50).round()} km',
                onChanged: (value) {
                  setSheetState(() => _maxDistance = value);
                },
              ),
              SizedBox(height: 16.h),
              Text('Minimum Rating', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              Row(
                children: List.generate(5, (index) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setSheetState(() => _minRating = (index + 1).toDouble());
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: (_minRating ?? 0) >= index + 1
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: (_minRating ?? 0) >= index + 1
                                ? AppColors.primary
                                : AppColors.textSecondary.withOpacity(0.2),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.star,
                                size: 16.w,
                                color: (_minRating ?? 0) >= index + 1
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                              Text(
                                '${index + 1}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: (_minRating ?? 0) >= index + 1
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 16.h),
              Text('Sort By', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                children: [
                  ChoiceChip(
                    label: const Text('Rating'),
                    selected: _sortBy == 'rating',
                    onSelected: (selected) {
                      if (selected) setSheetState(() => _sortBy = 'rating');
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: _sortBy == 'rating' ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('Distance'),
                    selected: _sortBy == 'distance',
                    onSelected: (selected) {
                      if (selected) setSheetState(() => _sortBy = 'distance');
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: _sortBy == 'distance' ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('Bookings'),
                    selected: _sortBy == 'bookings',
                    onSelected: (selected) {
                      if (selected) setSheetState(() => _sortBy = 'bookings');
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: _sortBy == 'bookings' ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _applyFilters();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: Size(double.infinity, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: const Text('Apply Filters'),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }
}
