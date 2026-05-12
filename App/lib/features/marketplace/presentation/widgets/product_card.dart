import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

import '../../data/models/marketplace_models.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: isDark ? 0.18 : 0.07),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
              child: AspectRatio(
                aspectRatio: 1.0,
                child:
                    product.firstImage.isNotEmpty
                        ? _buildProductImage(context, product.firstImage)
                        : _buildImagePlaceholder(context),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.categoryName != null)
                      Container(
                        constraints: BoxConstraints(maxWidth: 96.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          product.categoryName!,
                          style: GoogleFonts.mulish(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    SizedBox(height: 4.h),

                    // Name
                    Text(
                      product.name,
                      style: GoogleFonts.mulish(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 6.h),

                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 12.sp,
                          color: colorScheme.tertiary,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: GoogleFonts.mulish(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '(${product.totalReviews})',
                          style: GoogleFonts.mulish(
                            fontSize: 9.sp,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'PKR ${product.price.toStringAsFixed(0)}',
                            style: GoogleFonts.mulish(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onAddToCart != null)
                          GestureDetector(
                            onTap: onAddToCart,
                            child: Container(
                              width: 32.w,
                              height: 32.w,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(
                                Icons.add,
                                size: 18.sp,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          size: 36.sp,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildProductImage(BuildContext context, String imageUrl) {
    if (imageUrl.startsWith('data:image/')) {
      try {
        final base64Data = imageUrl.split(',').last;
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => _buildImagePlaceholder(context),
        );
      } catch (_) {
        return _buildImagePlaceholder(context);
      }
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildImagePlaceholder(context),
      errorWidget: (context, url, error) => _buildImagePlaceholder(context),
    );
  }
}
