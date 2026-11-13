import 'package:flutter/foundation.dart';

import '../models/product_model.dart';
import '../services/api_service_products.dart';

class ProductProvider extends ChangeNotifier {
  final ApiServiceProducts _api = ApiServiceProducts();

  List<Product> _allProducts = [];
  List<Product> _products = [];
  List<String> _categoryList = [];
  List<Category> _categories = [];

  bool _loading = false;
  String? _error;
  int _total = 0;
  int _skip = 0;
  int _limit = 30;
  String _selectedCategory = '';

  List<Product> get products => _products;
  List<String> get categoryList => _categoryList;
  List<Category> get categories => _categories;
  bool get loading => _loading;
  String? get error => _error;
  int get total => _total;
  int get skip => _skip;
  int get limit => _limit;
  String get selectedCategory => _selectedCategory;

  Future<void> _run(Future<void> Function() task) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await task();
    } catch (e) {
      _error = 'Gagal memproses data: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _refreshPage() {
    _total = _allProducts.length;
    final start = _skip.clamp(0, _total);
    final end = (start + _limit).clamp(0, _total);
    _products = _allProducts.sublist(start, end);
  }

  Future<void> fetchProducts({int limit = 30, int skip = 0}) => _run(() async {
    final res = await _api.getAllProducts(limit: 1000, skip: 0);
    _allProducts = res.products;
    _selectedCategory = '';
    _limit = limit;
    _skip = skip;
    _refreshPage();
  });

  Future<void> fetchSingleProductList() => _run(() async {
    final product = await _api.getProduct(1);
    _allProducts = [product];
    _skip = 0;
    _limit = 30;
    _selectedCategory = '';
    _refreshPage();
  });

  Future<void> searchProducts(String query) => _run(() async {
    if (query.trim().isEmpty) {
      final res = await _api.getAllProducts(limit: 1000);
      _allProducts = res.products;
    } else {
      final res = await _api.searchProducts(query.trim());
      _allProducts = res.products;
    }

    _selectedCategory = '';
    _skip = 0;
    _refreshPage();
  });

  Future<void> fetchSelectedFields() => _run(() async {
    final res = await _api.getProductsPaginated(limit: 10, skip: 10);
    _allProducts = res.products;
    _selectedCategory = '';
    _skip = 0;
    _limit = 30;
    _refreshPage();
  });

  Future<void> sortProducts(String field, String order) => _run(() async {
    final res = await _api.sortProducts(field, order);
    _allProducts = res.products;
    _selectedCategory = '';
    _skip = 0;
    _limit = 30;
    _refreshPage();
  });

  Future<void> fetchCategories() async {
    try {
      _categories = await _api.getCategories();
      _categoryList = await _api.getCategoryList();
      notifyListeners();
    } catch (e) {
      _error = 'Gagal memuat kategori: $e';
      notifyListeners();
    }
  }

  Future<void> filterByCategory(String category) => _run(() async {
    final res = await _api.getProductsByCategory(category);
    _allProducts = res.products;
    _selectedCategory = category;
    _skip = 0;
    _limit = 30;
    _refreshPage();
  });

  Future<Product> getProductForDetail(int id) {
    return _api.getProduct(id);
  }

  Future<Product> addProduct(Map<String, dynamic> data) async {
    final product = await _api.addProduct(data);
    await fetchProducts();
    return product;
  }

  Future<Product> updateProduct(int id, Map<String, dynamic> data) async {
    final product = await _api.updateProduct(id, data);
    await fetchProducts();
    return product;
  }

  Future<Product> patchProduct(int id, Map<String, dynamic> data) async {
    final product = await _api.patchProduct(id, data);
    await fetchProducts();
    return product;
  }

  Future<void> deleteProduct(int id) async {
    await _api.deleteProduct(id);
    await fetchProducts();
  }
}
