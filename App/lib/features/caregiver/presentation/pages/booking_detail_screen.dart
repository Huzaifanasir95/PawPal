import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/models/booking_models.dart';
import '../../../chat/data/repositories/chat_repository.dart';
import '../../../chat/presentation/pages/chat_conversation_screen.dart';

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
  List<BookingPayment> _payments = [];
  bool _isLoading = true;
  bool _isProcessingPayment = false;
  bool _isOpeningChat = false;

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
        _payments = details.payments ?? const [];
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Booking Details',
          style: AppTextStyles.titleLarge.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
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
        color: Theme.of(context).colorScheme.surface,
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
              color: Theme.of(context).colorScheme.onSurface,
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
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Text(
                  widget.isCaregiver
                      ? (_booking!.ownerName ?? 'O')[0].toUpperCase()
                      : (_booking!.caregiverName ?? 'C')[0].toUpperCase(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.primary,
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
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
          Icon(icon, size: 20.w, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
    final hasCompletedPayment = _hasCompletedPayment;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Invoice Summary',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color:
                      hasCompletedPayment
                          ? Colors.green.withOpacity(0.14)
                          : Colors.orange.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  hasCompletedPayment ? 'PAID' : 'UNPAID',
                  style: AppTextStyles.labelSmall.copyWith(
                    color:
                        hasCompletedPayment
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invoice #${_booking!.bookingNumber}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Issued on ${_formatDate(_booking!.requestedAt ?? _booking!.createdAt ?? _booking!.startDatetime)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
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
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          if (_payments.isNotEmpty) ...[
            SizedBox(height: 14.h),
            Text(
              'Transactions',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            ..._payments.take(3).map((payment) {
              final isCompleted = payment.status.toLowerCase() == 'completed';
              return Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${payment.paymentType.toUpperCase()} • ${payment.paymentMethod ?? 'method'}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${payment.currency} ${payment.amount.toStringAsFixed(0)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color:
                            isCompleted
                                ? Colors.green.shade700
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
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
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Text(
            '${isDiscount ? '-' : ''}${_booking!.currency} ${amount.abs().toStringAsFixed(0)}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDiscount ? Colors.green : Theme.of(context).colorScheme.onSurface,
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
        color: Theme.of(context).colorScheme.surface,
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
              color: Theme.of(context).colorScheme.onSurface,
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
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on,
              color: Theme.of(context).colorScheme.primary,
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
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                Text(
                  point.recordedAt != null
                      ? '${point.recordedAt!.hour}:${point.recordedAt!.minute.toString().padLeft(2, '0')}'
                      : '',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
        color: Theme.of(context).colorScheme.surface,
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
              color: Theme.of(context).colorScheme.onSurface,
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
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    );
                  }).toList(),
            ),
          ],
          if (_completionReport!.behaviorNotes != null) ...[
            SizedBox(height: 12.h),
            Text(
              'Behavior Notes: ${_completionReport!.behaviorNotes}',
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
        if (_canOpenChat) ...[
          OutlinedButton.icon(
            onPressed: _isOpeningChat ? null : _openBookingChat,
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              minimumSize: Size(double.infinity, 48.h),
            ),
            icon:
                _isOpeningChat
                    ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.chat_bubble_outline),
            label: Text(_isOpeningChat ? 'Opening Chat...' : 'Message'),
          ),
          SizedBox(height: 12.h),
        ],
        if (_canOwnerProcessPayment) ...[
          ElevatedButton.icon(
            onPressed: _isProcessingPayment ? null : _showPaymentDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              minimumSize: Size(double.infinity, 48.h),
            ),
            icon:
                _isProcessingPayment
                    ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(Icons.payment),
            label: Text(
              _isProcessingPayment ? 'Processing Payment...' : 'Pay Now (Demo)',
            ),
          ),
          SizedBox(height: 12.h),
        ],
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
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ] else if (status == 'accepted' && widget.isCaregiver) ...[
          if (_hasCompletedPayment)
            ElevatedButton(
              onPressed: _startService,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                minimumSize: Size(double.infinity, 48.h),
              ),
              child: const Text('Start Service'),
            )
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'Waiting for owner payment before service can start.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ] else if (status == 'in_progress' && widget.isCaregiver) ...[
          ElevatedButton(
            onPressed: _showCompleteDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              minimumSize: Size(double.infinity, 48.h),
            ),
            child: const Text('Complete Service'),
          ),
        ] else if (status == 'completed' && !widget.isCaregiver) ...[
          ElevatedButton(
            onPressed: _showReviewDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
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

  bool get _hasCompletedPayment {
    return _payments.any(
      (payment) =>
          payment.status.toLowerCase() == 'completed' &&
          payment.paymentType.toLowerCase() != 'refund',
    );
  }

  bool get _canOwnerProcessPayment {
    return !widget.isCaregiver &&
        _booking != null &&
        _booking!.status == 'accepted' &&
        !_hasCompletedPayment;
  }

  bool get _canOpenChat {
    if (_booking == null) return false;

    const nonChatStatuses = {'declined', 'cancelled_owner', 'cancelled_caregiver'};
    return !nonChatStatuses.contains(_booking!.status);
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

  Future<void> _openBookingChat() async {
    if (_booking == null || _isOpeningChat) return;

    setState(() => _isOpeningChat = true);
    try {
      final chatRepository = getIt<ChatRepository>();
      final chat = await chatRepository.startBookingChat(
        bookingId: widget.bookingId,
      );

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => ChatConversationScreen(
                chatId: chat.id,
                otherUserName:
                    widget.isCaregiver
                        ? (_booking!.ownerName ?? 'Pet Owner')
                        : (_booking!.caregiverName ?? 'Caregiver'),
              ),
        ),
      );
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isOpeningChat = false);
      }
    }
  }

  Future<void> _showPaymentDialog() async {
    if (_booking == null || _isProcessingPayment) return;

    var selectedMethod = 'card';
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Complete Payment (Demo)'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total payable: ${_booking!.currency} ${_booking!.totalAmount.toStringAsFixed(0)}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      DropdownButtonFormField<String>(
                        value: selectedMethod,
                        items: const [
                          DropdownMenuItem(value: 'card', child: Text('Card')),
                          DropdownMenuItem(
                            value: 'jazzcash',
                            child: Text('JazzCash'),
                          ),
                          DropdownMenuItem(
                            value: 'easypaisa',
                            child: Text('EasyPaisa'),
                          ),
                          DropdownMenuItem(
                            value: 'bank_transfer',
                            child: Text('Bank Transfer'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => selectedMethod = value);
                        },
                        decoration: const InputDecoration(
                          labelText: 'Payment Method',
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
                      child: const Text('Pay'),
                    ),
                  ],
                ),
          ),
    );

    if (confirmed == true) {
      await _processPayment(selectedMethod);
    }
  }

  Future<void> _processPayment(String method) async {
    if (_booking == null || _isProcessingPayment) return;

    setState(() => _isProcessingPayment = true);
    try {
      await _repository.processPayment(
        widget.bookingId,
        ProcessPaymentRequest(
          amount: _booking!.totalAmount,
          paymentType: 'final',
          paymentMethod: method,
        ),
      );

      if (mounted) {
        CustomSnackbar.showSuccess(
          context,
          'Payment completed. Your caregiver can now start the service.',
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
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
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

