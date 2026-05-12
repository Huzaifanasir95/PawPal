import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import '../../../../core/services/api_client.dart';
import '../cubit/marketplace_cubit.dart';
import '../cubit/marketplace_state.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../../data/models/marketplace_models.dart';
import '../../data/repositories/marketplace_repository.dart';
import '../../../chat/data/models/chat_model.dart';
import '../../../chat/data/repositories/chat_repository.dart';
import '../../../chat/presentation/pages/chat_conversation_screen.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final MarketplaceRepository _repo = MarketplaceRepository.instance;
  final ChatRepository _chatRepository = ChatRepository(ApiClient.instance);
  int _quantity = 1;
  int _selectedImageIndex = 0;
  bool _isLoadingReviews = false;
  bool _isSubmittingReview = false;
  bool _isOpeningSellerChat = false;
  String? _reviewsError;
  List<ProductReview> _reviews = const <ProductReview>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketplaceCubit>().loadProductDetail(widget.productId);
      _loadReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocBuilder<MarketplaceCubit, MarketplaceState>(
        builder: (context, state) {
          if (state.isLoadingDetail) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (state.selectedProduct == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    state.error ?? 'Product not found',
                    style: GoogleFonts.mulish(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                    ),
                    child: Text(
                      'Go Back',
                      style: GoogleFonts.mulish(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final product = state.selectedProduct!;
          final safeImageIndex =
              product.images.isNotEmpty &&
                      _selectedImageIndex < product.images.length
                  ? _selectedImageIndex
                  : 0;

          return CustomScrollView(
            slivers: [
              // Hero image sliver
              SliverAppBar(
                expandedHeight: 320.h,
                pinned: true,
                backgroundColor: colorScheme.surface,
                leading: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: CircleAvatar(
                    backgroundColor: colorScheme.surface,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: colorScheme.onSurface,
                        size: 16.sp,
                      ),
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
                          ? _buildProductImage(product.images[safeImageIndex])
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
                                onTap:
                                    () =>
                                        setState(() => _selectedImageIndex = i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                                  width: i == _selectedImageIndex ? 24.w : 8.w,
                                  height: 8.h,
                                  decoration: BoxDecoration(
                                    color:
                                        i == safeImageIndex
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                ),
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
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24.r),
                    ),
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
                              _buildChip(
                                product.categoryName!,
                                colorScheme.primary.withValues(alpha: 0.2),
                                colorScheme.primary,
                              ),
                            if (product.petType != null && product.petType!.isNotEmpty) ...[
                              SizedBox(width: 8.w),
                              _buildChip(
                                product.petType![0].toUpperCase() +
                                    product.petType!.substring(1),
                                colorScheme.secondaryContainer,
                                colorScheme.onSecondaryContainer,
                              ),
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
                            height: 1.25,
                            color: colorScheme.onSurface,
                          ),
                        ),

                        SizedBox(height: 10.h),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: colorScheme.outline.withValues(
                                alpha: 0.28,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Price',
                                style: GoogleFonts.mulish(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'PKR ${product.price.toStringAsFixed(0)}',
                                style: GoogleFonts.mulish(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w900,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 10.h),

                        _buildStockPill(product.stockQuantity),

                        SizedBox(height: 12.h),

                        _buildProductMetaCards(
                          product.rating,
                          product.totalReviews,
                          product.totalSold,
                        ),

                        SizedBox(height: 18.h),

                        _buildDescriptionSection(product.description),

                        SizedBox(height: 16.h),

                        _buildReviewsSection(product),

                        SizedBox(height: 16.h),

                        // Seller
                        if (product.sellerName != null) ...[
                          Divider(
                            color: colorScheme.outline.withValues(alpha: 0.35),
                            height: 1.h,
                          ),
                          SizedBox(height: 16.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: colorScheme.outline.withValues(
                                  alpha: 0.25,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18.r,
                                  backgroundColor: colorScheme.primary
                                      .withValues(alpha: 0.18),
                                  child: Icon(
                                    Icons.person_outline_rounded,
                                    size: 18.sp,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Seller',
                                        style: GoogleFonts.mulish(
                                          fontSize: 11.sp,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      Text(
                                        product.sellerName!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.mulish(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 80.w,
                                  child: OutlinedButton.icon(
                                    onPressed:
                                        _isOpeningSellerChat ||
                                                ApiClient.instance.userId ==
                                                    product.sellerId
                                            ? null
                                            : () => _startChatWithSeller(product),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: colorScheme.primary,
                                      side: BorderSide(
                                        color: colorScheme.primary.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 8.h,
                                      ),
                                    ),
                                  icon:
                                      _isOpeningSellerChat
                                          ? SizedBox(
                                            width: 14.w,
                                            height: 14.h,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: colorScheme.primary,
                                            ),
                                          )
                                          : Icon(
                                            Icons.chat_bubble_outline_rounded,
                                            size: 15.sp,
                                          ),
                                    label: Text(
                                      _isOpeningSellerChat
                                          ? 'Opening...'
                                          : 'Message',
                                      style: GoogleFonts.mulish(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

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
          return _buildBottomBar(context, product);
        },
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Product product) {
    final colorScheme = Theme.of(context).colorScheme;
    final inStock = product.stockQuantity > 0;
    final canAddToCart =
        ApiClient.instance.userId == null ||
        ApiClient.instance.userId != product.sellerId;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.12),
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
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  _quantityButton(
                    Icons.remove_rounded,
                    () => setState(
                      () => _quantity = (_quantity - 1).clamp(1, 99),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Text(
                      '$_quantity',
                      style: GoogleFonts.mulish(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
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
                    context.read<CartCubit>().clearAddedProductId();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Added to cart!',
                          style: GoogleFonts.mulish(),
                        ),
                        backgroundColor: colorScheme.tertiary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => BlocProvider.value(
                              value: context.read<CartCubit>(),
                              child: const CartScreen(),
                            ),
                      ),
                    );
                  }

                  if (state.error != null && state.error!.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.error!,
                          style: GoogleFonts.mulish(),
                        ),
                        backgroundColor: colorScheme.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    );
                  }
                },
                builder: (context, cartState) {
                  return ElevatedButton(
                    onPressed:
                        inStock && canAddToCart && !cartState.isAddingToCart
                            ? () => context.read<CartCubit>().addToCart(
                              product.id,
                              _quantity,
                            )
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          inStock
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 0,
                    ),
                    child:
                        cartState.isAddingToCart
                            ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(
                                color: colorScheme.onPrimary,
                                strokeWidth: 2,
                              ),
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  color: colorScheme.onPrimary,
                                  size: 18.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  !canAddToCart
                                      ? 'Your Listing'
                                      : (inStock
                                          ? 'Add to Cart'
                                          : 'Out of Stock'),
                                  style: GoogleFonts.mulish(
                                    color: colorScheme.onPrimary,
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

  Future<void> _startChatWithSeller(Product product) async {
    if (_isOpeningSellerChat) {
      return;
    }

    final viewerId = ApiClient.instance.userId?.trim();
    if (viewerId == null || viewerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please sign in to message sellers.',
            style: GoogleFonts.mulish(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (viewerId == product.sellerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'This is your own listing.',
            style: GoogleFonts.mulish(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isOpeningSellerChat = true);

    try {
      final chat = await _chatRepository.startChat(
        StartChatRequest(vetId: product.sellerId),
      );

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => ChatConversationScreen(
                chatId: chat.id,
                otherUserName: product.sellerName ?? 'Seller',
              ),
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
        setState(() => _isOpeningSellerChat = false);
      }
    }
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
      _reviewsError = null;
    });

    try {
      final reviews = await _repo.getProductReviews(
        widget.productId,
        limit: 20,
      );
      if (!mounted) return;
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _reviewsError = e.toString().replaceAll('Exception: ', '');
        _isLoadingReviews = false;
      });
    }
  }

  Future<void> _showReviewDialog(Product product) async {
    final colorScheme = Theme.of(context).colorScheme;
    final currentUserId = ApiClient.instance.userId;
    if (currentUserId != null && currentUserId == product.sellerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You cannot review your own product.',
            style: GoogleFonts.mulish(),
          ),
          backgroundColor: colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final commentController = TextEditingController();
    int rating = 5;

    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(
                'Write a Review',
                style: GoogleFonts.mulish(fontWeight: FontWeight.w800),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reviews can only be submitted after delivery.',
                    style: GoogleFonts.mulish(
                      fontSize: 12.sp,
                      color: colorScheme.onSurfaceVariant,
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
                          color: colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Share your experience (optional)',
                      hintStyle: GoogleFonts.mulish(fontSize: 13.sp),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      _isSubmittingReview
                          ? null
                          : () => Navigator.of(dialogContext).pop(false),
                  child: Text('Cancel', style: GoogleFonts.mulish()),
                ),
                ElevatedButton(
                  onPressed:
                      _isSubmittingReview
                          ? null
                          : () async {
                            setState(() => _isSubmittingReview = true);
                            try {
                              await _repo.addProductReview(
                                product.id,
                                CreateProductReviewRequest(
                                  rating: rating,
                                  comment: commentController.text.trim(),
                                ),
                              );

                              if (dialogContext.mounted) {
                                Navigator.of(dialogContext).pop(true);
                              }
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceAll('Exception: ', ''),
                                    style: GoogleFonts.mulish(),
                                  ),
                                  backgroundColor: colorScheme.error,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } finally {
                              if (mounted) {
                                setState(() => _isSubmittingReview = false);
                              }
                            }
                          },
                  child:
                      _isSubmittingReview
                          ? SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            'Submit',
                            style: GoogleFonts.mulish(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                ),
              ],
            );
          },
        );
      },
    );

    commentController.dispose();

    if (submitted == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Review submitted!', style: GoogleFonts.mulish()),
          backgroundColor: colorScheme.tertiary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _loadReviews();
      if (mounted) {
        context.read<MarketplaceCubit>().loadProductDetail(widget.productId);
      }
    }
  }

  Widget _buildReviewsSection(Product product) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentUserId = ApiClient.instance.userId;
    final canAttemptReview =
        currentUserId == null || currentUserId != product.sellerId;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.reviews_outlined,
                size: 18.sp,
                color: colorScheme.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                'Customer Reviews',
                style: GoogleFonts.mulish(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (canAttemptReview)
                TextButton.icon(
                  onPressed:
                      _isSubmittingReview
                          ? null
                          : () => _showReviewDialog(product),
                  icon: Icon(Icons.edit_rounded, size: 16.sp),
                  label: Text(
                    'Write Review',
                    style: GoogleFonts.mulish(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          if (_isLoadingReviews)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              ),
            )
          else if (_reviewsError != null)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                _reviewsError!,
                style: GoogleFonts.mulish(
                  fontSize: 12.sp,
                  color: colorScheme.error,
                ),
              ),
            )
          else if (_reviews.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                'No reviews yet. Purchase and receive the product to leave the first review.',
                style: GoogleFonts.mulish(
                  fontSize: 13.sp,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            )
          else
            Column(children: _reviews.map(_buildReviewTile).toList()),
        ],
      ),
    );
  }

  Widget _buildReviewTile(ProductReview review) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14.r,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
                child: Text(
                  (review.userName ?? 'P').isNotEmpty
                      ? (review.userName ?? 'P')[0].toUpperCase()
                      : 'P',
                  style: GoogleFonts.mulish(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  review.userName ?? 'Pet owner',
                  style: GoogleFonts.mulish(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                _formatReviewDate(review.createdAt),
                style: GoogleFonts.mulish(
                  fontSize: 11.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < review.rating
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                size: 16.sp,
                color: colorScheme.secondary,
              ),
            ),
          ),
          if (review.comment != null && review.comment!.trim().isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              review.comment!,
              style: GoogleFonts.mulish(
                fontSize: 13.sp,
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatReviewDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays < 1) return 'Today';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  Widget _quantityButton(IconData icon, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        alignment: Alignment.center,
        child: Icon(icon, size: 18.sp, color: colorScheme.onSurface),
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

  Widget _buildProductMetaCards(
    double rating,
    int totalReviews,
    int totalSold,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildMetaCard(
            icon: Icons.star_rounded,
            iconColor: Theme.of(context).colorScheme.secondary,
            title: rating.toStringAsFixed(1),
            subtitle: '$totalReviews reviews',
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildMetaCard(
            icon: Icons.local_shipping_outlined,
            iconColor: Theme.of(context).colorScheme.primary,
            title: '$totalSold sold',
            subtitle: 'Completed orders',
          ),
        ),
      ],
    );
  }

  Widget _buildMetaCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: iconColor),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.mulish(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.mulish(
                    fontSize: 11.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(String description) {
    final colorScheme = Theme.of(context).colorScheme;
    final highlights = _buildDescriptionHighlights(description);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 18.sp,
                color: colorScheme.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                'About this product',
                style: GoogleFonts.mulish(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ...highlights.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 15.sp,
                    color: colorScheme.tertiary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.mulish(
                        fontSize: 13.sp,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            description,
            style: GoogleFonts.mulish(
              fontSize: 14.sp,
              height: 1.65,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockPill(int stockQuantity) {
    final colorScheme = Theme.of(context).colorScheme;
    final inStock = stockQuantity > 0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      decoration: BoxDecoration(
        color:
            inStock
                ? colorScheme.tertiary.withValues(alpha: 0.1)
                : colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color:
              inStock
                  ? colorScheme.tertiary.withValues(alpha: 0.35)
                  : colorScheme.error.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            inStock ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 16.sp,
            color: inStock ? colorScheme.tertiary : colorScheme.error,
          ),
          SizedBox(width: 7.w),
          Text(
            inStock ? '$stockQuantity in stock' : 'Out of stock',
            style: GoogleFonts.mulish(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: inStock ? colorScheme.tertiary : colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _buildDescriptionHighlights(String description) {
    final cleaned = description.trim();
    if (cleaned.isEmpty) return ['No description available'];

    final parts =
        cleaned
            .split(RegExp(r'[.!?]+\s*'))
            .map((e) => e.trim())
            .where((e) => e.length >= 12)
            .toList();

    if (parts.isEmpty) return [cleaned];
    return parts.take(3).toList();
  }

  Widget _buildPlaceholder() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          size: 64.sp,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.startsWith('data:image/')) {
      try {
        final base64Data = imageUrl.split(',').last;
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      } catch (_) {
        return _buildPlaceholder();
      }
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder:
          (_, __) => Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
      errorWidget: (_, __, ___) => _buildPlaceholder(),
    );
  }
}
