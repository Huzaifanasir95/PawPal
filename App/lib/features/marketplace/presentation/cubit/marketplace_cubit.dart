import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/marketplace_models.dart';
import '../../data/repositories/marketplace_repository.dart';
import 'marketplace_state.dart';

class MarketplaceCubit extends Cubit<MarketplaceState> {
  final MarketplaceRepository _repo;

  MarketplaceCubit(this._repo) : super(const MarketplaceState());

  void _safeEmit(MarketplaceState newState) {
    if (!isClosed) {
      emit(newState);
    }
  }

  Future<void> loadInitial() async {
    _safeEmit(state.copyWith(isLoading: true, error: null));
    try {
      final results = await Future.wait([
        _repo.getCategories(),
        _repo.getProducts(limit: 20),
      ]);
      _safeEmit(state.copyWith(
        isLoading: false,
        categories: results[0] as List<ProductCategory>,
        products: results[1] as List<Product>,
      ));
    } catch (e) {
      _safeEmit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> filterProducts({
    String? categoryId,
    String? petType,
    String? search,
    double? minPrice,
    double? maxPrice,
  }) async {
    _safeEmit(state.copyWith(
      isLoadingProducts: true,
      selectedCategoryId: categoryId,
      selectedPetType: petType,
      searchQuery: search,
      error: null,
    ));
    try {
      final products = await _repo.getProducts(
        categoryId: categoryId,
        petType: petType,
        search: search,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
      _safeEmit(state.copyWith(
        isLoadingProducts: false,
        products: products,
      ));
    } catch (e) {
      _safeEmit(state.copyWith(
        isLoadingProducts: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> loadProductDetail(String productId) async {
    _safeEmit(state.copyWith(isLoadingDetail: true, selectedProduct: null, error: null));
    try {
      final product = await _repo.getProductById(productId);
      _safeEmit(state.copyWith(isLoadingDetail: false, selectedProduct: product));
    } catch (e) {
      _safeEmit(state.copyWith(
        isLoadingDetail: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void clearError() => _safeEmit(state.copyWith(error: null));
  void clearSelectedProduct() => _safeEmit(state.copyWith(selectedProduct: null));
}
