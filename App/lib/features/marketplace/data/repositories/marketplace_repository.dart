import 'package:dio/dio.dart';
import '../../../../core/services/api_client.dart';
import '../models/marketplace_models.dart';

class MarketplaceRepository {
  final ApiClient _apiClient;

  MarketplaceRepository(this._apiClient);

  static MarketplaceRepository get instance =>
      MarketplaceRepository(ApiClient.instance);

  // ─── Categories ────────────────────────────────────────────────

  Future<List<ProductCategory>> getCategories() async {
    try {
      final response = await _apiClient.get('/api/v1/marketplace/categories');
      if (response.data['success'] == true) {
        final list = response.data['categories'] as List<dynamic>;
        return list
            .map((e) => ProductCategory.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception(response.data['error'] ?? 'Failed to load categories');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ?? 'Network error: ${e.message}',
      );
    }
  }

  // ─── Products ──────────────────────────────────────────────────

  Future<List<Product>> getProducts({
    String? categoryId,
    String? petType,
    double? minPrice,
    double? maxPrice,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (categoryId != null) 'categoryId': categoryId,
        if (petType != null) 'petType': petType,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _apiClient.get(
        '/api/v1/marketplace/products',
        queryParameters: queryParams,
      );
      if (response.data['success'] == true) {
        final list = response.data['products'] as List<dynamic>;
        return list
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception(response.data['error'] ?? 'Failed to load products');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ?? 'Network error: ${e.message}',
      );
    }
  }

  Future<Product> getProductById(String productId) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/marketplace/products/$productId',
      );
      if (response.data['success'] == true) {
        return Product.fromJson(
          response.data['product'] as Map<String, dynamic>,
        );
      }
      throw Exception(response.data['error'] ?? 'Failed to load product');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ?? 'Network error: ${e.message}',
      );
    }
  }

  Future<Product> createProduct(CreateProductRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/marketplace/products',
        data: request.toJson(),
      );
      if (response.data['success'] == true) {
        return Product.fromJson(
          response.data['product'] as Map<String, dynamic>,
        );
      }
      throw Exception(response.data['error'] ?? 'Failed to create product');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ?? 'Network error: ${e.message}',
      );
    }
  }

  Future<List<Product>> getMyProducts({int page = 1, int limit = 50}) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/marketplace/products/mine',
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.data['success'] == true) {
        final list = response.data['products'] as List<dynamic>;
        return list
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception(response.data['error'] ?? 'Failed to load your products');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ?? 'Network error: ${e.message}',
      );
    }
  }

  Future<Product> updateProduct(
    String productId,
    UpdateProductRequest request,
  ) async {
    try {
      final response = await _apiClient.put(
        '/api/v1/marketplace/products/$productId',
        data: request.toJson(),
      );
      if (response.data['success'] == true) {
        return Product.fromJson(
          response.data['product'] as Map<String, dynamic>,
        );
      }
      throw Exception(response.data['error'] ?? 'Failed to update product');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ?? 'Network error: ${e.message}',
      );
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      final response = await _apiClient.delete(
        '/api/v1/marketplace/products/$productId',
      );
      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Failed to delete product');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ?? 'Network error: ${e.message}',
      );
    }
  }

  // ─── Cart ──────────────────────────────────────────────────────

  Future<List<CartItem>> getCart() async {
    try {
      final response = await _apiClient.get('/api/v1/marketplace/cart');
      if (response.data['success'] == true) {
        final list = response.data['items'] as List<dynamic>;
        return list
            .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception(response.data['error'] ?? 'Failed to load cart');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ?? 'Network error: ${e.message}',
      );
    }
  }

  Future<CartItem> addToCart(String productId, int quantity) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/marketplace/cart',
        data: {'productId': productId, 'quantity': quantity},
      );
      if (response.data['success'] == true) {
        final itemJson =
            response.data['cartItem'] ?? response.data['cart_item'];
        if (itemJson is Map<String, dynamic>) {
          return CartItem.fromJson(itemJson);
        }
        return CartItem.fromJson(
          response.data['cartItem'] as Map<String, dynamic>,
        );
      }
      throw Exception(response.data['error'] ?? 'Failed to add to cart');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ?? 'Network error: ${e.message}',
      );
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      final response = await _apiClient.delete(
        '/api/v1/marketplace/cart/$cartItemId',
      );
      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Failed to remove from cart');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ?? 'Network error: ${e.message}',
      );
    }
  }

  Future<void> updateCartItem(String cartItemId, int quantity) async {
    try {
      final response = await _apiClient.put(
        '/api/v1/marketplace/cart/$cartItemId',
        data: {'quantity': quantity},
      );
      if (response.data['success'] != true) {
        throw Exception(response.data['error'] ?? 'Failed to update cart');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ?? 'Network error: ${e.message}',
      );
    }
  }

  // ─── Orders ────────────────────────────────────────────────────

  Future<Order> placeOrder(PlaceOrderRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/marketplace/orders',
        data: request.toJson(),
      );
      if (response.data['success'] == true) {
        return Order.fromJson(response.data['order'] as Map<String, dynamic>);
      }
      throw Exception(response.data['error'] ?? 'Failed to place order');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ?? 'Network error: ${e.message}',
      );
    }
  }

  Future<List<Order>> getMyOrders({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/marketplace/orders',
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.data['success'] == true) {
        final list = response.data['orders'] as List<dynamic>;
        return list
            .map((e) => Order.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception(response.data['error'] ?? 'Failed to load orders');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ?? 'Network error: ${e.message}',
      );
    }
  }

  Future<Order> getOrderById(String orderId) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/marketplace/orders/$orderId',
      );
      if (response.data['success'] == true) {
        return Order.fromJson(response.data['order'] as Map<String, dynamic>);
      }
      throw Exception(response.data['error'] ?? 'Failed to load order');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ?? 'Network error: ${e.message}',
      );
    }
  }

  Future<List<Order>> getSellerOrders({int page = 1, int limit = 50}) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/marketplace/seller/orders',
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.data['success'] == true) {
        final list = response.data['orders'] as List<dynamic>;
        return list
            .map((e) => Order.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception(response.data['error'] ?? 'Failed to load seller orders');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ?? 'Network error: ${e.message}',
      );
    }
  }

  Future<void> updateOrderStatus(
    String orderId,
    UpdateOrderStatusRequest request,
  ) async {
    try {
      final response = await _apiClient.put(
        '/api/v1/marketplace/orders/$orderId/status',
        data: request.toJson(),
      );
      if (response.data['success'] != true) {
        throw Exception(
          response.data['error'] ?? 'Failed to update order status',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['error'] ?? 'Network error: ${e.message}',
      );
    }
  }
}
