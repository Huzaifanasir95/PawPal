import '../../data/models/marketplace_models.dart';

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
    Order? selectedOrder,
    String? error,
  }) {
    return OrdersState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      orders: orders ?? this.orders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      error: error,
    );
  }
}
