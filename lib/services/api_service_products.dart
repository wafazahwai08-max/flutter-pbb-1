import 'package:dio/dio.dart';

import '../models/product_model.dart';

class ApiServiceProducts {
  ApiServiceProducts({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'http://192.168.11.147:8080/api',
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {'Content-Type': 'application/json'},
            ),
          );

  final Dio _dio;

  Future<List<Product>> _fetchAll() async {
    final response = await _dio.get('/products');
    final data = Map<String, dynamic>.from(response.data as Map);
    final list = data['products'] as List? ?? [];

    return list
        .whereType<Map>()
        .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<ProductsResponse> _paginate(
    List<Product> products, {
    int limit = 30,
    int skip = 0,
  }) async {
    final start = skip.clamp(0, products.length);
    final end = (start + limit).clamp(0, products.length);

    return ProductsResponse(
      products: products.sublist(start, end),
      total: products.length,
      skip: start,
      limit: limit,
    );
  }

  Future<ProductsResponse> getAllProducts({
    int limit = 30,
    int skip = 0,
  }) async {
    final products = await _fetchAll();
    return _paginate(products, limit: limit, skip: skip);
  }

  Future<ProductsResponse> getProducts({
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String order = 'asc',
  }) async {
    final products = await _fetchAll();

    if (sortBy != null && sortBy.isNotEmpty) {
      products.sort((a, b) {
        final result = sortBy == 'price'
            ? a.price.compareTo(b.price)
            : a.title.toLowerCase().compareTo(b.title.toLowerCase());

        return order == 'desc' ? -result : result;
      });
    }

    return _paginate(products, limit: limit, skip: skip);
  }

  Future<Product> getProduct(int id) async {
    final response = await _dio.get('/products/$id');
    final data = Map<String, dynamic>.from(response.data as Map);

    return Product.fromJson(Map<String, dynamic>.from(data['product'] ?? data));
  }

  Future<ProductsResponse> searchProducts(
    String query, {
    int limit = 20,
    int skip = 0,
  }) async {
    final products = await _fetchAll();
    final keyword = query.toLowerCase();

    final filtered = products.where((product) {
      return product.title.toLowerCase().contains(keyword) ||
          product.description.toLowerCase().contains(keyword) ||
          product.category.toLowerCase().contains(keyword);
    }).toList();

    return _paginate(filtered, limit: limit, skip: skip);
  }

  Future<List<Category>> getCategories() async {
    final products = await _fetchAll();

    final names = products
        .map((product) => product.category)
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();

    return names
        .map((name) => Category(slug: name, name: name, url: ''))
        .toList();
  }

  Future<List<String>> getCategoryList() async {
    final categories = await getCategories();
    return categories.map((category) => category.slug).toList();
  }

  Future<ProductsResponse> getProductsByCategory(
    String category, {
    int limit = 20,
    int skip = 0,
  }) async {
    final products = await _fetchAll();

    final filtered = products
        .where((product) => product.category == category)
        .toList();

    return _paginate(filtered, limit: limit, skip: skip);
  }

  Future<ProductsResponse> getProductsPaginated({
    int limit = 10,
    int skip = 0,
    String? select,
  }) async {
    final products = await _fetchAll();
    return _paginate(products, limit: limit, skip: skip);
  }

  Future<ProductsResponse> sortProducts(String field, String order) async {
    final products = await _fetchAll();

    products.sort((a, b) {
      final result = field == 'price'
          ? a.price.compareTo(b.price)
          : a.title.toLowerCase().compareTo(b.title.toLowerCase());

      return order == 'desc' ? -result : result;
    });

    return _paginate(products, limit: products.length, skip: 0);
  }

  Future<Product> addProduct(Map<String, dynamic> product) async {
    final response = await _dio.post('/products', data: product);
    final data = Map<String, dynamic>.from(response.data as Map);

    return Product.fromJson(Map<String, dynamic>.from(data['product'] as Map));
  }

  Future<Product> updateProduct(int id, Map<String, dynamic> product) async {
    final response = await _dio.put('/products/$id', data: product);
    final data = Map<String, dynamic>.from(response.data as Map);

    return Product.fromJson(Map<String, dynamic>.from(data['product'] as Map));
  }

  Future<Product> patchProduct(int id, Map<String, dynamic> product) async {
    final response = await _dio.patch('/products/$id', data: product);
    final data = Map<String, dynamic>.from(response.data as Map);

    return Product.fromJson(Map<String, dynamic>.from(data['product'] as Map));
  }

  Future<void> deleteProduct(int id) async {
    await _dio.delete('/products/$id');
  }
}
