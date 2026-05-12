import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../cubit/events_cubit.dart';
import '../cubit/events_state.dart';

class EventDetailPage extends StatefulWidget {
  final String eventId;
  const EventDetailPage({super.key, required this.eventId});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<EventsCubit>().loadEventDetail(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventsCubit, EventsState>(
      listener: (context, state) {
        if (state.error != null) {
          CustomSnackbar.showError(context, state.error!);
          context.read<EventsCubit>().clearError();
        }
      },
      builder: (context, state) {
        final event = state.selectedEvent;
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
              'Event Details',
              style: AppTextStyles.onboardingTitle.copyWith(
                fontSize: 20.sp,
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: state.isLoadingDetail || event == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + type badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: AppTextStyles.onboardingTitle.copyWith(
                                fontSize: 22.sp,
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _typeBadge(event.eventType),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Date & time
                      _infoCard(
                        icon: Icons.calendar_today,
                        title: 'Date & Time',
                        content: _formatDateRange(event.startDate, event.endDate),
                      ),
                      SizedBox(height: 12.h),

                      // Location
                      if (event.location != null && event.location!.isNotEmpty)
                        _infoCard(
                          icon: Icons.location_on,
                          title: 'Location',
                          content: event.location!,
                        ),
                      SizedBox(height: 12.h),

                      // Capacity
                      _infoCard(
                        icon: Icons.people,
                        title: 'Attendees',
                        content: event.maxAttendees != null
                            ? '${event.rsvpCount} / ${event.maxAttendees} spots filled'
                            : '${event.rsvpCount} attending',
                      ),
                      SizedBox(height: 12.h),

                      // Pet friendly
                      if (event.isPetFriendly)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiaryContainer,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiary
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.pets,
                                size: 20.sp,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pet Friendly Event',
                                      style: AppTextStyles.onboardingBody.copyWith(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onTertiaryContainer,
                                      ),
                                    ),
                                    if (event.petTypesAllowed.isNotEmpty)
                                      Text(
                                        'Allowed: ${event.petTypesAllowed.join(', ')}',
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
                      SizedBox(height: 20.h),

                      // Description
                      Text(
                        'About this Event',
                        style: AppTextStyles.onboardingTitle.copyWith(
                          fontSize: 16.sp,
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        event.description,
                        style: AppTextStyles.onboardingBody.copyWith(
                          fontSize: 14.sp,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Status
                      Row(
                        children: [
                          Text(
                            'Status: ',
                            style: AppTextStyles.onboardingBody.copyWith(
                              fontSize: 14.sp,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: _statusColor(event.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              event.status.toUpperCase(),
                              style: AppTextStyles.onboardingBody.copyWith(
                                fontSize: 12.sp,
                                color: _statusColor(event.status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // RSVP buttons
                      _buildRsvpSection(context, state),
                      SizedBox(height: 24.h),

                      // Attendees list
                      if (state.eventRsvps.isNotEmpty) ...[
                        Text(
                          'Attendees (${state.eventRsvps.length})',
                          style: AppTextStyles.onboardingTitle.copyWith(
                            fontSize: 16.sp,
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        ...state.eventRsvps.map((rsvp) => Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18.r,
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    backgroundImage: rsvp.userAvatar != null
                                        ? NetworkImage(rsvp.userAvatar!)
                                        : null,
                                    child: rsvp.userAvatar == null
                                        ? Icon(Icons.person, size: 18.sp, color: Theme.of(context).colorScheme.secondary)
                                        : null,
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Text(
                                      rsvp.userName ?? 'User',
                                      style: AppTextStyles.onboardingBody.copyWith(
                                        fontSize: 14.sp,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                    decoration: BoxDecoration(
                                      color: rsvp.status == 'going'
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Text(
                                      rsvp.status,
                                      style: AppTextStyles.onboardingBody.copyWith(
                                        fontSize: 11.sp,
                                        color: rsvp.status == 'going'
                                            ? Colors.green
                                            : Colors.blue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                      SizedBox(height: 16.h),

                      // Organizer
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Theme.of(context).colorScheme.outline),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20.r,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              backgroundImage: event.organizerAvatar != null
                                  ? NetworkImage(event.organizerAvatar!)
                                  : null,
                              child: event.organizerAvatar == null
                                  ? Icon(Icons.person, size: 20.sp, color: Theme.of(context).colorScheme.secondary)
                                  : null,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Organized by',
                                    style: AppTextStyles.onboardingBody.copyWith(
                                      fontSize: 11.sp,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                  Text(
                                    event.organizerName ?? 'Unknown',
                                    style: AppTextStyles.onboardingBody.copyWith(
                                      fontSize: 14.sp,
                                      color: Theme.of(context).colorScheme.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildRsvpSection(BuildContext context, EventsState state) {
    final myRsvp = state.myRsvp;
    final isRsvping = state.isRsvping;

    if (myRsvp != null) {
      // User has RSVPed
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Text(
              'You\'re ${myRsvp.status == 'going' ? 'Going' : 'Interested'}!',
              style: AppTextStyles.onboardingTitle.copyWith(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: isRsvping
                    ? null
                    : () => context.read<EventsCubit>().cancelRsvp(widget.eventId),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: isRsvping
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Cancel RSVP',
                        style: AppTextStyles.onboardingBody.copyWith(
                          fontSize: 14.sp,
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    }

    // No RSVP yet — show buttons
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isRsvping
                ? null
                : () => context.read<EventsCubit>().rsvpEvent(widget.eventId, 'going'),
            icon: isRsvping
                ? SizedBox(
                    width: 18.w,
                    height: 18.h,
                    child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check_circle, color: Colors.white),
            label: Text(
              'Going',
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isRsvping
                ? null
                : () => context.read<EventsCubit>().rsvpEvent(widget.eventId, 'interested'),
            icon: Icon(
              Icons.star_outline,
              color: Theme.of(context).colorScheme.secondary,
            ),
            label: Text(
              'Interested',
              style: AppTextStyles.onboardingBody.copyWith(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).colorScheme.secondary),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.onboardingBody.copyWith(
                    fontSize: 11.sp,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  content,
                  style: AppTextStyles.onboardingBody.copyWith(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface,
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

  Widget _typeBadge(String type) {
    Color color;
    String label;
    switch (type) {
      case 'meetup':
        color = Colors.blue;
        label = 'Meetup';
        break;
      case 'adoption_drive':
        color = Colors.green;
        label = 'Adoption Drive';
        break;
      case 'training':
        color = Colors.orange;
        label = 'Training';
        break;
      case 'competition':
        color = Colors.purple;
        label = 'Competition';
        break;
      case 'charity':
        color = Colors.pink;
        label = 'Charity';
        break;
      default:
        color = Colors.grey;
        label = 'Other';
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.onboardingBody.copyWith(
          fontSize: 11.sp,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'upcoming':
        return Colors.green;
      case 'ongoing':
        return Colors.blue;
      case 'completed':
        return Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
      case 'cancelled':
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    }
  }

  String _formatDateRange(DateTime start, DateTime? end) {
    final fmt = DateFormat('EEE, MMM d, yyyy · h:mm a');
    if (end == null) return fmt.format(start);
    final dateFmt = DateFormat('EEE, MMM d, yyyy');
    final timeFmt = DateFormat('h:mm a');
    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      return '${dateFmt.format(start)} · ${timeFmt.format(start)} - ${timeFmt.format(end)}';
    }
    return '${fmt.format(start)} –\n${fmt.format(end)}';
  }
}


