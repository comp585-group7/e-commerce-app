import 'package:flutter/material.dart';

// pages import
import 'home_page.dart';
import 'profile_page.dart'; 
import 'shop_page.dart';
import 'cart_page.dart';



///
/// Method to build the top AppBar for reuse
///   - this is the top Appbar seen on most pages
///
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
                MaterialPageRoute(builder: (context) => const HomePage()));
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
                      builder: (context) => const ProfilePage(
                          appBarBuilder: buildAppBar, username: "admin")),
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
                          ShopPage(appBarBuilder: buildAppBar)),
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
                          const CartPage(appBarBuilder: buildAppBar)),
                );
              },
            ),
            
          ],
        ),
      ],
    ),
  );
}

/// End of Global AppBar global method

/// 
/// Unused imports/code:
///

// import 'cart_editor.dart';
// TextButton(onPressed: () {
//                Navigator.pushReplacement(
//                  context,
  //                // goes to the Search page
    //              MaterialPageRoute(
      //                builder: (context) =>
        //                  CartEditorPage()),
          //      );
            //  }, 
