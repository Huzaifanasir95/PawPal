import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load vets on init
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Find a Vet'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _filterCity != null || _filterSpecialization != null || _filterMinRating != null,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16.w),
            color: AppColors.surface,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search vets...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
              onChanged: (value) {
                // Implement search if needed
              },
            ),
          ),

          // Vets List
          Expanded(
            child: BlocConsumer<VetBloc, VetState>(
              listener: (context, state) {
                state.maybeWhen(
                  error: (message) => CustomSnackbar.showError(context, message),
                  orElse: () {},
                );
              },
              builder: (context, state) {
                return state.when(
                  initial: () => const Center(child: Text('Search for vets')),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  profileLoaded: (_) => const SizedBox(),
                  vetsListLoaded: (vets, total, page, limit, hasMore, _, __, ___) {
                    if (vets.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64.sp, color: AppColors.neutral400),
                            SizedBox(height: 16.h),
                            Text(
                              'No vets found',
                              style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary),
                            ),
                            if (_filterCity != null || _filterSpecialization != null || _filterMinRating != null) ...[
                              SizedBox(height: 8.h),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _filterCity = null;
                                    _filterSpecialization = null;
                                    _filterMinRating = null;
                                  });
                                  context.read<VetBloc>().add(const VetEvent.clearFilters());
                                },
                                child: const Text('Clear Filters'),
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<VetBloc>().add(VetEvent.listVets(
                          city: _filterCity,
                          specialization: _filterSpecialization,
                          minRating: _filterMinRating,
                        ));
                      },
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16.w),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                        ),
                        itemCount: vets.length + (hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= vets.length) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          return _VetCard(vet: vets[index]);
                        },
                      ),
                    );
                  },
                  profileSaved: (_) => const SizedBox(),
                  error: (message) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
                        SizedBox(height: 16.h),
                        Text(
                          'Error loading vets',
                          style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          message,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () => context.read<VetBloc>().add(const VetEvent.listVets()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VetDetailScreen(vetId: vet.userId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            Container(
              height: 120.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  size: 48.sp,
                  color: AppColors.primary,
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    vet.fullName,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),

                  // Degree
                  Text(
                    vet.degree,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),

                  // Experience
                  Row(
                    children: [
                      Icon(Icons.work_outline, size: 14.sp, color: AppColors.textSecondary),
                      SizedBox(width: 4.w),
                      Text(
                        '${vet.experience} years',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),

                  // Rating (commented out - fields not in model yet)
                  // if (vet.averageRating != null && vet.totalRatings != null)
                  //   Row(
                  //     children: [
                  //       Icon(Icons.star, size: 14.sp, color: Colors.amber),
                  //       SizedBox(width: 4.w),
                  //       Text(
                  //         '${vet.averageRating!.toStringAsFixed(1)} (${vet.totalRatings})',
                  //         style: AppTextStyles.bodySmall.copyWith(
                  //           color: AppColors.textSecondary,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  SizedBox(height: 8.h),

                  // Consultation Fee
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '\$${vet.consultationFee.toStringAsFixed(0)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
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
    'Internal Medicine',
    'Radiology',
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
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Vets',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // City
                  Text(
                    'City',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      hintText: 'Enter city name',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Specialization
                  Text(
                    'Specialization',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _specializations.map((spec) {
                      final isSelected = _selectedSpecialization == spec;
                      return FilterChip(
                        label: Text(spec),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedSpecialization = selected ? spec : null;
                          });
                        },
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        checkmarkColor: AppColors.primary,
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 24.h),

                  // Min Rating
                  Text(
                    'Minimum Rating',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _minRating,
                          min: 0,
                          max: 5,
                          divisions: 10,
                          label: _minRating > 0 ? _minRating.toStringAsFixed(1) : 'Any',
                          activeColor: AppColors.primary,
                          onChanged: (value) {
                            setState(() => _minRating = value);
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 16.sp, color: Colors.amber),
                            SizedBox(width: 4.w),
                            Text(
                              _minRating > 0 ? _minRating.toStringAsFixed(1) : 'Any',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            widget.onClear();
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: Text(
                            'Clear',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            widget.onApply(
                              _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
                              _selectedSpecialization,
                              _minRating > 0 ? _minRating : null,
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: Text(
                            'Apply Filters',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
