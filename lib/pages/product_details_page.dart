// ignore_for_file: use_build_context_synchronously
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;

import 'cart_page.dart';
import 'shop_page.dart';
import 'app_bar.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productName;
  final String productDescription;
  final String productImage;
  final double productPrice;
  final int productId;

  const ProductDetailsPage({
    super.key,
    required this.productName,
    required this.productDescription,
    required this.productImage,
    required this.productPrice,
    required this.productId,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

// Method to show the dialog when "Add to Cart" is pressed
void _showAddToCartDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(message),
        content: const Text('Would you like to shop for more?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(appBarBuilder: buildAppBar),
                ),
              );
            },
            child: const Text('Go to Cart'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ShopPage(appBarBuilder: buildAppBar),
                ),
              );
            },
            child: const Text('Shop More'),
          ),
        ],
      );
    },
  );
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int quantity = 1; // Default quantity

  // ignore: non_constant_identifier_names
  String mapping_string = 'http://localhost:5000';  // the web mapping string is by default

  // Add items to the cart via the Flask API
  Future<void> _addToCart(BuildContext context, int quantity) async {
    final cartItem = {
      'id': widget.productId.toString(),
      'name': widget.productName,
      'price': widget.productPrice,
      'quantity': quantity,
      'image': widget.productImage,
      'desc': widget.productDescription
    };

    if(isAndroid()) {
      mapping_string = 'http://10.0.2.2:5000';
    }

    final response = await http.post(
      Uri.parse('$mapping_string/api/cart'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(cartItem),
    );

    if (response.statusCode == 201) {
      _showAddToCartDialog(context, "Added to cart: ${widget.productName}");
    } else {
      _showAddToCartDialog(context, "Failed to add item to cart");
    }
  }

  // Checks for the platform if its on Android
  bool isAndroid() {
    if (kIsWeb) {
      return false;
    } else {
      return Platform.isAndroid;
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Carousel Section
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: 3, // Display the same image multiple times for now, not working currently
                itemBuilder: (context, index) {
                  return Image.network(
                    widget.productImage,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error); // Show an error icon if image fails to load
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Product Info and Description Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.productName,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '\$${widget.productPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20.0,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.productDescription,
                      style: const TextStyle(fontSize: 16.0),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 40, thickness: 1.5),

            // Quantity Selector Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quantity:',
                  style: TextStyle(fontSize: 18.0),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() {
                            quantity--;
                          });
                        }
                      },
                    ),
                    Text(
                      quantity.toString(),
                      style: const TextStyle(fontSize: 18.0),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),

            const Spacer(),

            // Add to Cart Button
            ElevatedButton(
              onPressed: () => _addToCart(context, quantity),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text(
                'Add to Cart',
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
