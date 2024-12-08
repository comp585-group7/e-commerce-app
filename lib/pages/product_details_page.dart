import 'package:flutter/material.dart';
import 'product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_page.dart';
import 'app_bar.dart';
import 'shop_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int quantity = 1;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user; // Make user nullable

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser; // Assign current user
  }

  Future<void> _addToCart(BuildContext context) async {
    if (user == null) {
      // User is not logged in, redirect to LoginPage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    try {
      final cartCollection = FirebaseFirestore.instance.collection('cart');

      // Check if the product is already in the user's cart
      final querySnapshot = await cartCollection
          .where('userId', isEqualTo: user!.uid)
          .where('productId', isEqualTo: widget.product.id)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Product already exists in the cart, update its quantity
        final docRef = querySnapshot.docs.first.reference;
        final currentData = querySnapshot.docs.first.data();
        final currentQuantity = currentData['quantity'] ?? 1;
        final newQuantity = currentQuantity + quantity;

        await docRef.update({'quantity': newQuantity});
        _showAddToCartDialog(context, 'Quantity updated in cart');
      } else {
        // Product not in cart, add a new entry
        await cartCollection.add({
          'userId': user!.uid,
          'productId': widget.product.id,
          'name': widget.product.name,
          'price': widget.product.price,
          'image': widget.product.image,
          'quantity': quantity,
          'description': widget.product.description,
        });

        _showAddToCartDialog(context, 'Item added to cart');
      }
    } catch (e) {
      print('Error adding to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add item to cart')),
      );
    }
  }

  void _showAddToCartDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            message,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          content: const Text(
            'Would you like to shop more or go to your cart?',
            style: TextStyle(fontSize: 16),
          ),
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
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
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
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              child: const Text('Shop More'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final priceText = '\$${product.price.toStringAsFixed(2)}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Product Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    product.image,
                    height: 300,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error,
                          size: 50, color: Colors.red);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Product Info Card
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        product.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        priceText,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Quantity Selector
              Text(
                'Quantity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _QuantityButton(
                    icon: Icons.remove,
                    onPressed: () {
                      if (quantity > 1) {
                        setState(() => quantity--);
                      }
                    },
                  ),
                  const SizedBox(width: 15),
                  Text(
                    quantity.toString(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(width: 15),
                  _QuantityButton(
                    icon: Icons.add,
                    onPressed: () {
                      setState(() => quantity++);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Add to Cart Button
              ElevatedButton(
                onPressed: () => _addToCart(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                ),
                child: Text(
                  'Add to Cart',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small widget for quantity buttons (plus and minus)
class _QuantityButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _QuantityButton({Key? key, required this.icon, required this.onPressed})
      : super(key: key);

  @override
  State<_QuantityButton> createState() => _QuantityButtonState();
}

class _QuantityButtonState extends State<_QuantityButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final scale = _hovering ? 1.1 : 1.0;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: CircleAvatar(
            backgroundColor: Colors.black,
            radius: 16,
            child: Icon(
              widget.icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
