import 'package:flutter_stripe/flutter_stripe.dart';

import '../../../../core/services/api_client.dart';
import '../models/payment_method_model.dart';

class _StripeSetupIntentSession {
  final String setupIntentId;
  final String clientSecret;
  final String publishableKey;

  const _StripeSetupIntentSession({
    required this.setupIntentId,
    required this.clientSecret,
    required this.publishableKey,
  });

  factory _StripeSetupIntentSession.fromJson(Map<String, dynamic> json) {
    return _StripeSetupIntentSession(
      setupIntentId: json['setupIntentId'] as String,
      clientSecret: json['clientSecret'] as String,
      publishableKey: json['publishableKey'] as String,
    );
  }
}

class PaymentMethodsRepository {
  final ApiClient _apiClient = ApiClient.instance;
  String? _initializedPublishableKey;

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

  Future<_StripeSetupIntentSession> _createStripeSetupIntent() async {
    final response = await _apiClient.post('/api/v1/payment-methods/stripe/setup-intent');
    if (response.data['success'] == true) {
      return _StripeSetupIntentSession.fromJson(
        response.data as Map<String, dynamic>,
      );
    }
    throw Exception(response.data['error'] ?? 'Failed to start Stripe card setup');
  }

  Future<void> _initializeStripe(String publishableKey) async {
    if (_initializedPublishableKey == publishableKey) {
      return;
    }
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
    _initializedPublishableKey = publishableKey;
  }

  Future<PaymentMethodModel> addPaymentMethod({
    required String cardholderName,
    String? nickname,
    bool setAsDefault = false,
  }) async {
    final trimmedName = cardholderName.trim();
    if (trimmedName.isEmpty) {
      throw Exception('Cardholder name is required');
    }

    final setupIntentSession = await _createStripeSetupIntent();
    await _initializeStripe(setupIntentSession.publishableKey);

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        setupIntentClientSecret: setupIntentSession.clientSecret,
        merchantDisplayName: 'PawPal',
      ),
    );

    try {
      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (e) {
      throw Exception(e.toString().replaceFirst('StripeException: ', ''));
    }

    final response = await _apiClient.post(
      '/api/v1/payment-methods/stripe/confirm',
      data: {
        'setupIntentId': setupIntentSession.setupIntentId,
        'cardholderName': trimmedName,
        if (nickname != null && nickname.trim().isNotEmpty) 'nickname': nickname.trim(),
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