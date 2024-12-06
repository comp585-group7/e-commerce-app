import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_details_page.dart';
import 'product_model.dart';
import 'shop_page.dart';
import 'app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'checkout.dart';

class CartPage extends StatefulWidget {
  final AppBar Function(BuildContext) appBarBuilder;

  const CartPage({Key? key, required this.appBarBuilder}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Product> cartItems = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user; // Make user nullable

  @override
  void initState() {
    super.initState();

    user = _auth.currentUser;

    if (user == null) {
      // Redirect to LoginPage
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    } else {
      _fetchCartItems();
    }
  }

  Future<void> _fetchCartItems() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: user!.uid)
          .get();

      List<Product> items = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Product(
          id: data['productId'] ?? 0,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          image: data['image'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          quantity: data['quantity'] ?? 1,
        );
      }).toList();

      setState(() {
        cartItems = items;
      });
    } catch (e) {
      print('Error fetching cart items: $e');
    }
  }

  Future<void> _removeFromCart(int productId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: user!.uid)
          .where('productId', isEqualTo: productId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        cartItems.removeWhere((item) => item.id == productId);
      });
    } catch (e) {
      print('Error removing item from cart: $e');
    }
  }

  double _calculateTotalPrice() {
    double total = 0;
    for (var item in cartItems) {
      total += item.price * item.quantity;
    }
    return total;
  }

  Future<void> _updateCartQuantity(int productId, int newQuantity) async {
    if (newQuantity < 1) {
      _removeFromCart(productId);
      return;
    }

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: user!.uid)
          .where('productId', isEqualTo: productId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'quantity': newQuantity});
      }

      setState(() {
        final index = cartItems.indexWhere((item) => item.id == productId);
        if (index != -1) {
          cartItems[index].quantity = newQuantity;
        }
      });
    } catch (e) {
      print('Error updating cart quantity: $e');
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCartItem({
    required Product item,
    required Function(int) onRemove,
    required Function(int, int) onUpdateQuantity,
    Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.image,
                width: 80.0,
                height: 80.0,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported, size: 80);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('Quantity: '),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        constraints: const BoxConstraints(maxHeight: 24),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          onUpdateQuantity(item.id, item.quantity - 1);
                        },
                      ),
                      Text('${item.quantity}'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        constraints: const BoxConstraints(maxHeight: 24),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          onUpdateQuantity(item.id, item.quantity + 1);
                        },
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Price: \$${item.price.toStringAsFixed(2)}',
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
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                onRemove(item.id);
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSectionHeader("Cart"),
                  const SizedBox(height: 20),
                  const Text(
                    "Your cart is empty.",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShopPage(
                            appBarBuilder: buildAppBar,
                          ),
                        ),
                      );
                    },
                    child: const Text('Browse Products'),
                  ),
                ],
              ),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsPage(
                                product: item,
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
                    // Navigate to CheckoutPage with total amount
                    double total = _calculateTotalPrice();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutPage(totalAmount: total),
                      ),
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
