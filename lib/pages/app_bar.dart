import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// pages import
import 'home_page.dart';
import 'profile_page.dart';
import 'shop_page.dart';
import 'cart_page.dart';
import 'login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

AppBar buildAppBar(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;

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
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const HomePage()));
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
                      builder: (context) => ShopPage(appBarBuilder: buildAppBar)),
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
                          CartPage(appBarBuilder: buildAppBar)),
                );
              },
            ),
            if (user != null)
              _buildFocusableIconButton(
                icon: Icons.person,
                context: context,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProfilePage(appBarBuilder: buildAppBar),
                    ),
                  );
                },
              )
            else
              _buildFocusableIconButton(
                icon: Icons.login,
                context: context,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
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
