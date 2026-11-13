import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/products_provider.dart';

const _purple = Color(0xFF8067A8);
const _dark = Color(0xFF403852);

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _category;
  late final TextEditingController _thumbnail;
  late final TextEditingController _stock;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final p = widget.product;

    _title = TextEditingController(text: p.title);
    _description = TextEditingController(text: p.description);
    _price = TextEditingController(text: p.price.toString());
    _category = TextEditingController(text: p.category);
    _thumbnail = TextEditingController(text: p.thumbnail);
    _stock = TextEditingController(text: p.stock.toString());
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _price.dispose();
    _category.dispose();
    _thumbnail.dispose();
    _stock.dispose();
    super.dispose();
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
        validator: validator,
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      await context.read<ProductsProvider>().updateProduct(widget.product.id, {
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'price': double.parse(_price.text),
        'category': _category.text.trim(),
        'thumbnail': _thumbnail.text.trim(),
        'stock': int.parse(_stock.text),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil diperbarui')),
      );

      context.go('/');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memperbarui produk: $e')));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Produk')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _field(
              'Nama Produk',
              _title,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Nama produk wajib diisi'
                  : null,
            ),
            _field('Deskripsi', _description, maxLines: 4),
            _field(
              'Harga',
              _price,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) =>
                  double.tryParse(v ?? '') == null ? 'Harga tidak valid' : null,
            ),
            _field(
              'Kategori',
              _category,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Kategori wajib diisi' : null,
            ),
            _field('URL Gambar', _thumbnail),
            _field(
              'Stok',
              _stock,
              keyboardType: TextInputType.number,
              validator: (v) => int.tryParse(v ?? '') == null
                  ? 'Stok harus berupa angka bulat'
                  : null,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
