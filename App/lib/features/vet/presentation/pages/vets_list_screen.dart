import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../data/models/vet_profile_model.dart';
import '../bloc/vet_bloc.dart';
import '../bloc/vet_event.dart';
import '../bloc/vet_state.dart';
import 'vet_detail_screen.dart';

class VetsListScreen extends StatefulWidget {
  const VetsListScreen({super.key});

  @override
  State<VetsListScreen> createState() => _VetsListScreenState();
}

class _VetsListScreenState extends State<VetsListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  
  String? _filterCity;
  String? _filterSpecialization;
  double? _filterMinRating;
  
  List<VetProfile> _cachedVets = [];
  bool _cachedHasMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<VetBloc>().add(const VetEvent.listVets());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      final currentState = context.read<VetBloc>().state;
      currentState.maybeWhen(
        vetsListLoaded: (vets, total, currentPage, limit, hasMore, city, spec, rating) {
          if (hasMore) {
            context.read<VetBloc>().add(VetEvent.listVets(
              city: city,
              specialization: spec,
              minRating: rating,
              page: currentPage + 1,
              limit: limit,
            ));
          }
        },
        orElse: () {},
      );
    }
  }

  bool get _hasActiveFilters =>
      _filterCity != null || _filterSpecialization != null || _filterMinRating != null;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              Expanded(child: _buildVetsList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_rounded,
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
                  'Find a Vet',
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Book appointments with verified vets',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showFilterBottomSheet,
            child: Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: _hasActiveFilters ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.tune_rounded,
                      color: _hasActiveFilters ? Colors.white : AppColors.textPrimary,
                      size: 22.sp,
                    ),
                  ),
                  if (_hasActiveFilters)
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
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

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(fontSize: 15.sp),
          decoration: InputDecoration(
            hintText: 'Search by name or specialization...',
            hintStyle: TextStyle(
              fontSize: 15.sp,
              color: AppColors.textSecondary,
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 16.w, right: 12.w),
              child: Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
                size: 22.sp,
              ),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 50.w),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 16.h),
          ),
        ),
      ),
    );
  }

  Widget _buildVetsList() {
    return BlocConsumer<VetBloc, VetState>(
      listener: (context, state) {
        state.maybeWhen(
          vetsListLoaded: (vets, total, page, limit, hasMore, _, __, ___) {
            setState(() {
              _cachedVets = vets;
              _cachedHasMore = hasMore;
            });
          },
          error: (message) => CustomSnackbar.showError(context, message),
          orElse: () {},
        );
      },
      builder: (context, state) {
        return state.when(
          initial: () => _buildEmptyState(),
          loading: () {
            if (_cachedVets.isNotEmpty) {
              return _buildList(_cachedVets, _cachedHasMore);
            }
            return _buildLoadingState();
          },
          profileLoaded: (_) {
            if (_cachedVets.isNotEmpty) {
              return _buildList(_cachedVets, _cachedHasMore);
            }
            return const SizedBox();
          },
          vetsListLoaded: (vets, total, page, limit, hasMore, _, __, ___) {
            return _buildList(vets, hasMore);
          },
          profileSaved: (_) {
            if (_cachedVets.isNotEmpty) {
              return _buildList(_cachedVets, _cachedHasMore);
            }
            return const SizedBox();
          },
          error: (message) => _buildErrorState(message),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: 4,
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: 80.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: 100.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 64.sp,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'No vets found',
            style: TextStyle(
              fontSize: 18.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          if (_hasActiveFilters) ...[
            SizedBox(height: 20.h),
            TextButton(
              onPressed: () {
                setState(() {
                  _filterCity = null;
                  _filterSpecialization = null;
                  _filterMinRating = null;
                });
                context.read<VetBloc>().add(const VetEvent.clearFilters());
              },
              child: Text(
                'Clear Filters',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64.sp,
              color: const Color(0xFFEF4444),
            ),
            SizedBox(height: 16.h),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: () => context.read<VetBloc>().add(const VetEvent.listVets()),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<VetProfile> vets, bool hasMore) {
    if (vets.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: () async {
        context.read<VetBloc>().add(VetEvent.listVets(
          city: _filterCity,
          specialization: _filterSpecialization,
          minRating: _filterMinRating,
        ));
      },
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
        itemCount: vets.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= vets.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: const Center(child: CircularProgressIndicator()),
            );
          }
          return _VetCard(vet: vets[index]);
        },
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        initialCity: _filterCity,
        initialSpecialization: _filterSpecialization,
        initialMinRating: _filterMinRating,
        onApply: (city, specialization, minRating) {
          setState(() {
            _filterCity = city;
            _filterSpecialization = specialization;
            _filterMinRating = minRating;
          });
          context.read<VetBloc>().add(VetEvent.filterVets(
            city: city,
            specialization: specialization,
            minRating: minRating,
          ));
        },
        onClear: () {
          setState(() {
            _filterCity = null;
            _filterSpecialization = null;
            _filterMinRating = null;
          });
          context.read<VetBloc>().add(const VetEvent.clearFilters());
        },
      ),
    );
  }
}

class _VetCard extends StatelessWidget {
  final VetProfile vet;

  const _VetCard({required this.vet});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VetDetailScreen(
            vetId: vet.userId,
            profilePhotoUrl: vet.profilePhotoUrl,
          ),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Photo
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
                image: vet.profilePhotoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(vet.profilePhotoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: vet.profilePhotoUrl == null
                  ? Center(
                      child: Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                        size: 36.sp,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 16.w),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vet.fullName,
                          style: TextStyle(
                            fontSize: 17.sp,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (vet.rating > 0) ...[
                        Icon(
                          Icons.star_rounded,
                          color: const Color(0xFFFBBF24),
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          vet.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${vet.degree} • ${vet.experience} yrs exp',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      if (vet.specialization.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            vet.specialization.first,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFF6366F1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const Spacer(),
                      Text(
                        'PKR ${vet.consultationFee.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final String? initialCity;
  final String? initialSpecialization;
  final double? initialMinRating;
  final Function(String?, String?, double?) onApply;
  final VoidCallback onClear;

  const _FilterBottomSheet({
    this.initialCity,
    this.initialSpecialization,
    this.initialMinRating,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late TextEditingController _cityController;
  String? _selectedSpecialization;
  double _minRating = 0;

  final List<String> _specializations = [
    'General Practice',
    'Emergency Care',
    'Surgery',
    'Dermatology',
    'Cardiology',
    'Oncology',
    'Dentistry',
    'Orthopedics',
  ];

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController(text: widget.initialCity);
    _selectedSpecialization = widget.initialSpecialization;
    _minRating = widget.initialMinRating ?? 0;
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Vets',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // City
                  Text(
                    'City',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: TextField(
                      controller: _cityController,
                      style: TextStyle(fontSize: 15.sp),
                      decoration: InputDecoration(
                        hintText: 'Enter city name',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15.sp,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Specialization
                  Text(
                    'Specialization',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _specializations.map((spec) {
                      final isSelected = _selectedSpecialization == spec;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _selectedSpecialization = isSelected ? null : spec;
                        }),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            spec,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 24.h),

                  // Min Rating
                  Row(
                    children: [
                      Text(
                        'Minimum Rating',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: const Color(0xFFFBBF24),
                            size: 18.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _minRating > 0 ? _minRating.toStringAsFixed(1) : 'Any',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: const Color(0xFFF5F7FA),
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withOpacity(0.1),
                      trackHeight: 6.h,
                    ),
                    child: Slider(
                      value: _minRating,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      onChanged: (value) => setState(() => _minRating = value),
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            widget.onClear();
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.primary),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Center(
                              child: Text(
                                'Clear',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            widget.onApply(
                              _cityController.text.trim().isEmpty
                                  ? null
                                  : _cityController.text.trim(),
                              _selectedSpecialization,
                              _minRating > 0 ? _minRating : null,
                            );
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Center(
                              child: Text(
                                'Apply Filters',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
