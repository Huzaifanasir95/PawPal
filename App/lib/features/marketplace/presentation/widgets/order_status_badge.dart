import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: config.$1.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: config.$1.withOpacity(0.4), width: 1),
      ),
      child: Text(
        config.$2,
        style: GoogleFonts.mulish(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: config.$1,
        ),
      ),
    );
  }

  (Color, String) _statusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return (const Color(0xFFF59E0B), 'Pending');
      case 'confirmed':
        return (const Color(0xFF3B82F6), 'Confirmed');
      case 'processing':
        return (const Color(0xFF8B5CF6), 'Processing');
      case 'shipped':
        return (const Color(0xFF06B6D4), 'Shipped');
      case 'delivered':
        return (const Color(0xFF10B981), 'Delivered');
      case 'cancelled':
        return (const Color(0xFFEF4444), 'Cancelled');
      default:
        return (const Color(0xFF6A6A6A), status);
    }
  }
}
