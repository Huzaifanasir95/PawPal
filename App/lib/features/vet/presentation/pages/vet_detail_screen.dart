import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../data/models/vet_profile_model.dart';
import '../../data/models/vet_review_model.dart';
import '../../data/models/vet_appointment_model.dart';
import '../../data/repositories/vet_appointment_repository.dart';
import '../../data/repositories/vet_repository.dart';
import '../bloc/vet_bloc.dart';
import '../bloc/vet_event.dart';
import '../bloc/vet_state.dart';
import '../../../chat/presentation/bloc/chat_bloc.dart';
import '../../../chat/presentation/bloc/chat_event.dart';
import '../../../chat/presentation/bloc/chat_state.dart';
import '../../../pets/data/models/pet_model.dart';
import '../../../pets/data/repositories/pet_repository_api.dart';

class VetDetailScreen extends StatefulWidget {
  final String vetId;
  final String? profilePhotoUrl;

  const VetDetailScreen({super.key, required this.vetId, this.profilePhotoUrl});

  @override
  State<VetDetailScreen> createState() => _VetDetailScreenState();
}

class _VetDetailScreenState extends State<VetDetailScreen>
    with SingleTickerProviderStateMixin {
  final VetRepository _vetRepository = VetRepository(ApiClient.instance);
  bool _isStartingChat = false;
  bool _isBookingAppointment = false;
  bool _isLoadingReviews = false;
  bool _isSubmittingReview = false;
  bool _animateIn = false;
  bool _isChatPressed = false;
  String? _reviewsError;
  List<VetReview> _reviews = const <VetReview>[];
  AnimationController? _pulseController;
  Animation<double> _pulseScale = const AlwaysStoppedAnimation<double>(1.0);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    );

    context.read<VetBloc>().add(VetEvent.loadVetProfile(widget.vetId));
    _loadReviews();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _animateIn = true);
      }
    });
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
        backgroundColor: AppColors.authBackground,
        body: MultiBlocListener(
          listeners: [
            BlocListener<VetBloc, VetState>(
              listener: (context, state) {
                state.maybeWhen(
                  error:
                      (message) => CustomSnackbar.showError(context, message),
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
                vetsListLoaded:
                    (_, __, ___, ____, _____, ______, _______, ________) =>
                        const SizedBox(),
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
      child: CircularProgressIndicator(color: AppColors.darkTeal),
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
                      onTap:
                          () => context.read<VetBloc>().add(
                            VetEvent.loadVetProfile(widget.vetId),
                          ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkTeal,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'Try Again',
                          style: TextStyle(
                            color: AppColors.surface,
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
        Positioned(
          top: -60.h,
          right: -40.w,
          child: Container(
            width: 180.w,
            height: 180.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.18),
            ),
          ),
        ),
        Positioned(
          top: 120.h,
          left: -50.w,
          child: Container(
            width: 140.w,
            height: 140.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.googleButton.withOpacity(0.14),
            ),
          ),
        ),
        Column(
          children: [
            SafeArea(bottom: false, child: _buildHeader(vet)),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                child: Column(
                  children: [
                    _buildEntranceSection(
                      index: 0,
                      child: _buildProfileSection(vet),
                    ),
                    _buildEntranceSection(index: 1, child: _buildInfoCard(vet)),
                    SizedBox(height: 14.h),
                    if (vet.specialization.isNotEmpty) ...[
                      _buildEntranceSection(
                        index: 2,
                        child: _buildSpecializationsCard(vet),
                      ),
                      SizedBox(height: 14.h),
                    ],
                    if (vet.clinicName != null ||
                        vet.clinicAddress != null) ...[
                      _buildEntranceSection(
                        index: 3,
                        child: _buildClinicCard(vet),
                      ),
                      SizedBox(height: 14.h),
                    ],
                    _buildEntranceSection(index: 4, child: _buildFeeCard(vet)),
                    if (vet.bio != null) ...[
                      SizedBox(height: 14.h),
                      _buildEntranceSection(
                        index: 5,
                        child: _buildAboutCard(vet),
                      ),
                    ],
                    SizedBox(height: 14.h),
                    _buildEntranceSection(
                      index: 6,
                      child: _buildReviewsCard(vet),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 14.h),
                child: _buildEntranceSection(
                  index: 7,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBookAppointmentButton(vet),
                      SizedBox(height: 10.h),
                      _buildChatButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.socialBorder),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.accent,
                size: 22.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              'Vet Profile',
              style: TextStyle(
                fontSize: 22.sp,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 44.w),
        ],
      ),
    );
  }

  Widget _buildEntranceSection({required int index, required Widget child}) {
    final delayFactor = (index * 0.05).clamp(0.0, 0.3);
    return AnimatedOpacity(
      opacity: _animateIn ? 1 : 0,
      duration: Duration(milliseconds: 280 + (index * 60)),
      curve: Curves.easeOut,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: _animateIn ? 1 : 0, end: _animateIn ? 0 : 1),
        duration: Duration(milliseconds: 320 + (index * 70)),
        curve: Curves.easeOutCubic,
        builder: (context, value, animatedChild) {
          return Transform.translate(
            offset: Offset(0, (20 * (1 - delayFactor)) * value),
            child: animatedChild,
          );
        },
        child: child,
      ),
    );
  }

  Widget _buildProfileSection(VetProfile vet) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.socialBorder.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              color: AppColors.googleButton.withOpacity(0.28),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: AppColors.socialBorder, width: 2),
              image:
                  (widget.profilePhotoUrl ?? vet.profilePhotoUrl) != null
                      ? DecorationImage(
                        image: NetworkImage(
                          widget.profilePhotoUrl ?? vet.profilePhotoUrl!,
                        ),
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            child:
                (widget.profilePhotoUrl ?? vet.profilePhotoUrl) == null
                    ? Center(
                      child: Icon(
                        Icons.person_rounded,
                        color: AppColors.darkTeal,
                        size: 48.sp,
                      ),
                    )
                    : null,
          ),
          SizedBox(height: 14.h),
          Text(
            vet.fullName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            vet.degree,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.authTitle,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (vet.rating > 0) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: const Color(0xFFFBBF24),
                    size: 18.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    vet.rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '${vet.totalReviews} reviews',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          width: 28.w,
          height: 28.h,
          decoration: BoxDecoration(
            color: AppColors.googleButton.withOpacity(0.35),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 16.sp, color: AppColors.darkTeal),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 17.sp,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(VetProfile vet) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.socialBorder.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
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
              color: AppColors.googleButton.withOpacity(0.35),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppColors.darkTeal, size: 22.sp),
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
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 50.h,
      color: AppColors.socialBorder.withOpacity(0.8),
    );
  }

  Widget _buildSpecializationsCard(VetProfile vet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.socialBorder.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.workspace_premium_rounded,
            title: 'Specializations',
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children:
                vet.specialization
                    .asMap()
                    .entries
                    .map((entry) => _buildAnimatedChip(entry.value, entry.key))
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedChip(String label, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: _animateIn ? 1 : 0, end: _animateIn ? 0 : 1),
      duration: Duration(milliseconds: 280 + (index * 80)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: 1 - (value * 0.35),
          child: Transform.translate(
            offset: Offset(0, 8 * value),
            child: child,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.googleButton.withOpacity(0.45),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.authTitle,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildClinicCard(VetProfile vet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.socialBorder.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.local_hospital_rounded,
            title: 'Clinic Information',
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
          _buildClinicRow(icon: Icons.phone_rounded, value: vet.phone),
        ],
      ),
    );
  }

  Widget _buildClinicRow({required IconData icon, required String value}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.darkTeal, size: 20.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.socialBorder.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
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
              _buildSectionTitle(
                icon: Icons.payments_rounded,
                title: 'Consultation Fee',
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
              color: AppColors.authTitle,
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.socialBorder.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(icon: Icons.info_outline_rounded, title: 'About'),
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

  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
      _reviewsError = null;
    });

    try {
      final reviews = await _vetRepository.getVetReviews(widget.vetId, limit: 20);
      if (!mounted) return;
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _reviewsError = e.toString().replaceFirst('Exception: ', '');
        _isLoadingReviews = false;
      });
    }
  }

  Future<void> _showVetReviewDialog(VetProfile vet) async {
    final currentUserId = ApiClient.instance.userId;
    if (currentUserId != null && currentUserId == vet.userId) {
      CustomSnackbar.showError(context, 'You cannot review your own vet profile.');
      return;
    }

    int rating = 5;
    final commentController = TextEditingController();

    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Rate This Vet'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reviews are allowed only after a completed appointment.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: List.generate(
                      5,
                      (index) => IconButton(
                        onPressed: () => setDialogState(() => rating = index + 1),
                        icon: Icon(
                          index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: const Color(0xFFFBBF24),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Write your review (optional)',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _isSubmittingReview
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isSubmittingReview
                      ? null
                      : () async {
                          setState(() => _isSubmittingReview = true);
                          try {
                            await _vetRepository.addVetReview(
                              vet.userId,
                              rating: rating,
                              comment: commentController.text.trim(),
                            );

                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop(true);
                            }
                          } catch (e) {
                            if (mounted) {
                              CustomSnackbar.showError(
                                context,
                                e.toString().replaceFirst('Exception: ', ''),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _isSubmittingReview = false);
                            }
                          }
                        },
                  child: _isSubmittingReview
                      ? SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );

    commentController.dispose();

    if (submitted == true) {
      if (mounted) {
        CustomSnackbar.showSuccess(context, 'Review submitted successfully!');
      }
      await _loadReviews();
      if (mounted) {
        context.read<VetBloc>().add(VetEvent.loadVetProfile(widget.vetId));
      }
    }
  }

  Widget _buildReviewsCard(VetProfile vet) {
    final canReview = ApiClient.instance.userId == null || ApiClient.instance.userId != vet.userId;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.socialBorder.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildSectionTitle(icon: Icons.reviews_rounded, title: 'Patient Reviews'),
              const Spacer(),
              if (canReview)
                TextButton.icon(
                  onPressed: _isSubmittingReview ? null : () => _showVetReviewDialog(vet),
                  icon: Icon(Icons.edit_rounded, size: 16.sp),
                  label: Text(
                    'Rate',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          if (_isLoadingReviews)
            const Center(child: CircularProgressIndicator(strokeWidth: 2))
          else if (_reviewsError != null)
            Text(
              _reviewsError!,
              style: TextStyle(color: const Color(0xFFEF4444), fontSize: 12.sp),
            )
          else if (_reviews.isEmpty)
            Text(
              'No reviews yet. Completed appointments can leave the first review.',
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
            )
          else
            Column(
              children: _reviews.take(5).map(_buildSingleReview).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSingleReview(VetReview review) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12.r,
                backgroundColor: AppColors.primary.withOpacity(0.25),
                child: Text(
                  (review.userName ?? 'P').isNotEmpty
                      ? (review.userName ?? 'P')[0].toUpperCase()
                      : 'P',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  review.userName ?? 'Pet owner',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                _formatReviewDate(review.createdAt),
                style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 16.sp,
                color: const Color(0xFFFBBF24),
              ),
            ),
          ),
          if (review.comment != null && review.comment!.trim().isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              review.comment!,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatReviewDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays < 1) return 'Today';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  Widget _buildBookAppointmentButton(VetProfile vet) {
    return GestureDetector(
      onTap:
          _isBookingAppointment ? null : () => _showBookAppointmentSheet(vet),
      child: AnimatedOpacity(
        opacity: _isBookingAppointment ? 0.7 : 1,
        duration: const Duration(milliseconds: 180),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.darkTeal.withOpacity(0.55)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_month_rounded,
                color: AppColors.darkTeal,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                _isBookingAppointment ? 'Preparing...' : 'Book Appointment',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.darkTeal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showBookAppointmentSheet(VetProfile vet) async {
    if (_isBookingAppointment) return;

    if (vet.userId.trim().isEmpty) {
      CustomSnackbar.showError(
        context,
        'Unable to book this vet right now. Missing vet account reference.',
      );
      return;
    }

    setState(() => _isBookingAppointment = true);

    final petRepository = PetRepositoryApi();
    final appointmentRepository = VetAppointmentRepository();

    List<PetModel> pets;
    try {
      pets = await petRepository.getPets();
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
      if (mounted) {
        setState(() => _isBookingAppointment = false);
      }
      return;
    }

    if (pets.isEmpty) {
      if (mounted) {
        CustomSnackbar.showInfo(
          context,
          'Add a pet profile before booking a vet appointment.',
        );
        setState(() => _isBookingAppointment = false);
      }
      return;
    }

    final reasonController = TextEditingController();
    final symptomsController = TextEditingController();
    final notesController = TextEditingController();

    String selectedPetId =
        pets
            .firstWhere(
              (pet) => pet.id.trim().isNotEmpty,
              orElse: () => pets.first,
            )
            .id;
    String meetingType = 'in_person';
    int duration = 30;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);
    bool isSubmitting = false;

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;

            Future<void> pickDate() async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: sheetContext,
                firstDate: now,
                lastDate: now.add(const Duration(days: 180)),
                initialDate: selectedDate,
              );
              if (picked != null) {
                setSheetState(() => selectedDate = picked);
              }
            }

            Future<void> pickTime() async {
              final picked = await showTimePicker(
                context: sheetContext,
                initialTime: selectedTime,
              );
              if (picked != null) {
                setSheetState(() => selectedTime = picked);
              }
            }

            Future<void> submit() async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                CustomSnackbar.showError(
                  context,
                  'Please provide appointment reason',
                );
                return;
              }

              if (reason.length < 3) {
                CustomSnackbar.showError(
                  context,
                  'Reason should be at least 3 characters',
                );
                return;
              }

              if (selectedPetId.trim().isEmpty) {
                CustomSnackbar.showError(
                  context,
                  'Please select a valid pet profile',
                );
                return;
              }

              final appointmentDateTime = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              );

              if (appointmentDateTime.isBefore(
                DateTime.now().add(const Duration(minutes: 5)),
              )) {
                CustomSnackbar.showError(
                  context,
                  'Please choose a future appointment time',
                );
                return;
              }

              setSheetState(() => isSubmitting = true);

              try {
                final normalizedMeetingType =
                    meetingType == 'video' ||
                            meetingType == 'chat' ||
                            meetingType == 'in_person'
                        ? meetingType
                        : 'in_person';
                final normalizedDuration =
                    <int>{15, 30, 45, 60}.contains(duration)
                        ? duration
                        : 30;

                await appointmentRepository.createAppointment(
                  CreateVetAppointmentRequest(
                    vetUserId: vet.userId,
                    petId: selectedPetId.trim(),
                    appointmentDatetime: appointmentDateTime,
                    durationMinutes: normalizedDuration,
                    meetingType: normalizedMeetingType,
                    reason: reason,
                    symptoms: symptomsController.text.trim(),
                    ownerNotes: notesController.text.trim(),
                    clinicAddress:
                        normalizedMeetingType == 'in_person'
                            ? (vet.clinicAddress?.trim().isNotEmpty == true
                                ? vet.clinicAddress!.trim()
                                : null)
                            : null,
                  ),
                );

                if (sheetContext.mounted) {
                  Navigator.of(sheetContext).pop(true);
                }
              } catch (e) {
                if (sheetContext.mounted) {
                  setSheetState(() => isSubmitting = false);
                }
                if (mounted) {
                  CustomSnackbar.showError(
                    context,
                    e.toString().replaceFirst('Exception: ', ''),
                  );
                }
              }
            }

            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              padding: EdgeInsets.fromLTRB(
                18.w,
                12.h,
                18.w,
                18.h + bottomInset,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      'Book Appointment',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    DropdownButtonFormField<String>(
                      value: selectedPetId,
                      decoration: const InputDecoration(
                        labelText: 'Select Pet',
                      ),
                      items:
                          pets
                              .map(
                                (pet) => DropdownMenuItem<String>(
                                  value: pet.id,
                                  child: Text('${pet.name} (${pet.type})'),
                                ),
                              )
                              .toList(),
                      onChanged:
                          isSubmitting
                              ? null
                              : (value) {
                                if (value != null) {
                                  setSheetState(() => selectedPetId = value);
                                }
                              },
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isSubmitting ? null : pickDate,
                            icon: const Icon(Icons.calendar_today_outlined),
                            label: Text(
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isSubmitting ? null : pickTime,
                            icon: const Icon(Icons.access_time_outlined),
                            label: Text(selectedTime.format(sheetContext)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    DropdownButtonFormField<String>(
                      value: meetingType,
                      decoration: const InputDecoration(
                        labelText: 'Meeting Type',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'in_person',
                          child: Text('In-person'),
                        ),
                        DropdownMenuItem(
                          value: 'video',
                          child: Text('Video Call'),
                        ),
                        DropdownMenuItem(
                          value: 'chat',
                          child: Text('Chat Consultation'),
                        ),
                      ],
                      onChanged:
                          isSubmitting
                              ? null
                              : (value) {
                                if (value != null) {
                                  setSheetState(() => meetingType = value);
                                }
                              },
                    ),
                    SizedBox(height: 12.h),
                    DropdownButtonFormField<int>(
                      value: duration,
                      decoration: const InputDecoration(labelText: 'Duration'),
                      items: const [
                        DropdownMenuItem(value: 15, child: Text('15 minutes')),
                        DropdownMenuItem(value: 30, child: Text('30 minutes')),
                        DropdownMenuItem(value: 45, child: Text('45 minutes')),
                        DropdownMenuItem(value: 60, child: Text('60 minutes')),
                      ],
                      onChanged:
                          isSubmitting
                              ? null
                              : (value) {
                                if (value != null) {
                                  setSheetState(() => duration = value);
                                }
                              },
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: reasonController,
                      enabled: !isSubmitting,
                      decoration: const InputDecoration(
                        labelText: 'Reason',
                        hintText: 'Describe the main concern',
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 10.h),
                    TextField(
                      controller: symptomsController,
                      enabled: !isSubmitting,
                      decoration: const InputDecoration(
                        labelText: 'Symptoms (optional)',
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 10.h),
                    TextField(
                      controller: notesController,
                      enabled: !isSubmitting,
                      decoration: const InputDecoration(
                        labelText: 'Additional Notes (optional)',
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : submit,
                        child:
                            isSubmitting
                                ? SizedBox(
                                  width: 18.w,
                                  height: 18.h,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('Confirm Appointment'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    reasonController.dispose();
    symptomsController.dispose();
    notesController.dispose();

    if (mounted) {
      setState(() => _isBookingAppointment = false);
      if (created == true) {
        CustomSnackbar.showSuccess(
          context,
          'Appointment request sent to ${vet.fullName}.',
        );
      }
    }
  }

  Widget _buildChatButton() {
    return GestureDetector(
      onTapDown:
          _isStartingChat ? null : (_) => setState(() => _isChatPressed = true),
      onTapUp:
          _isStartingChat
              ? null
              : (_) => setState(() => _isChatPressed = false),
      onTapCancel:
          _isStartingChat ? null : () => setState(() => _isChatPressed = false),
      onTap: _isStartingChat ? null : () => _startChatWithVet(context),
      child: AnimatedBuilder(
        animation: _pulseScale,
        builder: (context, child) {
          final shouldPulse = !_isStartingChat && !_isChatPressed;
          return Transform.scale(
            scale: shouldPulse ? _pulseScale.value : 1,
            child: child,
          );
        },
        child: AnimatedScale(
          scale: _isChatPressed ? 0.98 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    _isStartingChat
                        ? [AppColors.textSecondary, AppColors.textSecondary]
                        : [AppColors.darkTeal, AppColors.authTitle],
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkTeal.withOpacity(
                    _isChatPressed ? 0.15 : 0.25,
                  ),
                  blurRadius: _isChatPressed ? 8 : 16,
                  offset: Offset(0, _isChatPressed ? 3 : 6),
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
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.surface,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.chat_bubble_rounded,
                    color: AppColors.surface,
                    size: 22.sp,
                  ),
                SizedBox(width: 10.w),
                Text(
                  _isStartingChat ? 'Starting Chat...' : 'Start Chat',
                  style: TextStyle(
                    color: AppColors.surface,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }
}
