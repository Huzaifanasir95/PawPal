class PaymentMethodModel {
  final String id;
  final String methodType;
  final String brand;
  final String cardholderName;
  final String last4;
  final int expiryMonth;
  final int expiryYear;
  final String? nickname;
  final bool isDefault;
  final String? maskedNumber;

  const PaymentMethodModel({
    required this.id,
    required this.methodType,
    required this.brand,
    required this.cardholderName,
    required this.last4,
    required this.expiryMonth,
    required this.expiryYear,
    required this.isDefault,
    this.nickname,
    this.maskedNumber,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String,
      methodType: json['methodType'] as String? ?? 'card',
      brand: json['brand'] as String? ?? 'Card',
      cardholderName: json['cardholderName'] as String? ?? '',
      last4: json['last4'] as String? ?? '0000',
      expiryMonth: json['expiryMonth'] as int? ?? 1,
      expiryYear: json['expiryYear'] as int? ?? 2026,
      nickname: json['nickname'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      maskedNumber: json['maskedNumber'] as String?,
    );
  }

  String get displayLabel =>
      nickname?.trim().isNotEmpty == true ? nickname! : brand;

  String get displayMask => maskedNumber ?? '**** **** **** $last4';
}