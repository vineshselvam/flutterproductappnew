import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ProductRepository {
  ProductRepository({http.Client? client}) : client = client ?? http.Client();

  final http.Client client;

  /// Only the fields the screens render. The full payload includes reviews
  /// and metadata that slow the download and JSON parse.
  static final Uri productsUri = Uri.parse(
    'https://dummyjson.com/products'
    '?limit=30&select=id,title,description,price,thumbnail,images',
  );

  Future<List<Product>> fetchProducts() async {
    final response = await client.get(productsUri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load products (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected response from the products API');
    }

    final rawProducts = decoded['products'];
    if (rawProducts is! List) {
      throw Exception('Unexpected response from the products API');
    }

    return rawProducts
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
  }
}
