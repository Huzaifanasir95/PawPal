import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/repositories/caregiver_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/models/caregiver_models.dart';
import '../../data/models/booking_models.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import 'caregiver_services_screen.dart';
import 'caregiver_availability_screen.dart';
import 'booking_detail_screen.dart';
import 'caregiver_profile_setup_screen.dart';

class CaregiverHomeScreen extends StatefulWidget {
  const CaregiverHomeScreen({super.key});

  @override
  State<CaregiverHomeScreen> createState() => _CaregiverHomeScreenState();
}

class _CaregiverHomeScreenState extends State<CaregiverHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CaregiverRepository _caregiverRepo;
  late BookingRepository _bookingRepo;

  CaregiverProfile? _profile;
  List<CaregiverService> _services = [];
  List<ServiceBooking> _pendingBookings = [];
  List<ServiceBooking> _activeBookings = [];
  List<ServiceBooking> _completedBookings = [];
  bool _isLoading = true;
  bool _profileSetupRequired = false;
  String? _errorMessage;

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
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _profileSetupRequired = false;
    });

    try {
      final profileData = await _caregiverRepo.getMyProfile();
      final bookingResults = await Future.wait([
        _bookingRepo.getMyBookings(role: 'caregiver', status: 'pending'),
        _bookingRepo.getMyBookings(
          role: 'caregiver',
          status: 'accepted,in_progress',
        ),
        _bookingRepo.getMyBookings(role: 'caregiver', status: 'completed'),
      ]);

      if (!mounted) return;

      setState(() {
        _profile = profileData.profile;
        _services = profileData.profile.services;
        _pendingBookings = bookingResults[0].bookings;
        _activeBookings = bookingResults[1].bookings;
        _completedBookings = bookingResults[2].bookings;
        _isLoading = false;
        _profileSetupRequired = false;
        _errorMessage = null;
      });
    } catch (e) {
      final message = _normalizeErrorMessage(e);
      final needsProfileSetup = _isProfileSetupError(message);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _profile = null;
        _services = [];
        _pendingBookings = [];
        _activeBookings = [];
        _completedBookings = [];
        _profileSetupRequired = needsProfileSetup;
        _errorMessage = needsProfileSetup ? null : message;
      });

      if (!needsProfileSetup && mounted) {
        CustomSnackbar.showError(context, message);
      }
    }
  }

  String _normalizeErrorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }

  bool _isProfileSetupError(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('profile not found') ||
        normalized.contains('create your profile') ||
        normalized.contains('caregiver profile not found');
  }

  Future<void> _openProfileSetup() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CaregiverProfileSetupScreen()),
    );
    if (!mounted) return;
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Caregiver Dashboard',
          style: AppTextStyles.titleLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: colorScheme.onSurface),
            onPressed: () async {
              await Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
              if (!mounted) return;
              await _loadData();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          tabs: [
            Tab(text: 'Pending (${_pendingBookings.length})'),
            Tab(text: 'Active (${_activeBookings.length})'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _profileSetupRequired
              ? RefreshIndicator(
                onRefresh: _loadData,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 40.h,
                  ),
                  children: [_buildProfileSetupState()],
                ),
              )
              : _errorMessage != null && _profile == null
              ? RefreshIndicator(
                onRefresh: _loadData,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 40.h,
                  ),
                  children: [_buildLoadErrorState()],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadData,
                child: Column(
                  children: [
                    // Stats cards
                    _buildStatsSection(),

                    // Quick actions
                    _buildQuickActions(),

                    // Services overview
                    _buildServicesOverview(),

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

  Widget _buildProfileSetupState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.assignment_ind_outlined,
            size: 56.w,
            color: colorScheme.primary,
          ),
          SizedBox(height: 16.h),
          Text(
            'Complete Your Caregiver Profile',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLarge.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Set up your profile to start receiving booking requests, manage jobs, and track your activity.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openProfileSetup,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Set Up Profile'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadErrorState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 56.w,
            color: colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 16.h),
          Text(
            'Unable to Load Dashboard',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLarge.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _errorMessage ?? 'Please try again.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ),
        ],
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
            color: Theme.of(context).colorScheme.primary,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24.w),
            SizedBox(height: 4.h),
            Text(
              value,
              style: AppTextStyles.titleLarge.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
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
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CaregiverServicesScreen(),
                  ),
                );
                if (!mounted) return;
                await _loadData();
              },
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildActionButton(
              icon: Icons.calendar_month,
              label: 'Availability',
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CaregiverAvailabilityScreen(),
                  ),
                );
                if (!mounted) return;
                await _loadData();
              },
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildActionButton(
              icon: Icons.photo_library,
              label: 'Gallery',
              onTap: () {
                CustomSnackbar.showInfo(
                  context,
                  'Gallery management will be available in an upcoming update.',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesOverview() {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.miscellaneous_services,
                  size: 18.w,
                  color: colorScheme.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Active Services',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_services.length}',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            if (_services.isEmpty)
              Text(
                'No services configured yet. Add services to appear in your dashboard and public profile.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children:
                    _services
                        .where((service) => service.isAvailable)
                        .map(
                          (service) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              service.serviceTypeDisplayName ??
                                  service.serviceTypeName ??
                                  'Service',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.25),
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary, size: 24.w),
            SizedBox(height: 4.h),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(List<ServiceBooking> bookings, String type) {
    final colorScheme = Theme.of(context).colorScheme;

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64.w,
              color: colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 16.h),
            Text(
              type == 'pending'
                  ? 'No pending booking requests'
                  : type == 'active'
                  ? 'No active bookings'
                  : 'No completed bookings yet',
              style: AppTextStyles.bodyLarge.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
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
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) => BookingDetailScreen(
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
                      color: colorScheme.primary,
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
                    backgroundColor: colorScheme.primary.withValues(
                      alpha: 0.12,
                    ),
                    child: Text(
                      (booking.ownerName ?? 'U')[0].toUpperCase(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.primary,
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
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          booking.serviceName ?? 'Service',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16.w,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _formatDate(booking.startDatetime),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Icon(
                    Icons.access_time,
                    size: 16.w,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _formatTime(booking.startDatetime, booking.endDatetime),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${booking.petIds.length} pet(s)',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${booking.currency} ${booking.totalAmount.toStringAsFixed(0)}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
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
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime start, DateTime end) {
    final startTime =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final endTime =
        '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
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
      await _loadData();
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
