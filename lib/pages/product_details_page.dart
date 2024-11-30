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
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  List<dynamic> cartItems = [];
  int quantity = 1; // Default quantity
  String optionMsg = "Add to Cart";
  PageController _pageController = PageController(); // Controller for image carousel
  int _currentPage = 0; // Track the currently active page

  String mapping_string = 'http://localhost:5000'; // the web mapping string is by default

  @override
  void initState() {
    super.initState();

    if (isAndroid()) {
      mapping_string = 'http://10.0.2.2:5000';
    }

    // Initializes the page and adds a way for us to check
    _initializePage();
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose of the controller to prevent memory leaks
    super.dispose();
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
        quantity = cartItem['quantity'] ?? 1;
      });
      optionMsg = "Update Cart";
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
  }

  Future<void> _fetchCartItems() async {
    try {
      final response = await http.get(Uri.parse('$mapping_string/api/cart'));
      if (response.statusCode == 200) {
        setState(() {
          cartItems = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  bool isAndroid() {
    if (kIsWeb) {
      return false;
    } else {
      return Platform.isAndroid;
    }
  }

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Image Carousel
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: 3, // Replace with the actual number of images
                      itemBuilder: (context, index) {
                        return Image.network(
                          widget.productImage, // Replace with list of images
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error, size: 100);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3, // Replace with the actual number of images
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: 8.0,
                        height: 8.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.productName,
                    style: const TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${widget.productPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22.0,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.productDescription,
                    style: const TextStyle(fontSize: 16.0, height: 1.5),
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _addToCart(context, quantity),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          optionMsg,
                          style: const TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
