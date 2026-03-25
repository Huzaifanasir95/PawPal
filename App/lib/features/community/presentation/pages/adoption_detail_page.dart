import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/community_hub_models.dart';
import '../cubit/adoption_cubit.dart';
import '../cubit/adoption_state.dart';

class AdoptionDetailPage extends StatefulWidget {
  final String listingId;
  const AdoptionDetailPage({super.key, required this.listingId});

  @override
  State<AdoptionDetailPage> createState() => _AdoptionDetailPageState();
}

class _AdoptionDetailPageState extends State<AdoptionDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdoptionCubit>().loadDetail(widget.listingId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdoptionCubit, AdoptionState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F6F2),
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.accent, size: 24.sp),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Adoption Details',
              style: AppTextStyles.onboardingTitle.copyWith(
                fontSize: 20.sp,
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(AdoptionState state) {
    if (state.isLoadingDetail) {
      return const Center(child: CircularProgressIndicator());
    }
    final listing = state.selectedListing;
    if (listing == null) {
      return Center(
        child: Text(state.error ?? 'Listing not found',
            style: TextStyle(fontSize: 14.sp)),
      );
    }
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pet name & price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  listing.petName,
                  style: AppTextStyles.onboardingTitle.copyWith(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C6E69),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  listing.adoptionFee != null && listing.adoptionFee! > 0
                      ? '\$${listing.adoptionFee!.toStringAsFixed(0)}'
                      : 'Free',
                  style: AppTextStyles.onboardingBody.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Pet quick info
          Text(
            [
              listing.petType,
              if (listing.breed != null) listing.breed,
              if (listing.age != null) listing.age,
              if (listing.gender != null) listing.gender,
              if (listing.size != null) listing.size,
            ].join(' • '),
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          // Status badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _statusColor(listing.status).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              listing.status.toUpperCase(),
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: _statusColor(listing.status),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // Health badges
          _sectionTitle('Health & Training'),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 8.h,
            children: [
              _healthBadge('Vaccinated', listing.isVaccinated, Icons.medical_services_outlined),
              _healthBadge('Neutered', listing.isNeutered, Icons.content_cut),
              _healthBadge('Trained', listing.isTrained, Icons.school_outlined),
              if (listing.goodWithKids != null)
                _healthBadge('Good with Kids', listing.goodWithKids, Icons.child_care),
              if (listing.goodWithPets != null)
                _healthBadge('Good with Pets', listing.goodWithPets, Icons.pets),
            ],
          ),
          SizedBox(height: 24.h),

          // Description
          _sectionTitle('About'),
          SizedBox(height: 8.h),
          Text(
            listing.description,
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 15.sp,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.h),

          // Medical info
          if (listing.medicalInfo != null) ...[
            _sectionTitle('Medical Information'),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                listing.medicalInfo!,
                style: AppTextStyles.onboardingBody.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],

          // Location
          if (listing.location != null) ...[
            _sectionTitle('Location'),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.location_on, color: AppColors.error, size: 18.sp),
                SizedBox(width: 6.w),
                Text(
                  listing.location!,
                  style: AppTextStyles.onboardingBody.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
          ],

          // Contact
          if (listing.contactPhone != null || listing.contactEmail != null) ...[
            _sectionTitle('Contact'),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  if (listing.contactPhone != null)
                    _contactRow(Icons.phone, listing.contactPhone!),
                  if (listing.contactPhone != null &&
                      listing.contactEmail != null)
                    SizedBox(height: 8.h),
                  if (listing.contactEmail != null)
                    _contactRow(Icons.email_outlined, listing.contactEmail!),
                ],
              ),
            ),
            SizedBox(height: 24.h),
          ],

          // Posted by
          _sectionTitle('Listed by'),
          SizedBox(height: 8.h),
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColors.primary,
                backgroundImage: listing.userAvatar != null
                    ? NetworkImage(listing.userAvatar!)
                    : null,
                child: listing.userAvatar == null
                    ? Icon(Icons.person, size: 20.sp)
                    : null,
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.userName ?? 'Unknown',
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatDate(listing.createdAt),
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.onboardingTitle.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _healthBadge(String label, bool? value, IconData icon) {
    final isPositive = value == true;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isPositive
            ? AppColors.success.withOpacity(0.1)
            : AppColors.neutral300,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isPositive ? AppColors.success.withOpacity(0.3) : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: isPositive ? AppColors.success : AppColors.textSecondary,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: isPositive ? AppColors.success : AppColors.textSecondary,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(
            isPositive ? Icons.check : Icons.close,
            size: 12.sp,
            color: isPositive ? AppColors.success : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: const Color(0xFF2C6E69)),
        SizedBox(width: 10.w),
        Text(
          text,
          style: AppTextStyles.onboardingBody.copyWith(
            fontSize: 14.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'available':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'adopted':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
