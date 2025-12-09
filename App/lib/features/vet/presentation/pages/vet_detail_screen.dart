import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/user_avatar.dart';
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

    setState(() {
      _isStartingChat = true;
    });

    // Start chat - petId will be determined from authenticated user by backend
    context.read<ChatBloc>().add(
      ChatEvent.startChat(
        vetId: widget.vetId,
        petId: null, // Backend will use authenticated user's ID
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: BlocBuilder<VetBloc, VetState>(
        builder: (context, state) {
          return state.maybeWhen(
            profileLoaded: (vet) => FloatingActionButton.extended(
              onPressed: _isStartingChat ? null : () => _startChatWithVet(context),
              backgroundColor: _isStartingChat ? AppColors.textSecondary : AppColors.primary,
              icon: _isStartingChat
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
                      ),
                    )
                  : Icon(Icons.chat_bubble_outline, color: AppColors.textOnPrimary),
              label: Text(
                _isStartingChat ? 'Starting...' : 'Start Chat',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          );
        },
      ),
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
                    setState(() {
                      _isStartingChat = false;
                    });
                    // Use passed profile photo first, then fall back to BLoC data
                    String? vetName;
                    String? vetPhoto = widget.profilePhotoUrl;
                    
                    final vetState = context.read<VetBloc>().state;
                    vetState.maybeWhen(
                      profileLoaded: (vet) {
                        vetName = vet.fullName;
                        // Only use BLoC photo if we don't have passed photo
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
                    setState(() {
                      _isStartingChat = false;
                    });
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
              initial: () => const Center(child: Text('Loading...')),
              loading: () => const Center(child: CircularProgressIndicator()),
              profileLoaded: (vet) => _buildProfileContent(context, vet),
              vetsListLoaded: (_, __, ___, ____, _____, ______, _______, ________) => const SizedBox(),
              profileSaved: (_) => const SizedBox(),
              error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading profile',
                    style: AppTextStyles.titleMedium,
                  ),
                  SizedBox(height: 8.h),
                  Text(message, style: AppTextStyles.bodyMedium),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<VetBloc>().add(VetEvent.loadVetProfile(widget.vetId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, VetProfile vet) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          vet.fullName,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.background,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Profile Image
                  UserAvatar(
                    imageUrl: widget.profilePhotoUrl ?? vet.profilePhotoUrl,
                    size: 120.sp,
                    fallbackIcon: Icons.person,
                    showBorder: true,
                    borderColor: AppColors.primary,
                    borderWidth: 4,
                  ),
                  SizedBox(height: 16.h),
                  // Name and Degree
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        Text(
                          vet.fullName,
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          vet.degree,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),

          // Qualifications Card
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Qualifications',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildQualificationItem(Icons.school, 'Degree', vet.degree),
                  if (vet.licenseNumber != null) ...[
                    SizedBox(height: 16.h),
                    _buildQualificationItem(Icons.badge, 'License', vet.licenseNumber!),
                  ],
                  SizedBox(height: 16.h),
                  _buildQualificationItem(Icons.work_outline, 'Experience', '${vet.experience} years'),
                ],
              ),
            ),
          ),

          // Specializations Card
          if (vet.specialization.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
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
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 10.h,
                      children: vet.specialization.map((spec) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.15),
                                AppColors.primary.withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            spec,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: 16.h),

          // Clinic Information Card
          if (vet.clinicName != null || vet.clinicAddress != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
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
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    if (vet.clinicName != null)
                      _buildQualificationItem(Icons.local_hospital, 'Clinic', vet.clinicName!),
                    if (vet.clinicAddress != null) ...[
                      SizedBox(height: 16.h),
                      _buildQualificationItem(Icons.location_on, 'Address', vet.clinicAddress!),
                    ],
                    if (vet.city != null && vet.state != null) ...[
                      SizedBox(height: 16.h),
                      _buildQualificationItem(Icons.place, 'Location', '${vet.city}, ${vet.state}'),
                    ],
                    SizedBox(height: 16.h),
                    _buildQualificationItem(Icons.phone, 'Phone', vet.phone),
                  ],
                ),
              ),
            ),
          SizedBox(height: 16.h),

          // Availability Card
          if (vet.availabilityHours != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Availability',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    _buildQualificationItem(Icons.access_time, 'Hours', vet.availabilityHours!),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: (vet.isAvailable ? AppColors.success : AppColors.error).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.circle,
                            size: 18.sp,
                            color: vet.isAvailable ? AppColors.success : AppColors.error,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              vet.isAvailable ? 'Available' : 'Not Available',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: vet.isAvailable ? AppColors.success : AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: 16.h),

          // Consultation Fee Card
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
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
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Per Session',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${vet.currency} \$${vet.consultationFee.toStringAsFixed(0)}',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // About Card
          if (vet.bio != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
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
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      vet.bio!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: 16.h),

          SizedBox(height: 100.h), // Space for floating button
        ],
      ),
      ),
    );
  }

  Widget _buildQualificationItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            size: 20.sp,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
