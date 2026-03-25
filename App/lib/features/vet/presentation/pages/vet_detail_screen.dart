import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../data/models/vet_profile_model.dart';
import '../bloc/vet_bloc.dart';
import '../bloc/vet_event.dart';
import '../bloc/vet_state.dart';
import '../../../chat/presentation/bloc/chat_bloc.dart';
import '../../../chat/presentation/bloc/chat_event.dart';
import '../../../chat/presentation/bloc/chat_state.dart';

class VetDetailScreen extends StatefulWidget {
  final String vetId;
  final String? profilePhotoUrl;

  const VetDetailScreen({
    super.key,
    required this.vetId,
    this.profilePhotoUrl,
  });

  @override
  State<VetDetailScreen> createState() => _VetDetailScreenState();
}

class _VetDetailScreenState extends State<VetDetailScreen> {
  bool _isStartingChat = false;

  @override
  void initState() {
    super.initState();
    context.read<VetBloc>().add(VetEvent.loadVetProfile(widget.vetId));
  }

  void _startChatWithVet(BuildContext context) async {
    if (_isStartingChat) return;
    setState(() => _isStartingChat = true);

    context.read<ChatBloc>().add(
      ChatEvent.startChat(vetId: widget.vetId, petId: null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: MultiBlocListener(
          listeners: [
            BlocListener<VetBloc, VetState>(
              listener: (context, state) {
                state.maybeWhen(
                  error: (message) => CustomSnackbar.showError(context, message),
                  orElse: () {},
                );
              },
            ),
            BlocListener<ChatBloc, ChatState>(
              listener: (context, state) {
                state.maybeWhen(
                  chatStarted: (chat) {
                    if (mounted) {
                      setState(() => _isStartingChat = false);
                      String? vetName;
                      String? vetPhoto = widget.profilePhotoUrl;
                      
                      context.read<VetBloc>().state.maybeWhen(
                        profileLoaded: (vet) {
                          vetName = vet.fullName;
                          vetPhoto ??= vet.profilePhotoUrl;
                        },
                        orElse: () {},
                      );
                      AppNavigator.navigateToConversation(
                        context,
                        chatId: chat.id,
                        otherUserName: vetName,
                        otherUserPhoto: vetPhoto,
                      );
                    }
                  },
                  error: (message) {
                    if (mounted) {
                      setState(() => _isStartingChat = false);
                      CustomSnackbar.showError(context, message);
                    }
                  },
                  orElse: () {},
                );
              },
            ),
          ],
          child: BlocBuilder<VetBloc, VetState>(
            builder: (context, state) {
              return state.when(
                initial: () => _buildLoading(),
                loading: () => _buildLoading(),
                profileLoaded: (vet) => _buildContent(vet),
                vetsListLoaded: (_, __, ___, ____, _____, ______, _______, ________) => const SizedBox(),
                profileSaved: (_) => const SizedBox(),
                error: (message) => _buildError(message),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _buildError(String message) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(null),
          Expanded(
            child: Center(
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
                      'Failed to load profile',
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
                      onTap: () => context.read<VetBloc>().add(VetEvent.loadVetProfile(widget.vetId)),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(VetProfile vet) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _buildHeader(vet),
                    _buildProfileSection(vet),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 120.h),
                      child: Column(
                        children: [
                          _buildInfoCard(vet),
                          SizedBox(height: 16.h),
                          if (vet.specialization.isNotEmpty) ...[
                            _buildSpecializationsCard(vet),
                            SizedBox(height: 16.h),
                          ],
                          if (vet.clinicName != null || vet.clinicAddress != null) ...[
                            _buildClinicCard(vet),
                            SizedBox(height: 16.h),
                          ],
                          _buildFeeCard(vet),
                          SizedBox(height: 16.h),
                          if (vet.bio != null) _buildAboutCard(vet),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          left: 20.w,
          right: 20.w,
          bottom: 32.h,
          child: _buildChatButton(),
        ),
      ],
    );
  }

  Widget _buildHeader(VetProfile? vet) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
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
            child: Text(
              'Vet Profile',
              style: TextStyle(
                fontSize: 20.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (vet != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: vet.isAvailable
                    ? const Color(0xFF10B981).withOpacity(0.1)
                    : const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: vet.isAvailable
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    vet.isAvailable ? 'Available' : 'Unavailable',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: vet.isAvailable
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
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

  Widget _buildProfileSection(VetProfile vet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        children: [
          Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 3,
              ),
              image: (widget.profilePhotoUrl ?? vet.profilePhotoUrl) != null
                  ? DecorationImage(
                      image: NetworkImage(widget.profilePhotoUrl ?? vet.profilePhotoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (widget.profilePhotoUrl ?? vet.profilePhotoUrl) == null
                ? Center(
                    child: Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                      size: 48.sp,
                    ),
                  )
                : null,
          ),
          SizedBox(height: 16.h),
          Text(
            vet.fullName,
            style: TextStyle(
              fontSize: 24.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            vet.degree,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.textSecondary,
            ),
          ),
          if (vet.rating > 0) ...[
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star_rounded,
                  color: const Color(0xFFFBBF24),
                  size: 20.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  vet.rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  '(${vet.totalReviews} reviews)',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(VetProfile vet) {
    return Container(
      padding: EdgeInsets.all(20.w),
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
          _buildInfoItem(
            icon: Icons.school_rounded,
            label: 'Degree',
            value: vet.degree,
          ),
          _buildDivider(),
          _buildInfoItem(
            icon: Icons.work_rounded,
            label: 'Experience',
            value: '${vet.experience} yrs',
          ),
          if (vet.licenseNumber != null) ...[
            _buildDivider(),
            _buildInfoItem(
              icon: Icons.verified_rounded,
              label: 'License',
              value: 'Verified',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 50.h,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildSpecializationsCard(VetProfile vet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Specializations',
            style: TextStyle(
              fontSize: 17.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: vet.specialization.map((spec) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  spec,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF6366F1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicCard(VetProfile vet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clinic Information',
            style: TextStyle(
              fontSize: 17.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          if (vet.clinicName != null)
            _buildClinicRow(
              icon: Icons.local_hospital_rounded,
              value: vet.clinicName!,
            ),
          if (vet.clinicAddress != null) ...[
            SizedBox(height: 12.h),
            _buildClinicRow(
              icon: Icons.location_on_rounded,
              value: vet.clinicAddress!,
            ),
          ],
          if (vet.city != null) ...[
            SizedBox(height: 12.h),
            _buildClinicRow(
              icon: Icons.place_rounded,
              value: '${vet.city}${vet.state != null ? ', ${vet.state}' : ''}',
            ),
          ],
          SizedBox(height: 12.h),
          _buildClinicRow(
            icon: Icons.phone_rounded,
            value: vet.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildClinicRow({required IconData icon, required String value}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeeCard(VetProfile vet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Consultation Fee',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Per session',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Text(
            'PKR ${vet.consultationFee.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 22.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(VetProfile vet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: TextStyle(
              fontSize: 17.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            vet.bio!,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatButton() {
    return GestureDetector(
      onTap: _isStartingChat ? null : () => _startChatWithVet(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: _isStartingChat ? AppColors.textSecondary : AppColors.primary,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isStartingChat)
              SizedBox(
                width: 20.w,
                height: 20.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 22.sp),
            SizedBox(width: 10.w),
            Text(
              _isStartingChat ? 'Starting Chat...' : 'Start Chat',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
