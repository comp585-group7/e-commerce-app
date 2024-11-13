import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:focusable_control_builder/focusable_control_builder.dart';

import 'product_details_page.dart'; // Import ProductDetailsPage

/// Shop Page
/// This page would show all the items being sold
/// can we add a way to use focusable_control_builder.dart so that the shop cards are higlighted with black when hovered on
class ShopPage extends StatefulWidget {
  final AppBar Function(BuildContext) appBarBuilder;

  const ShopPage({super.key, required this.appBarBuilder});

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final ScrollController _scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  List<dynamic> products = [];
  List<dynamic> searchResults = [];
  List<dynamic> categories = [];

  @override
  void initState() {
    super.initState();
    loadProductData();
    _loadCategoryData();
    searchController.addListener(() {
      filterSearchResults(searchController.text);
    });
  }

  // Load category data from JSON
  Future<void> _loadCategoryData() async {
    final String response =
        await rootBundle.loadString('assets/data-ctlg.json');
    final data = await json.decode(response);
    setState(() {
      categories = data['categories'];
    });
  }

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

  /*
  Future<void> loadProductData() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:5000/api/products'));
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
  */

  Future<void> loadProductData() async {
    // LOAD DATA FROM ASSETS FOR NOW, DELETE LATER ON PRODUCTION
    try {
    final String response = await rootBundle.loadString('assets/product.json');
    final jsonData = json.decode(response);
    setState(() {
      products = jsonData['products'];
      searchResults = products;
    });
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

  Widget _buildShopCard(String productName, String imageAsset,
      double productPrice, String pdescription, int productId) {
    String priceRecord = "\$$productPrice";

    return FocusableControlBuilder(
      builder: (context, state) {
        bool isHovered = state.isHovered;

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
          child: AnimatedScale(
            scale: isHovered ? 1.0 : 0.9, // Zoom in when hovered
            duration: const Duration(milliseconds: 200), // Animation duration
            curve: Curves.easeInOut, // Smooth scaling curve
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  bottomRight: Radius.circular(16.0),
                ),
                side: BorderSide(
                  color: isHovered ? Colors.black : Colors.transparent,
                  width: 2.0,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                          8.0), // Rounded corners for image
                      child: Image.network(
                        imageAsset,
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error,
                              size:
                                  40); // Show error icon if image fails to load
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      productName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      priceRecord,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(String category, String imageAsset) {
    return GestureDetector(
      onTap: () {
        // filter products based on category
        filterSearchResults(category);
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 15),
              Image.network(
                imageAsset,
                width: 30,
                height: 30,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons
                      .error); // Show an error icon in case image fails to load
                },
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () {
                  // filter products based on category
                  filterSearchResults(category);
                },
                child: Text(category,
                    style:
                        const TextStyle(color: Colors.black, fontSize: 16.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    var isSmallScreen = screenWidth < 830;

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
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: _scrollLeft,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    child: Row(
                      children: categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: _buildCategoryCard(
                              category['name'], category['image']),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: _scrollRight,
                ),
              ],
            ),
            const SizedBox(height: 5),
            searchResults.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: searchResults.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isSmallScreen ? 2 : 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio:
                          isSmallScreen ? 2 / 2.8 : 2 / 2.5, // Adjust the ratio
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
