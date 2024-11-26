// ignore_for_file: use_build_context_synchronously
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:carousel_slider/carousel_slider.dart';

import 'cart_page.dart';
import 'shop_page.dart';
import 'app_bar.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productName;
  final String productDescription;
  final String productImage;
  final double productPrice;
  final int productId;
  final int? quantity;

  const ProductDetailsPage(
      {super.key,
      required this.productName,
      required this.productDescription,
      required this.productImage,
      required this.productPrice,
      required this.productId,
      this.quantity});

  @override
  // ignore: library_private_types_in_public_api
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  List<dynamic> cartItems = [];
  int quantity = 1; // Default quantity
  String optionMsg = "Add to Cart";

  // ignore: non_constant_identifier_names
  String mapping_string =
      'http://localhost:5000'; // the web mapping string is by default

  @override
  void initState() {
    super.initState();

    if (isAndroid()) {
      mapping_string = 'http://10.0.2.2:5000';
    }

    // Initializes the page and adds a way for us to check
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _fetchCartItems();

    // Now check if the product ID exists in the cart items
    final cartItem = cartItems.firstWhere(
      (item) => item['id'] == widget.productId.toString(),
      orElse: () => null, // If not found, return null
    );

    if (cartItem != null) {
      setState(() {
        quantity = cartItem['quantity'] ??
            1; // Set quantity to the cart item's quantity or default to 1
      });
      print(
          "Product with ID ${widget.productId} is already in the cart with quantity $quantity.");
      optionMsg = "Update Cart";
    } else {
      print("Product with ID ${widget.productId} is not in the cart.");
    }
  }

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
  } // end of _addToCart()

  // We can fetch the cart, check if the item is already on the cart and checks for its quantity
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
  } // end of _fetchCartItems()

  // Checks for the platform if its on Android
  bool isAndroid() {
    if (kIsWeb) {
      return false;
    } else {
      return Platform.isAndroid;
    }
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
          CarouselSlider(
            options: CarouselOptions(
              height: 250,
              autoPlay: true, // Enable auto-scrolling
              enlargeCenterPage: true,
              aspectRatio: 16 / 9,
              viewportFraction: 0.8,
            ),
            items: [
              widget.productImage,
              widget.productImage, // Use the same image for testing
            ].map((imageUrl) {
              return Builder(
                builder: (BuildContext context) {
                  return Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.error,
                        size: 100,
                      ); // Error icon if the image fails to load
                    },
                  );
                },
              );
            }).toList(),
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
            child: Text(
              optionMsg,
              style: const TextStyle(fontSize: 18.0, color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}
}