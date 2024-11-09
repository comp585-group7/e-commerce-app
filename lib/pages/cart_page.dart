// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:json_editor_flutter/json_editor_flutter.dart';
import 'package:http/http.dart' as http;

// import pages
import 'home_page.dart';
import 'profile_page.dart';
import 'shop_page.dart';
import 'checkout.dart';

class CartPage extends StatefulWidget {
  final AppBar Function(BuildContext) appBarBuilder;

  const CartPage({super.key, required this.appBarBuilder});

  @override
  _CartPageState createState() => _CartPageState();
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

class _CartPageState extends State<CartPage> {
  List<dynamic> cartItems = [];

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:5000/api/cart'));
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
      final response = await http
          .delete(Uri.parse('http://localhost:5000/api/cart/$itemId'));
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
      Uri.parse('http://localhost:5000/api/cart'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBarBuilder(context),
      body: cartItems.isEmpty
          ? Column(
              children: [
                _buildSectionHeader("Cart"),
                const Center(child: Text("Your cart is empty."))
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
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Row(
                            children: [
                              Image.network(
                                item['image'], // Uses 'image' URL from JSON
                                width: 90.0, // Constant width
                                height: 90.0, // Constant height
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 8), // Spacing between image and text
                              Expanded(
                                child: Text(
                                  item['name'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _removeFromCart(item['id'].toString());
                                },
                              ),
                            ],
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text('Quantity: '),
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  _updateCartQuantity(
                                      item['id'], item['quantity'] - 1);
                                },
                              ),
                              Text('${item['quantity']}'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  _updateCartQuantity(
                                      item['id'], item['quantity'] + 1);
                                },
                              ),
                              const SizedBox(width: 16), // Spacing before price
                              Text(
                                  'Price: \$${item['price'].toStringAsFixed(2)}'),
                            ],
                          ),
                        ),
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
