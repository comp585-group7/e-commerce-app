// the usual package
import 'package:flutter/material.dart';

// this package are for more decorations
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// for reading json files, remember to update pubsec.yaml file
import 'dart:convert';

void main() {
  runApp(StyleHiveApp());
}

// Declaring global variables
const double titleSpace = 4.0;

class StyleHiveApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StyleHive',
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: HomePage(),
    );
  }
}
/// END  of StyleHiveApp, Root of App

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  // Scroll functions
  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 300,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 300,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // Method to build the top AppBar for reuse
  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      automaticallyImplyLeading: false, // No back button at all
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ShopPage(appBarBuilder: buildAppBar)),
              );
            },
            child: const Text(
              'Shop',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
            },
            child: const Text(
              'StyleHive',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ProfilePage(appBarBuilder: buildAppBar)),
                  );
                },
                child: const Text(
                  'Profile',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SearchPage(appBarBuilder: buildAppBar)),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CartPage(appBarBuilder: buildAppBar)),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Main Landing Page structure
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double cardHeight = screenHeight * 0.4;
    double cardWidth = screenWidth > 650 ? screenWidth * 0.3 : screenWidth * 0.5;

    // Adjust padding based on screen size
    double productPadding = screenWidth > 600 ? 20.0 : 50.0;

    return Scaffold(
      appBar: buildAppBar(context), // Use the reusable AppBar method
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(    // Banner where we can show the products we have
            height: 250.0,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/nature.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20), // divides banner from Product scroll
          // Product scroll
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),  
            child: Text(
              'Shop Latest Apparel',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Stack(
              children: [
                Row(
                  children: [
                    SizedBox(width: productPadding),
                    Expanded(
                      child: SizedBox(
                        height: cardHeight,
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailsPage(
                                      productName: 'Product ${index + 1}',
                                      productDescription:
                                          'Description of Product ${index + 1}',
                                      productImage:
                                          'assets/images/product_${index % 4 + 1}.png',
                                      // placeholder price
                                      productPrice: (index + 1) * 20.0,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 5.0 : 8.0), // Adjust horizontal padding
                                child: SizedBox(
                                  width: cardWidth,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8.0),
                                          child: Image.asset(
                                            'assets/images/product_${index % 4 + 1}.png',
                                            fit: BoxFit.contain,
                                            width: double.infinity,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Product ${index + 1}',
                                              style: const TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 5),  // dividing the product title from price
                                            Text(
                                              '\$${(index + 1) * 20}',
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: productPadding), // Adjust spacing
                  ],
                ),
                if (screenWidth > 600) // Conditionally show buttons on large screens
                  Positioned(
                    left: 0,
                    top: cardHeight / 2 - 25,
                    child: FloatingActionButton(
                      backgroundColor: Colors.black,
                      mini: true,
                      onPressed: _scrollLeft,
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                if (screenWidth > 600)
                  Positioned(
                    right: 0,
                    top: cardHeight / 2 - 25,
                    child: FloatingActionButton(
                      backgroundColor: Colors.black,
                      mini: true,
                      onPressed: _scrollRight,
                      child: const Icon(Icons.arrow_forward, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // About Us and Contact Us section
          Container(
            color: Colors.grey[900],
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'About Us',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'StyleHive is your go-to destination for the latest trends in fashion. We are dedicated to bringing you the most stylish, sustainable, and affordable apparel.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Contact Us',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.facebook,
                          color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.twitter,
                          color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.instagram,
                          color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// End of Main Landing Page class

///
/// Global Method to build the top AppBar for reuse
///   - this is the top bar seen on most
AppBar buildAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.black,
    automaticallyImplyLeading: false, // No back button at all
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              // Goes to the shop page
              MaterialPageRoute(
                  builder: (context) => ShopPage(appBarBuilder: buildAppBar)),
            );
          },
          child: const Text(
            'Shop',
            style: TextStyle(color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
                context,
                // Just goes back to the landing page
                MaterialPageRoute(builder: (context) => HomePage()));
          },
          child: const Text(
            'StyleHive',
            style: TextStyle(color: Colors.white),
          ),
        ),
        Row(
          children: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  // Goes to the Profile page
                  MaterialPageRoute(
                      builder: (context) =>
                          ProfilePage(appBarBuilder: buildAppBar)),
                );
              },
              child: const Text(
                'Profile',
                style: TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  // goes to the Search page
                  MaterialPageRoute(
                      builder: (context) =>
                          SearchPage(appBarBuilder: buildAppBar)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CartPage(appBarBuilder: buildAppBar)),
                );
              },
            ),
          ],
        ),
      ],
    ),
  );
}

