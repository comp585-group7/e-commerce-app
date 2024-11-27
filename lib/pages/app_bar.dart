import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:layout_basics1/pages/ar_page.txt';
import 'camera_page.dart';

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
          label: 'Shop',
          context: context,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ShopPage(appBarBuilder: buildAppBar)),
            );
          },
        ),
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
            _buildFocusableButton(
              label: 'Profile',
              context: context,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfilePage(
                          appBarBuilder: buildAppBar, username: "admin")),
                );
              },
            ),
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
              icon: Icons.camera,
              context: context,
              onPressed: () async {
                try {
                  // Fetch available cameras
                  final cameras = await availableCameras();

                  if (cameras.isEmpty) {
                    // Handle the case where no camera is available
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('No cameras available')),
                    );
                    return;
                  }

                  // Select the first camera (typically the rear camera)
                  final firstCamera = cameras.first;

                  // Navigate to CameraScreen and pass both the selected camera and the list of cameras
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CameraScreen(camera: firstCamera, cameras: cameras),
                    ),
                  );
                } catch (e) {
                  // Handle any errors (e.g., permission issues or device errors)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to access the camera: $e')),
                  );
                }
              },
            )
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