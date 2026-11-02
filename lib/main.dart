import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/product_provider.dart';
import 'repositories/product_repository.dart';
import 'screens/product_list_screen.dart';

const Color productBlue = Color(0xFF1E88E5);

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.repository});

  /// Optional repository so tests can supply a fake HTTP client.
  final ProductRepository? repository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final productProvider = ProductProvider(
          repository: repository ?? ProductRepository(),
        );
        productProvider.fetchProducts();
        return productProvider;
      },
      child: MaterialApp(
        title: 'Products',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF4F6F8),
          colorScheme: ColorScheme.fromSeed(
            seedColor: productBlue,
            primary: productBlue,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: productBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            centerTitle: false,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
        home: const ProductListScreen(),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}
