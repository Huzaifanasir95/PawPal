import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/marketplace_models.dart';
import '../../data/repositories/marketplace_repository.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final MarketplaceRepository _repo;

  CartCubit(this._repo) : super(const CartState());

  void _safeEmit(CartState newState) {
    if (!isClosed) {
      emit(newState);
    }
  }

  Future<void> loadCart() async {
    _safeEmit(state.copyWith(isLoading: true, error: null));
    try {
      final items = await _repo.getCart();
      _safeEmit(state.copyWith(isLoading: false, items: items));
    } catch (e) {
      _safeEmit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    _safeEmit(state.copyWith(isAddingToCart: true, error: null, addedProductId: null));
    try {
      await _repo.addToCart(productId, quantity);
      await loadCart();
      _safeEmit(state.copyWith(isAddingToCart: false, addedProductId: productId));
    } catch (e) {
      _safeEmit(state.copyWith(
        isAddingToCart: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> removeItem(String cartItemId) async {
    try {
      await _repo.removeFromCart(cartItemId);
      final updated = state.items.where((i) => i.id != cartItemId).toList();
      _safeEmit(state.copyWith(items: updated));
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString().replaceAll('Exception: ', '')));
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
      _safeEmit(state.copyWith(items: updated));
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> placeOrder(PlaceOrderRequest request) async {
    _safeEmit(state.copyWith(isPlacingOrder: true, error: null, lastOrder: null));
    try {
      var order = await _repo.placeOrder(request);
      if (request.paymentMethod == 'card') {
        order = await _repo.completeStripePayment(order.id);
      }
      _safeEmit(state.copyWith(
        isPlacingOrder: false,
        lastOrder: order,
        items: [],
      ));
    } catch (e) {
      _safeEmit(state.copyWith(
        isPlacingOrder: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  double get total => state.items.fold(0.0, (sum, i) => sum + i.totalPrice);
  int get itemCount => state.items.fold(0, (sum, i) => sum + i.quantity);

  void clearError() => _safeEmit(state.copyWith(error: null));
  void clearAddedProductId() => _safeEmit(state.copyWith(addedProductId: null));
  void clearLastOrder() => _safeEmit(state.copyWith(lastOrder: null));
}
