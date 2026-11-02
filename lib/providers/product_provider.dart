import 'package:flutter/foundation.dart';

import '../models/product_model.dart';
import '../repositories/product_repository.dart';

enum ProductStatus { loading, success, error }

class ProductProvider extends ChangeNotifier {
  ProductProvider({required this.repository});

  final ProductRepository repository;

  ProductStatus _status = ProductStatus.loading;
  List<Product> _products = [];
  String? _errorMessage;
  Future<void>? _inFlight;

  ProductStatus get status => _status;
  List<Product> get products => List.unmodifiable(_products);
  String? get errorMessage => _errorMessage;

  /// Loads products and shows the full-screen loading state.
  /// A request already in progress is reused so the list is not fetched twice.
  Future<void> fetchProducts() {
    final inFlight = _inFlight;
    if (inFlight != null) return inFlight;

    _errorMessage = null;
    if (_status != ProductStatus.loading) {
      _status = ProductStatus.loading;
      notifyListeners();
    }
    return _startLoad();
  }

  /// Reloads products without replacing the current screen with a spinner.
  /// Used by pull-to-refresh so the refresh indicator stays visible.
  Future<void> refreshProducts() {
    final inFlight = _inFlight;
    if (inFlight != null) return inFlight;
    return _startLoad();
  }

  Future<void> _startLoad() {
    final future = _loadProducts();
    _inFlight = future;
    return future;
  }

  Future<void> _loadProducts() async {
    try {
      final products = await repository.fetchProducts();
      _products = products;
      _status = ProductStatus.success;
      _errorMessage = null;
    } catch (error) {
      _status = ProductStatus.error;
      _errorMessage = error.toString();
    } finally {
      _inFlight = null;
    }
    notifyListeners();
  }
}
