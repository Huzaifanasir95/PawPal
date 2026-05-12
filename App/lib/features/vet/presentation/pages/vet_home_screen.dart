import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/services/api_client.dart';
import '../../data/models/vet_profile_model.dart';
import '../../data/repositories/vet_repository.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../chat/data/models/chat_model.dart';
import '../bloc/vet_bloc.dart';
import '../bloc/vet_event.dart';
import '../bloc/vet_state.dart';
import '../../../chat/presentation/bloc/chat_bloc.dart';
import '../../../chat/presentation/bloc/chat_event.dart';
import '../../../chat/presentation/bloc/chat_state.dart';
import '../../../chat/presentation/pages/chat_conversation_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import 'vet_appointments_screen.dart';
import 'vet_profile_setup_screen.dart';

class VetHomeScreen extends StatefulWidget {
  const VetHomeScreen({super.key});

  @override
  State<VetHomeScreen> createState() => _VetHomeScreenState();
}

class _VetHomeScreenState extends State<VetHomeScreen> {
  int _currentIndex = 0;
  bool _isCheckingProfile = true;
  bool _hasRedirectedToSetup = false;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    await _ensureVetProfileIsReady();
    if (!mounted || _hasRedirectedToSetup) return;

    setState(() {
      _isCheckingProfile = false;
    });

    _refreshDashboard();
  }

  Future<void> _refreshDashboard() async {
    context.read<VetBloc>().add(const VetEvent.loadMyProfile());
    context.read<ChatBloc>().add(const ChatEvent.loadChats());
  }

  Future<void> _ensureVetProfileIsReady() async {
    try {
      final profile = await VetRepository(ApiClient.instance).getMyProfile();
      if (_isProfileComplete(profile)) {
        return;
      }

      await _navigateToProfileSetup();
    } catch (e) {
      if (_isProfileMissingMessage(e.toString())) {
        await _navigateToProfileSetup();
      }
    }
  }

  bool _isProfileComplete(VetProfile profile) {
    return profile.fullName.trim().isNotEmpty &&
        profile.degree.trim().isNotEmpty &&
        profile.experience > 0 &&
        profile.specialization.isNotEmpty &&
        profile.phone.trim().isNotEmpty &&
        profile.consultationFee > 0;
  }

  bool _isProfileMissingMessage(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('profile not found') ||
        (normalized.contains('vet profile') &&
            normalized.contains('not found')) ||
        normalized.contains('no vet profile');
  }

  Future<void> _navigateToProfileSetup() async {
    if (!mounted || _hasRedirectedToSetup) return;

    _hasRedirectedToSetup = true;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const VetProfileSetupScreen()),
    );
  }

  Future<void> _openVetProfileEditor({required int initialStep}) async {
    if (!mounted) return;

    final didUpdate = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (context) => VetProfileSetupScreen(
              isEditing: true,
              initialStep: initialStep,
            ),
      ),
    );

    if (didUpdate == true && mounted) {
      await _refreshDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isCheckingProfile) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return BlocListener<VetBloc, VetState>(
      listener: (context, state) {
        state.maybeWhen(
          error: (message) {
            if (_isProfileMissingMessage(message)) {
              _navigateToProfileSetup();
            } else {
              CustomSnackbar.showError(context, message);
            }
          },
          orElse: () {},
        );
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: RefreshIndicator(
          onRefresh: _refreshDashboard,
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
                  child: Builder(builder: (context) {
                    final colorScheme = Theme.of(context).colorScheme;
                    return Text(
                      'Pending Chats',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    );
                  }),
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
                  child: Builder(builder: (context) {
                    final colorScheme = Theme.of(context).colorScheme;
                    return Text(
                      'Quick Actions',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    );
                  }),
                ),
                SizedBox(height: 12.h),

                _buildQuickActions(),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.colorScheme.surface,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurfaceVariant,
          currentIndex: _currentIndex,
          onTap: (index) {
            switch (index) {
              case 0: // Home/Dashboard
                setState(() {
                  _currentIndex = 0;
                });
                break;
              case 1: // Chats
                AppNavigator.navigateToChats(context);
                break;
              case 2: // Profile
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(VetProfile profile) {
    // Get user's photo from auth state
    final userPhotoUrl = context.read<AuthBloc>().state.maybeWhen(
      authenticated: (user) => user.photoUrl,
      orElse: () => null,
    );

    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)],
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
                UserAvatar(
                  imageUrl: userPhotoUrl ?? profile.profilePhotoUrl,
                  size: 64.r,
                  showBorder: true,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.onPrimary.withValues(alpha: 0.85),
                        ),
                      ),
                      Text(
                        profile.fullName,
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: colorScheme.onPrimary,
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
                color:
                    profile.isAvailable
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.orange.withValues(alpha: 0.2),
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
                      color: colorScheme.onPrimary,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(20.w),
      color: colorScheme.primary,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32.r,
                  backgroundColor: colorScheme.onPrimary.withValues(alpha: 0.25),
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
                          color: colorScheme.onPrimary.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 150.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimary.withValues(alpha: 0.25),
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
          Expanded(
            child: _StatCard(
              icon: Icons.medical_services,
              iconColor: Theme.of(context).colorScheme.primary,
              title: 'Experience',
              value: '${profile.experience}',
              subtitle: 'Years',
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                int unreadCount = 0;
                state.maybeWhen(
                  chatsLoaded: (chats) {
                    unreadCount = chats.fold(
                      0,
                      (sum, chat) => sum + chat.unreadCountVet,
                    );
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
    final pendingChats =
        chats.where((chat) => chat.unreadCountVet > 0).toList();

    final colorScheme = Theme.of(context).colorScheme;
    if (pendingChats.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 48.sp,
                color: Colors.green,
              ),
              SizedBox(height: 12.h),
              Text(
                'All caught up!',
                style: AppTextStyles.titleMedium.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'No pending chats at the moment',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
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
    final colorScheme = Theme.of(context).colorScheme;
    final shimmer = colorScheme.onSurface.withValues(alpha: 0.08);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: List.generate(3, (index) {
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: shimmer,
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
                          color: shimmer,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 180.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: shimmer,
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
              _openVetProfileEditor(initialStep: 0);
            },
          ),
          SizedBox(height: 12.h),
          _QuickActionButton(
            icon: Icons.schedule,
            title: 'Manage Availability',
            subtitle: 'Update your schedule',
            onTap: () {
              _openVetProfileEditor(initialStep: 4);
            },
          ),
          SizedBox(height: 12.h),
          _QuickActionButton(
            icon: Icons.event_note_outlined,
            title: 'Manage Appointments',
            subtitle: 'Respond to requests and complete visits',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VetAppointmentsScreen(isVetView: true),
                ),
              );
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28.sp, color: iconColor),
          SizedBox(height: 8.h),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
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
      child: Builder(builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                  child: Icon(
                    Icons.person,
                    size: 24.sp,
                    color: colorScheme.primary,
                  ),
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
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (chat.lastMessage != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      chat.lastMessage!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
        );
      }),
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
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 24.sp),
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
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
