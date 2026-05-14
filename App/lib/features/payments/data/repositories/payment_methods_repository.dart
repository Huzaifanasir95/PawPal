import '../../../../core/services/api_client.dart';
import '../models/payment_method_model.dart';

class PaymentMethodsRepository {
  final ApiClient _apiClient = ApiClient.instance;

  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final response = await _apiClient.get('/api/v1/payment-methods');
    if (response.data['success'] == true) {
      final list = response.data['paymentMethods'] as List<dynamic>? ?? const [];
      return list
          .map((item) => PaymentMethodModel.fromJson(
                item as Map<String, dynamic>,
              ))
          .toList();
    }
    throw Exception(response.data['error'] ?? 'Failed to load payment methods');
  }

  Future<PaymentMethodModel> addPaymentMethod({
    required String cardholderName,
    required String cardNumber,
    required int expiryMonth,
    required int expiryYear,
    required String cvv,
    String? nickname,
    bool setAsDefault = false,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/payment-methods',
      data: {
        'cardholderName': cardholderName,
        'cardNumber': cardNumber,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'cvv': cvv,
        if (nickname != null && nickname.trim().isNotEmpty) 'nickname': nickname,
        'setAsDefault': setAsDefault,
      },
    );

    if (response.data['success'] == true) {
      return PaymentMethodModel.fromJson(
        response.data['paymentMethod'] as Map<String, dynamic>,
      );
    }
    throw Exception(response.data['error'] ?? 'Failed to save payment method');
  }

  Future<void> deletePaymentMethod(String paymentMethodId) async {
    final response = await _apiClient.delete('/api/v1/payment-methods/$paymentMethodId');
    if (response.data['success'] != true) {
      throw Exception(response.data['error'] ?? 'Failed to delete payment method');
    }
  }

  Future<void> setDefaultPaymentMethod(String paymentMethodId) async {
    final response = await _apiClient.post('/api/v1/payment-methods/$paymentMethodId/default');
    if (response.data['success'] != true) {
      throw Exception(response.data['error'] ?? 'Failed to update payment method');
    }
  }
}