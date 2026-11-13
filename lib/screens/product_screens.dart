import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/product_provider.dart';

final _money = NumberFormat.currency(
  locale: 'en_US',
  symbol: r'$ ',
  decimalDigits: 2,
);

class ListProductScreen extends StatefulWidget {
  const ListProductScreen({super.key});
  @override
  State<ListProductScreen> createState() => _ListProductScreenState();
}

class _ListProductScreenState extends State<ListProductScreen> {
  final _search = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProductProvider>();
      p.fetchProducts();
      p.fetchCategories();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProductProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Produk'),
        actions: [
          IconButton(
            tooltip: 'Tambah produk (mock)',
            onPressed: () => context.push('/add'),
            icon: const Icon(Icons.add_box_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onSubmitted: p.searchProducts,
              decoration: InputDecoration(
                hintText: 'Cari produk, contoh: phone',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () {
                    _search.clear();
                    p.fetchProducts();
                  },
                  icon: const Icon(Icons.close),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _filterChip(
                  'Semua',
                  p.selectedCategory.isEmpty,
                  () => p.fetchProducts(),
                ),
                _filterChip(
                  'Smartphones',
                  p.selectedCategory == 'smartphones',
                  () => p.filterByCategory('smartphones'),
                ),
                _filterChip(
                  'Beauty',
                  p.selectedCategory == 'beauty',
                  () => p.filterByCategory('beauty'),
                ),
                _filterChip(
                  'Laptops',
                  p.selectedCategory == 'laptops',
                  () => p.filterByCategory('laptops'),
                ),
                _filterChip(
                  'Kategori A-Z',
                  false,
                  () => p.sortProducts('title', 'asc'),
                ),
                _filterChip(
                  'Harga tertinggi',
                  false,
                  () => p.sortProducts('price', 'desc'),
                ),
                _filterChip(
                  'SELECT title, price',
                  false,
                  p.fetchSelectedFields,
                ),
                _filterChip('GET /products/1', false, p.fetchSingleProductList),
              ],
            ),
          ),
          if (p.error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(p.error!, style: const TextStyle(color: Colors.red)),
            ),
          if (p.loading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${p.products.length} produk ditampilkan • total API ${p.total}',
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => p.fetchProducts(limit: 30, skip: 0),
                  icon: const Icon(Icons.refresh, size: 17),
                  label: const Text('Muat ulang'),
                ),
              ],
            ),
          ),
          Expanded(
            child: p.loading && p.products.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : p.products.isEmpty
                ? const Center(child: Text('Tidak ada produk ditemukan.'))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: .62,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: p.products.length,
                    itemBuilder: (context, i) =>
                        ProductCard(product: p.products[i]),
                  ),
          ),
          if (p.selectedCategory.isEmpty && p.total > 30)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: p.skip > 0
                        ? () => p.fetchProducts(
                            limit: 30,
                            skip: (p.skip - 30).clamp(0, p.total).toInt(),
                          )
                        : null,
                    child: const Text('Sebelumnya'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '${p.skip + 1}–${(p.skip + p.limit).clamp(0, p.total)} dari ${p.total}',
                    ),
                  ),
                  FilledButton(
                    onPressed: p.skip + p.limit < p.total
                        ? () => p.fetchProducts(limit: 30, skip: p.skip + 30)
                        : null,
                    child: const Text('Berikutnya'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback action) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => action(),
        ),
      );
}

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => context.push('/detail/${product.id}'),
    borderRadius: BorderRadius.circular(16),
    child: Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFFF0F3F8),
              child: CachedNetworkImage(
                imageUrl: product.thumbnail,
                fit: BoxFit.contain,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.image_not_supported_outlined, size: 42),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _money.format(product.price),
                  style: const TextStyle(
                    color: Color(0xFF2457C5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 15, color: Colors.amber),
                    const SizedBox(width: 3),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        product.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class DetailProductScreen extends StatefulWidget {
  final int id;
  const DetailProductScreen({super.key, required this.id});
  @override
  State<DetailProductScreen> createState() => _DetailProductScreenState();
}

class _DetailProductScreenState extends State<DetailProductScreen> {
  Product? product;
  String? error;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await context.read<ProductProvider>().getProductForDetail(
        widget.id,
      );
      if (mounted)
        setState(() {
          product = p;
          loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          error = e.toString();
          loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Detail Produk')),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : product == null
        ? Center(child: Text(error ?? 'Produk tidak ditemukan'))
        : ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                height: 260,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: CachedNetworkImage(
                  imageUrl: product!.thumbnail,
                  fit: BoxFit.contain,
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.image_not_supported, size: 60),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                product!.title,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _money.format(product!.price),
                style: const TextStyle(
                  fontSize: 21,
                  color: Color(0xFF2457C5),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Brand: ${product!.brand.isEmpty ? '-' : product!.brand}  •  Kategori: ${product!.category}',
              ),
              Text(
                'Rating ${product!.rating}  •  Stok ${product!.stock}  •  Diskon ${product!.discountPercentage}%',
              ),
              const Divider(height: 28),
              const Text(
                'Deskripsi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              const SizedBox(height: 6),
              Text(product!.description),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () =>
                    context.push('/edit/${product!.id}', extra: product),
                icon: const Icon(Icons.edit),
                label: const Text('Edit produk'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Hapus produk?'),
                      content: const Text(
                        'DummyJSON hanya mengembalikan simulasi penghapusan; data server tidak dihapus permanen.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Batal'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Lanjutkan'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true && context.mounted) {
                    try {
                      await context.read<ProductProvider>().deleteProduct(
                        product!.id,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Respons DELETE diterima (simulasi).',
                            ),
                          ),
                        );
                        context.pop();
                      }
                    } catch (e) {
                      if (context.mounted)
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Gagal: $e')));
                    }
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hapus (mock)'),
              ),
              const SizedBox(height: 18),
              const Text(
                'Review produk',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              ...product!.reviews.map(
                (r) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.account_circle_outlined),
                  title: Text(r.reviewerName),
                  subtitle: Text(r.comment),
                  trailing: Text('★ ${r.rating}'),
                ),
              ),
            ],
          ),
  );
}

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});
  @override
  State<AddProductScreen> createState() =>
      _ProductFormState<AddProductScreen>();
}

