import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';
import '../widgets/order_status_badge.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersCubit>().loadOrderDetail(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: const Color(0xFF191D21), size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order Details',
          style: GoogleFonts.mulish(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF191D21),
          ),
        ),
      ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state.isLoadingDetail) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2C6E69)));
          }

          final order = state.selectedOrder;
          if (order == null) {
            return Center(
              child: Text(state.error ?? 'Order not found',
                  style: GoogleFonts.mulish(color: AppColors.textSecondary)),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status card
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order #${order.id.substring(0, 8).toUpperCase()}',
                                style: GoogleFonts.mulish(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF191D21),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                _formatDate(order.createdAt),
                                style: GoogleFonts.mulish(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          OrderStatusBadge(status: order.status),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      // Status timeline
                      _buildStatusTimeline(order.status),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                // Items
                _buildSectionTitle('Items Ordered'),
                SizedBox(height: 8.h),
                _buildCard(
                  child: Column(
                    children: [
                      ...order.items.asMap().entries.map((entry) {
                        final i = entry.key;
                        final item = entry.value;
                        return Column(
                          children: [
                            if (i > 0)
                              Divider(
                                  color: const Color(0xFFF0F0F0), height: 1.h),
                            if (i > 0) SizedBox(height: 12.h),
                            _buildOrderItemRow(item),
                            SizedBox(height: i < order.items.length - 1 ? 12.h : 0),
                          ],
                        );
                      }),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                // Price breakdown
                _buildSectionTitle('Price Details'),
                SizedBox(height: 8.h),
                _buildCard(
                  child: Column(
                    children: [
                      _priceRow('Subtotal',
                          'PKR ${order.totalAmount.toStringAsFixed(0)}'),
                      SizedBox(height: 8.h),
                      _priceRow('Delivery', 'PKR 150'),
                      SizedBox(height: 8.h),
                      Divider(color: const Color(0xFFE0E0E0), height: 1.h),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total',
                              style: GoogleFonts.mulish(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF191D21))),
                          Text(
                            'PKR ${(order.totalAmount + 150).toStringAsFixed(0)}',
                            style: GoogleFonts.mulish(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF2C6E69)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                // Shipping & Payment
                _buildSectionTitle('Delivery & Payment'),
                SizedBox(height: 8.h),
                _buildCard(
                  child: Column(
                    children: [
                      _infoRow(
                        Icons.location_on_outlined,
                        'Delivery Address',
                        order.shippingAddress,
                      ),
                      SizedBox(height: 12.h),
                      Divider(color: const Color(0xFFF0F0F0), height: 1.h),
                      SizedBox(height: 12.h),
                      _infoRow(
                        Icons.payment_outlined,
                        'Payment Method',
                        _paymentLabel(order.paymentMethod),
                      ),
                      SizedBox(height: 12.h),
                      Divider(color: const Color(0xFFF0F0F0), height: 1.h),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Icon(Icons.receipt_outlined,
                              size: 18.sp, color: const Color(0xFF2C6E69)),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Payment Status',
                                    style: GoogleFonts.mulish(
                                        fontSize: 12.sp,
                                        color: AppColors.textSecondary)),
                                SizedBox(height: 2.h),
                                OrderStatusBadge(status: order.paymentStatus),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (order.notes != null && order.notes!.isNotEmpty) ...[
                        SizedBox(height: 12.h),
                        Divider(color: const Color(0xFFF0F0F0), height: 1.h),
                        SizedBox(height: 12.h),
                        _infoRow(
                          Icons.note_outlined,
                          'Notes',
                          order.notes!,
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 40.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusTimeline(String currentStatus) {
    final stages = [
      'pending',
      'confirmed',
      'processing',
      'shipped',
      'delivered'
    ];

    if (currentStatus == 'cancelled') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withOpacity(0.08),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel_outlined,
                size: 16.sp, color: const Color(0xFFEF4444)),
            SizedBox(width: 8.w),
            Text('This order was cancelled',
                style: GoogleFonts.mulish(
                    fontSize: 12.sp, color: const Color(0xFFEF4444))),
          ],
        ),
      );
    }

    final currentIdx = stages.indexOf(currentStatus);

    return Row(
      children: stages.asMap().entries.map((entry) {
        final i = entry.key;
        final done = i <= currentIdx;
        final isLast = i == stages.length - 1;

        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 18.w,
                    height: 18.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done
                          ? const Color(0xFF2C6E69)
                          : const Color(0xFFE0E0E0),
                      border: Border.all(
                        color: done
                            ? const Color(0xFF2C6E69)
                            : const Color(0xFFE0E0E0),
                        width: 2,
                      ),
                    ),
                    child: done
                        ? Icon(Icons.check_rounded,
                            size: 10.sp, color: Colors.white)
                        : null,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    stages[i][0].toUpperCase() + stages[i].substring(1),
                    style: GoogleFonts.mulish(
                      fontSize: 8.sp,
                      fontWeight:
                          done ? FontWeight.w700 : FontWeight.w400,
                      color: done
                          ? const Color(0xFF2C6E69)
                          : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2.h,
                    margin: EdgeInsets.only(bottom: 16.h),
                    color: i < currentIdx
                        ? const Color(0xFF2C6E69)
                        : const Color(0xFFE0E0E0),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderItemRow(item) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: SizedBox(
            width: 56.w,
            height: 56.w,
            child: item.productImage.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: item.productImage,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: const Color(0xFFF3EFE8)),
                    errorWidget: (_, __, ___) =>
                        Container(color: const Color(0xFFF3EFE8)),
                  )
                : Container(
                    color: const Color(0xFFF3EFE8),
                    child: Icon(Icons.shopping_bag_outlined,
                        size: 22.sp, color: AppColors.primary),
                  ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style: GoogleFonts.mulish(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF191D21),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.sellerName != null)
                Text(
                  'by ${item.sellerName}',
                  style: GoogleFonts.mulish(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'PKR ${item.unitPrice.toStringAsFixed(0)}',
              style: GoogleFonts.mulish(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF191D21),
              ),
            ),
            Text(
              '×${item.quantity}',
              style: GoogleFonts.mulish(
                fontSize: 11.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.mulish(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF191D21),
      ),
    );
  }

  Widget _priceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.mulish(
                fontSize: 13.sp, color: AppColors.textSecondary)),
        Text(value,
            style: GoogleFonts.mulish(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF191D21))),
      ],
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.sp, color: const Color(0xFF2C6E69)),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.mulish(
                      fontSize: 12.sp, color: AppColors.textSecondary)),
              SizedBox(height: 2.h),
              Text(value,
                  style: GoogleFonts.mulish(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF191D21))),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _paymentLabel(String method) {
    switch (method) {
      case 'cash_on_delivery': return 'Cash on Delivery';
      case 'bank_transfer': return 'Bank Transfer';
      case 'easypaisa': return 'Easypaisa';
      default: return method;
    }
  }
}
