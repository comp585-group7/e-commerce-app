import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
                  builder: (context) => CartPage(appBarBuilder: buildAppBar), // Navigate to Cart Page
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
                  builder: (context) => ShopPage(appBarBuilder: buildAppBar), // Navigate to Shop Page
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

  // Add items to the cart via the Flask API
  Future<void> _addToCart(BuildContext context, int quantity) async {
    final cartItem = {
      'id': widget.productId.toString(),
      'name': widget.productName,
      'price': widget.productPrice,
      'quantity': quantity, // Include quantity in the cart item
    };

    final response = await http.post(
      Uri.parse('http://localhost:5000/api/cart'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(cartItem),
    );

    if (response.statusCode == 201) {
      _showAddToCartDialog(context, "Added to cart: ${widget.productName}");
    } else {
      // Handle error
      _showAddToCartDialog(context, "Failed to add item to cart");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(widget.productImage, height: 200, fit: BoxFit.contain),
            const SizedBox(height: 20),
            Text(
              widget.productName,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '\$${widget.productPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20.0,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.productDescription,
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 20),
            // Quantity Selector
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
