import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/marketplace_models.dart';
import '../../data/repositories/marketplace_repository.dart';
import '../widgets/order_status_badge.dart';

class SellerOrderDetailScreen extends StatefulWidget {
  final String orderId;
  final Order? initialOrder;

  const SellerOrderDetailScreen({
    super.key,
    required this.orderId,
    this.initialOrder,
  });

  @override
  State<SellerOrderDetailScreen> createState() =>
      _SellerOrderDetailScreenState();
}

class _SellerOrderDetailScreenState extends State<SellerOrderDetailScreen> {
  final MarketplaceRepository _repo = MarketplaceRepository.instance;

  static const List<String> _progressStatuses = [
    'pending',
    'confirmed',
    'processing',
    'shipped',
    'delivered',
  ];

  static const List<String> _statusOptions = [
    'pending',
    'confirmed',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
  ];

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _hasUpdates = false;
  String? _error;

  Order? _order;
  late final TextEditingController _trackingController;
  String _selectedStatus = 'pending';

  @override
  void initState() {
    super.initState();

    _order = widget.initialOrder;
    _trackingController = TextEditingController(
      text: widget.initialOrder?.trackingNumber ?? '',
    );

    if (_order != null) {
      _selectedStatus = _normalizedStatus(_sellerOrderStatus(_order!));
    }

    _loadOrder(showLoader: _order == null);
  }

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  Future<void> _loadOrder({bool showLoader = true}) async {
    if (showLoader) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    } else {
      setState(() {
        _error = null;
      });
    }

