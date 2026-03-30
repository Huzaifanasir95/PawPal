import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

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
          'My Cart',
          style: GoogleFonts.mulish(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF191D21),
          ),
        ),
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2C6E69)));
          }

          if (state.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 72.sp, color: AppColors.primary),
                  SizedBox(height: 16.h),
                  Text(
                    'Your cart is empty',
                    style: GoogleFonts.mulish(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF191D21),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Add some products to get started',
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
                      'Browse Products',
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

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 6.h),
                child: Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.25)),
                      ),
                      child: Text(
                        '${state.items.length} items in your cart',
                        style: GoogleFonts.mulish(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C6E69),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Review before checkout',
                      style: GoogleFonts.mulish(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding:
                      EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, i) {
                    final item = state.items[i];
                    return _buildCartItem(context, item);
                  },
                ),
              ),
              _buildOrderSummary(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, item) {
    final product = item.product;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: SizedBox(
                  width: 72.w,
                  height: 72.w,
                  child: product?.firstImage.isNotEmpty == true
                      ? CachedNetworkImage(
                          imageUrl: product!.firstImage,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: const Color(0xFFF3EFE8)),
                          errorWidget: (_, __, ___) =>
                              Container(color: const Color(0xFFF3EFE8)),
                        )
                      : Container(
                          color: const Color(0xFFF3EFE8),
                          child: Icon(Icons.shopping_bag_outlined,
                              size: 28.sp, color: AppColors.primary),
                        ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product?.name ?? 'Product',
                      style: GoogleFonts.mulish(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        color: const Color(0xFF191D21),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 9.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            'Unit PKR ${product?.price.toStringAsFixed(0) ?? '0'}',
                            style: GoogleFonts.mulish(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2C6E69),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'PKR ${item.totalPrice.toStringAsFixed(0)}',
                          style: GoogleFonts.mulish(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF191D21),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => context.read<CartCubit>().removeItem(item.id),
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: Icon(Icons.delete_outline_rounded,
                      size: 18.sp, color: const Color(0xFFEF4444)),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Text(
                'Quantity',
                style: GoogleFonts.mulish(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(width: 10.w),
              _quantityBtn(Icons.remove_rounded, () {
                context
                    .read<CartCubit>()
                    .updateQuantity(item.id, item.quantity - 1);
              }),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(
                  '${item.quantity}',
                  style: GoogleFonts.mulish(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF191D21),
                  ),
                ),
              ),
              _quantityBtn(Icons.add_rounded, () {
                context
                    .read<CartCubit>()
                    .updateQuantity(item.id, item.quantity + 1);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartState state) {
    final subtotal = state.items.fold(0.0, (s, i) => s + i.totalPrice);
    const delivery = 150.0;
    final total = subtotal + delivery;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 18.sp, color: const Color(0xFF2C6E69)),
                SizedBox(width: 8.w),
                Text(
                  'Order Summary',
                  style: GoogleFonts.mulish(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF191D21),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _summaryRow('Subtotal', 'PKR ${subtotal.toStringAsFixed(0)}'),
            SizedBox(height: 8.h),
            _summaryRow('Delivery', 'PKR ${delivery.toStringAsFixed(0)}'),
            SizedBox(height: 8.h),
            Divider(color: const Color(0xFFE0E0E0), height: 1.h),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.mulish(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF191D21),
                  ),
                ),
                Text(
                  'PKR ${total.toStringAsFixed(0)}',
                  style: GoogleFonts.mulish(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2C6E69),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.items.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<CartCubit>(),
                              child: CheckoutScreen(cartItems: state.items),
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C6E69),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r)),
                  elevation: 0,
                ),
                child: Text(
                  'Proceed to Checkout',
                  style: GoogleFonts.mulish(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.mulish(
                fontSize: 14.sp, color: AppColors.textSecondary)),
        Text(value,
            style: GoogleFonts.mulish(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF191D21))),
      ],
    );
  }

  Widget _quantityBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28.w,
        height: 28.w,
        decoration: BoxDecoration(
          color: const Color(0xFFF3EFE8),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, size: 14.sp, color: const Color(0xFF191D21)),
      ),
    );
  }
}
