import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/navigation/app_navigator.dart';
import '../../../caregiver/presentation/pages/caregivers_list_screen.dart';
import '../../../chatbot/presentation/pages/chatbot_screen.dart';
import '../../../pets/presentation/pages/my_pets_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';

class AllCategoriesPage extends StatelessWidget {
  const AllCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final actions = <_CategoryAction>[
      _CategoryAction(
        title: 'Community',
        subtitle: 'Forums and support',
        icon: Icons.groups_rounded,
        onTap: () => AppNavigator.navigateToCommunityHub(
          context,
          initialTabIndex: 0,
        ),
      ),
      _CategoryAction(
        title: 'Lost & Found',
        subtitle: 'Report and discover pets',
        icon: Icons.pets_rounded,
        onTap: () => AppNavigator.navigateToCommunityHub(
          context,
          initialTabIndex: 1,
        ),
      ),
      _CategoryAction(
        title: 'Adoption',
        subtitle: 'Find new companions',
        icon: Icons.volunteer_activism_rounded,
        onTap: () => AppNavigator.navigateToCommunityHub(
          context,
          initialTabIndex: 2,
        ),
      ),
      _CategoryAction(
        title: 'Events',
        subtitle: 'Meetups and activities',
        icon: Icons.event_available_rounded,
        onTap: () => AppNavigator.navigateToCommunityHub(
          context,
          initialTabIndex: 3,
        ),
      ),
      _CategoryAction(
        title: 'AI Chatbot',
        subtitle: 'Instant pet help',
        icon: Icons.smart_toy_outlined,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatbotScreen()),
        ),
      ),
      _CategoryAction(
        title: 'Marketplace',
        subtitle: 'Food, toys, essentials',
        icon: Icons.storefront_rounded,
        onTap: () => AppNavigator.navigateToMarketplace(context),
      ),
      _CategoryAction(
        title: 'Pet Caregiver Services',
        subtitle: 'Find trusted pet caregivers',
        icon: Icons.support_agent_rounded,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CaregiversListScreen()),
        ),
      ),
      _CategoryAction(
        title: 'Diet Plans',
        subtitle: 'Nutrition guidance',
        icon: Icons.restaurant_menu_rounded,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatbotScreen()),
        ),
      ),
      _CategoryAction(
        title: 'Pet Journals',
        subtitle: 'Track daily records',
        icon: Icons.edit_note_rounded,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyPetsScreen()),
        ),
      ),
      _CategoryAction(
        title: 'Vet Consultation',
        subtitle: 'Book trusted vets',
        icon: Icons.local_hospital_outlined,
        onTap: () => AppNavigator.navigateToVetsList(context),
      ),
      _CategoryAction(
        title: 'Chats',
        subtitle: 'Open your messages',
        icon: Icons.chat_bubble_outline_rounded,
        onTap: () => AppNavigator.navigateToChats(context),
      ),
      _CategoryAction(
        title: 'Orders',
        subtitle: 'Track your deliveries',
        icon: Icons.receipt_long_rounded,
        onTap: () => AppNavigator.navigateToOrders(context),
      ),
      _CategoryAction(
        title: 'Profile',
        subtitle: 'Manage account settings',
        icon: Icons.person_outline_rounded,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        title: Text(
          'All Categories',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
          child: GridView.builder(
            itemCount: actions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.08,
            ),
            itemBuilder: (context, index) {
              final action = actions[index];
              return InkWell(
                borderRadius: BorderRadius.circular(18.r),
                onTap: action.onTap,
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.r),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors:
                          isDark
                              ? <Color>[
                                colorScheme.surface,
                                colorScheme.surfaceContainerHighest,
                              ]
                              : const <Color>[
                                Color(0xFFF1F6F8),
                                Color(0xFFDDE9EE),
                              ],
                    ),
                    border: Border.all(
                      color:
                          isDark
                              ? colorScheme.outline.withValues(alpha: 0.26)
                              : const Color(0xFFB9CBD4),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.07),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(14.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44.w,
                          height: 44.h,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Icon(
                            action.icon,
                            size: 22.sp,
                            color: colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          action.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          action.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            height: 1.15,
                          ),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: colorScheme.onSurfaceVariant,
                            size: 18.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CategoryAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  _CategoryAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}