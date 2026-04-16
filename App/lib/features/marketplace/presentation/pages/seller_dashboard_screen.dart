import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/utils/image_service.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../data/models/marketplace_models.dart';
import '../../data/repositories/marketplace_repository.dart';
import 'seller_order_detail_screen.dart';
import '../widgets/order_status_badge.dart';

class _ProductDialogResult {
  final String? productId;
  final CreateProductRequest? createRequest;
  final UpdateProductRequest? updateRequest;
  final List<XFile> localImages;

  const _ProductDialogResult.create(
    this.createRequest, {
    this.localImages = const [],
  }) : productId = null,
       updateRequest = null;

  const _ProductDialogResult.edit(
    this.productId,
    this.updateRequest, {
    this.localImages = const [],
  }) : createRequest = null;
}

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  final MarketplaceRepository _repo = MarketplaceRepository.instance;
  final ImagePicker _imagePicker = ImagePicker();
  final ImageService _imageService = getIt<ImageService>();

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  int _tabIndex = 0;

  List<ProductCategory> _categories = [];
  List<Product> _myProducts = [];
  List<Order> _sellerOrders = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard({bool showLoader = true}) async {
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
      final results = await Future.wait([
        _repo.getCategories(),
        _repo.getMyProducts(limit: 100),
        _repo.getSellerOrders(limit: 100),
      ]);

      if (!mounted) return;
      setState(() {
        _categories = results[0] as List<ProductCategory>;
        _myProducts = results[1] as List<Product>;
        _sellerOrders = results[2] as List<Order>;
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Seller Dashboard',
          style: GoogleFonts.mulish(
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.24),
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 20.sp,
                  color: colorScheme.onSurface,
                ),
                onPressed: _isSubmitting ? null : () => _loadDashboard(),
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
            colors:
                isDark
                    ? <Color>[
                      colorScheme.surface,
                      colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
                    ]
                    : const <Color>[Color(0xFFF4F8FC), Color(0xFFEAF1F8)],
          ),
        ),
        child: _buildBody(),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2C6E69)),
      );
    }

    if (_error != null && _myProducts.isEmpty && _sellerOrders.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 52.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 10.h),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.mulish(color: colorScheme.onSurfaceVariant),
              ),
              SizedBox(height: 14.h),
              ElevatedButton(
                onPressed: () => _loadDashboard(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                ),
                child: Text(
                  'Retry',
                  style: GoogleFonts.mulish(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadDashboard(showLoader: false),
      color: const Color(0xFF2C6E69),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
            child: Column(
              children: [
                _buildHeroBanner(),
                SizedBox(height: 12.h),
                _buildStatsGrid(),
                SizedBox(height: 12.h),
                _buildTabSwitcher(),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
            ),
          Expanded(
            child: _tabIndex == 0 ? _buildInventoryTab() : _buildOrdersTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    final colorScheme = Theme.of(context).colorScheme;
    final pendingOrders =
        _sellerOrders
            .where(
              (o) => [
                'pending',
                'confirmed',
                'processing',
              ].contains(_sellerOrderStatus(o)),
            )
            .length;
    final lowStock = _myProducts.where((p) => p.stockQuantity <= 5).length;
    final totalProductReviews = _myProducts.fold<int>(
      0,
      (sum, product) => sum + product.totalReviews,
    );
    final weightedRatings = _myProducts.fold<double>(
      0,
      (sum, product) => sum + (product.rating * product.totalReviews),
    );
    final sellerRating =
        totalProductReviews == 0 ? 0.0 : weightedRatings / totalProductReviews;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Snapshot',
            style: GoogleFonts.mulish(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: colorScheme.onPrimary.withValues(alpha: 0.82),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'You have $pendingOrders orders to process',
            style: GoogleFonts.mulish(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: colorScheme.onPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _heroInfoPill(
                  icon: Icons.warning_amber_rounded,
                  label: 'Low stock',
                  value: '$lowStock items',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _heroInfoPill(
                  icon: Icons.star_rounded,
                  label: 'Seller rating',
                  value: totalProductReviews > 0
                      ? '${sellerRating.toStringAsFixed(1)} ($totalProductReviews)'
                      : 'No reviews',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroInfoPill({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.onPrimary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.onPrimary.withValues(alpha: 0.86), size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.mulish(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onPrimary.withValues(alpha: 0.78),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.mulish(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final activeProducts = _myProducts.where((p) => p.isActive).length;
    final lowStock = _myProducts.where((p) => p.stockQuantity <= 5).length;
    final pendingOrders =
        _sellerOrders
            .where(
              (o) => [
                'pending',
                'confirmed',
                'processing',
              ].contains(_sellerOrderStatus(o)),
            )
            .length;
    final completedRevenue = _sellerOrders.fold<double>(0, (sum, order) {
      final deliveredTotal = order.items
          .where((item) => item.sellerStatus == 'delivered')
          .fold<double>(0, (itemSum, item) => itemSum + item.totalPrice);
      return sum + deliveredTotal;
    });

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                'Products',
                '$activeProducts',
                Icons.inventory_2_outlined,
                const Color(0xFF2C6E69),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _statCard(
                'Pending',
                '$pendingOrders',
                Icons.local_shipping_outlined,
                const Color(0xFF2563EB),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _statCard(
                'Low Stock',
                '$lowStock',
                Icons.warning_amber_rounded,
                const Color(0xFFF59E0B),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _statCard(
                'Revenue',
                'PKR ${completedRevenue.toStringAsFixed(0)}',
                Icons.payments_outlined,
                const Color(0xFF10B981),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF102A43).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Icon(icon, size: 16.sp, color: color),
          ),
          SizedBox(height: 7.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.mulish(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.mulish(
              fontSize: 11.sp,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    final colorScheme = Theme.of(context).colorScheme;

    Widget chip(String label, IconData icon, int index) {
      final selected = _tabIndex == index;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _tabIndex = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color:
                  selected
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color:
                    selected
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 15.sp,
                  color:
                      selected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 6.w),
                Text(
                  label,
                  style: GoogleFonts.mulish(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color:
                        selected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip('Inventory', Icons.inventory_2_outlined, 0),
        SizedBox(width: 10.w),
        chip('Orders', Icons.local_shipping_outlined, 1),
      ],
    );
  }

  Widget _buildInventoryTab() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : () => _openProductDialog(),
              icon: Icon(Icons.add_rounded, size: 18.sp),
              label: Text(
                'Add New Product',
                style: GoogleFonts.mulish(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.sp,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
        Expanded(
          child:
              _myProducts.isEmpty
                  ? _emptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'No products yet',
                    subtitle:
                        'Create your first listing to appear in marketplace',
                  )
                  : ListView.separated(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 18.h),
                    itemCount: _myProducts.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final product = _myProducts[index];
                      return _buildProductCard(product);
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    final colorScheme = Theme.of(context).colorScheme;
    final lowStock = product.stockQuantity <= 5;
    final imageUrl = product.images.isNotEmpty ? product.images.first : null;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF102A43).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildProductImagePreview(imageUrl),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.mulish(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'PKR ${product.price.toStringAsFixed(0)}',
                      style: GoogleFonts.mulish(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_horiz_rounded,
                  size: 22.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
                onSelected: (value) {
                  if (_isSubmitting) return;
                  if (value == 'edit') {
                    _openProductDialog(product: product);
                  } else {
                    _confirmDeactivateProduct(product);
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                        value: 'remove',
                        child: Text('Remove'),
                      ),
                    ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _pill(
                product.isActive ? 'Active' : 'Inactive',
                product.isActive
                    ? const Color(0xFF10B981)
                    : const Color(0xFF6B7280),
              ),
              _pill(
                'Stock: ${product.stockQuantity}',
                lowStock ? const Color(0xFFF59E0B) : const Color(0xFF2563EB),
              ),
              if (product.categoryName != null)
                _pill(product.categoryName!, const Color(0xFF9333EA)),
              if (product.petType != null && product.petType!.isNotEmpty)
                _pill(product.petType!, const Color(0xFF0EA5E9)),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      _isSubmitting
                          ? null
                          : () => _openProductDialog(product: product),
                  icon: Icon(Icons.edit_outlined, size: 16.sp),
                  label: Text(
                    'Edit',
                    style: GoogleFonts.mulish(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.onSurface,
                    side: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.45),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      _isSubmitting
                          ? null
                          : () => _confirmDeactivateProduct(product),
                  icon: Icon(Icons.delete_outline_rounded, size: 16.sp),
                  label: Text(
                    'Remove',
                    style: GoogleFonts.mulish(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE3E3),
                    foregroundColor: const Color(0xFF9B1C1C),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
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

  Widget _pill(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: GoogleFonts.mulish(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    if (_sellerOrders.isEmpty) {
      return _emptyState(
        icon: Icons.local_shipping_outlined,
        title: 'No orders yet',
        subtitle: 'Orders for your products will appear here',
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 18.h),
      itemCount: _sellerOrders.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final order = _sellerOrders[index];
        return _buildSellerOrderCard(order);
      },
    );
  }

  Widget _buildSellerOrderCard(Order order) {
    final colorScheme = Theme.of(context).colorScheme;
    final status = _sellerOrderStatus(order);
    final sellerAmount = order.items.fold<double>(
      0,
      (s, i) => s + i.totalPrice,
    );

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF102A43).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
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
                  'Order #${order.id.substring(0, 8).toUpperCase()}',
                  style: GoogleFonts.mulish(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              OrderStatusBadge(status: status),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            _formatDate(order.createdAt),
            style: GoogleFonts.mulish(
              fontSize: 11.sp,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 10.h),
          if (order.items.isNotEmpty)
            ...order.items
                .take(2)
                .map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.productName} x${item.quantity}',
                            style: GoogleFonts.mulish(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'PKR ${item.totalPrice.toStringAsFixed(0)}',
                          style: GoogleFonts.mulish(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          if (order.items.length > 2)
            Text(
              '+ ${order.items.length - 2} more item(s)',
              style: GoogleFonts.mulish(
                fontSize: 11.sp,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deliver to: ${order.shippingAddress}',
                  style: GoogleFonts.mulish(
                    fontSize: 11.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (order.shippingPhone != null &&
                    order.shippingPhone!.isNotEmpty)
                  Text(
                    'Phone: ${order.shippingPhone}',
                    style: GoogleFonts.mulish(
                      fontSize: 11.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                SizedBox(height: 4.h),
                Text(
                  'Your total: PKR ${sellerAmount.toStringAsFixed(0)}',
                  style: GoogleFonts.mulish(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          if (order.trackingNumber?.isNotEmpty == true)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF5FF),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'Tracking: ${order.trackingNumber}',
                style: GoogleFonts.mulish(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E429F),
                ),
              ),
            ),
          if (order.trackingNumber?.isNotEmpty == true) SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  _isSubmitting ? null : () => _openSellerOrderDetail(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: 11.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 0,
              ),
              icon: Icon(Icons.visibility_outlined, size: 17.sp),
              label: Text(
                'Open Order Workspace',
                style: GoogleFonts.mulish(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSellerOrderDetail(Order order) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                SellerOrderDetailScreen(orderId: order.id, initialOrder: order),
      ),
    );

    if (updated == true && mounted) {
      await _loadDashboard(showLoader: false);
    }
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 36.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 68.sp, color: AppColors.primary),
            SizedBox(height: 12.h),
            Text(
              title,
              style: GoogleFonts.mulish(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              subtitle,
              style: GoogleFonts.mulish(
                fontSize: 13.sp,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final colorScheme = Theme.of(context).colorScheme;

    return BottomAppBar(
      color: colorScheme.surface,
      elevation: 8,
      child: SizedBox(
        height: 72.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _bottomItem(
                icon: Icons.dashboard_outlined,
                label: 'Dashboard',
                selected: true,
                onTap: () {},
              ),
            ),
            Expanded(
              child: _bottomItem(
                icon: Icons.storefront_outlined,
                label: 'Marketplace',
                selected: false,
                onTap: () => AppNavigator.navigateToMarketplace(context),
              ),
            ),
            Expanded(
              child: _bottomItem(
                icon: Icons.person_outline,
                label: 'Profile',
                selected: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22.sp,
              color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 2.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: GoogleFonts.mulish(
                  fontSize: 11.sp,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openProductDialog({Product? product}) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final isEdit = product != null;

    final nameController = TextEditingController(text: product?.name ?? '');
    final descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    final priceController = TextEditingController(
      text: product != null ? product.price.toStringAsFixed(0) : '',
    );
    final stockController = TextEditingController(
      text: product != null ? product.stockQuantity.toString() : '',
    );
    final imagesController = TextEditingController(
      text: product?.images.join(', ') ?? '',
    );

    String? selectedCategoryId;
    if (product?.categoryId != null &&
        _categories.any((category) => category.id == product!.categoryId)) {
      selectedCategoryId = product!.categoryId;
    }
    String? selectedPetType = product?.petType;
    bool isActive = product?.isActive ?? true;
    List<XFile> selectedLocalImages = [];

    final result = await showDialog<_ProductDialogResult>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isEdit ? 'Edit Product' : 'Add Product',
                style: GoogleFonts.mulish(fontWeight: FontWeight.w800),
              ),
              content: SizedBox(
                width: 360.w,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _dialogField(nameController, 'Product name'),
                      SizedBox(height: 10.h),
                      _dialogField(
                        descriptionController,
                        'Description',
                        maxLines: 3,
                      ),
                      SizedBox(height: 10.h),
                      _dialogField(
                        priceController,
                        'Price (PKR)',
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 10.h),
                      _dialogField(
                        stockController,
                        'Stock quantity',
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 10.h),
                      DropdownButtonFormField<String?>(
                        initialValue: selectedCategoryId,
                        isExpanded: true,
                        decoration: _dialogDecoration('Category *'),
                        items: [
                          ..._categories.map(
                            (category) => DropdownMenuItem<String?>(
                              value: category.id,
                              child: Text(category.name),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            selectedCategoryId = value;
                          });
                        },
                      ),
                      SizedBox(height: 10.h),
                      DropdownButtonFormField<String?>(
                        initialValue: selectedPetType,
                        isExpanded: true,
                        decoration: _dialogDecoration('Pet type (optional)'),
                        items: const [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Any'),
                          ),
                          DropdownMenuItem<String?>(
                            value: 'dog',
                            child: Text('Dog'),
                          ),
                          DropdownMenuItem<String?>(
                            value: 'cat',
                            child: Text('Cat'),
                          ),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            selectedPetType = value;
                          });
                        },
                      ),
                      SizedBox(height: 10.h),
                      _dialogField(
                        imagesController,
                        'Image URLs (comma separated)',
                        maxLines: 2,
                      ),
                      SizedBox(height: 10.h),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed:
                              _isSubmitting
                                  ? null
                                  : () async {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    final picked = await _imagePicker
                                        .pickMultiImage(imageQuality: 80);
                                    if (picked.isEmpty) return;
                                    setDialogState(() {
                                      selectedLocalImages = [
                                        ...selectedLocalImages,
                                        ...picked,
                                      ];
                                    });
                                  },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF243B53),
                            side: BorderSide(
                              color: const Color(
                                0xFF243B53,
                              ).withValues(alpha: 0.35),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                          ),
                          icon: Icon(Icons.upload_file_rounded, size: 16.sp),
                          label: Text(
                            'Add Images From Device',
                            style: GoogleFonts.mulish(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      if (selectedLocalImages.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FAFC),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: const Color(0xFFD9E2EC)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selected local files: ${selectedLocalImages.length}',
                                style: GoogleFonts.mulish(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF243B53),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              ...selectedLocalImages.asMap().entries.map(
                                (entry) => Padding(
                                  padding: EdgeInsets.only(bottom: 4.h),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          entry.value.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.mulish(
                                            fontSize: 11.sp,
                                            color: const Color(0xFF486581),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        icon: Icon(
                                          Icons.close_rounded,
                                          size: 16.sp,
                                          color: const Color(0xFF9B1C1C),
                                        ),
                                        onPressed: () {
                                          setDialogState(() {
                                            selectedLocalImages.removeAt(
                                              entry.key,
                                            );
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (isEdit) ...[
                        SizedBox(height: 10.h),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Product active',
                            style: GoogleFonts.mulish(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          value: isActive,
                          onChanged: (value) {
                            setDialogState(() {
                              isActive = value;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      _isSubmitting
                          ? null
                          : () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            Navigator.pop(dialogContext);
                          },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed:
                      _isSubmitting
                          ? null
                          : () async {
                            final name = nameController.text.trim();
                            final description =
                                descriptionController.text.trim();
                            final price = double.tryParse(
                              priceController.text.trim(),
                            );
                            final stock = int.tryParse(
                              stockController.text.trim(),
                            );
                            final selectedCategory =
                                selectedCategoryId?.trim() ?? '';

                            if (name.isEmpty ||
                                description.isEmpty ||
                                price == null ||
                                stock == null) {
                              _showSnack(
                                'Please fill all required fields',
                                isError: true,
                              );
                              return;
                            }

                            if (price <= 0) {
                              _showSnack(
                                'Price must be greater than 0',
                                isError: true,
                              );
                              return;
                            }

                            if (stock < 0) {
                              _showSnack(
                                'Stock quantity cannot be negative',
                                isError: true,
                              );
                              return;
                            }

                            if (selectedCategory.isEmpty) {
                              _showSnack(
                                'Please select a product category',
                                isError: true,
                              );
                              return;
                            }

                            final images =
                                imagesController.text
                                    .split(RegExp(r'[,\n]'))
                                    .map((e) => e.trim())
                                    .where((e) => e.isNotEmpty)
                                    .toList();

                            FocusManager.instance.primaryFocus?.unfocus();
                            await Future<void>.delayed(
                              const Duration(milliseconds: 16),
                            );
                            if (!dialogContext.mounted) return;

                            if (isEdit) {
                              Navigator.pop(
                                dialogContext,
                                _ProductDialogResult.edit(
                                  product.id,
                                  UpdateProductRequest(
                                    name: name,
                                    description: description,
                                    price: price,
                                    stockQuantity: stock,
                                    categoryId: selectedCategoryId,
                                    petType: selectedPetType,
                                    images: images,
                                    isActive: isActive,
                                  ),
                                  localImages: selectedLocalImages,
                                ),
                              );
                            } else {
                              Navigator.pop(
                                dialogContext,
                                _ProductDialogResult.create(
                                  CreateProductRequest(
                                    name: name,
                                    description: description,
                                    price: price,
                                    stockQuantity: stock,
                                    categoryId: selectedCategory,
                                    petType: selectedPetType,
                                    images: images,
                                  ),
                                  localImages: selectedLocalImages,
                                ),
                              );
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C6E69),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isEdit ? 'Update' : 'Create'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();
    imagesController.dispose();

    if (result == null) return;

    if (result.updateRequest != null && result.productId != null) {
      await _submitEditProduct(
        result.productId!,
        result.updateRequest!,
        localImages: result.localImages,
      );
      return;
    }

    if (result.createRequest != null) {
      await _submitCreateProduct(
        result.createRequest!,
        localImages: result.localImages,
      );
    }
  }

  InputDecoration _dialogDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Color(0xFF2C6E69)),
      ),
    );
  }

  Widget _dialogField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _dialogDecoration(label),
    );
  }

  Future<void> _submitCreateProduct(
    CreateProductRequest request, {
    List<XFile> localImages = const [],
  }) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final uploadedLocalImages = await _uploadLocalProductImages(localImages);
      if (uploadedLocalImages == null) return;

      final resolvedRequest = CreateProductRequest(
        name: request.name,
        description: request.description,
        price: request.price,
        currency: request.currency,
        stockQuantity: request.stockQuantity,
        categoryId: request.categoryId,
        petType: request.petType,
        images: [...request.images, ...uploadedLocalImages],
      );

      await _repo.createProduct(resolvedRequest);
      await _loadDashboard(showLoader: false);
      _showSnack('Product created successfully');
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

  Future<void> _submitEditProduct(
    String productId,
    UpdateProductRequest request, {
    List<XFile> localImages = const [],
  }) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final uploadedLocalImages = await _uploadLocalProductImages(localImages);
      if (uploadedLocalImages == null) return;

      final mergedImages = [
        ...(request.images ?? const <String>[]),
        ...uploadedLocalImages,
      ];

      final resolvedRequest = UpdateProductRequest(
        name: request.name,
        description: request.description,
        price: request.price,
        currency: request.currency,
        stockQuantity: request.stockQuantity,
        categoryId: request.categoryId,
        petType: request.petType,
        images: mergedImages,
        isActive: request.isActive,
      );

      await _repo.updateProduct(productId, resolvedRequest);
      await _loadDashboard(showLoader: false);
      _showSnack('Product updated successfully');
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

  Future<List<String>?> _uploadLocalProductImages(
    List<XFile> localImages,
  ) async {
    if (localImages.isEmpty) {
      return const <String>[];
    }

    final uploaded = await _imageService.uploadImages(
      localImages,
      folder: 'marketplace/products',
    );

    if (uploaded.isEmpty) {
      _showSnack(
        'Failed to upload local images. Please try another image.',
        isError: true,
      );
      return null;
    }

    if (uploaded.length < localImages.length) {
      _showSnack(
        'Some local images failed to upload. Continuing with available uploads.',
      );
    }

    return uploaded;
  }

  Future<void> _confirmDeactivateProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove product?'),
          content: Text('"${product.name}" will be removed from marketplace.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _repo.deleteProduct(product.id);
      await _loadDashboard(showLoader: false);
      _showSnack('Product removed successfully');
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

  String _sellerOrderStatus(Order order) {
    if (order.items.isEmpty) {
      return order.status;
    }

    final statuses =
        order.items.map((item) => item.sellerStatus.toLowerCase()).toSet();

    if (statuses.length == 1) {
      return statuses.first;
    }

    return order.status;
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.mulish()),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFF2C6E69),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildProductImagePreview(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Icon(
        Icons.inventory_2_outlined,
        size: 20.sp,
        color: const Color(0xFF627D98),
      );
    }

    if (imageUrl.startsWith('data:image/')) {
      try {
        final base64Data = imageUrl.split(',').last;
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => Icon(
                Icons.image_not_supported_outlined,
                size: 18.sp,
                color: const Color(0xFF829AB1),
              ),
        );
      } catch (_) {
        return Icon(
          Icons.image_not_supported_outlined,
          size: 18.sp,
          color: const Color(0xFF829AB1),
        );
      }
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder:
          (_, __, ___) => Icon(
            Icons.image_not_supported_outlined,
            size: 18.sp,
            color: const Color(0xFF829AB1),
          ),
    );
  }
}
