import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'screens/edit_product_screen.dart';
import 'models/product_model.dart';
import 'screens/add_product_screen.dart';
import 'providers/products_provider.dart';
import 'screens/product_detail_screen.dart';
import 'screens/products_screen.dart';
import 'services/api_service_products.dart';

const Color pastelBackground = Color(0xFFFFF9F2);
const Color pastelPurple = Color(0xFFE6DDF5);
const Color pastelAccent = Color(0xFF8067A8);
const Color pastelText = Color(0xFF403852);
const Color pastelMint = Color(0xFFD9EFE4);
const Color pastelPeach = Color(0xFFF8DCCF);

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ProductsProvider(ApiServiceProducts()),
      child: const ProductApp(),
    ),
  );
}

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const ProductsScreen()),
    GoRoute(
      path: '/product/:id',
      builder: (context, state) =>
          ProductDetailScreen(id: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/add',
      builder: (context, state) => const AddProductScreen(),
    ),
    GoRoute(
      path: '/edit/:id',
      builder: (context, state) {
        final product = state.extra as Product;

        return EditProductScreen(product: product);
      },
    ),
  ],
);

class ProductApp extends StatelessWidget {
  const ProductApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Little Finds',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: pastelBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: pastelAccent,
          primary: pastelAccent,
          secondary: pastelMint,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: pastelBackground,
          foregroundColor: pastelText,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFF0E8E2)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFF0E8E2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: pastelAccent, width: 1.5),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,
          selectedColor: pastelPurple,
          side: const BorderSide(color: Color(0xFFF0E8E2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          labelStyle: const TextStyle(color: pastelText),
        ),
      ),
      routerConfig: _router,
    );
  }
}
