import '../../data/models/marketplace_models.dart';

const Object _unset = Object();

class CartState {
  final bool isLoading;
  final bool isAddingToCart;
  final bool isPlacingOrder;
  final List<CartItem> items;
  final Order? lastOrder;
  final String? addedProductId;
  final String? error;

  const CartState({
    this.isLoading = false,
    this.isAddingToCart = false,
    this.isPlacingOrder = false,
    this.items = const [],
    this.lastOrder,
    this.addedProductId,
    this.error,
  });

  CartState copyWith({
    bool? isLoading,
    bool? isAddingToCart,
    bool? isPlacingOrder,
    List<CartItem>? items,
    Object? lastOrder = _unset,
    Object? addedProductId = _unset,
    Object? error = _unset,
  }) {
    return CartState(
      isLoading: isLoading ?? this.isLoading,
      isAddingToCart: isAddingToCart ?? this.isAddingToCart,
      isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder,
      items: items ?? this.items,
      lastOrder:
          identical(lastOrder, _unset) ? this.lastOrder : lastOrder as Order?,
      addedProductId: identical(addedProductId, _unset)
          ? this.addedProductId
          : addedProductId as String?,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}
