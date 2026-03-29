import '../../data/models/marketplace_models.dart';

const Object _unset = Object();

class MarketplaceState {
  final bool isLoading;
  final bool isLoadingProducts;
  final bool isLoadingDetail;
  final List<ProductCategory> categories;
  final List<Product> products;
  final Product? selectedProduct;
  final String? selectedCategoryId;
  final String? selectedPetType;
  final String? searchQuery;
  final String? error;

  const MarketplaceState({
    this.isLoading = false,
    this.isLoadingProducts = false,
    this.isLoadingDetail = false,
    this.categories = const [],
    this.products = const [],
    this.selectedProduct,
    this.selectedCategoryId,
    this.selectedPetType,
    this.searchQuery,
    this.error,
  });

  MarketplaceState copyWith({
    bool? isLoading,
    bool? isLoadingProducts,
    bool? isLoadingDetail,
    List<ProductCategory>? categories,
    List<Product>? products,
    Object? selectedProduct = _unset,
    Object? selectedCategoryId = _unset,
    Object? selectedPetType = _unset,
    Object? searchQuery = _unset,
    Object? error = _unset,
  }) {
    return MarketplaceState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      categories: categories ?? this.categories,
      products: products ?? this.products,
      selectedProduct: identical(selectedProduct, _unset)
          ? this.selectedProduct
          : selectedProduct as Product?,
      selectedCategoryId: identical(selectedCategoryId, _unset)
          ? this.selectedCategoryId
          : selectedCategoryId as String?,
      selectedPetType: identical(selectedPetType, _unset)
          ? this.selectedPetType
          : selectedPetType as String?,
      searchQuery: identical(searchQuery, _unset)
          ? this.searchQuery
          : searchQuery as String?,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}
