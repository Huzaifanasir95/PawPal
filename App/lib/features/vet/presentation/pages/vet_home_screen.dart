import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../data/models/vet_profile_model.dart';
import '../../../chat/data/models/chat_model.dart';
import '../bloc/vet_bloc.dart';
import '../bloc/vet_event.dart';
import '../bloc/vet_state.dart';
import '../../../chat/presentation/bloc/chat_bloc.dart';
import '../../../chat/presentation/bloc/chat_event.dart';
import '../../../chat/presentation/bloc/chat_state.dart';
import '../../../chat/presentation/pages/chat_conversation_screen.dart';
import 'vet_profile_setup_screen.dart';

class VetHomeScreen extends StatefulWidget {
  const VetHomeScreen({super.key});

  @override
  State<VetHomeScreen> createState() => _VetHomeScreenState();
}

class _VetHomeScreenState extends State<VetHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VetBloc>().add(const VetEvent.loadMyProfile());
    context.read<ChatBloc>().add(const ChatEvent.loadChats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Vet Dashboard'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<VetBloc>().add(const VetEvent.loadMyProfile());
              context.read<ChatBloc>().add(const ChatEvent.loadChats());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<VetBloc>().add(const VetEvent.loadMyProfile());
          context.read<ChatBloc>().add(const ChatEvent.loadChats());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              BlocBuilder<VetBloc, VetState>(
                builder: (context, state) {
                  return state.maybeWhen(
                    profileLoaded: (profile) => _buildWelcomeHeader(profile),
                    orElse: () => _buildWelcomeHeaderSkeleton(),
                  );
                },
              ),

              SizedBox(height: 16.h),

              // Stats Cards
              BlocBuilder<VetBloc, VetState>(
                builder: (context, state) {
                  return state.maybeWhen(
                    profileLoaded: (profile) => _buildStatsCards(profile),
                    orElse: () => const SizedBox(),
                  );
                },
              ),

              SizedBox(height: 24.h),

              // Pending Chats Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  'Pending Chats',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  return state.maybeWhen(
                    chatsLoaded: (chats) => _buildPendingChats(chats),
                    orElse: () => _buildPendingChatsSkeleton(),
                  );
                },
              ),

              SizedBox(height: 24.h),

              // Quick Actions
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  'Quick Actions',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              _buildQuickActions(),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(VetProfile profile) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32.r,
                  backgroundColor: AppColors.surface,
                  child: Icon(Icons.person, size: 32.sp, color: AppColors.primary),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textOnPrimary.withOpacity(0.9),
                        ),
                      ),
                      Text(
                        profile.fullName,
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: profile.isAvailable
                    ? Colors.green.withOpacity(0.2)
                    : Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: profile.isAvailable ? Colors.green : Colors.orange,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 8.sp,
                    color: profile.isAvailable ? Colors.green : Colors.orange,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    profile.isAvailable ? 'Available' : 'Not Available',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeaderSkeleton() {
    return Container(
      padding: EdgeInsets.all(20.w),
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32.r,
                  backgroundColor: AppColors.surface.withOpacity(0.3),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: AppColors.surface.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 150.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: AppColors.surface.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(VetProfile profile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          // Rating card - commented out until averageRating field added to model
          // Expanded(
          //   child: _StatCard(
          //     icon: Icons.star,
          //     iconColor: Colors.amber,
          //     title: 'Rating',
          //     value: profile.averageRating?.toStringAsFixed(1) ?? 'N/A',
          //     subtitle: '${profile.totalRatings ?? 0} reviews',
          //   ),
          // ),
          // SizedBox(width: 12.w),
          Expanded(
            child: _StatCard(
              icon: Icons.medical_services,
              iconColor: AppColors.primary,
              title: 'Experience',
              value: '${profile.experience}',
              subtitle: 'Years',
            ),
          ),
          SizedBox(width: 12.w),
          // Consultations card - commented out until totalConsultations field added
          // Expanded(
          //   child: _StatCard(
          //     icon: Icons.medical_services,
          //     iconColor: AppColors.primary,
          //     title: 'Consultations',
          //     value: profile.totalConsultations?.toString() ?? '0',
          //     subtitle: 'Total',
          //   ),
          // ),
          // SizedBox(width: 12.w),
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                int unreadCount = 0;
                state.maybeWhen(
                  chatsLoaded: (chats) {
                    unreadCount = chats.fold(0, (sum, chat) => sum + chat.unreadCountVet);
                  },
                  orElse: () {},
                );
                
                return _StatCard(
                  icon: Icons.chat,
                  iconColor: Colors.blue,
                  title: 'Pending',
                  value: unreadCount.toString(),
                  subtitle: 'Chats',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingChats(List<Chat> chats) {
    final pendingChats = chats.where((chat) => chat.unreadCountVet > 0).toList();

    if (pendingChats.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.check_circle_outline, size: 48.sp, color: AppColors.success),
              SizedBox(height: 12.h),
              Text(
                'All caught up!',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'No pending chats at the moment',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: pendingChats.take(5).length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final chat = pendingChats[index];
        return _PendingChatCard(chat: chat);
      },
    );
  }

  Widget _buildPendingChatsSkeleton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: List.generate(3, (index) {
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: AppColors.neutral300,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: AppColors.neutral300,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 180.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: AppColors.neutral300,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          _QuickActionButton(
            icon: Icons.edit,
            title: 'Edit Profile',
            subtitle: 'Update your information',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VetProfileSetupScreen()),
              );
            },
          ),
          SizedBox(height: 12.h),
          _QuickActionButton(
            icon: Icons.schedule,
            title: 'Manage Availability',
            subtitle: 'Update your schedule',
            onTap: () {
              CustomSnackbar.showInfo(context, 'Coming soon!');
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28.sp, color: iconColor),
          SizedBox(height: 8.h),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingChatCard extends StatelessWidget {
  final Chat chat;

  const _PendingChatCard({required this.chat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatConversationScreen(chatId: chat.id),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(Icons.person, size: 24.sp, color: AppColors.primary),
                ),
                if (chat.unreadCountVet > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        chat.unreadCountVet.toString(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pet Owner',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (chat.lastMessage != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      chat.lastMessage!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
