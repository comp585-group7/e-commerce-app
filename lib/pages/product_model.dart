import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String description;
  final int id;
  final String image;
  final String name;
  final double price;
  int quantity; // Made mutable

  Product({
    required this.description,
    required this.id,
    required this.image,
    required this.name,
    required this.price,
    this.quantity = 1, // Default quantity to 1
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Product(
      description: data['description'] ?? '',
      id: data['id'] ?? 0,
      image: data['image'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      quantity: data['quantity'] ?? 1,
    );
  }

  // Method to convert Product to Map (useful for adding to cart)
  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'id': id,
      'image': image,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}

// Define the Category class
class Category {
  final String name;
  final String image;

  Category({
    required this.name,
    required this.image,
  });

  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Category(
      name: data['name'] ?? '',
      image: data['image'] ?? '',
    );
  }
}
