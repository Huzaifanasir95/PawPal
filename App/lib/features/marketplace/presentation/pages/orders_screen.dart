import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/repositories/marketplace_repository.dart';
import '../../data/models/marketplace_models.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';
import '../widgets/order_status_badge.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          OrdersCubit(MarketplaceRepository.instance)..loadOrders(),
      child: const _OrdersView(),
    );
  }
}

class _OrdersView extends StatelessWidget {
  const _OrdersView();

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
          'My Orders',
          style: GoogleFonts.mulish(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF191D21),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded,
                color: const Color(0xFF191D21), size: 22.sp),
            onPressed: () => context.read<OrdersCubit>().loadOrders(),
          ),
        ],
      ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2C6E69)));
          }

          if (state.error != null && state.orders.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(40.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        size: 48.sp, color: AppColors.textSecondary),
                    SizedBox(height: 12.h),
                    Text(state.error!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.mulish(
                            color: AppColors.textSecondary)),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<OrdersCubit>().loadOrders(),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary),
                      child: Text('Retry',
                          style: GoogleFonts.mulish(
                              color: const Color(0xFF191D21),
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 72.sp, color: AppColors.primary),
                  SizedBox(height: 16.h),
                  Text(
                    'No orders yet',
                    style: GoogleFonts.mulish(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF191D21),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Your orders will appear here',
                    style: GoogleFonts.mulish(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C6E69),
                      padding: EdgeInsets.symmetric(
                          horizontal: 32.w, vertical: 14.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r)),
                    ),
                    child: Text(
                      'Start Shopping',
                      style: GoogleFonts.mulish(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: state.orders.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, i) {
              return _buildOrderCard(context, state.orders[i]);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    return GestureDetector(
      onTap: () {
        final cubit = context.read<OrdersCubit>();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: cubit,
              child: OrderDetailScreen(orderId: order.id),
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF191D21),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _formatDate(order.createdAt),
                      style: GoogleFonts.mulish(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                OrderStatusBadge(status: order.status),
              ],
            ),

            SizedBox(height: 12.h),
            Divider(color: const Color(0xFFF0F0F0), height: 1.h),
            SizedBox(height: 12.h),

            // Items summary
            if (order.items.isNotEmpty)
              Text(
                order.items.length == 1
                    ? order.items.first.productName
                    : '${order.items.first.productName} + ${order.items.length - 1} more',
                style: GoogleFonts.mulish(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

            SizedBox(height: 12.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
                      style: GoogleFonts.mulish(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      _paymentLabel(order.paymentMethod),
                      style: GoogleFonts.mulish(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'PKR ${order.totalAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.mulish(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2C6E69),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'View Details',
                          style: GoogleFonts.mulish(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2C6E69),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 10.sp, color: const Color(0xFF2C6E69)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