/// Shop Page
///
/// This page would show all the items being sold
class ShopPage extends StatelessWidget {
  final AppBar Function(BuildContext) appBarBuilder;

  ShopPage({required this.appBarBuilder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarBuilder(context), // Use the same AppBar
      body: const Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Shop Page"),
          SizedBox(height: 4.0),
        ],
      )),
    );
  }
}

// Profile Page
class ProfilePage extends StatelessWidget {
  final AppBar Function(BuildContext) appBarBuilder;

  ProfilePage({required this.appBarBuilder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarBuilder(context),
      body: const Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Placeholder text title
          Text("User Profile Page"),
          SizedBox(height: titleSpace),
        ],
      )),
    );
  }
}

// Search Page
class SearchPage extends StatelessWidget {
  final AppBar Function(BuildContext) appBarBuilder;

  SearchPage({required this.appBarBuilder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarBuilder(context),
      body: const Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Search Page"),
        ],
      )),
    );
  }
}

///   This section is for the Cart Page,
///   this is where the user would be able to see all the items they are going to buy.
///
///   DESIGN PLANS: Add a way to show many items are in the customer's cart
class CartPage extends StatelessWidget {
  final AppBar Function(BuildContext) appBarBuilder;

  CartPage({super.key, required this.appBarBuilder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarBuilder(context),
      body: const Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Child Placeholder Title
          Text("Cart Page"),
        ], // end of row's children
      )),
    );
  }
}

/// End of Cart page

///   This section below is for Product Details, this is showed when
///   the user clicks the product on the
///
///   Current design, Image of item(right) Description with price(left)
///   DESIGN PLANS: We need to make the graphics look better, it looks like a skeleton
///
class ProductDetailsPage extends StatelessWidget {
  final String productName;
  final String productDescription;
  final String productImage;
  final double productPrice;

  ProductDetailsPage({
    required this.productName,
    required this.productDescription,
    required this.productImage,
    required this.productPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white, // Make back arrow white
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // If the width is less than 600, use a vertical layout (image on top of description)
            bool isSmallScreen = constraints.maxWidth < 750;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isSmallScreen
                    ? Column(
                        children: [
                          Image.asset(productImage, fit: BoxFit.contain),
                          const SizedBox(height: 20),
                          _buildProductDetails(context),
                        ],
                      )
                    : Flexible(
                        child: Row(
                          children: [
                            // Product Image
                            Expanded(
                              child: Image.asset(productImage,
                                  fit: BoxFit.contain),
                            ),
                            const SizedBox(width: 20),
                            // Product Description and Add to Cart Button
                            Expanded(
                              child: _buildProductDetails(context),
                            ),
                          ],
                        ),
                      )
              ],
            );
          },
        ),
      ),
    );
  }

  // Widget to build product details and buy button
  Widget _buildProductDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          productName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          productDescription,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        Text(
          '\$${productPrice.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 20,
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            _showAddToCartDialog(context);
          },
          child: const Text('Add to Cart'),
        ),
      ],
    );
  }

  // Method to show the dialog when "Add to Cart" is pressed
  void _showAddToCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Item Added to Cart'),
          content: const Text(
              'The item is added to the cart. Would you like to shop for more?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartPage(
                        appBarBuilder: buildAppBar), // Navigate to Cart Page
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
                    builder: (context) => ShopPage(
                        appBarBuilder: buildAppBar), // Navigate to Shop Page
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
}
// End of Product Details Page SECTION

/// End of document