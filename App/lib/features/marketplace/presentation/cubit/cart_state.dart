import '../../data/models/marketplace_models.dart';

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
    Order? lastOrder,
    String? addedProductId,
    String? error,
  }) {
    return CartState(
      isLoading: isLoading ?? this.isLoading,
      isAddingToCart: isAddingToCart ?? this.isAddingToCart,
      isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder,
      items: items ?? this.items,
      lastOrder: lastOrder ?? this.lastOrder,
      addedProductId: addedProductId ?? this.addedProductId,
      error: error,
    );
  }
}
