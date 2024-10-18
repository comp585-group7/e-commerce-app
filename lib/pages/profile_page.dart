import 'package:flutter/material.dart';
import 'app_bar.dart'; // Import buildAppBar function

// Profile Page
class ProfilePage extends StatelessWidget {
  final AppBar Function(BuildContext) appBarBuilder;
  final String username;

  const ProfilePage(
      {super.key,
      required this.appBarBuilder,
      required this.username}); // end of ProfilePage constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarBuilder(context),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                  color: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  child: const Row(
                    children: [
                      SizedBox(width: 15),
                      Icon(Icons.people_rounded,
                          size: 24.0, color: Colors.white),
                      SizedBox(width: 15),
                      Text("User Profile Page",
                          style:
                              TextStyle(color: Colors.white, fontSize: 24.0)),
                    ],
                  )),
            ],
          ),
        ));
  }
}