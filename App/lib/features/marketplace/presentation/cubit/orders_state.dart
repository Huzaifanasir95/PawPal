import '../../data/models/marketplace_models.dart';

const Object _unset = Object();

class OrdersState {
  final bool isLoading;
  final bool isLoadingDetail;
  final List<Order> orders;
  final Order? selectedOrder;
  final String? error;

  const OrdersState({
    this.isLoading = false,
    this.isLoadingDetail = false,
    this.orders = const [],
    this.selectedOrder,
    this.error,
  });

  OrdersState copyWith({
    bool? isLoading,
    bool? isLoadingDetail,
    List<Order>? orders,
    Object? selectedOrder = _unset,
    Object? error = _unset,
  }) {
    return OrdersState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      orders: orders ?? this.orders,
      selectedOrder:
          identical(selectedOrder, _unset)
              ? this.selectedOrder
              : selectedOrder as Order?,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}
