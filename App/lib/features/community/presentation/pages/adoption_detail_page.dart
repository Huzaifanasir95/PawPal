import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
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
  bool _hasVerifiedBadge(AdoptionListing listing) {
    return listing.isBreedVerified ||
        (listing.verifiedBreed != null && listing.verifiedBreed!.trim().isNotEmpty);
  }

  Widget _buildImageFromPath(String imagePath, {required AdoptionListing listing}) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => _buildPlaceholder(listing),
      );
    }

    if (imagePath.startsWith('data:image/')) {
      try {
        final comma = imagePath.indexOf(',');
        if (comma > 0 && comma < imagePath.length - 1) {
          final bytes = base64Decode(imagePath.substring(comma + 1));
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (_, __, ___) => _buildPlaceholder(listing),
          );
        }
      } catch (_) {
        return _buildPlaceholder(listing);
      }
    }

    final localPath = imagePath.startsWith('file://')
        ? (Uri.tryParse(imagePath)?.toFilePath() ?? imagePath)
        : imagePath;

    return FutureBuilder<Uint8List>(
      future: XFile(localPath).readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (_, __, ___) => _buildPlaceholder(listing),
          );
        }
        return _buildPlaceholder(listing);
      },
    );
  }

  Widget _buildAvatarFromPath(String? path) {
    if (path == null || path.trim().isEmpty) {
      return Icon(
        Icons.person,
        size: 28.sp,
        color: Theme.of(context).colorScheme.onPrimary,
      );
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(
          Icons.person,
          size: 28.sp,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      );
    }

    if (path.startsWith('data:image/')) {
      try {
        final comma = path.indexOf(',');
        if (comma > 0 && comma < path.length - 1) {
          final bytes = base64Decode(path.substring(comma + 1));
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(
              Icons.person,
              size: 28.sp,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          );
        }
      } catch (_) {
        return Icon(
          Icons.person,
          size: 28.sp,
          color: Theme.of(context).colorScheme.onPrimary,
        );
      }
    }

    final localPath = path.startsWith('file://')
        ? (Uri.tryParse(path)?.toFilePath() ?? path)
        : path;

    return FutureBuilder<Uint8List>(
      future: XFile(localPath).readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(
              Icons.person,
              size: 28.sp,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          );
        }

        return Icon(
          Icons.person,
          size: 28.sp,
          color: Theme.of(context).colorScheme.onPrimary,
        );
      },
    );
  }

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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary, size: 24.sp),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Adoption Details',
              style: AppTextStyles.onboardingTitle.copyWith(
                fontSize: 20.sp,
                color: Theme.of(context).colorScheme.onPrimary,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Image Section
          Stack(
            children: [
              Container(
                height: 320.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),
                child: listing.imageUrls.isNotEmpty
                    ? PageView.builder(
                        itemCount: listing.imageUrls.length,
                        itemBuilder: (context, index) {
                          return _buildImageFromPath(
                            listing.imageUrls[index],
                            listing: listing,
                          );
                        },
                      )
                    : _buildPlaceholder(listing),
              ),
              // Image indicators
              if (listing.imageUrls.length > 1)
                Positioned(
                  bottom: 12.h,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      listing.imageUrls.length,
                      (index) => Container(
                        width: 8.w,
                        height: 8.h,
                        margin: EdgeInsets.symmetric(horizontal: 3.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.surface,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .shadow
                                  .withValues(alpha: 0.2),
                              blurRadius: 4.r,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Content section
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pet name & price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              listing.petName,
                              style: AppTextStyles.onboardingTitle.copyWith(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onSurface,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_hasVerifiedBadge(listing))
                            Padding(
                              padding: EdgeInsets.only(left: 8.w),
                              child: Icon(
                                Icons.verified_rounded,
                                size: 22.sp,
                                color: const Color(0xFF0E9F6E),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8.r,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        listing.adoptionFee > 0
                            ? 'PKR ${listing.adoptionFee.toStringAsFixed(0)}'
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
                SizedBox(height: 12.h),
                // Pet quick info
                Text(
                  [
                    listing.petType,
                    if (listing.verifiedBreed != null && listing.verifiedBreed!.isNotEmpty)
                      listing.verifiedBreed
                    else if (listing.breed != null)
                      listing.breed,
                    if (listing.age != null) listing.age,
                    if (listing.gender != null) listing.gender,
                    if (listing.size != null) listing.size,
                  ].join(' • '),
                  style: AppTextStyles.onboardingBody.copyWith(
                    fontSize: 15.sp,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16.h),
                if (_hasVerifiedBadge(listing)) ...[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E9F6E).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, color: const Color(0xFF0E9F6E), size: 16.sp),
                        SizedBox(width: 6.w),
                        Text(
                          'Breed Verified',
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0E9F6E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
                // Status badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: _statusColor(listing.status),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: _statusColor(listing.status).withOpacity(0.3),
                        blurRadius: 8.r,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    listing.status.toUpperCase(),
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 32.h),

                // Health & Training Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .shadow
                            .withValues(alpha: 0.08),
                        blurRadius: 12.r,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.health_and_safety_outlined,
                              color: Colors.green,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'Health & Training',
                            style: AppTextStyles.onboardingTitle.copyWith(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
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
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // Description Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .shadow
                            .withValues(alpha: 0.08),
                        blurRadius: 12.r,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.description_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'About',
                            style: AppTextStyles.onboardingTitle.copyWith(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        listing.description,
                        style: AppTextStyles.onboardingBody.copyWith(
                          fontSize: 15.sp,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.6,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // Medical Information Card
                if (listing.medicalInfo != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .shadow
                              .withValues(alpha: 0.08),
                          blurRadius: 12.r,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.local_hospital_outlined,
                                color: Colors.red,
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Medical Information',
                              style: AppTextStyles.onboardingTitle.copyWith(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          listing.medicalInfo!,
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 15.sp,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (listing.medicalInfo != null) SizedBox(height: 20.h),

                // Location Card
                if (listing.location != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .shadow
                              .withValues(alpha: 0.08),
                          blurRadius: 12.r,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: Colors.orange,
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Location',
                              style: AppTextStyles.onboardingTitle.copyWith(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          listing.location!,
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 15.sp,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (listing.location != null) SizedBox(height: 20.h),

                // Contact Card
                if (listing.contactPhone != null || listing.contactEmail != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .shadow
                              .withValues(alpha: 0.08),
                          blurRadius: 12.r,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.contact_page_outlined,
                                color: Colors.blue,
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Contact',
                              style: AppTextStyles.onboardingTitle.copyWith(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        if (listing.contactPhone != null)
                          _contactActionRow(
                            Icons.phone_outlined,
                            'Phone',
                            listing.contactPhone!,
                            Colors.green,
                          ),
                        if (listing.contactPhone != null && listing.contactEmail != null)
                          SizedBox(height: 12.h),
                        if (listing.contactEmail != null)
                          _contactActionRow(
                            Icons.email_outlined,
                            'Email',
                            listing.contactEmail!,
                            Colors.blue,
                          ),
                      ],
                    ),
                  ),
                if (listing.contactPhone != null || listing.contactEmail != null)
                  SizedBox(height: 20.h),

                // Listed by Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .shadow
                            .withValues(alpha: 0.08),
                        blurRadius: 12.r,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 28.r,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: ClipOval(
                            child: SizedBox(
                              width: 56.r,
                              height: 56.r,
                              child: _buildAvatarFromPath(listing.userAvatar),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Listed by',
                              style: AppTextStyles.onboardingBody.copyWith(
                                fontSize: 12.sp,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              listing.userName ?? 'Unknown',
                              style: AppTextStyles.onboardingBody.copyWith(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              _formatDate(listing.createdAt),
                              style: AppTextStyles.onboardingBody.copyWith(
                                fontSize: 12.sp,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(AdoptionListing listing) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              listing.petType.toLowerCase() == 'dog'
                  ? Icons.pets
                  : Icons.flutter_dash,
              size: 80.sp,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            SizedBox(height: 12.h),
            Text(
              'No photo available',
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _healthBadge(String label, bool? value, IconData icon) {
    final isPositive = value == true;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isPositive
            ? Colors.green.withOpacity(0.15)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: isPositive
                ? Colors.green.withOpacity(0.1)
                : Colors.black.withOpacity(0.02),
            blurRadius: 4.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: isPositive ? Colors.green : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTextStyles.onboardingBody.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: isPositive ? Colors.green : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          SizedBox(width: 6.w),
          Icon(
            isPositive ? Icons.check_circle : Icons.cancel,
            size: 14.sp,
            color: isPositive ? Colors.green : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  Widget _contactActionRow(IconData icon, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              size: 18.sp,
              color: color,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.onboardingBody.copyWith(
                    fontSize: 12.sp,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: AppTextStyles.onboardingBody.copyWith(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14.sp,
            color: color,
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'adopted':
        return Theme.of(context).colorScheme.primary;
      default:
        return Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}


