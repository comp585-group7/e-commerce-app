import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

///
/// Build the footer of the website
///
Widget buildBottom() {
  return Container(
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
              icon:
                  const FaIcon(FontAwesomeIcons.facebook, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.twitter, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon:
                  const FaIcon(FontAwesomeIcons.instagram, color: Colors.white),
              onPressed: () {},
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