    try {
      final order = await _repo.getOrderById(widget.orderId);
      if (!mounted) return;

      setState(() {
        _order = order;
        _selectedStatus = _normalizedStatus(_sellerOrderStatus(order));
        _trackingController.text = order.trackingNumber ?? '';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final order = _order;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20.sp,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context, _hasUpdates),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Workspace',
              style: GoogleFonts.mulish(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              'Track fulfillment and delivery details',
              style: GoogleFonts.mulish(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: Container(
              decoration: BoxDecoration(
                  color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.28),
                  ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 20.sp,
                    color: colorScheme.onSurface,
                ),
                onPressed:
                    _isSubmitting ? null : () => _loadOrder(showLoader: false),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? <Color>[
                    colorScheme.surface,
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
                  ]
                : <Color>[
                    colorScheme.surface,
                    colorScheme.surfaceContainer,
                  ],
          ),
        ),
        child: Builder(
          builder: (_) {
          if (_isLoading && order == null) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (order == null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(28.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 52.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      _error ?? 'Order not found',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.mulish(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    ElevatedButton(
                      onPressed: () => _loadOrder(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final sellerStatus = _sellerOrderStatus(order);
          final isClosed =
              sellerStatus == 'delivered' || sellerStatus == 'cancelled';

          return RefreshIndicator(
            onRefresh: () => _loadOrder(showLoader: false),
            color: colorScheme.primary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
              children: [
                if (_error != null)
                  Container(
                    margin: EdgeInsets.only(bottom: 10.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: colorScheme.error.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      _error!,
                      style: GoogleFonts.mulish(
                        color: colorScheme.onErrorContainer,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                _buildSummaryCard(order, sellerStatus),
                SizedBox(height: 12.h),
                _buildTimelineCard(sellerStatus),
                SizedBox(height: 12.h),
                _buildUpdateCard(order, sellerStatus, isClosed),
                SizedBox(height: 12.h),
                _buildShippingCard(order),
                SizedBox(height: 12.h),
                _buildItemsCard(order),
              ],
            ),
          );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Order order, String sellerStatus) {
    final colorScheme = Theme.of(context).colorScheme;
    final sellerTotal = _sellerAmount(order);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8).toUpperCase()}',
                      style: GoogleFonts.mulish(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      _formatDateTime(order.createdAt),
                      style: GoogleFonts.mulish(
                        fontSize: 12.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              OrderStatusBadge(status: sellerStatus),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _metricTile(
                    label: 'Items',
                    value: '${order.items.length}',
                    color: colorScheme.secondary,
                  ),
                ),
                Expanded(
                  child: _metricTile(
                    label: 'Your amount',
                    value: 'PKR ${sellerTotal.toStringAsFixed(0)}',
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricTile({
    required String label,
    required String value,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.mulish(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.mulish(
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineCard(String sellerStatus) {
    final colorScheme = Theme.of(context).colorScheme;

    if (sellerStatus == 'cancelled') {
      return _card(
        child: Row(
          children: [
            Icon(
              Icons.cancel_outlined,
              size: 20.sp,
              color: colorScheme.error,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'This order has been cancelled.',
                style: GoogleFonts.mulish(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final currentIndex = _progressStatuses.indexOf(sellerStatus);
    final safeCurrentIndex = currentIndex < 0 ? 0 : currentIndex;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fulfillment Progress',
            style: GoogleFonts.mulish(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 10.h),
          ..._progressStatuses.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final done = index < safeCurrentIndex;
            final active = index == safeCurrentIndex;
            final isLast = index == _progressStatuses.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            done || active
                                ? colorScheme.primary
                                : colorScheme.outline.withValues(alpha: 0.35),
                      ),
                      child:
                          done || active
                              ? Icon(
                                Icons.check_rounded,
                                size: 13.sp,
                                color: colorScheme.onPrimary,
                              )
                              : null,
                    ),
                    if (!isLast)
                      Container(
                        width: 2.w,
                        height: 30.h,
                        color:
                            index < safeCurrentIndex
                                ? colorScheme.primary
                                : colorScheme.outline.withValues(alpha: 0.35),
                      ),
                  ],
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _statusLabel(step),
                          style: GoogleFonts.mulish(
                            fontSize: 13.sp,
                            fontWeight:
                                active ? FontWeight.w800 : FontWeight.w600,
                            color:
                                done || active
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (active)
                          Padding(
                            padding: EdgeInsets.only(top: 2.h),
                            child: Text(
                              'Current step',
                              style: GoogleFonts.mulish(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUpdateCard(Order order, String sellerStatus, bool isClosed) {
    final colorScheme = Theme.of(context).colorScheme;
    final canDispatch =
        !isClosed && sellerStatus != 'shipped' && sellerStatus != 'delivered';

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Update Dispatch Status',
            style: GoogleFonts.mulish(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 10.h),
          DropdownButtonFormField<String>(
            initialValue: _selectedStatus,
            decoration: InputDecoration(
              labelText: 'Order status',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: colorScheme.primary),
              ),
            ),
            items:
                _statusOptions
                    .map(
                      (status) => DropdownMenuItem<String>(
                        value: status,
                        child: Text(_statusLabel(status)),
                      ),
                    )
                    .toList(),
            onChanged:
                _isSubmitting || isClosed
                    ? null
                    : (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: _trackingController,
            enabled: !_isSubmitting && !isClosed,
            decoration: InputDecoration(
              labelText: 'Tracking number (optional)',
              hintText: 'Enter courier or shipment reference',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: colorScheme.primary),
              ),
            ),
          ),
          if (isClosed)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                'This order is closed and can no longer be updated.',
                style: GoogleFonts.mulish(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      _isSubmitting || !canDispatch
                          ? null
                          : () => _saveUpdate(forcedStatus: 'shipped'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.onSurface,
                    side: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.45),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 11.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  icon: Icon(Icons.local_shipping_outlined, size: 16.sp),
                  label: Text(
                    'Mark Dispatched',
                    style: GoogleFonts.mulish(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      _isSubmitting || isClosed ? null : () => _saveUpdate(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: 11.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    elevation: 0,
                  ),
                  icon: Icon(Icons.save_outlined, size: 16.sp),
                  label: Text(
                    _isSubmitting ? 'Saving...' : 'Save Update',
                    style: GoogleFonts.mulish(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShippingCard(Order order) {
    final colorScheme = Theme.of(context).colorScheme;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer & Delivery',
            style: GoogleFonts.mulish(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 10.h),
          _infoRow(
            icon: Icons.location_on_outlined,
            label: 'Address',
            value:
                order.shippingCity?.isNotEmpty == true
                    ? '${order.shippingAddress}, ${order.shippingCity}'
                    : order.shippingAddress,
          ),
          if (order.shippingPhone?.isNotEmpty == true) SizedBox(height: 10.h),
          if (order.shippingPhone?.isNotEmpty == true)
            _infoRow(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: order.shippingPhone!,
            ),
          SizedBox(height: 10.h),
          _infoRow(
            icon: Icons.payment_outlined,
            label: 'Payment',
            value:
                '${_paymentLabel(order.paymentMethod)} (${_statusLabel(order.paymentStatus)})',
          ),
          if (order.trackingNumber?.isNotEmpty == true) SizedBox(height: 10.h),
          if (order.trackingNumber?.isNotEmpty == true)
            _infoRow(
              icon: Icons.qr_code_2_outlined,
              label: 'Tracking',
              value: order.trackingNumber!,
            ),
          if (order.notes?.isNotEmpty == true) SizedBox(height: 10.h),
          if (order.notes?.isNotEmpty == true)
            _infoRow(
              icon: Icons.note_alt_outlined,
              label: 'Notes',
              value: order.notes!,
            ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(Order order) {
    final colorScheme = Theme.of(context).colorScheme;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Items to Fulfill',
            style: GoogleFonts.mulish(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 10.h),
          ...order.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return Column(
              children: [
                if (index > 0)
                  Divider(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    height: 16.h,
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 18.sp,
                        color: colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: GoogleFonts.mulish(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            'Qty ${item.quantity} x PKR ${item.unitPrice.toStringAsFixed(0)}',
                            style: GoogleFonts.mulish(
                              fontSize: 11.sp,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'PKR ${item.totalPrice.toStringAsFixed(0)}',
                          style: GoogleFonts.mulish(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        OrderStatusBadge(status: item.sellerStatus),
                      ],
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
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
                label,
                style: GoogleFonts.mulish(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: GoogleFonts.mulish(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Future<void> _saveUpdate({String? forcedStatus}) async {
    final order = _order;
    if (order == null) return;

    final nextStatus = _normalizedStatus(forcedStatus ?? _selectedStatus);
    final nextTracking = _trackingController.text.trim();

    final currentStatus = _sellerOrderStatus(order);
    final currentTracking = (order.trackingNumber ?? '').trim();

    if (nextStatus == currentStatus && nextTracking == currentTracking) {
      _showSnack('No changes to update');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _repo.updateOrderStatus(
        order.id,
        UpdateOrderStatusRequest(
          status: nextStatus,
          trackingNumber: nextTracking.isEmpty ? null : nextTracking,
        ),
      );

      if (!mounted) return;

      _hasUpdates = true;
      await _loadOrder(showLoader: false);
      _showSnack('Order updated successfully');
    } catch (e) {
      _showSnack(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _normalizedStatus(String status) {
    if (_statusOptions.contains(status)) {
      return status;
    }
    return 'pending';
  }

  double _sellerAmount(Order order) {
    return order.items.fold<double>(0, (sum, item) => sum + item.totalPrice);
  }

  String _sellerOrderStatus(Order order) {
    if (order.items.isEmpty) {
      return _normalizedStatus(order.status);
    }

    final statuses =
        order.items.map((item) => _normalizedStatus(item.sellerStatus)).toSet();

    if (statuses.length == 1) {
      return statuses.first;
    }

    return _normalizedStatus(order.status);
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
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

  String _formatDateTime(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year}  '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.mulish()),
        backgroundColor:
            isError ? colorScheme.error : colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
