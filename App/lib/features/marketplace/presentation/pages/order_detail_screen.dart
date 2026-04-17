import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/marketplace_models.dart';
import '../../data/repositories/marketplace_repository.dart';
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
  final MarketplaceRepository _repo = MarketplaceRepository.instance;
  final Set<String> _submittingReviewItemIds = <String>{};
  final Set<String> _reviewedItemIds = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersCubit>().loadOrderDetail(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order Details',
          style: GoogleFonts.mulish(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state.isLoadingDetail) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          final order = state.selectedOrder;
          if (order == null) {
            return Center(
              child: Text(
                state.error ?? 'Order not found',
                style: GoogleFonts.mulish(color: colorScheme.onSurfaceVariant),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderMetaStrip(order),

                SizedBox(height: 10.h),

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
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                _formatDate(order.createdAt),
                                style: GoogleFonts.mulish(
                                  fontSize: 12.sp,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          OrderStatusBadge(status: order.status),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      // Status timeline
                      _buildStatusTimeline(order.status),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                // Items
                _buildSectionTitle(
                  'Items Ordered',
                  Icons.shopping_bag_outlined,
                ),
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
                                color: colorScheme.outline.withValues(
                                  alpha: 0.25,
                                ),
                                height: 1.h,
                              ),
                            if (i > 0) SizedBox(height: 12.h),
                            _buildOrderItemRow(order, item),
                            SizedBox(
                              height: i < order.items.length - 1 ? 12.h : 0,
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                // Price breakdown
                _buildSectionTitle(
                  'Price Details',
                  Icons.receipt_long_outlined,
                ),
                SizedBox(height: 8.h),
                _buildCard(
                  child: Column(
                    children: [
                      _priceRow(
                        'Subtotal',
                        'PKR ${order.totalAmount.toStringAsFixed(0)}',
                      ),
                      SizedBox(height: 8.h),
                      _priceRow('Delivery', 'PKR 150'),
                      SizedBox(height: 8.h),
                      Divider(
                        color: colorScheme.outline.withValues(alpha: 0.35),
                        height: 1.h,
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: GoogleFonts.mulish(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'PKR ${(order.totalAmount + 150).toStringAsFixed(0)}',
                            style: GoogleFonts.mulish(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                // Shipping & Payment
                _buildSectionTitle(
                  'Delivery & Payment',
                  Icons.local_shipping_outlined,
                ),
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
                      Divider(
                        color: colorScheme.outline.withValues(alpha: 0.25),
                        height: 1.h,
                      ),
                      SizedBox(height: 12.h),
                      _infoRow(
                        Icons.payment_outlined,
                        'Payment Method',
                        _paymentLabel(order.paymentMethod),
                      ),
                      SizedBox(height: 12.h),
                      Divider(
                        color: colorScheme.outline.withValues(alpha: 0.25),
                        height: 1.h,
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Icon(
                            Icons.receipt_outlined,
                            size: 18.sp,
                            color: colorScheme.primary,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Payment Status',
                                  style: GoogleFonts.mulish(
                                    fontSize: 12.sp,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                OrderStatusBadge(status: order.paymentStatus),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (order.notes != null && order.notes!.isNotEmpty) ...[
                        SizedBox(height: 12.h),
                        Divider(
                          color: colorScheme.outline.withValues(alpha: 0.25),
                          height: 1.h,
                        ),
                        SizedBox(height: 12.h),
                        _infoRow(Icons.note_outlined, 'Notes', order.notes!),
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

  Widget _buildOrderMetaStrip(Order order) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
              style: GoogleFonts.mulish(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              _paymentLabel(order.paymentMethod),
              style: GoogleFonts.mulish(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'PKR ${(order.totalAmount + 150).toStringAsFixed(0)}',
            style: GoogleFonts.mulish(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(String currentStatus) {
    final colorScheme = Theme.of(context).colorScheme;
    final stages = [
      'pending',
      'confirmed',
      'processing',
      'shipped',
      'delivered',
    ];

    if (currentStatus == 'cancelled') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(
              Icons.cancel_outlined,
              size: 16.sp,
              color: colorScheme.onErrorContainer,
            ),
            SizedBox(width: 8.w),
            Text(
              'This order was cancelled',
              style: GoogleFonts.mulish(
                fontSize: 12.sp,
                color: colorScheme.onErrorContainer,
              ),
            ),
          ],
        ),
      );
    }

    final currentIdx = stages.indexOf(currentStatus);

    return Row(
      children:
          stages.asMap().entries.map((entry) {
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
                          color:
                              done
                                  ? colorScheme.primary
                                  : colorScheme.outline.withValues(alpha: 0.35),
                          border: Border.all(
                            color:
                                done
                                    ? colorScheme.primary
                                    : colorScheme.outline.withValues(
                                      alpha: 0.35,
                                    ),
                            width: 2,
                          ),
                        ),
                        child:
                            done
                                ? Icon(
                                  Icons.check_rounded,
                                  size: 10.sp,
                                  color: colorScheme.onPrimary,
                                )
                                : null,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        stages[i][0].toUpperCase() + stages[i].substring(1),
                        style: GoogleFonts.mulish(
                          fontSize: 8.sp,
                          fontWeight: done ? FontWeight.w700 : FontWeight.w400,
                          color:
                              done
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
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
                        color:
                            i < currentIdx
                                ? colorScheme.primary
                                : colorScheme.outline.withValues(alpha: 0.35),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildOrderItemRow(Order order, OrderItem item) {
    final colorScheme = Theme.of(context).colorScheme;
    final canReview = _canReviewOrderItem(order, item);
    final isSubmittingReview = _submittingReviewItemIds.contains(item.id);
    final alreadyReviewed = _reviewedItemIds.contains(item.id);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: SizedBox(
            width: 56.w,
            height: 56.w,
            child:
                item.productImage.isNotEmpty
                    ? CachedNetworkImage(
                      imageUrl: item.productImage,
                      fit: BoxFit.cover,
                      placeholder:
                          (_, __) => Container(
                            color: colorScheme.surfaceContainerHighest,
                          ),
                      errorWidget:
                          (_, __, ___) => Container(
                            color: colorScheme.surfaceContainerHighest,
                          ),
                    )
                    : Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 22.sp,
                        color: colorScheme.primary,
                      ),
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
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (item.sellerName != null)
                Text(
                  'by ${item.sellerName}',
                  style: GoogleFonts.mulish(
                    fontSize: 11.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Flexible(child: OrderStatusBadge(status: item.sellerStatus)),
                  const Spacer(),
                  if (canReview && !alreadyReviewed)
                    TextButton.icon(
                      onPressed:
                          isSubmittingReview
                              ? null
                              : () => _showProductReviewDialog(order, item),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                      ),
                      icon:
                          isSubmittingReview
                              ? SizedBox(
                                width: 14.w,
                                height: 14.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.primary,
                                ),
                              )
                              : Icon(
                                Icons.star_outline_rounded,
                                size: 16.sp,
                                color: colorScheme.primary,
                              ),
                      label: Text(
                        isSubmittingReview ? 'Submitting...' : 'Rate Product',
                        style: GoogleFonts.mulish(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    )
                  else if (alreadyReviewed)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        'Reviewed',
                        style: GoogleFonts.mulish(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.tertiary,
                        ),
                      ),
                    ),
                ],
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
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'x${item.quantity}',
                style: GoogleFonts.mulish(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _canReviewOrderItem(Order order, OrderItem item) {
    final orderStatus = order.status.trim().toLowerCase();
    final sellerStatus = item.sellerStatus.trim().toLowerCase();
    return orderStatus == 'delivered' || sellerStatus == 'delivered';
  }

  Future<void> _showProductReviewDialog(Order order, OrderItem item) async {
    if (!_canReviewOrderItem(order, item)) {
      return;
    }

    int rating = 5;
    final commentController = TextEditingController();

    final submit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(
                'Rate Product',
                style: GoogleFonts.mulish(fontWeight: FontWeight.w800),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.mulish(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 4.w,
                    children: List.generate(
                      5,
                      (index) => IconButton(
                        onPressed: () {
                          setDialogState(() => rating = index + 1);
                        },
                        icon: Icon(
                          index < rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Share your feedback (optional)',
                      hintStyle: GoogleFonts.mulish(fontSize: 13.sp),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text('Cancel', style: GoogleFonts.mulish()),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(
                    'Submit',
                    style: GoogleFonts.mulish(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (submit != true || !mounted) {
      return;
    }

    setState(() => _submittingReviewItemIds.add(item.id));

    try {
      await _repo.addProductReview(
        item.productId,
        CreateProductReviewRequest(
          rating: rating,
          comment: commentController.text.trim(),
          orderItemId: item.id,
        ),
      );

      if (!mounted) return;

      setState(() => _reviewedItemIds.add(item.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Review submitted!', style: GoogleFonts.mulish()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: GoogleFonts.mulish(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submittingReviewItemIds.remove(item.id));
      }
    }
  }

  Widget _buildCard({required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 17.sp, color: colorScheme.primary),
        SizedBox(width: 7.w),
        Text(
          title,
          style: GoogleFonts.mulish(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _priceRow(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.mulish(
            fontSize: 13.sp,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.mulish(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.sp, color: colorScheme.primary),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.mulish(
                  fontSize: 12.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: GoogleFonts.mulish(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _paymentLabel(String method) {
    switch (method) {
      case 'cash_on_delivery':
        return 'Cash on Delivery';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'easypaisa':
        return 'Easypaisa';
      default:
        return method;
    }
  }
}
