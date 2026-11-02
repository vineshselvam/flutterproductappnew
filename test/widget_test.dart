import 'dart:convert';

import 'package:ecomproduct/main.dart';
import 'package:ecomproduct/models/product_model.dart';
import 'package:ecomproduct/providers/product_provider.dart';
import 'package:ecomproduct/repositories/product_repository.dart';
import 'package:ecomproduct/screens/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const sampleProduct = {
    'id': 1,
    'title': 'Nike Air Max 270 Running Shoes',
    'description': 'The Nike Air Max 270 delivers visible Air cushioning under every step.',
    'price': 299.99,
    'thumbnail': 'https://example.com/shoe.png',
    'images': ['https://example.com/shoe-large.png'],
  };

  ProductRepository repositoryWith(MockClient client) {
    return ProductRepository(client: client);
  }

  test('Product.fromJson parses the DummyJSON product fields', () {
    final product = Product.fromJson(sampleProduct);

    expect(product.id, 1);
    expect(product.title, 'Nike Air Max 270 Running Shoes');
    expect(product.price, 299.99);
    expect(product.formattedPrice, r'$299.99');
    expect(product.detailImageUrl, 'https://example.com/shoe-large.png');
  });

  test('repository returns products from a successful response', () async {
    final repository = repositoryWith(
      MockClient((request) async {
        expect(request.url.path, ProductRepository.productsUri.path);
        expect(request.url.queryParameters['limit'], '30');
        expect(
          request.url.queryParameters['select'],
          'id,title,description,price,thumbnail,images',
        );
        return http.Response(
          jsonEncode({
            'products': [sampleProduct],
          }),
          200,
        );
      }),
    );

    final products = await repository.fetchProducts();

    expect(products, hasLength(1));
    expect(products.single.title, 'Nike Air Max 270 Running Shoes');
  });

  test('repository throws when the API request fails', () async {
    final repository = repositoryWith(
      MockClient((request) async => http.Response('error', 500)),
    );

    expect(repository.fetchProducts(), throwsException);
  });

  test('provider publishes loading, success, and error states', () async {
    var shouldFail = true;
    final provider = ProductProvider(
      repository: repositoryWith(
        MockClient((request) async {
          if (shouldFail) {
            return http.Response('error', 500);
          }
          return http.Response(
            jsonEncode({
              'products': [sampleProduct],
            }),
            200,
          );
        }),
      ),
    );

    await provider.fetchProducts();
    expect(provider.status, ProductStatus.error);
    expect(provider.products, isEmpty);

    shouldFail = false;
    await provider.fetchProducts();
    expect(provider.status, ProductStatus.success);
    expect(provider.products.single.formattedPrice, r'$299.99');
  });

  testWidgets('lists products and opens the selected product details', (
    tester,
  ) async {
    final repository = repositoryWith(
      MockClient((request) async {
        return http.Response(
          jsonEncode({
            'products': [
              sampleProduct,
              {
                'id': 2,
                'title': 'Apple iPhone 14 128GB Purple Extra Long Name That Should Ellipsize',
                'description': 'A purple iPhone.',
                'price': 999,
                'thumbnail': 'https://example.com/phone.png',
                'images': ['https://example.com/phone.png'],
              },
            ],
          }),
          200,
        );
      }),
    );

    await tester.pumpWidget(MyApp(repository: repository));

    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Loading products...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump();
    await tester.pump();

    expect(find.text('Nike Air Max 270 Running Shoes'), findsOneWidget);
    expect(find.text(r'$299.99'), findsOneWidget);
    expect(find.text(r'$999.00'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);

    await tester.tap(find.text('Nike Air Max 270 Running Shoes'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Product Details'), findsOneWidget);
    expect(
      find.text(
        'The Nike Air Max 270 delivers visible Air cushioning under every step.',
      ),
      findsOneWidget,
    );
    expect(find.text('Description'), findsOneWidget);
    expect(find.text(r'$299.99'), findsNWidgets(2));

    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Products'), findsOneWidget);
    expect(
      find.text(
        'Apple iPhone 14 128GB Purple Extra Long Name That Should Ellipsize',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows an error and retries the request', (tester) async {
    var calls = 0;
    final repository = repositoryWith(
      MockClient((request) async {
        calls++;
        if (calls == 1) {
          return http.Response('error', 500);
        }
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return http.Response(
          jsonEncode({
            'products': [sampleProduct],
          }),
          200,
        );
      }),
    );

    await tester.pumpWidget(MyApp(repository: repository));
    await tester.pump();
    await tester.pump();

    expect(find.text('Failed to load products'), findsOneWidget);
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(find.text('Loading products...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();

    expect(find.text('Nike Air Max 270 Running Shoes'), findsOneWidget);
    expect(calls, 2);
  });

  testWidgets('details page swipes through every product image', (
    tester,
  ) async {
    final product = Product.fromJson({
      ...sampleProduct,
      'images': [
        'https://example.com/shoe-1.png',
        'https://example.com/shoe-2.png',
        'https://example.com/shoe-3.png',
      ],
    });

    await tester.pumpWidget(
      MaterialApp(home: ProductDetailsScreen(product: product)),
    );

    expect(product.galleryImages, hasLength(3));
    expect(find.byType(PageView), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.controller?.page, closeTo(1, 0.01));
  });
}
