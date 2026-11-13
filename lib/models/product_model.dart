class ProductsResponse {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  const ProductsResponse({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) =>
      ProductsResponse(
        products: (json['products'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(Product.fromJson)
            .toList(),
        total: (json['total'] as num?)?.toInt() ?? 0,
        skip: (json['skip'] as num?)?.toInt() ?? 0,
        limit: (json['limit'] as num?)?.toInt() ?? 0,
      );
}

class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final List<String> tags;
  final String brand;
  final String sku;
  final int weight;
  final Dimensions? dimensions;
  final String warrantyInformation;
  final String shippingInformation;
  final String availabilityStatus;
  final List<ProductReview> reviews;
  final String returnPolicy;
  final int minimumOrderQuantity;
  final ProductMeta? meta;
  final String thumbnail;
  final List<String> images;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.tags,
    required this.brand,
    required this.sku,
    required this.weight,
    required this.dimensions,
    required this.warrantyInformation,
    required this.shippingInformation,
    required this.availabilityStatus,
    required this.reviews,
    required this.returnPolicy,
    required this.minimumOrderQuantity,
    required this.meta,
    required this.thumbnail,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: (json['id'] as num?)?.toInt() ?? 0,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    category: json['category'] as String? ?? '',
    price: double.tryParse(json['price']?.toString() ?? '') ?? 0,
    discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0,
    rating: (json['rating'] as num?)?.toDouble() ?? 0,
    stock: (json['stock'] as num?)?.toInt() ?? 0,
    tags: (json['tags'] as List? ?? []).whereType<String>().toList(),
    brand: json['brand'] as String? ?? 'Tidak diketahui',
    sku: json['sku'] as String? ?? '',
    weight: (json['weight'] as num?)?.toInt() ?? 0,
    dimensions: json['dimensions'] is Map<String, dynamic>
        ? Dimensions.fromJson(json['dimensions'])
        : null,
    warrantyInformation: json['warrantyInformation'] as String? ?? '',
    shippingInformation: json['shippingInformation'] as String? ?? '',
    availabilityStatus: json['availabilityStatus'] as String? ?? '',
    reviews: (json['reviews'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(ProductReview.fromJson)
        .toList(),
    returnPolicy: json['returnPolicy'] as String? ?? '',
    minimumOrderQuantity: (json['minimumOrderQuantity'] as num?)?.toInt() ?? 1,
    meta: json['meta'] is Map<String, dynamic>
        ? ProductMeta.fromJson(json['meta'])
        : null,
    thumbnail: json['thumbnail'] as String? ?? '',
    images: (json['images'] as List? ?? []).whereType<String>().toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'price': price,
    'discountPercentage': discountPercentage,
    'rating': rating,
    'stock': stock,
    'tags': tags,
    'brand': brand,
    'sku': sku,
    'weight': weight,
    'dimensions': dimensions?.toJson(),
    'warrantyInformation': warrantyInformation,
    'shippingInformation': shippingInformation,
    'availabilityStatus': availabilityStatus,
    'reviews': reviews.map((e) => e.toJson()).toList(),
    'returnPolicy': returnPolicy,
    'minimumOrderQuantity': minimumOrderQuantity,
    'meta': meta?.toJson(),
    'thumbnail': thumbnail,
    'images': images,
  };
}

class Dimensions {
  final double width;
  final double height;
  final double depth;
  const Dimensions({
    required this.width,
    required this.height,
    required this.depth,
  });
  factory Dimensions.fromJson(Map<String, dynamic> json) => Dimensions(
    width: (json['width'] as num?)?.toDouble() ?? 0,
    height: (json['height'] as num?)?.toDouble() ?? 0,
    depth: (json['depth'] as num?)?.toDouble() ?? 0,
  );
  Map<String, dynamic> toJson() => {
    'width': width,
    'height': height,
    'depth': depth,
  };
}

class ProductReview {
  final int rating;
  final String comment;
  final String date;
  final String reviewerName;
  final String reviewerEmail;
  const ProductReview({
    required this.rating,
    required this.comment,
    required this.date,
    required this.reviewerName,
    required this.reviewerEmail,
  });
  factory ProductReview.fromJson(Map<String, dynamic> json) => ProductReview(
    rating: (json['rating'] as num?)?.toInt() ?? 0,
    comment: json['comment'] as String? ?? '',
    date: json['date'] as String? ?? '',
    reviewerName: json['reviewerName'] as String? ?? '',
    reviewerEmail: json['reviewerEmail'] as String? ?? '',
  );
  Map<String, dynamic> toJson() => {
    'rating': rating,
    'comment': comment,
    'date': date,
    'reviewerName': reviewerName,
    'reviewerEmail': reviewerEmail,
  };
}

class ProductMeta {
  final String createdAt;
  final String updatedAt;
  final String barcode;
  final String qrCode;
  const ProductMeta({
    required this.createdAt,
    required this.updatedAt,
    required this.barcode,
    required this.qrCode,
  });
  factory ProductMeta.fromJson(Map<String, dynamic> json) => ProductMeta(
    createdAt: json['createdAt'] as String? ?? '',
    updatedAt: json['updatedAt'] as String? ?? '',
    barcode: json['barcode'] as String? ?? '',
    qrCode: json['qrCode'] as String? ?? '',
  );
  Map<String, dynamic> toJson() => {
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'barcode': barcode,
    'qrCode': qrCode,
  };
}

class Category {
  final String slug;
  final String name;
  final String url;

  const Category({required this.slug, required this.name, required this.url});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}
