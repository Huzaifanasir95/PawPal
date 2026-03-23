import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
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
  String? _selectedPetType;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: _buildSearchBar(context),
          ),
          SliverToBoxAdapter(
            child: _buildPetTypeFilter(context),
          ),
          SliverToBoxAdapter(
            child: _buildCategoryChips(context),
          ),
          _buildProductGrid(context),
          SliverToBoxAdapter(child: SizedBox(height: 80.h)),
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
                onSubmitted: (val) {
                  context.read<MarketplaceCubit>().filterProducts(
                        search: val.isEmpty ? null : val,
                        categoryId: context
                            .read<MarketplaceCubit>()
                            .state
                            .selectedCategoryId,
                        petType: _selectedPetType,
                      );
                },
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  context.read<MarketplaceCubit>().filterProducts(
                        categoryId: context
                            .read<MarketplaceCubit>()
                            .state
                            .selectedCategoryId,
                        petType: _selectedPetType,
                      );
                  setState(() {});
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

  Widget _buildPetTypeFilter(BuildContext context) {
    final petTypes = ['All', 'dog', 'cat', 'bird', 'fish', 'other'];
    return SizedBox(
      height: 44.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: petTypes.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, i) {
          final type = petTypes[i];
          final selected = type == 'All'
              ? _selectedPetType == null
              : _selectedPetType == type;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPetType = type == 'All' ? null : type;
              });
              context.read<MarketplaceCubit>().filterProducts(
                    petType: _selectedPetType,
                    search: _searchController.text.isNotEmpty
                        ? _searchController.text
                        : null,
                    categoryId: context
                        .read<MarketplaceCubit>()
                        .state
                        .selectedCategoryId,
                  );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF2C6E69) : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: selected
                    ? [
                        BoxShadow(
                            color: const Color(0xFF2C6E69).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  type == 'All'
                      ? 'All'
                      : type[0].toUpperCase() + type.substring(1),
                  style: GoogleFonts.mulish(
                    fontSize: 12.sp,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? Colors.white : const Color(0xFF6A6A6A),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    return BlocBuilder<MarketplaceCubit, MarketplaceState>(
      builder: (context, state) {
        if (state.categories.isEmpty) return const SizedBox.shrink();
        final all = [null, ...state.categories.map((c) => c)];
        return SizedBox(
          height: 50.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            itemCount: all.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, i) {
              final cat = all[i];
              final selected = state.selectedCategoryId == cat?.id;
              return GestureDetector(
                onTap: () {
                  context.read<MarketplaceCubit>().filterProducts(
                        categoryId: cat?.id,
                        petType: _selectedPetType,
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
                        : const Color(0xFFF3EFE8),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : Colors.transparent,
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

        if (state.products.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(60.w),
                child: Column(
                  children: [
                    Icon(Icons.shopping_bag_outlined,
                        size: 56.sp, color: AppColors.primary),
                    SizedBox(height: 16.h),
                    Text('No products found',
                        style: GoogleFonts.mulish(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        )),
                    SizedBox(height: 8.h),
                    Text('Try adjusting your filters',
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
                final product = state.products[i];
                return ProductCard(
                  product: product,
                  onTap: () => _openProductDetail(context, product.id),
                  onAddToCart: () => context
                      .read<CartCubit>()
                      .addToCart(product.id, 1),
                );
              },
              childCount: state.products.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.65,
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
          childAspectRatio: 0.65,
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
