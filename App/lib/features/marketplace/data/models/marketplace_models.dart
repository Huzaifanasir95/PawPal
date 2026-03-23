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
      icon: json['icon'] as String?,
      isActive: json['is_active'] as bool? ?? true,
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
      sellerId: json['seller_id'] as String,
      categoryId: json['category_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'PKR',
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      petType: json['pet_type'] as String?,
      images: imageList,
      isActive: json['is_active'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      totalSold: json['total_sold'] as int? ?? 0,
      sellerName: json['seller_name'] as String?,
      categoryName: json['category_name'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
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
      userId: json['user_id'] as String,
      productId: json['product_id'] as String,
      quantity: json['quantity'] as int? ?? 1,
      product: json['product'] != null
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

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.sellerName,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String? ?? '',
      productImage: json['product_image'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      sellerName: json['seller_name'] as String?,
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
    this.notes,
    required this.items,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    List<OrderItem> itemList = [];
    if (rawItems is List) {
      itemList = rawItems
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return Order(
      id: json['id'] as String,
      buyerId: json['buyer_id'] as String,
      status: json['status'] as String? ?? 'pending',
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String? ?? 'cash_on_delivery',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'PKR',
      shippingAddress: json['shipping_address'] as String? ?? '',
      notes: json['notes'] as String?,
      items: itemList,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending': return 'Pending';
      case 'confirmed': return 'Confirmed';
      case 'processing': return 'Processing';
      case 'shipped': return 'Shipped';
      case 'delivered': return 'Delivered';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }
}

class CreateProductRequest {
  final String name;
  final String description;
  final double price;
  final String currency;
  final int stockQuantity;
  final String? categoryId;
  final String? petType;
  final List<String> images;

  const CreateProductRequest({
    required this.name,
    required this.description,
    required this.price,
    this.currency = 'PKR',
    required this.stockQuantity,
    this.categoryId,
    this.petType,
    this.images = const [],
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'price': price,
        'currency': currency,
        'stock_quantity': stockQuantity,
        if (categoryId != null) 'category_id': categoryId,
        if (petType != null) 'pet_type': petType,
        'images': images,
      };
}

class PlaceOrderRequest {
  final List<Map<String, dynamic>> items;
  final String shippingAddress;
  final String paymentMethod;
  final String? notes;

  const PlaceOrderRequest({
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'items': items,
        'shipping_address': shippingAddress,
        'payment_method': paymentMethod,
        if (notes != null) 'notes': notes,
      };
}
