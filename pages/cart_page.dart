
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


///   This section is for the Cart Page,
///   this is where the user would be able to see all the items they are going to buy.
///
///   DESIGN PLANS: Add a way to show many items are in the customer's cart
///
///
class CartPage extends StatefulWidget {
  final AppBar Function(BuildContext) appBarBuilder;

  const CartPage({super.key, required this.appBarBuilder});

  @override
  _CartPageState createState() => _CartPageState();
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
      final response = await http.get(Uri.parse('http://localhost:5000/api/cart'));
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
      final response = await http.delete(Uri.parse('http://localhost:5000/api/cart/$itemId'));
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
      total += item['price'] * item['quantity']; // Assuming 'quantity' is now in the cart item structure
    }
    return total;
  }

  Future<void> _updateCartQuantity(String id, int newQuantity) async {
    // Only proceed if new quantity is valid
    if (newQuantity < 1) {
      // Optionally, handle removing the item if quantity goes to zero
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
      // Successfully updated cart
      setState(() {
        // Update the local cartItems list to reflect changes
        final index = cartItems.indexWhere((item) => item['id'] == id);
        if (index != -1) {
          cartItems[index]['quantity'] = newQuantity;
        }
      });
    } else {
      // Handle error
      // You could show a message to the user about the error
      print('Failed to update item in cart');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBarBuilder(context),
      body: cartItems.isEmpty
          ? const Center(child: Text("Your cart is empty."))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        title: Text(item['name']),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Quantity: ${item['quantity']}'),
                            Text('Price: \$${item['price'].toStringAsFixed(2)}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                _updateCartQuantity(item['id'], item['quantity'] - 1);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                _updateCartQuantity(item['id'], item['quantity'] + 1);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _removeFromCart(item['id'].toString());
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total: \$${_calculateTotalPrice().toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to checkout page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CheckoutPage()), // Replace with your CheckoutPage
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



/// End of Cart page