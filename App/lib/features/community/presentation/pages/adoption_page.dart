import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/community_hub_models.dart';
import '../cubit/adoption_cubit.dart';
import '../cubit/adoption_state.dart';
import 'adoption_detail_page.dart';
import 'create_adoption_page.dart';

class AdoptionPage extends StatefulWidget {
  const AdoptionPage({super.key});

  @override
  State<AdoptionPage> createState() => _AdoptionPageState();
}

class _AdoptionPageState extends State<AdoptionPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdoptionCubit, AdoptionState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
            heroTag: 'adoption_fab',
            onPressed: () async {
              final created = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<AdoptionCubit>(),
                    child: const CreateAdoptionPage(),
                  ),
                ),
              );
              if (created == true) {
                context.read<AdoptionCubit>().loadListings();
              }
            },
            child: Icon(Icons.add, color: AppColors.accent, size: 28.sp),
          ),
          body: Column(
            children: [
              _buildSearchBar(context, state.searchQuery),
              _buildPetTypeFilter(context, state.filterPetType),
              Expanded(child: _buildBody(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context, String currentQuery) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: 16.w),
            Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  context.read<AdoptionCubit>().searchListings(value);
                },
                style: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 15.sp,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search by pet name...',
                  hintStyle: AppTextStyles.onboardingBody.copyWith(
                    fontSize: 15.sp,
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (currentQuery.isNotEmpty)
              IconButton(
                icon: Icon(
                  Icons.clear,
                  color: AppColors.textSecondary,
                  size: 20.sp,
                ),
                onPressed: () {
                  _searchController.clear();
                  context.read<AdoptionCubit>().searchListings('');
                },
              ),
            SizedBox(width: 8.w),
          ],
        ),
      ),
    );
  }

  Widget _buildPetTypeFilter(BuildContext context, String? activeType) {
    final types = ['All', 'Dog', 'Cat', 'Bird', 'Other'];
    return SizedBox(
      height: 52.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        itemCount: types.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final type = types[index];
          final filterVal = type == 'All' ? null : type.toLowerCase();
          final isActive = activeType == filterVal;
          return GestureDetector(
            onTap: () =>
                context.read<AdoptionCubit>().loadListings(petType: filterVal),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isActive ? AppColors.accent : AppColors.surface,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isActive ? AppColors.accent : AppColors.border,
                ),
              ),
              child: Text(
                type,
                style: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 13.sp,
                  color: isActive ? Colors.white : AppColors.textPrimary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, AdoptionState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.error!, style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 12.h),
            ElevatedButton(
              onPressed: () => context.read<AdoptionCubit>().loadListings(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    final displayListings = state.filteredListings;
    
    if (state.listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64.sp, color: AppColors.textSecondary),
            SizedBox(height: 12.h),
            Text(
              'No adoption listings yet',
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    
    if (displayListings.isEmpty && state.searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64.sp, color: AppColors.textSecondary),
            SizedBox(height: 12.h),
            Text(
              'No pets found matching "${state.searchQuery}"',
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => context
          .read<AdoptionCubit>()
          .loadListings(petType: state.filterPetType),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        itemCount: displayListings.length,
        itemBuilder: (context, index) =>
            _buildListingCard(context, displayListings[index]),
      ),
    );
  }

  Widget _buildListingCard(BuildContext context, AdoptionListing listing) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<AdoptionCubit>(),
              child: AdoptionDetailPage(listingId: listing.id),
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Pet image / placeholder
            Container(
              width: 110.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(16.r),
                ),
              ),
              child: listing.imageUrls != null && listing.imageUrls!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(16.r)),
                      child: Image.network(
                        listing.imageUrls!.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _petPlaceholder(listing.petType),
                      ),
                    )
                  : _petPlaceholder(listing.petType),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            listing.petName,
                            style: AppTextStyles.onboardingTitle.copyWith(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (listing.adoptionFee != null &&
                            listing.adoptionFee! > 0)
                          Text(
                            '\$${listing.adoptionFee!.toStringAsFixed(0)}',
                            style: AppTextStyles.onboardingBody.copyWith(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2C6E69),
                            ),
                          )
                        else
                          Text(
                            'Free',
                            style: AppTextStyles.onboardingBody.copyWith(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      [
                        listing.petType,
                        if (listing.breed != null) listing.breed,
                        if (listing.age != null) listing.age,
                      ].join(' • '),
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Badges
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      children: [
                        if (listing.isVaccinated == true)
                          _badge('Vaccinated', AppColors.success),
                        if (listing.isNeutered == true)
                          _badge('Neutered', AppColors.info),
                        if (listing.isTrained == true)
                          _badge('Trained', const Color(0xFF8D6E63)),
                      ],
                    ),
                    if (listing.location != null) ...[
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 12.sp, color: AppColors.textSecondary),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              listing.location!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.onboardingBody.copyWith(
                                fontSize: 11.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _petPlaceholder(String petType) {
    return Center(
      child: Icon(
        petType.toLowerCase() == 'cat' ? Icons.pets : Icons.pets,
        size: 40.sp,
        color: const Color(0xFF2C6E69).withOpacity(0.4),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.onboardingBody.copyWith(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
