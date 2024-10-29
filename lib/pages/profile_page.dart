import 'package:flutter/material.dart';
// ignore: unused_import
import 'app_bar.dart'; // Import your custom AppBar

class ProfilePage extends StatelessWidget {
  final AppBar Function(BuildContext) appBarBuilder;
  final String username;

  const ProfilePage({
    super.key,
    required this.appBarBuilder,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarBuilder(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Card(
              color: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.people_rounded,
                      size: 32.0,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "Hello, $username!",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Personal Information Section
            _buildSectionHeader("Personal Information"),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text("Username: $username"),
              subtitle: const Text("Edit your username"),
              trailing: const Icon(Icons.edit),
              onTap: () {
                // Add action to edit username
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text("Email"),
              subtitle: const Text("Add or edit your email address"),
              trailing: const Icon(Icons.edit),
              onTap: () {
                // Add action to edit email
              },
            ),
            const Divider(height: 20, thickness: 1),

            // Mailing Address Section
            _buildSectionHeader("Mailing Address"),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Mailing Address"),
              subtitle: const Text("Add or edit your mailing address"),
              trailing: const Icon(Icons.edit),
              onTap: () {
                // Add action to edit mailing address
              },
            ),
            const Divider(height: 20, thickness: 1),

            // My Orders Section
            _buildSectionHeader("My Orders"),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text("View Orders"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to orders page
              },
            ),
            const Divider(height: 20, thickness: 1),

            // Account Settings Section
            _buildSectionHeader("Account Settings"),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Change Password"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Add action to change password
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("Notification Settings"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Add action for notification settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Add logout action
              },
            ),
          const SizedBox(height: 10),
          //buildBottom()
          ],
        ),
      ),
    );
  }

  // Helper method to build section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
