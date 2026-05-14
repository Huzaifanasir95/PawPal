import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentCompletedScreen extends StatelessWidget {
  final double amount;
  final String currency;
  final String transactionId;
  final String referenceId; // orderId or bookingId
  final String paymentMethod;
  final bool isBooking;
  final VoidCallback onViewDetails;

  const PaymentCompletedScreen({
    super.key,
    required this.amount,
    this.currency = 'PKR',
    required this.transactionId,
    required this.referenceId,
    required this.paymentMethod,
    this.isBooking = false,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 32.h),
              
              // Success Icon
              Container(
                width: 96.w,
                height: 96.w,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 64.w,
                  ),
                ),
              ),
              
              SizedBox(height: 24.h),
              
              Text(
                'Payment Completed!',
                style: GoogleFonts.mulish(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              
              SizedBox(height: 8.h),
              
              Text(
                'Your transaction was successful.',
                style: GoogleFonts.mulish(
                  fontSize: 14.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              
              SizedBox(height: 48.h),
              
              // Transaction Summary
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      context,
                      'Amount Paid',
                      '$currency ${amount.toStringAsFixed(0)}',
                      isHighlight: true,
                    ),
                    Divider(height: 24.h, color: colorScheme.outline.withOpacity(0.2)),
                    _buildSummaryRow(context, 'Date', _formatDate(DateTime.now())),
                    SizedBox(height: 12.h),
                    _buildSummaryRow(context, 'Payment Method', paymentMethod.toUpperCase()),
                    SizedBox(height: 12.h),
                    _buildSummaryRow(context, isBooking ? 'Booking ID' : 'Order ID', referenceId),
                    if (transactionId.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      _buildSummaryRow(context, 'Transaction ID', transactionId),
                    ],
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Navigation Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onViewDetails,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: Text(
                    isBooking ? 'View Booking Details' : 'View Order Details',
                  ),
                ),
              ),
              
              SizedBox(height: 16.h),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: const Text('Back to Home'),
                ),
              ),
              
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, {bool isHighlight = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.mulish(
            fontSize: 14.sp,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 16.w),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.mulish(
              fontSize: isHighlight ? 18.sp : 14.sp,
              color: isHighlight ? colorScheme.primary : colorScheme.onSurface,
              fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
