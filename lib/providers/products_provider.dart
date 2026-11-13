import 'package:flutter/foundation.dart';

import '../models/product_model.dart';
import '../services/api_service_products.dart';

class ProductsProvider extends ChangeNotifier {
  ProductsProvider(this._api);
  final ApiServiceProducts _api;
  List<Product> products = [];
  List<String> categories = [];
  int total = 0;
  int skip = 0;
  final int limit = 20;
  bool isLoading = false;
  String? error;
  String? selectedCategory;
  String? sortBy;
  String sortOrder = 'asc';

  Future<void> loadProducts({bool reset = true}) async {
    if (reset) skip = 0;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = selectedCategory == null
          ? await _api.getProducts(
              limit: limit,
              skip: skip,
              sortBy: sortBy,
              order: sortOrder,
            )
          : await _api.getProductsByCategory(
              selectedCategory!,
              limit: limit,
              skip: skip,
            );
      products = reset ? result.products : [...products, ...result.products];
      total = result.total;
      skip = result.skip + result.products.length;
    } catch (e) {
      error =
          'Gagal mengambil produk. Periksa koneksi internet lalu coba lagi.';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    try {
      final result = await _api.getCategories();
      categories = result.map((category) => category.slug).toList();
      notifyListeners();
    } catch (_) {
      error = 'Gagal mengambil kategori.';
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = query.trim().isEmpty
          ? await _api.getProducts(
              limit: limit,
              skip: 0,
              sortBy: sortBy,
              order: sortOrder,
            )
          : await _api.searchProducts(query.trim(), limit: limit);
      products = result.products;
      total = result.total;
      skip = result.products.length;
    } catch (_) {
      error = 'Pencarian gagal. Periksa koneksi internet.';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> selectCategory(String? category) async {
    selectedCategory = category;
    await loadProducts();
  }

  Future<void> setSort(String? field, {String order = 'asc'}) async {
    sortBy = field;
    sortOrder = order;
    await loadProducts();
  }

  Future<Product> addProduct(Map<String, dynamic> data) async {
    final product = await _api.addProduct(data);
    await loadProducts();
    return product;
  }

  Future<Product> getProduct(int id) {
    return _api.getProduct(id);
  }

  Future<Product> updateProduct(int id, Map<String, dynamic> data) async {
    final product = await _api.updateProduct(id, data);
    await loadProducts();
    return product;
  }

  Future<void> deleteProduct(int id) async {
    await _api.deleteProduct(id);
    await loadProducts();
  }
}