class EditProductScreen extends StatefulWidget {
  final Product product;
  const EditProductScreen({super.key, required this.product});
  @override
  State<EditProductScreen> createState() =>
      _ProductFormState<EditProductScreen>();
}

class _ProductFormState<T extends StatefulWidget> extends State<T> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _price = TextEditingController();
  final _brand = TextEditingController();
  final _description = TextEditingController();
  final _stock = TextEditingController(text: '10');
  bool busy = false;
  bool get editing => widget is EditProductScreen;
  Product? get original =>
      editing ? (widget as EditProductScreen).product : null;
  @override
  void initState() {
    super.initState();
    final p = original;
    if (p != null) {
      _title.text = p.title;
      _price.text = p.price.toString();
      _brand.text = p.brand;
      _description.text = p.description;
      _stock.text = p.stock.toString();
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _brand.dispose();
    _description.dispose();
    _stock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(editing ? 'Edit Produk' : 'Tambah Produk')),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TextFormField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Nama produk',
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Harga',
              border: OutlineInputBorder(),
            ),
            validator: (v) => double.tryParse(v ?? '') == null
                ? 'Masukkan harga yang valid'
                : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _brand,
            decoration: const InputDecoration(
              labelText: 'Brand',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _stock,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Stok',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _description,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Deskripsi',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: busy ? null : _save,
            child: Text(
              busy
                  ? 'Menyimpan...'
                  : editing
                  ? 'Simpan perubahan (PUT)'
                  : 'Tambah produk (POST)',
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Catatan: endpoint POST/PUT DummyJSON bersifat simulasi. Perubahan tidak tersimpan permanen di server.',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    ),
  );
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => busy = true);
    final data = {
      'title': _title.text.trim(),
      'price': double.parse(_price.text),
      'brand': _brand.text.trim(),
      'description': _description.text.trim(),
      'stock': int.tryParse(_stock.text) ?? 0,
      'category': original?.category ?? 'beauty',
    };
    try {
      final api = context.read<ProductProvider>();
      final result = editing
          ? await api.updateProduct(original!.id, data)
          : await api.addProduct(data);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Respons API diterima'),
          content: Text(
            'ID: ${result.id}\nNama: ${result.title}\n\nIni respons simulasi DummyJSON; data tidak disimpan permanen.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
