import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focusable_control_builder/focusable_control_builder.dart';
import 'product_details_page.dart';
import 'product_model.dart';
import 'app_bar.dart';

class ShopPage extends StatefulWidget {
  final AppBar Function(BuildContext) appBarBuilder;
  final String? category;

  const ShopPage({Key? key, required this.appBarBuilder, this.category})
      : super(key: key);

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final ScrollController _scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  List<Product> products = [];
  List<Product> searchResults = [];
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();

    _initializePage();

    // Set up the search controller listener
    searchController.addListener(() {
      filterSearchResults(searchController.text);
    });
  }

  Future<void> _initializePage() async {
    await _loadProductData();
    await _loadCatalogData();

    // Apply category filter if provided
    if (widget.category != null && widget.category!.isNotEmpty) {
      String searchTerm = widget.category!;
      if (products.isNotEmpty) {
        setState(() {
          searchController.text = searchTerm;
          filterSearchResults(searchTerm);
        });
      }
    }
  }

  // Load products from Firestore
  Future<void> _loadProductData() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('products').get();

      List<Product> productList = querySnapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();

      setState(() {
        products = productList;
        searchResults = productList;
      });
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  // Load categories from Firestore
  Future<void> _loadCatalogData() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('categories').get();

      List<Category> categoryList = querySnapshot.docs
          .map((doc) => Category.fromFirestore(doc))
          .toList();

      setState(() {
        categories = categoryList;
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
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

  void filterSearchResults(String query) {
    List<Product> results = [];
    if (query.isNotEmpty) {
      results = products.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } else {
      results = products;
    }
    setState(() {
      searchResults = results;
    });
  }

  Widget _buildCategoryCard(Category category) {
    return GestureDetector(
      onTap: () {
        // Filter products based on category
        filterSearchResults(category.name);
        searchController.text = category.name;
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
                category.image,
                width: 30,
                height: 30,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error);
                },
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () {
                  // Filter products based on category
                  filterSearchResults(category.name);
                  searchController.text = category.name;
                },
                child: Text(
                  category.name,
                  style: const TextStyle(color: Colors.black, fontSize: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopCard(Product product) {
    String priceRecord = "\$${product.price.toStringAsFixed(2)}";

    return FocusableControlBuilder(
      builder: (context, state) {
        bool isHovered = state.isHovered;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsPage(
                  product: product,
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
                borderRadius: const BorderRadius.only(
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
                      borderRadius:
                          BorderRadius.circular(8.0), // Rounded corners for image
                      child: Image.network(
                        product.image,
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error, size: 40);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product.name,
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
                      filterSearchResults('');
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
                          child: _buildCategoryCard(category),
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
                      return _buildShopCard(searchResults[index]);
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
