import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/marketplace_cubit.dart';
import '../cubit/marketplace_state.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../../data/repositories/marketplace_repository.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketplaceCubit>().loadProductDetail(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: BlocBuilder<MarketplaceCubit, MarketplaceState>(
        builder: (context, state) {
          if (state.isLoadingDetail) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2C6E69)),
            );
          }

          final product = state.selectedProduct;
          if (product == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 48.sp, color: AppColors.textSecondary),
                  SizedBox(height: 12.h),
                  Text(state.error ?? 'Product not found',
                      style: GoogleFonts.mulish(color: AppColors.textSecondary)),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    child: Text('Go Back',
                        style: GoogleFonts.mulish(
                            color: const Color(0xFF191D21),
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Hero image sliver
              SliverAppBar(
                expandedHeight: 320.h,
                pinned: true,
                backgroundColor: AppColors.primary,
                leading: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: const Color(0xFF191D21), size: 16.sp),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Main image
                      product.images.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: product.images[_selectedImageIndex],
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                  color: const Color(0xFFF3EFE8)),
                              errorWidget: (_, __, ___) =>
                                  _buildPlaceholder(),
                            )
                          : _buildPlaceholder(),

                      // Image thumbnails
                      if (product.images.length > 1)
                        Positioned(
                          bottom: 12.h,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              product.images.length,
                              (i) => GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedImageIndex = i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 3.w),
                                  width: i == _selectedImageIndex ? 24.w : 8.w,
                                  height: 8.h,
                                  decoration: BoxDecoration(
                                    color: i == _selectedImageIndex
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Price badge
                      Positioned(
                        top: 80.h,
                        right: 16.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C6E69),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'PKR ${product.price.toStringAsFixed(0)}',
                            style: GoogleFonts.mulish(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F6F2),
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24.r)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category & Pet Type
                        Row(
                          children: [
                            if (product.categoryName != null)
                              _buildChip(product.categoryName!,
                                  AppColors.primary.withOpacity(0.3),
                                  const Color(0xFF2C6E69)),
                            if (product.petType != null) ...[
                              SizedBox(width: 8.w),
                              _buildChip(
                                  product.petType![0].toUpperCase() +
                                      product.petType!.substring(1),
                                  const Color(0xFFFFF3E0),
                                  const Color(0xFFE65100)),
                            ],
                          ],
                        ),

                        SizedBox(height: 12.h),

                        // Name
                        Text(
                          product.name,
                          style: GoogleFonts.mulish(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF191D21),
                          ),
                        ),

                        SizedBox(height: 8.h),

                        // Rating row
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (i) => Icon(
                                i < product.rating.round()
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: const Color(0xFFFFA726),
                                size: 18.sp,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '${product.rating.toStringAsFixed(1)} (${product.totalReviews} reviews)',
                              style: GoogleFonts.mulish(
                                fontSize: 13.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 6.h),
                        Text(
                          '${product.totalSold} sold',
                          style: GoogleFonts.mulish(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Divider
                        Divider(color: const Color(0xFFE0E0E0), height: 1.h),
                        SizedBox(height: 16.h),

                        // Description
                        Text(
                          'About this product',
                          style: GoogleFonts.mulish(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF191D21),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          product.description,
                          style: GoogleFonts.mulish(
                            fontSize: 14.sp,
                            height: 1.6,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Seller
                        if (product.sellerName != null) ...[
                          Divider(color: const Color(0xFFE0E0E0), height: 1.h),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18.r,
                                backgroundColor: AppColors.primary,
                                child: Icon(Icons.person_outline_rounded,
                                    size: 18.sp,
                                    color: const Color(0xFF191D21)),
                              ),
                              SizedBox(width: 12.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Seller',
                                      style: GoogleFonts.mulish(
                                          fontSize: 11.sp,
                                          color: AppColors.textSecondary)),
                                  Text(product.sellerName!,
                                      style: GoogleFonts.mulish(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF191D21))),
                                ],
                              ),
                            ],
                          ),
                        ],

                        SizedBox(height: 24.h),

                        // Stock info
                        Row(
                          children: [
                            Icon(
                              product.stockQuantity > 0
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.cancel_outlined,
                              size: 16.sp,
                              color: product.stockQuantity > 0
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              product.stockQuantity > 0
                                  ? '${product.stockQuantity} in stock'
                                  : 'Out of stock',
                              style: GoogleFonts.mulish(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: product.stockQuantity > 0
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 80.h), // padding for bottom bar
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<MarketplaceCubit, MarketplaceState>(
        builder: (context, state) {
          final product = state.selectedProduct;
          if (product == null) return const SizedBox.shrink();
          return _buildBottomBar(context, product.stockQuantity > 0, product.id);
        },
      ),
    );
  }

  Widget _buildBottomBar(
      BuildContext context, bool inStock, String productId) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Quantity selector
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3EFE8),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  _quantityButton(
                    Icons.remove_rounded,
                    () => setState(
                        () => _quantity = (_quantity - 1).clamp(1, 99)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Text(
                      '$_quantity',
                      style: GoogleFonts.mulish(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF191D21),
                      ),
                    ),
                  ),
                  _quantityButton(
                    Icons.add_rounded,
                    () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            // Add to cart
            Expanded(
              child: BlocConsumer<CartCubit, CartState>(
                listener: (context, state) {
                  if (state.addedProductId != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added to cart!',
                            style: GoogleFonts.mulish()),
                        backgroundColor: const Color(0xFF2C6E69),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                builder: (context, cartState) {
                  return ElevatedButton(
                    onPressed: inStock && !cartState.isAddingToCart
                        ? () => context
                            .read<CartCubit>()
                            .addToCart(productId, _quantity)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: inStock
                          ? const Color(0xFF2C6E69)
                          : AppColors.textSecondary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r)),
                      elevation: 0,
                    ),
                    child: cartState.isAddingToCart
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart_outlined,
                                  color: Colors.white, size: 18.sp),
                              SizedBox(width: 8.w),
                              Text(
                                inStock ? 'Add to Cart' : 'Out of Stock',
                                style: GoogleFonts.mulish(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15.sp,
                                ),
                              ),
                            ],
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        alignment: Alignment.center,
        child: Icon(icon, size: 18.sp, color: const Color(0xFF191D21)),
      ),
    );
  }

  Widget _buildChip(String label, Color bg, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.mulish(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFF3EFE8),
      child: Center(
        child: Icon(Icons.shopping_bag_outlined,
            size: 64.sp, color: AppColors.primary),
      ),
    );
  }
}
