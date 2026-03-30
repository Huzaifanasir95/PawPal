import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/marketplace_models.dart';
import '../../data/repositories/marketplace_repository.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final MarketplaceRepository _repo;

  CartCubit(this._repo) : super(const CartState());

  Future<void> loadCart() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final items = await _repo.getCart();
      emit(state.copyWith(isLoading: false, items: items));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    emit(state.copyWith(isAddingToCart: true, error: null, addedProductId: null));
    try {
      await _repo.addToCart(productId, quantity);
      await loadCart();
      emit(state.copyWith(isAddingToCart: false, addedProductId: productId));
    } catch (e) {
      emit(state.copyWith(
        isAddingToCart: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> removeItem(String cartItemId) async {
    try {
      await _repo.removeFromCart(cartItemId);
      final updated = state.items.where((i) => i.id != cartItemId).toList();
      emit(state.copyWith(items: updated));
    } catch (e) {
      emit(state.copyWith(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(cartItemId);
      return;
    }
    try {
      await _repo.updateCartItem(cartItemId, quantity);
      final updated = state.items.map((i) {
        if (i.id == cartItemId) {
          i.quantity = quantity;
          return i;
        }
        return i;
      }).toList();
      emit(state.copyWith(items: updated));
    } catch (e) {
      emit(state.copyWith(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> placeOrder(PlaceOrderRequest request) async {
    emit(state.copyWith(isPlacingOrder: true, error: null, lastOrder: null));
    try {
      final order = await _repo.placeOrder(request);
      emit(state.copyWith(
        isPlacingOrder: false,
        lastOrder: order,
        items: [],
      ));
    } catch (e) {
      emit(state.copyWith(
        isPlacingOrder: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  double get total => state.items.fold(0.0, (sum, i) => sum + i.totalPrice);
  int get itemCount => state.items.fold(0, (sum, i) => sum + i.quantity);

  void clearError() => emit(state.copyWith(error: null));
  void clearAddedProductId() => emit(state.copyWith(addedProductId: null));
  void clearLastOrder() => emit(state.copyWith(lastOrder: null));
}
