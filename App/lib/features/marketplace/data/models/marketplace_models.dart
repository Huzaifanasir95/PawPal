class ProductCategory {
  final String id;
  final String name;
  final String description;
  final String? icon;
  final bool isActive;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.description,
    this.icon,
    required this.isActive,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      icon: (json['iconUrl'] ?? json['icon']) as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class Product {
  final String id;
  final String sellerId;
  final String? categoryId;
  final String name;
  final String description;
  final double price;
  final String currency;
  final int stockQuantity;
  final String? petType;
  final List<String> images;
  final bool isActive;
  final double rating;
  final int totalReviews;
  final int totalSold;
  final String? sellerName;
  final String? categoryName;
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.sellerId,
    this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.stockQuantity,
    this.petType,
    required this.images,
    required this.isActive,
    required this.rating,
    required this.totalReviews,
    required this.totalSold,
    this.sellerName,
    this.categoryName,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    List<String> imageList = [];
    if (rawImages is List) {
      imageList = rawImages.map((e) => e.toString()).toList();
    }

    return Product(
      id: json['id'] as String,
      sellerId: json['sellerId'] as String,
      categoryId: json['categoryId'] as String?,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'PKR',
      stockQuantity: json['stockQuantity'] as int? ?? 0,
      petType: json['petType'] as String?,
      images: imageList,
      isActive: json['isActive'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      totalSold: json['totalSold'] as int? ?? 0,
      sellerName: json['sellerName'] as String?,
      categoryName: json['categoryName'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  String get firstImage => images.isNotEmpty ? images.first : '';
}

class CartItem {
  final String id;
  final String userId;
  final String productId;
  int quantity;
  final Product? product;

  CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      userId: json['userId'] as String,
      productId: json['productId'] as String,
      quantity: json['quantity'] as int? ?? 1,
      product:
          json['product'] != null
              ? Product.fromJson(json['product'] as Map<String, dynamic>)
              : null,
    );
  }

  double get totalPrice => (product?.price ?? 0) * quantity;
}

class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? sellerName;
  final String sellerStatus;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.sellerName,
    this.sellerStatus = 'pending',
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String? ?? '',
      productImage: json['productImage'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      sellerName: json['sellerName'] as String?,
      sellerStatus: json['sellerStatus'] as String? ?? 'pending',
    );
  }
}

class Order {
  final String id;
  final String buyerId;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final double totalAmount;
  final String currency;
  final String shippingAddress;
  final String? shippingCity;
  final String? shippingPhone;
  final String? trackingNumber;
  final String? notes;
  final List<OrderItem> items;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.buyerId,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.totalAmount,
    required this.currency,
    required this.shippingAddress,
    this.shippingCity,
    this.shippingPhone,
    this.trackingNumber,
    this.notes,
    required this.items,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    List<OrderItem> itemList = [];
    if (rawItems is List) {
      itemList =
          rawItems
              .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList();
    }

    return Order(
      id: json['id'] as String,
      buyerId: json['buyerId'] as String,
      status: json['status'] as String? ?? 'pending',
      paymentStatus: json['paymentStatus'] as String? ?? 'pending',
      paymentMethod: json['paymentMethod'] as String? ?? 'cash_on_delivery',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'PKR',
      shippingAddress: json['shippingAddress'] as String? ?? '',
      shippingCity: json['shippingCity'] as String?,
      shippingPhone: json['shippingPhone'] as String?,
      trackingNumber: json['trackingNumber'] as String?,
      notes: json['notes'] as String?,
      items: itemList,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}

class CreateProductRequest {
  final String name;
  final String description;
  final double price;
  final String currency;
  final int stockQuantity;
  final String categoryId;
  final String? petType;
  final List<String> images;

  const CreateProductRequest({
    required this.name,
    required this.description,
    required this.price,
    this.currency = 'PKR',
    required this.stockQuantity,
    required this.categoryId,
    this.petType,
    this.images = const [],
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'price': price,
    'currency': currency,
    'stockQuantity': stockQuantity,
    'categoryId': categoryId,
    if (petType != null) 'petType': petType,
    'images': images,
  };
}

class UpdateProductRequest {
  final String? name;
  final String? description;
  final double? price;
  final String? currency;
  final int? stockQuantity;
  final String? categoryId;
  final String? petType;
  final List<String>? images;
  final bool? isActive;

  const UpdateProductRequest({
    this.name,
    this.description,
    this.price,
    this.currency,
    this.stockQuantity,
    this.categoryId,
    this.petType,
    this.images,
    this.isActive,
  });

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (description != null) 'description': description,
    if (price != null) 'price': price,
    if (currency != null) 'currency': currency,
    if (stockQuantity != null) 'stockQuantity': stockQuantity,
    if (categoryId != null) 'categoryId': categoryId,
    if (petType != null) 'petType': petType,
    if (images != null) 'images': images,
    if (isActive != null) 'isActive': isActive,
  };
}

class PlaceOrderRequest {
  final List<Map<String, dynamic>> items;
  final String shippingAddress;
  final String? shippingCity;
  final String? shippingPhone;
  final String paymentMethod;
  final String? notes;

  const PlaceOrderRequest({
    this.items = const [],
    required this.shippingAddress,
    this.shippingCity,
    this.shippingPhone,
    required this.paymentMethod,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    if (items.isNotEmpty) 'items': items,
    'shippingAddress': shippingAddress,
    if (shippingCity != null) 'shippingCity': shippingCity,
    if (shippingPhone != null) 'shippingPhone': shippingPhone,
    'paymentMethod': paymentMethod,
    if (notes != null) 'notes': notes,
  };
}

class UpdateOrderStatusRequest {
  final String status;
  final String? trackingNumber;

  const UpdateOrderStatusRequest({required this.status, this.trackingNumber});

  Map<String, dynamic> toJson() => {
    'status': status,
    if (trackingNumber?.isNotEmpty == true) 'trackingNumber': trackingNumber,
  };
}
