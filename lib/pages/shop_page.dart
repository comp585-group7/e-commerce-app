import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product_details_page.dart'; // Import ProductDetailsPage

import 'app_bar.dart'; // Import buildAppBar function

/// Shop Page
///
/// This page would show all the items being sold
class ShopPage extends StatefulWidget {
  final AppBar Function(BuildContext) appBarBuilder;

  const ShopPage({super.key, required this.appBarBuilder});

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  List<dynamic> products = [];
  List<dynamic> searchResults = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProductData();
    searchController.addListener(() {
      filterSearchResults(searchController.text);
    });
  }

  Future<void> loadProductData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:5000/api/products'));
      //final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/products')); // for android emulator
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          products = jsonData['products'];
          searchResults = products;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  void filterSearchResults(String query) {
    List<dynamic> results = [];
    if (query.isNotEmpty) {
      results = products.where((product) {
        return product['name'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    } else {
      results = products;
    }
    setState(() {
      searchResults = results;
    });
  }

  Widget _buildShopCard(
      String productName, String imageAsset, double productPrice, String pdescription, int productId) {
    String priceRecord = "\$$productPrice";
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
              productName: productName,
              productDescription: pdescription,
              productImage: imageAsset,
              productPrice: productPrice,
              productId: productId,
            ),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Add some padding for spacing
          child: Center(
            child: Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center, // Ensure horizontal centering
                children: [
                  Image.asset(imageAsset,
                      width: 160,
                      height: 160), // Increased image size for better visibility
                  const SizedBox(height: 10), // Vertical space between image and text
                  Text(productName,
                      textAlign: TextAlign.center), // Center the text
                  Text(
                    priceRecord,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    var isSmallScreen = screenWidth < 750;

    return Scaffold(
      appBar: widget.appBarBuilder(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: "What do you want to look for?",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear();
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            searchResults.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: searchResults.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isSmallScreen ? 2 : 4, // Number of cards per row
                      crossAxisSpacing: 10, // Horizontal space between cards
                      mainAxisSpacing: 10, // Vertical space between cards
                      childAspectRatio: isSmallScreen ? 2 / 2.8 : 2 / 1.5,
                    ),
                    itemBuilder: (context, index) {
                      return _buildShopCard(
                        searchResults[index]['name'],
                        searchResults[index]['image'],
                        searchResults[index]['price'],
                        searchResults[index]['description'],
                        searchResults[index]['id'],
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
