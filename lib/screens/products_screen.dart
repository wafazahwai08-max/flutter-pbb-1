import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';

const _cream = Color(0xFFFFF9F2);
const _lavender = Color(0xFFE6DDF5);
const _purple = Color(0xFF8067A8);
const _dark = Color(0xFF403852);
const _mint = Color(0xFFD9EFE4);
const _peach = Color(0xFFF8DCCF);
const _border = Color(0xFFF0E8E2);
const _muted = Color(0xFF8B8194);

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProductsProvider>();
      p.loadProducts();
      p.loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _cream,
    appBar: AppBar(
      backgroundColor: _cream,
      foregroundColor: _dark,
      elevation: 0,
      titleSpacing: 20,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Little Finds',
            style: TextStyle(
              color: _dark,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
            ),
          ),
          Text(
            'Temukan favoritmu hari ini',
            style: TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: IconButton.filledTonal(
            tooltip: 'Tambah produk',
            onPressed: () => context.push('/add'),
            style: IconButton.styleFrom(
              backgroundColor: _lavender,
              foregroundColor: _purple,
            ),
            icon: const Icon(Icons.add_rounded),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton.filledTonal(
            tooltip: 'Muat ulang produk',
            onPressed: () => context.read<ProductsProvider>().loadProducts(),
            style: IconButton.styleFrom(
              backgroundColor: _lavender,
              foregroundColor: _purple,
            ),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ),
      ],
    ),
    body: Consumer<ProductsProvider>(
      builder: (context, p, _) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: p.search,
              decoration: InputDecoration(
                hintText: 'Cari produk favoritmu...',
                hintStyle: const TextStyle(color: _muted, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, color: _purple),
                suffixIcon: IconButton(
                  tooltip: 'Hapus pencarian',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _searchController.clear();
                    p.search('');
                    FocusScope.of(context).unfocus();
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: _border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: _purple, width: 1.5),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: p.selectedCategory,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      labelStyle: const TextStyle(color: _muted, fontSize: 13),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: _border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: _border),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Semua'),
                      ),
                      ...p.categories.map(
                        (c) => DropdownMenuItem<String?>(
                          value: c,
                          child: Text(c, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                    onChanged: p.selectCategory,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: p.sortBy,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Urutkan',
                      labelStyle: const TextStyle(color: _muted, fontSize: 13),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: _border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: _border),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Default'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'title',
                        child: Text('Nama'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'price',
                        child: Text('Harga'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'rating',
                        child: Text('Rating'),
                      ),
                    ],
                    onChanged: p.setSort,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _purple,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Jelajahi Produk',
                    style: TextStyle(
                      color: _dark,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${p.products.length} produk',
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ),

          if (p.error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _peach,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(p.error!, style: const TextStyle(color: _dark)),
              ),
            ),

          if (p.isLoading && p.products.isEmpty)
            const Expanded(
              child: Center(child: CircularProgressIndicator(color: _purple)),
            )
          else
            Expanded(
              child: p.products.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 54,
                            color: _purple,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Produk tidak ditemukan',
                            style: TextStyle(
                              color: _dark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Coba kata kunci lainnya',
                            style: TextStyle(color: _muted, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                      itemCount: p.products.length + (p.skip < p.total ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == p.products.length) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: p.isLoading
                                  ? const CircularProgressIndicator(
                                      color: _purple,
                                    )
                                  : OutlinedButton.icon(
                                      onPressed: () =>
                                          p.loadProducts(reset: false),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: _purple,
                                        side: const BorderSide(color: _purple),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 22,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.expand_more_rounded,
                                      ),
                                      label: const Text('Muat lebih banyak'),
                                    ),
                            ),
                          );
                        }

                        final item = p.products[index];
                        final imageBackground = index % 3 == 0
                            ? _lavender
                            : index % 3 == 1
                            ? _mint
                            : _peach;

                        return Card(
                          color: Colors.white,
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 12),
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                            side: const BorderSide(color: _border),
                          ),
                          child: InkWell(
                            onTap: () => context.push('/product/${item.id}'),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 104,
                                    height: 112,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: imageBackground,
                                      borderRadius: BorderRadius.circular(17),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: item.thumbnail,
                                      fit: BoxFit.contain,
                                      placeholder: (_, __) => const Center(
                                        child: SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: _purple,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (_, __, ___) => const Icon(
                                        Icons.image_not_supported_outlined,
                                        color: _purple,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 13),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _lavender,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            item.category.toUpperCase(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: _purple,
                                              fontSize: 9,
                                              letterSpacing: 0.4,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 7),
                                        Text(
                                          item.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: _dark,
                                            fontSize: 14,
                                            height: 1.25,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 7),
                                        Text(
                                          'Rp ${item.price.toStringAsFixed(2)}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: _purple,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.star_rounded,
                                              size: 16,
                                              color: Color(0xFFD69A42),
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              item.rating.toString(),
                                              style: const TextStyle(
                                                color: _muted,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const Spacer(),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              color: _purple,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    ),
  );
}
