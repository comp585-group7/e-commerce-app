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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePage();

    // Update search results as the user types
    searchController.addListener(() {
      filterSearchResults(searchController.text);
    });
  }

  Future<void> _initializePage() async {
    await _loadProductData();
    await _loadCatalogData();

    // Apply category filter if provided
    if (widget.category != null && widget.category!.isNotEmpty) {
      final searchTerm = widget.category!;
      if (products.isNotEmpty) {
        setState(() {
          searchController.text = searchTerm;
          filterSearchResults(searchTerm);
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  // Load products from Firestore
  Future<void> _loadProductData() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('products').get();

      final productList =
          querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

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
      final querySnapshot =
          await FirebaseFirestore.instance.collection('categories').get();

      final categoryList =
          querySnapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();

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
    if (query.isNotEmpty) {
      final results = products.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
      setState(() {
        searchResults = results;
      });
    } else {
      setState(() {
        searchResults = products;
      });
    }
  }

  Widget _buildCategoryCard(Category category) {
    return GestureDetector(
      onTap: () {
        filterSearchResults(category.name);
        searchController.text = category.name;
      },
      child: Card(
        color: Colors.white, // Ensure the category card is white
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            children: [
              Image.network(
                category.image,
                width: 30,
                height: 30,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error);
                },
              ),
              const SizedBox(width: 10),
              Text(
                category.name,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopCard(Product product) {
    final priceRecord = "\$${product.price.toStringAsFixed(2)}";

    return FocusableControlBuilder(
      builder: (context, state) {
        final isHovered = state.isHovered;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsPage(product: product),
              ),
            );
          },
          child: AnimatedScale(
            scale: isHovered ? 1.0 : 0.9,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Card(
              color: Colors.white, // Ensure the product card is white
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
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
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
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildCategoriesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Column(
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Categories',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _scrollLeft,
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 15.0, 16.0, 10.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: "Search products...",
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
    );
  }

  Widget _buildProductsSection() {
    double screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 830;

    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (searchResults.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: Text(
            'No products found.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: searchResults.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isSmallScreen ? 2 : 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: isSmallScreen ? 2 / 2.8 : 2 / 2.5,
        ),
        itemBuilder: (context, index) {
          return _buildShopCard(searchResults[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBarBuilder(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchBar(),
            _buildCategoriesSection(),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Products',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 10),
            _buildProductsSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
