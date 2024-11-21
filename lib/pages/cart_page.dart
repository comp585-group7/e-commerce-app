// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:json_editor_flutter/json_editor_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

// import pages
import 'home_page.dart';
import 'profile_page.dart';
import 'shop_page.dart';
import 'checkout.dart';
import 'cart_product_page.dart';

class CartPage extends StatefulWidget {
  final AppBar Function(BuildContext) appBarBuilder;

  const CartPage({super.key, required this.appBarBuilder});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> cartItems = [];
  // ignore: non_constant_identifier_names
  String mapping_string = 'http://localhost:5000';

  @override
  void initState() {
    super.initState();

    if(isAndroid()) {
      mapping_string = 'http://10.0.2.2:5000';
    }

    _fetchCartItems();
  }

  // Checks for the platform if its on Android
  bool isAndroid() {
    if (kIsWeb) {
      return false;
    } else {
      return Platform.isAndroid;
    }
  }

  Future<void> _fetchCartItems() async {
    try {
      final response = await http.get(Uri.parse('$mapping_string/api/cart'));
      if (response.statusCode == 200) {
        setState(() {
          cartItems = jsonDecode(response.body);
        });
      } else {
        print('Failed to load cart items');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _removeFromCart(String itemId) async {
    try {
      final response =
          await http.delete(Uri.parse('$mapping_string/api/cart/$itemId'));
      if (response.statusCode == 200) {
        setState(() {
          cartItems.removeWhere((item) => item['id'].toString() == itemId);
        });
      } else {
        print('Failed to remove item: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  double _calculateTotalPrice() {
    double total = 0;
    for (var item in cartItems) {
      total += item['price'] * item['quantity'];
    }
    return total;
  }

  Future<void> _updateCartQuantity(String id, int newQuantity) async {
    if (newQuantity < 1) {
      _removeFromCart(id);
      return;
    }

    final updatedItem = {
      'id': id,
      'quantity': newQuantity,
    };

    final response = await http.post(
      Uri.parse('$mapping_string/api/cart'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedItem),
    );

    if (response.statusCode == 201) {
      setState(() {
        final index = cartItems.indexWhere((item) => item['id'] == id);
        if (index != -1) {
          cartItems[index]['quantity'] = newQuantity;
        }
      });
    } else {
      print('Failed to update item in cart');
    }
  }

  // Helper method to build section headers with a centered, rounded square, black background, and white font
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 8.0, horizontal: 16.0), // Adds padding on the sides
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8.0), // Rounded square shape
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.white, // White font color
          ),
          textAlign: TextAlign.center, // Center the text within the container
        ),
      ),
    );
  }

  // Helper method to build a cart item widget
  Widget _buildCartItem({
    required Map<String, dynamic> item,
    required Function(String) onRemove,
    required Function(String, int) onUpdateQuantity,
    Function()? onTap, // Optional callback for item click
  }) {
    return GestureDetector(
      onTap: onTap, // Triggered when the item is tapped
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image of the cart item
            ClipRRect(
              borderRadius: BorderRadius.circular(8), // Rounded image corners
              child: Image.network(
                item['image'], // Uses 'image' URL from JSON
                width: 80.0,
                height: 80.0,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported, size: 80);
                },
              ),
            ),
            const SizedBox(width: 8), // Spacing between image and text

            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // Handle long names
                  ),
                  const SizedBox(height: 4),
                  // Quantity and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('Quantity: '),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        constraints: const BoxConstraints(maxHeight: 24),
                        padding: EdgeInsets.zero, // Compact buttons
                        onPressed: () {
                          onUpdateQuantity(item['id'], item['quantity'] - 1);
                        },
                      ),
                      Text('${item['quantity']}'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        constraints: const BoxConstraints(maxHeight: 24),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          onUpdateQuantity(item['id'], item['quantity'] + 1);
                        },
                      ),
                      const SizedBox(width: 8), // Spacing before price
                      Flexible(
                        child: Text(
                          'Price: \$${item['price'].toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 14.0),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Delete button
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                onRemove(item['id'].toString());
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBarBuilder(context),
      body: cartItems.isEmpty
          ? Column(
              children: [
                _buildSectionHeader("Cart"),
                const Center(child: Text("Your cart is empty.")),
              ],
            )
          : Column(
              children: [
                _buildSectionHeader("Cart"),
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(
                        item: item,
                        onRemove: _removeFromCart,
                        onUpdateQuantity: _updateCartQuantity,
                        onTap: () {
                          print('Tapped on item: ${item['name']}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CartProductPage(
                                productName: item['name'],
                                productDescription: item['desc'],
                                productImage: item['image'],
                                productPrice: item['price'],
                                productId: int.parse(item['id']),
                                productQuantity: item['quantity'],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total: \$${_calculateTotalPrice().toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CheckoutPage()),
                    );
                  },
                  child: const Text('Checkout'),
                ),
                const SizedBox(height: 15),
              ],
            ),
    );
  }
}
