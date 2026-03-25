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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Find Caregivers',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textPrimary),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildServiceTypeFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _caregivers.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadInitialData,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(16.w),
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search caregivers...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
        onSubmitted: (value) => _applyFilters(),
      ),
    );
  }

  Widget _buildServiceTypeFilter() {
    return SizedBox(
      height: 40.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _serviceTypes.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: ChoiceChip(
                label: const Text('All'),
                selected: _selectedServiceType == null,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedServiceType = null);
                    _applyFilters();
                  }
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: _selectedServiceType == null ? Colors.white : AppColors.textPrimary,
                ),
              ),
            );
          }
          
          final serviceType = _serviceTypes[index - 1];
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(serviceType.displayName),
              selected: _selectedServiceType == serviceType.name,
              onSelected: (selected) {
                setState(() {
                  _selectedServiceType = selected ? serviceType.name : null;
                });
                _applyFilters();
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: _selectedServiceType == serviceType.name ? Colors.white : AppColors.textPrimary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64.w, color: AppColors.textSecondary),
          SizedBox(height: 16.h),
          Text(
            'No caregivers found',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try adjusting your filters',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCaregiverCard(CaregiverProfile caregiver) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CaregiverDetailScreen(caregiverId: caregiver.id),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                CircleAvatar(
                  radius: 28.r,
                  backgroundImage: caregiver.userAvatar != null
                      ? NetworkImage(caregiver.userAvatar!)
                      : null,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: caregiver.userAvatar == null
                      ? Text(
                          (caregiver.userName ?? 'C')[0].toUpperCase(),
                          style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
                        )
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              caregiver.userName ?? 'Caregiver',
                              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (caregiver.isVerified) ...[
                            SizedBox(width: 4.w),
                            Icon(Icons.verified, color: Colors.blue, size: 16.w),
                          ],
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16.w),
                          SizedBox(width: 4.w),
                          Text(
                            caregiver.averageRating.toStringAsFixed(1),
                            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '(${caregiver.totalReviews})',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                          if (caregiver.totalBookings > 0) ...[
                            SizedBox(width: 12.w),
                            Icon(Icons.check_circle, color: Colors.green, size: 14.w),
                            SizedBox(width: 4.w),
                            Text(
                              '${caregiver.totalBookings} bookings',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (caregiver.headline != null) ...[
              SizedBox(height: 12.h),
              Text(
                caregiver.headline!,
                style: AppTextStyles.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: 12.h),
            Row(
              children: [
                _buildInfoChip(Icons.location_on, caregiver.city ?? 'Unknown'),
                SizedBox(width: 8.w),
                _buildInfoChip(Icons.home, caregiver.hasFencedYard ? 'Fenced Yard' : 'Home'),
              ],
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 4.h,
              children: [
                if (caregiver.acceptedPetTypes.contains('dog'))
                  _buildPetChip('🐕', 'Dogs'),
                if (caregiver.acceptedPetTypes.contains('cat'))
                  _buildPetChip('🐈', 'Cats'),
                if (caregiver.acceptedPetTypes.any((t) => t != 'dog' && t != 'cat'))
                  _buildPetChip('🐾', 'Other'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.w, color: AppColors.primary),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildPetChip(String emoji, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppTextStyles.labelSmall,
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
