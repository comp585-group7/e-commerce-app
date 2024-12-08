import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  final AppBar Function(BuildContext) appBarBuilder;

  const ProfilePage({Key? key, required this.appBarBuilder}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user; // Nullable user to handle logged-out states.
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;

    // If user is not logged in, redirect to the LoginPage immediately.
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If user is null (not logged in), return an empty widget.
    if (user == null) {
      return const SizedBox.shrink();
    }

    final String email = user!.email ?? "No Email";
    final String userName = _getUserName(email);

    return Scaffold(
      appBar: widget.appBarBuilder(context),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header Card
                  Card(
                    color: Colors.blueGrey.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.orangeAccent,
                            radius: 24.0,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hello, $userName",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24.0,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Welcome back to your account",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Personal Information Section
                  _buildSectionHeader(context, "Personal Information",
                      icon: Icons.info_outline),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(
                      "Email: $email",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    subtitle: const Text("Tap to edit your email address"),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showEditEmailDialog(context),
                  ),
                  const Divider(height: 20, thickness: 1),

                  // Account Settings Section
                  _buildSectionHeader(context, "Account Settings",
                      icon: Icons.settings),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text("Change Password"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text("Logout"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      await _auth.signOut();
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomePage()),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
    );
  }

  // Extracts a user-friendly username from the email (just the part before '@')
  String _getUserName(String email) {
    if (email.contains('@')) {
      return email.split('@').first;
    }
    return email;
  }

  // Builds a styled section header with an optional icon
  Widget _buildSectionHeader(BuildContext context, String title,
      {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
          ),
        ],
      ),
    );
  }

  // Shows a dialog to edit the user's email address
  void _showEditEmailDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String newEmail = '';
    String password = '';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Email'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: user!.email,
                  decoration: const InputDecoration(labelText: 'New Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    } else if (!RegExp(
                            r'^([a-zA-Z0-9_\.\-])+\@([a-zA-Z0-9\-]+\.)+([a-zA-Z0-9]{2,4})+$')
                        .hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                  onChanged: (value) => newEmail = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Enter your password to confirm'
                      : null,
                  onChanged: (value) => password = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(); // Close dialog
                  await _updateEmail(newEmail, password);
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Updates the user's email, re-authenticating if necessary
  Future<void> _updateEmail(String newEmail, String password) async {
    setState(() => isLoading = true);

    try {
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: password,
      );
      await user!.reauthenticateWithCredential(credential);
      await user!.updateEmail(newEmail);
      await user!.reload();
      user = FirebaseAuth.instance.currentUser;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email updated successfully')),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'email-already-in-use') {
        message = 'This email is already in use.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else {
        message = 'An error occurred. Please try again.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Shows a dialog to change the user's password
  void _showChangePasswordDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String newPassword = '';
    String currentPassword = '';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Current Password'),
                  obscureText: true,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please enter your current password'
                      : null,
                  onChanged: (value) => currentPassword = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'New Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    } else if (value.length < 6) {
                      return 'Password should be at least 6 characters';
                    }
                    return null;
                  },
                  onChanged: (value) => newPassword = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Change'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(); // Close dialog
                  await _changePassword(currentPassword, newPassword);
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Changes the user's password after re-authenticating
  Future<void> _changePassword(
      String currentPassword, String newPassword) async {
    setState(() => isLoading = true);

    try {
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: currentPassword,
      );
      await user!.reauthenticateWithCredential(credential);
      await user!.updatePassword(newPassword);
      await user!.reload();
      user = FirebaseAuth.instance.currentUser;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'The password is too weak.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect current password.';
      } else {
        message = 'An error occurred. Please try again.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
