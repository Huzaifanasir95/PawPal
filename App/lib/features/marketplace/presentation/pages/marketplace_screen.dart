import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/marketplace_models.dart';
import '../../data/repositories/marketplace_repository.dart';
import '../cubit/marketplace_cubit.dart';
import '../cubit/marketplace_state.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = MarketplaceRepository.instance;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MarketplaceCubit(repo)..loadInitial()),
        BlocProvider(create: (_) => CartCubit(repo)..loadCart()),
      ],
      child: const _MarketplaceView(),
    );
  }
}

class _MarketplaceView extends StatefulWidget {
  const _MarketplaceView();

  @override
  State<_MarketplaceView> createState() => _MarketplaceViewState();
}

class _MarketplaceViewState extends State<_MarketplaceView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filterProducts(List<Product> products) {
    if (_searchQuery.isEmpty) return products;
    
    final query = _searchQuery.toLowerCase();
    return products.where((product) {
      final name = product.name.toLowerCase();
      final description = product.description.toLowerCase();
      final category = (product.categoryName ?? '').toLowerCase();
      final petType = (product.petType ?? '').toLowerCase();
      
      return name.contains(query) ||
             description.contains(query) ||
             category.contains(query) ||
             petType.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: Stack(
        children: [
          Positioned(
            top: -90.h,
            right: -70.w,
            child: Container(
              width: 240.w,
              height: 240.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.22),
              ),
            ),
          ),
          Positioned(
            top: 180.h,
            left: -60.w,
            child: Container(
              width: 180.w,
              height: 180.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE6F4F2),
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: _buildSearchBar(context),
              ),
              SliverToBoxAdapter(
                child: _buildCategoryChips(context),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 6.h),
                  child: BlocBuilder<MarketplaceCubit, MarketplaceState>(
                    builder: (context, state) {
                      final filtered = _filterProducts(state.products);
                      return Row(
                        children: [
                          Text(
                            '${filtered.length} items found',
                            style: GoogleFonts.mulish(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2C6E69),
                            ),
                          ),
                          const Spacer(),
                          if (state.isLoadingProducts)
                            SizedBox(
                              width: 14.w,
                              height: 14.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.darkTeal,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              _buildProductGrid(context),
              SliverToBoxAdapter(child: SizedBox(height: 80.h)),
            ],
          ),
        ],
      ),
      floatingActionButton: _buildCartFab(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160.h,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: const Color(0xFF191D21), size: 20.sp),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            final count = state.items.fold(0, (s, i) => s + i.quantity);
            return Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: IconButton(
                icon: Badge(
                  label: count > 0 ? Text('$count') : null,
                  isLabelVisible: count > 0,
                  child: Icon(Icons.shopping_cart_outlined,
                      color: const Color(0xFF191D21), size: 24.sp),
                ),
                onPressed: () => _openCart(context),
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFB3E0DB), Color(0xFF7FC9C2)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40.h),
                  Text(
                    'Pet Shop',
                    style: GoogleFonts.mulish(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF191D21),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Everything your pet needs',
                    style: GoogleFonts.mulish(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2C6E69),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: 16.w),
            Icon(Icons.search_rounded,
                color: AppColors.textSecondary, size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.mulish(
                    fontSize: 14.sp, color: const Color(0xFF191D21)),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: GoogleFonts.mulish(
                      fontSize: 14.sp, color: AppColors.textSecondary),
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: Icon(Icons.close_rounded,
                      color: AppColors.textSecondary, size: 18.sp),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    return BlocBuilder<MarketplaceCubit, MarketplaceState>(
      builder: (context, state) {
        if (state.categories.isEmpty) return const SizedBox.shrink();
        final all = [null, ...state.categories.map((c) => c)];
        return SizedBox(
          height: 56.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
            itemCount: all.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, i) {
              final cat = all[i];
              final selected = state.selectedCategoryId == cat?.id;
              return GestureDetector(
                onTap: () {
                  context.read<MarketplaceCubit>().filterProducts(
                        categoryId: cat?.id,
                        search: _searchController.text.isNotEmpty
                            ? _searchController.text
                            : null,
                      );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF7FC9C2)
                          : AppColors.primary.withOpacity(0.35),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      cat?.name ?? 'All',
                      style: GoogleFonts.mulish(
                        fontSize: 12.sp,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected
                            ? const Color(0xFF191D21)
                            : const Color(0xFF6A6A6A),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductGrid(BuildContext context) {
    return BlocBuilder<MarketplaceCubit, MarketplaceState>(
      builder: (context, state) {
        if (state.isLoading) {
          return SliverToBoxAdapter(child: _buildLoadingSkeleton());
        }

        if (state.error != null && state.products.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(40.w),
                child: Column(
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
                          context.read<MarketplaceCubit>().loadInitial(),
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
            ),
          );
        }

        final filteredProducts = _filterProducts(state.products);

        if (filteredProducts.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(60.w),
                child: Column(
                  children: [
                    Icon(Icons.shopping_bag_outlined,
                        size: 56.sp, color: AppColors.primary),
                    SizedBox(height: 16.h),
                    Text(
                        _searchQuery.isNotEmpty
                            ? 'No products match "$_searchQuery"'
                            : 'No products found',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.mulish(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        )),
                    SizedBox(height: 8.h),
                    Text(
                        _searchQuery.isNotEmpty
                            ? 'Try a different search term'
                            : 'Try adjusting your filters',
                        style: GoogleFonts.mulish(
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final product = filteredProducts[i];
                return ProductCard(
                  product: product,
                  onTap: () => _openProductDetail(context, product.id),
                  onAddToCart: () => context
                      .read<CartCubit>()
                      .addToCart(product.id, 1),
                );
              },
              childCount: filteredProducts.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.58,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartFab(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final count = state.items.fold(0, (s, i) => s + i.quantity);
        if (count == 0) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => _openCart(context),
          backgroundColor: const Color(0xFF2C6E69),
          icon: Icon(Icons.shopping_cart_rounded,
              color: Colors.white, size: 20.sp),
          label: Text(
            'Cart ($count)',
            style: GoogleFonts.mulish(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingSkeleton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.58,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EFE8),
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.r)),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 10.h,
                        width: 60.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3EFE8),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        height: 14.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3EFE8),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openProductDetail(BuildContext context, String productId) {
    final marketplaceCubit = context.read<MarketplaceCubit>();
    final cartCubit = context.read<CartCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: marketplaceCubit),
            BlocProvider.value(value: cartCubit),
          ],
          child: ProductDetailScreen(productId: productId),
        ),
      ),
    );
  }

  void _openCart(BuildContext context) {
    final cartCubit = context.read<CartCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cartCubit,
          child: const CartScreen(),
        ),
      ),
    );
  }
}
