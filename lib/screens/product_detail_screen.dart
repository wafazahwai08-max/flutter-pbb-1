import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/products_provider.dart';

const _purple = Color(0xFF8067A8);
const _dark = Color(0xFF403852);

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.id});

  final int id;

  Future<void> _deleteProduct(BuildContext context, Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: Text(
          'Produk "${product.title}" akan dihapus permanen dari database.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    try {
      await context.read<ProductsProvider>().deleteProduct(product.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil dihapus dari database')),
      );

      context.go('/');
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menghapus produk: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: FutureBuilder<Product>(
        future: context.read<ProductsProvider>().getProduct(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Detail produk gagal dimuat.'));
          }

          final product = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                height: 250,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: product.thumbnail.isEmpty
                    ? const Icon(Icons.image_not_supported_outlined, size: 60)
                    : CachedNetworkImage(
                        imageUrl: product.thumbnail,
                        fit: BoxFit.contain,
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.image_not_supported_outlined,
                          size: 60,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              Text(
                product.title,
                style: const TextStyle(
                  color: _dark,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rp ${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: _purple,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text('Kategori: ${product.category}'),
              Text('Stok: ${product.stock}'),
              const Divider(height: 30),
              const Text(
                'Deskripsi Produk',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: _dark,
                ),
              ),
              const SizedBox(height: 8),
              Text(product.description),
              const SizedBox(height: 25),
              FilledButton.icon(
                onPressed: () {
                  context.push('/edit/${product.id}', extra: product);
                },
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Edit Produk'),
                style: FilledButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _deleteProduct(context, product),
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Hapus Produk'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
