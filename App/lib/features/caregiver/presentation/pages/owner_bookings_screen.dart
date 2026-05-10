import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../data/models/booking_models.dart';
import '../../data/repositories/booking_repository.dart';
import 'booking_detail_screen.dart';

class OwnerBookingsScreen extends StatefulWidget {
  const OwnerBookingsScreen({super.key});

  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen>
    with SingleTickerProviderStateMixin {
  late final BookingRepository _repository;
  late final TabController _tabController;

  List<ServiceBooking> _pendingBookings = [];
  List<ServiceBooking> _activeBookings = [];
  List<ServiceBooking> _historyBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = getIt<BookingRepository>();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _repository.getMyBookings(role: 'owner', status: 'pending'),
        _repository.getMyBookings(
          role: 'owner',
          status: 'accepted,in_progress',
        ),
        _repository.getMyBookings(
          role: 'owner',
          status: 'completed,cancelled_owner,cancelled_caregiver,declined',
        ),
      ]);

      if (!mounted) return;

      setState(() {
        _pendingBookings = results[0].bookings;
        _activeBookings = results[1].bookings;
        _historyBookings = results[2].bookings;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      CustomSnackbar.showError(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'My Caregiver Bookings',
          style: AppTextStyles.titleLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          tabs: [
            Tab(text: 'Pending (${_pendingBookings.length})'),
            Tab(text: 'Active (${_activeBookings.length})'),
            Tab(text: 'History (${_historyBookings.length})'),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadBookings,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingsList(
                      _pendingBookings,
                      emptyMessage: 'No pending booking requests',
                    ),
                    _buildBookingsList(
                      _activeBookings,
                      emptyMessage: 'No active bookings currently',
                    ),
                    _buildBookingsList(
                      _historyBookings,
                      emptyMessage: 'No past bookings yet',
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildBookingsList(
    List<ServiceBooking> bookings, {
    required String emptyMessage,
  }) {
    if (bookings.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 120.h),
          Icon(
            Icons.event_note_outlined,
            size: 56.w,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          SizedBox(height: 12.h),
          Center(
            child: Text(
              emptyMessage,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildBookingCard(ServiceBooking booking) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BookingDetailScreen(bookingId: booking.id),
            ),
          );
          if (!mounted) return;
          await _loadBookings();
        },
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    booking.bookingNumber,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                  _buildStatusChip(booking.status),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                booking.serviceName ?? 'Pet Care Service',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                booking.caregiverName ?? 'Caregiver',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 15.w,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    _formatDateTime(booking.startDatetime),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${booking.currency} ${booking.totalAmount.toStringAsFixed(0)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (booking.status == 'completed') ...[
                SizedBox(height: 10.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => BookingDetailScreen(bookingId: booking.id),
                        ),
                      );
                      if (!mounted) return;
                      await _loadBookings();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                    ),
                    icon: Icon(
                      Icons.star_outline_rounded,
                      size: 16.sp,
                      color: colorScheme.primary,
                    ),
                    label: Text(
                      'Rate Caregiver',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'declined':
      case 'cancelled_owner':
      case 'cancelled_caregiver':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    }
  }

  String _formatDateTime(DateTime datetime) {
    final minutes = datetime.minute.toString().padLeft(2, '0');
    return '${datetime.day}/${datetime.month}/${datetime.year}  ${datetime.hour}:$minutes';
  }
}

