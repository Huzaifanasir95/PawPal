import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/repositories/caregiver_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/models/caregiver_models.dart';
import '../../data/models/booking_models.dart';
import 'caregiver_services_screen.dart';
import 'caregiver_availability_screen.dart';
import 'booking_detail_screen.dart';

class CaregiverHomeScreen extends StatefulWidget {
  const CaregiverHomeScreen({super.key});

  @override
  State<CaregiverHomeScreen> createState() => _CaregiverHomeScreenState();
}

class _CaregiverHomeScreenState extends State<CaregiverHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CaregiverRepository _caregiverRepo;
  late BookingRepository _bookingRepo;

  CaregiverProfile? _profile;
  List<ServiceBooking> _pendingBookings = [];
  List<ServiceBooking> _activeBookings = [];
  List<ServiceBooking> _completedBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _caregiverRepo = getIt<CaregiverRepository>();
    _bookingRepo = getIt<BookingRepository>();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final profileData = await _caregiverRepo.getMyProfile();
      _profile = profileData.profile;

      // Load bookings for caregiver
      final pendingResult = await _bookingRepo.getMyBookings(role: 'caregiver', status: 'pending');
      final activeResult = await _bookingRepo.getMyBookings(role: 'caregiver', status: 'accepted,in_progress');
      final completedResult = await _bookingRepo.getMyBookings(role: 'caregiver', status: 'completed');

      setState(() {
        _pendingBookings = pendingResult.bookings;
        _activeBookings = activeResult.bookings;
        _completedBookings = completedResult.bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        CustomSnackbar.showError(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Caregiver Dashboard',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textPrimary),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'Pending (${_pendingBookings.length})'),
            Tab(text: 'Active (${_activeBookings.length})'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: Column(
                children: [
                  // Stats cards
                  _buildStatsSection(),
                  
                  // Quick actions
                  _buildQuickActions(),
                  
                  // Bookings tabs
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBookingsList(_pendingBookings, 'pending'),
                        _buildBookingsList(_activeBookings, 'active'),
                        _buildBookingsList(_completedBookings, 'completed'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.star,
            value: _profile?.averageRating.toStringAsFixed(1) ?? '0.0',
            label: 'Rating',
            color: Colors.amber,
          ),
          SizedBox(width: 12.w),
          _buildStatCard(
            icon: Icons.calendar_today,
            value: _profile?.totalBookings.toString() ?? '0',
            label: 'Bookings',
            color: AppColors.primary,
          ),
          SizedBox(width: 12.w),
          _buildStatCard(
            icon: Icons.check_circle,
            value: '${_profile?.completionRate.toStringAsFixed(0) ?? 100}%',
            label: 'Completion',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24.w),
            SizedBox(height: 4.h),
            Text(value, style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary)),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.miscellaneous_services,
              label: 'Services',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CaregiverServicesScreen()),
                );
              },
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildActionButton(
              icon: Icons.calendar_month,
              label: 'Availability',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CaregiverAvailabilityScreen()),
                );
              },
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildActionButton(
              icon: Icons.photo_library,
              label: 'Gallery',
              onTap: () {
                // TODO: Navigate to gallery
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24.w),
            SizedBox(height: 4.h),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(List<ServiceBooking> bookings, String type) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64.w, color: AppColors.textSecondary),
            SizedBox(height: 16.h),
            Text(
              type == 'pending'
                  ? 'No pending booking requests'
                  : type == 'active'
                      ? 'No active bookings'
                      : 'No completed bookings yet',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(booking, type);
      },
    );
  }

  Widget _buildBookingCard(ServiceBooking booking, String type) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BookingDetailScreen(
                bookingId: booking.id,
                isCaregiver: true,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.r),
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
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  _buildStatusChip(booking.status),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      (booking.ownerName ?? 'U')[0].toUpperCase(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.ownerName ?? 'Pet Owner',
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          booking.serviceName ?? 'Service',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16.w, color: AppColors.textSecondary),
                  SizedBox(width: 8.w),
                  Text(
                    _formatDate(booking.startDatetime),
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  SizedBox(width: 16.w),
                  Icon(Icons.access_time, size: 16.w, color: AppColors.textSecondary),
                  SizedBox(width: 8.w),
                  Text(
                    _formatTime(booking.startDatetime, booking.endDatetime),
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${booking.petIds.length} pet(s)',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  Text(
                    '${booking.currency} ${booking.totalAmount.toStringAsFixed(0)}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              if (type == 'pending') ...[
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _respondToBooking(booking.id, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Decline'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _respondToBooking(booking.id, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'accepted':
        color = Colors.blue;
        label = 'Accepted';
        break;
      case 'in_progress':
        color = Colors.green;
        label = 'In Progress';
        break;
      case 'completed':
        color = Colors.grey;
        label = 'Completed';
        break;
      case 'cancelled_owner':
      case 'cancelled_caregiver':
        color = Colors.red;
        label = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime start, DateTime end) {
    final startTime = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final endTime = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    return '$startTime - $endTime';
  }

  Future<void> _respondToBooking(String bookingId, bool accept) async {
    try {
      await _bookingRepo.respondToBooking(
        bookingId,
        RespondToBookingRequest(accept: accept),
      );
      if (mounted) {
        CustomSnackbar.showSuccess(
          context,
          accept ? 'Booking accepted!' : 'Booking declined',
        );
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }
}
