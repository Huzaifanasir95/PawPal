import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/marketplace_models.dart';
import '../../data/repositories/marketplace_repository.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final MarketplaceRepository _repo;

  OrdersCubit(this._repo) : super(const OrdersState());

  Future<void> loadOrders() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final orders = await _repo.getMyOrders();
      emit(state.copyWith(isLoading: false, orders: orders));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> loadOrderDetail(String orderId) async {
    emit(state.copyWith(isLoadingDetail: true, selectedOrder: null, error: null));
    try {
      final order = await _repo.getOrderById(orderId);
      emit(state.copyWith(isLoadingDetail: false, selectedOrder: order));
    } catch (e) {
      emit(state.copyWith(
        isLoadingDetail: false,
        error: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void clearError() => emit(state.copyWith(error: null));
}
