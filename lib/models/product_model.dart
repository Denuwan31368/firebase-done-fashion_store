class Product {
  final String id;
  final String name;
  final String price;
  final String image; 
  final String code;
  final String category;
  final List<String> sizes;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.code,
    required this.category,
    required this.sizes,
  });

  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      price: data['price'] ?? '',
      image: data['image'] ?? '',
      code: data['code'] ?? '',
      category: data['category'] ?? '',
      sizes: List<String>.from(data['size'] ?? []),
    );
  }
}