import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/marketplace_models.dart';
import '../../data/repositories/marketplace_repository.dart';
import 'marketplace_state.dart';

class MarketplaceCubit extends Cubit<MarketplaceState> {
  final MarketplaceRepository _repo;

  MarketplaceCubit(this._repo) : super(const MarketplaceState());

  Future<void> loadInitial() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final results = await Future.wait([
        _repo.getCategories(),
        _repo.getProducts(limit: 20),
      ]);
      emit(state.copyWith(
        isLoading: false,
        categories: results[0] as List<ProductCategory>,
        products: results[1] as List<Product>,
      ));
    } catch (e) {
      emit(state.copyWith(
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
    emit(state.copyWith(
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
      emit(state.copyWith(
        isLoadingProducts: false,
        products: products,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingProducts: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> loadProductDetail(String productId) async {
    emit(state.copyWith(isLoadingDetail: true, selectedProduct: null, error: null));
    try {
      final product = await _repo.getProductById(productId);
      emit(state.copyWith(isLoadingDetail: false, selectedProduct: product));
    } catch (e) {
      emit(state.copyWith(
        isLoadingDetail: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void clearError() => emit(state.copyWith(error: null));
  void clearSelectedProduct() => emit(state.copyWith(selectedProduct: null));
}
