import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/products_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _thumbnailController = TextEditingController();
  final _stockController = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _thumbnailController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      await context.read<ProductsProvider>().addProduct({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text),
        'category': _categoryController.text.trim(),
        'thumbnail': _thumbnailController.text.trim(),
        'stock': int.parse(_stockController.text),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil ditambahkan')),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menambahkan produk: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label wajib diisi';
          }

          if (keyboardType == TextInputType.number &&
              double.tryParse(value) == null) {
            return 'Masukkan angka yang valid';
          }

          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field('Nama Produk', _titleController),
              _field('Deskripsi', _descriptionController, maxLines: 3),
              _field(
                'Harga',
                _priceController,
                keyboardType: TextInputType.number,
              ),
              _field('Kategori', _categoryController),
              _field('URL Gambar', _thumbnailController),
              _field(
                'Stok',
                _stockController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _saveProduct,
                  child: _saving
                      ? const CircularProgressIndicator()
                      : const Text('Simpan Produk'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
