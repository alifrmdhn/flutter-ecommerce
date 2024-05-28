import 'dart:convert';

class Product {
  final int id;
  final String name;
  final String description;
  final String processor;
  final String memory;
  final String storage;
  final int price;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.processor,
    required this.memory,
    required this.storage,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      processor: json['processor'] ?? '',
      memory: json['memory'] ?? '',
      storage: json['storage'] ?? '',
      price: json['price'] ?? 0,
    );
  }
}

// Parse daftar produk
List<Product> parseProducts(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Product>((json) => Product.fromJson(json)).toList();
}
