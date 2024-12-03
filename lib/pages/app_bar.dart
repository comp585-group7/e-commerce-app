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
    automaticallyImplyLeading: false,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildFocusableButton(
          label: 'StyleHive',
          context: context,
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const HomePage()));
          },
        ),
        Row(
          children: [
            _buildFocusableIconButton(
              icon: Icons.search,
              context: context,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ShopPage(appBarBuilder: buildAppBar)),
                );
              },
            ),
            _buildFocusableIconButton(
              icon: Icons.shopping_cart,
              context: context,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const CartPage(appBarBuilder: buildAppBar)),
                );
              },
            ),
            _buildFocusableIconButton(
              icon: Icons.person, // or another profile-related icon
              context: context,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(
                      appBarBuilder: buildAppBar,
                      username: "admin",
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    ),
  );
}

// Helper function for focusable TextButton
Widget _buildFocusableButton({
  required String label,
  required BuildContext context,
  required VoidCallback onPressed,
}) {
  return MouseRegion(
    child: Focus(
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          foregroundColor: MaterialStateColor.resolveWith((states) {
            if (states.contains(MaterialState.focused) ||
                states.contains(MaterialState.hovered)) {
              return Colors.deepOrangeAccent; // Highlighted color
            }
            return Colors.white; // Default color
          }),
        ),
        child: Text(label),
      ),
    ),
  );
}

// Helper function for focusable IconButton
Widget _buildFocusableIconButton({
  required IconData icon,
  required BuildContext context,
  required VoidCallback onPressed,
}) {
  return MouseRegion(
    child: Focus(
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: Colors.white,
        iconSize: 24.0,
        splashColor: Colors.blue,
      ),
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