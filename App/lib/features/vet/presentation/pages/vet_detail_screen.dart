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
    return CustomScrollView(
      slivers: [
        // App Bar with Image
        SliverAppBar(
          expandedHeight: 200.h,
          pinned: true,
          backgroundColor: AppColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: AppColors.primary.withOpacity(0.2),
              child: Center(
                child: UserAvatar(
                  imageUrl: widget.profilePhotoUrl ?? vet.profilePhotoUrl,
                  size: 160.sp,
                  fallbackIcon: Icons.person,
                ),
              ),
            ),
          ),
        ),

        // Profile Content
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name and Basic Info
              Container(
                padding: EdgeInsets.all(20.w),
                color: AppColors.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vet.fullName,
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      vet.degree,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Rating (commented out - fields not in model yet)
                    // if (vet.averageRating != null && vet.totalRatings != null)
                    //   Row(
                    //     children: [
                    //       ...List.generate(5, (index) {
                    //         return Icon(
                    //           index < vet.averageRating!.round()
                    //               ? Icons.star
                    //               : Icons.star_border,
                    //           color: Colors.amber,
                    //           size: 20.sp,
                    //         );
                    //       }),
                    //       SizedBox(width: 8.w),
                    //       Text(
                    //         '${vet.averageRating!.toStringAsFixed(1)} (${vet.totalRatings} reviews)',
                    //         style: AppTextStyles.bodyMedium.copyWith(
                    //           color: AppColors.textSecondary,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // Qualifications
              _buildSection(
                'Qualifications',
                [
                  _buildInfoRow(Icons.school, 'Degree', vet.degree),
                  if (vet.licenseNumber != null)
                    _buildInfoRow(Icons.badge, 'License', vet.licenseNumber!),
                  _buildInfoRow(Icons.work, 'Experience', '${vet.experience} years'),
                ],
              ),

              SizedBox(height: 12.h),

              // Specializations
              if (vet.specialization.isNotEmpty)
                _buildSection(
                  'Specializations',
                  [
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: vet.specialization.map((spec) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: AppColors.primary),
                          ),
                          child: Text(
                            spec,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

              SizedBox(height: 12.h),

              // Clinic Information
              if (vet.clinicName != null || vet.clinicAddress != null)
                _buildSection(
                  'Clinic Information',
                  [
                    if (vet.clinicName != null)
                      _buildInfoRow(Icons.local_hospital, 'Clinic', vet.clinicName!),
                    if (vet.clinicAddress != null)
                      _buildInfoRow(Icons.location_on, 'Address', vet.clinicAddress!),
                    if (vet.city != null && vet.state != null)
                      _buildInfoRow(Icons.place, 'Location', '${vet.city}, ${vet.state}'),
                    _buildInfoRow(Icons.phone, 'Phone', vet.phone),
                  ],
                ),

              SizedBox(height: 12.h),

              // Availability
              if (vet.availabilityHours != null)
                _buildSection(
                  'Availability',
                  [
                    _buildInfoRow(Icons.access_time, 'Hours', vet.availabilityHours!),
                    _buildInfoRow(
                      Icons.circle,
                      'Status',
                      vet.isAvailable ? 'Available' : 'Not Available',
                      valueColor: vet.isAvailable ? AppColors.success : AppColors.error,
                    ),
                  ],
                ),

              SizedBox(height: 12.h),

              // About
              if (vet.bio != null)
                _buildSection(
                  'About',
                  [
                    Text(
                      vet.bio!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),

              SizedBox(height: 12.h),

              // Consultation Fee
              _buildSection(
                'Consultation Fee',
                [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Consultation Fee',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${vet.currency} \$${vet.consultationFee.toStringAsFixed(0)}',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 100.h), // Space for floating button
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(20.w),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.sp, color: AppColors.textSecondary),
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
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: valueColor ?? AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
