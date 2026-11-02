class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.thumbnail,
    required this.images,
  });

  final int id;
  final String title;
  final String description;
  final double price;
  final String thumbnail;
  final List<String> images;

  /// Full-size photos for the details carousel, falling back to the thumbnail.
  List<String> get galleryImages {
    if (images.isNotEmpty) return images;
    if (thumbnail.isNotEmpty) return [thumbnail];
    return const [];
  }

  /// Full-size image for the details screen, falling back to the thumbnail.
  String get detailImageUrl =>
      galleryImages.isNotEmpty ? galleryImages.first : '';

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      thumbnail: json['thumbnail'] as String? ?? '',
      images: rawImages is List
          ? rawImages.map((image) => image.toString()).toList()
          : const [],
    );
  }
}
