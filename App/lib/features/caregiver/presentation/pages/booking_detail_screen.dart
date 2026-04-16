import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/models/booking_models.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;
  final bool isCaregiver;

  const BookingDetailScreen({
    super.key,
    required this.bookingId,
    this.isCaregiver = false,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late BookingRepository _repository;
  ServiceBooking? _booking;
  CompletionReport? _completionReport;
  List<BookingTracking> _tracking = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = getIt<BookingRepository>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final details = await _repository.getBookingDetails(widget.bookingId);
      final tracking = await _repository.getTracking(widget.bookingId);

      setState(() {
        _booking = details.booking;
        _completionReport = details.completionReport;
        _tracking = tracking;
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
          'Booking Details',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _booking == null
              ? const Center(child: Text('Booking not found'))
              : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusCard(),
                      SizedBox(height: 16.h),
                      _buildDetailsCard(),
                      SizedBox(height: 16.h),
                      _buildPricingCard(),
                      if (_tracking.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        _buildTrackingCard(),
                      ],
                      if (_completionReport != null) ...[
                        SizedBox(height: 16.h),
                        _buildCompletionReportCard(),
                      ],
                      SizedBox(height: 16.h),
                      _buildActionsCard(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _getStatusColor(_booking!.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(_booking!.status),
            color: _getStatusColor(_booking!.status),
            size: 32.w,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _booking!.bookingNumber,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _getStatusText(_booking!.status),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _getStatusColor(_booking!.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Details',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          _buildDetailRow(
            Icons.miscellaneous_services,
            'Service',
            _booking!.serviceName ?? 'Pet Care',
          ),
          _buildDetailRow(
            Icons.calendar_today,
            'Date',
            _formatDate(_booking!.startDatetime),
          ),
          _buildDetailRow(
            Icons.access_time,
            'Time',
            _formatTime(_booking!.startDatetime, _booking!.endDatetime),
          ),
          _buildDetailRow(
            Icons.location_on,
            'Location',
            _booking!.serviceAddress ?? _booking!.serviceLocationType,
          ),
          _buildDetailRow(
            Icons.pets,
            'Pets',
            '${_booking!.petIds.length} pet(s)',
          ),
          if (_booking!.specialInstructions != null)
            _buildDetailRow(
              Icons.note,
              'Instructions',
              _booking!.specialInstructions!,
            ),
          SizedBox(height: 16.h),
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  widget.isCaregiver
                      ? (_booking!.ownerName ?? 'O')[0].toUpperCase()
                      : (_booking!.caregiverName ?? 'C')[0].toUpperCase(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isCaregiver ? 'Pet Owner' : 'Caregiver',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    widget.isCaregiver
                        ? (_booking!.ownerName ?? 'Pet Owner')
                        : (_booking!.caregiverName ?? 'Caregiver'),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.w, color: AppColors.textSecondary),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(value, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Summary',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          _buildPriceRow('Base Amount', _booking!.baseAmount),
          if (_booking!.additionalPetsFee > 0)
            _buildPriceRow('Additional Pets Fee', _booking!.additionalPetsFee),
          _buildPriceRow('Service Fee', _booking!.serviceFee),
          if (_booking!.discountAmount > 0)
            _buildPriceRow(
              'Discount',
              -_booking!.discountAmount,
              isDiscount: true,
            ),
          Divider(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${_booking!.currency} ${_booking!.totalAmount.toStringAsFixed(0)}',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            '${isDiscount ? '-' : ''}${_booking!.currency} ${amount.abs().toStringAsFixed(0)}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDiscount ? Colors.green : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Tracking',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          ..._tracking.map((point) => _buildTrackingPoint(point)),
        ],
      ),
    );
  }

  Widget _buildTrackingPoint(BookingTracking point) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on,
              color: AppColors.primary,
              size: 16.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point.activityType ?? 'Location Update',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (point.note != null)
                  Text(
                    point.note!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                Text(
                  point.recordedAt != null
                      ? '${point.recordedAt!.hour}:${point.recordedAt!.minute.toString().padLeft(2, '0')}'
                      : '',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionReportCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Completion Report',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          Text(_completionReport!.summary, style: AppTextStyles.bodyMedium),
          if (_completionReport!.activitiesPerformed.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              'Activities:',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Wrap(
              spacing: 8.w,
              children:
                  _completionReport!.activitiesPerformed.map((activity) {
                    return Chip(
                      label: Text(activity, style: AppTextStyles.labelSmall),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                    );
                  }).toList(),
            ),
          ],
          if (_completionReport!.behaviorNotes != null) ...[
            SizedBox(height: 12.h),
            Text(
              'Behavior Notes: ${_completionReport!.behaviorNotes}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    final status = _booking!.status;

    return Column(
      children: [
        if (status == 'pending' && widget.isCaregiver) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _respondToBooking(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _respondToBooking(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ] else if (status == 'accepted' && widget.isCaregiver) ...[
          ElevatedButton(
            onPressed: _startService,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              minimumSize: Size(double.infinity, 48.h),
            ),
            child: const Text('Start Service'),
          ),
        ] else if (status == 'in_progress' && widget.isCaregiver) ...[
          ElevatedButton(
            onPressed: _showCompleteDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              minimumSize: Size(double.infinity, 48.h),
            ),
            child: const Text('Complete Service'),
          ),
        ] else if (status == 'completed' && !widget.isCaregiver) ...[
          ElevatedButton(
            onPressed: _showReviewDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              minimumSize: Size(double.infinity, 48.h),
            ),
            child: const Text('Leave Review'),
          ),
        ],
        SizedBox(height: 12.h),
        if (status == 'pending' || status == 'accepted') ...[
          OutlinedButton(
            onPressed: _showCancelDialog,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              minimumSize: Size(double.infinity, 48.h),
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'in_progress':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'accepted':
        return Icons.check_circle_outline;
      case 'in_progress':
        return Icons.play_circle_outline;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.cancel;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Waiting for caregiver response';
      case 'accepted':
        return 'Booking confirmed';
      case 'in_progress':
        return 'Service in progress';
      case 'completed':
        return 'Service completed';
      case 'cancelled_owner':
        return 'Cancelled by owner';
      case 'cancelled_caregiver':
        return 'Cancelled by caregiver';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime start, DateTime end) {
    return '${start.hour}:${start.minute.toString().padLeft(2, '0')} - ${end.hour}:${end.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _respondToBooking(bool accept) async {
    try {
      await _repository.respondToBooking(
        widget.bookingId,
        RespondToBookingRequest(accept: accept),
      );
      CustomSnackbar.showSuccess(
        context,
        accept ? 'Booking accepted!' : 'Booking declined',
      );
      _loadData();
    } catch (e) {
      CustomSnackbar.showError(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _startService() async {
    try {
      final latitude = _booking?.serviceLatitude;
      final longitude = _booking?.serviceLongitude;

      await _repository.startService(
        widget.bookingId,
        StartServiceRequest(latitude: latitude, longitude: longitude),
      );
      CustomSnackbar.showSuccess(context, 'Service started!');
      _loadData();
    } catch (e) {
      CustomSnackbar.showError(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _showCompleteDialog() async {
    final summaryController = TextEditingController();
    final behaviorController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Complete Service'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: summaryController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Summary',
                    hintText: 'How did the service go?',
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: behaviorController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Pet Behavior Notes',
                    hintText: 'Optional notes about pet behavior',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Complete'),
              ),
            ],
          ),
    );

    if (result == true && summaryController.text.isNotEmpty) {
      try {
        await _repository.completeService(
          widget.bookingId,
          SubmitCompletionReportRequest(
            summary: summaryController.text,
            behaviorNotes:
                behaviorController.text.isNotEmpty
                    ? behaviorController.text
                    : null,
          ),
        );
        CustomSnackbar.showSuccess(context, 'Service completed!');
        _loadData();
      } catch (e) {
        CustomSnackbar.showError(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  Future<void> _showReviewDialog() async {
    int rating = 5;
    final reviewController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Leave a Review'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 32.w,
                            ),
                            onPressed: () {
                              setDialogState(() => rating = index + 1);
                            },
                          );
                        }),
                      ),
                      SizedBox(height: 16.h),
                      TextField(
                        controller: reviewController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Review',
                          hintText: 'Share your experience...',
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Submit'),
                    ),
                  ],
                ),
          ),
    );

    if (result == true) {
      try {
        await _repository.submitOwnerReview(
          widget.bookingId,
          SubmitOwnerReviewRequest(
            rating: rating,
            review:
                reviewController.text.isNotEmpty ? reviewController.text : null,
          ),
        );
        CustomSnackbar.showSuccess(context, 'Review submitted!');
        Navigator.of(context).pop();
      } catch (e) {
        CustomSnackbar.showError(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  Future<void> _showCancelDialog() async {
    final reasonController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Booking'),
            content: TextField(
              controller: reasonController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Reason for cancellation',
                hintText: 'Please provide a reason',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep Booking'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Cancel Booking',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (result == true && reasonController.text.isNotEmpty) {
      try {
        await _repository.cancelBooking(
          widget.bookingId,
          CancelBookingRequest(reason: reasonController.text),
        );
        CustomSnackbar.showSuccess(context, 'Booking cancelled');
        Navigator.of(context).pop();
      } catch (e) {
        CustomSnackbar.showError(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }
}
