import '../../data/models/marketplace_models.dart';

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
    Product? selectedProduct,
    String? selectedCategoryId,
    String? selectedPetType,
    String? searchQuery,
    String? error,
  }) {
    return MarketplaceState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      categories: categories ?? this.categories,
      products: products ?? this.products,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedPetType: selectedPetType ?? this.selectedPetType,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error,
    );
  }
}
