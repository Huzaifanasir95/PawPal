import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/community_hub_models.dart';
import '../cubit/events_cubit.dart';
import '../cubit/events_state.dart';
import 'event_detail_page.dart';
import 'create_event_page.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  static const _eventTypes = [
    'All',
    'Meetup',
    'Adoption Drive',
    'Training',
    'Competition',
    'Charity',
    'Other',
  ];

  static String _filterValue(String label) {
    if (label == 'All') return '';
    if (label == 'Adoption Drive') return 'adoption_drive';
    return label.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsCubit, EventsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
            heroTag: 'events_fab',
            onPressed: () async {
              final created = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<EventsCubit>(),
                    child: const CreateEventPage(),
                  ),
                ),
              );
              if (created == true) {
                context.read<EventsCubit>().loadEvents(eventType: state.filterType);
              }
            },
            child: Icon(Icons.add, color: AppColors.accent, size: 28.sp),
          ),
          body: Column(
            children: [
              // Filter chips
              SizedBox(
                height: 48.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: _eventTypes.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (context, i) {
                    final label = _eventTypes[i];
                    final val = _filterValue(label);
                    final isActive = (state.filterType ?? '') == val;
                    return GestureDetector(
                      onTap: () => context
                          .read<EventsCubit>()
                          .loadEvents(eventType: val.isEmpty ? null : val),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.accent : AppColors.surface,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isActive ? AppColors.accent : AppColors.border,
                          ),
                        ),
                        child: Text(
                          label,
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
              ),

              // Content
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.events.isEmpty
                        ? Center(
                            child: Text(
                              'No events found',
                              style: AppTextStyles.onboardingBody.copyWith(
                                fontSize: 15.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => context
                                .read<EventsCubit>()
                                .loadEvents(eventType: state.filterType),
                            child: ListView.separated(
                              padding: EdgeInsets.all(16.w),
                              itemCount: state.events.length,
                              separatorBuilder: (_, __) => SizedBox(height: 12.h),
                              itemBuilder: (context, i) =>
                                  _EventCard(event: state.events[i]),
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  final PetEvent event;
  const _EventCard({required this.event});

  Color get _typeColor {
    switch (event.eventType) {
      case 'meetup':
        return Colors.blue;
      case 'adoption_drive':
        return Colors.green;
      case 'training':
        return Colors.orange;
      case 'competition':
        return Colors.purple;
      case 'charity':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  String get _typeLabel {
    switch (event.eventType) {
      case 'meetup':
        return 'Meetup';
      case 'adoption_drive':
        return 'Adoption Drive';
      case 'training':
        return 'Training';
      case 'competition':
        return 'Competition';
      case 'charity':
        return 'Charity';
      default:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('EEE, MMM d · h:mm a');
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<EventsCubit>(),
            child: EventDetailPage(eventId: event.id),
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with type badge and status
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: _typeColor.withOpacity(0.08),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _typeColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      _typeLabel,
                      style: AppTextStyles.onboardingBody.copyWith(
                        fontSize: 11.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (event.isPetFriendly)
                    Row(
                      children: [
                        Icon(Icons.pets, size: 14.sp, color: _typeColor),
                        SizedBox(width: 4.w),
                        Text(
                          'Pet Friendly',
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 11.sp,
                            color: _typeColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: AppTextStyles.onboardingTitle.copyWith(
                      fontSize: 16.sp,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),

                  // Date
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14.sp, color: AppColors.textSecondary),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          dateFormatter.format(event.startDate),
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),

                  // Location
                  if (event.location != null && event.location!.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14.sp, color: AppColors.textSecondary),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: AppTextStyles.onboardingBody.copyWith(
                              fontSize: 13.sp,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 8.h),

                  Text(
                    event.description,
                    style: AppTextStyles.onboardingBody.copyWith(
                      fontSize: 13.sp,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12.h),

                  // Footer: attendees & capacity
                  Row(
                    children: [
                      Icon(Icons.people, size: 16.sp, color: AppColors.darkTeal),
                      SizedBox(width: 4.w),
                      Text(
                        '${event.rsvpCount} attending',
                        style: AppTextStyles.onboardingBody.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.darkTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (event.maxAttendees != null) ...[
                        Text(
                          ' / ${event.maxAttendees}',
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: event.status == 'upcoming'
                              ? AppColors.success.withOpacity(0.1)
                              : event.status == 'ongoing'
                                  ? Colors.blue.withOpacity(0.1)
                                  : AppColors.textSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          event.status.toUpperCase(),
                          style: AppTextStyles.onboardingBody.copyWith(
                            fontSize: 10.sp,
                            color: event.status == 'upcoming'
                                ? AppColors.success
                                : event.status == 'ongoing'
                                    ? Colors.blue
                                    : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
