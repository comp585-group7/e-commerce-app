import 'package:flutter/material.dart'; // basic flutter package
import 'pages/home_page.dart';  // Import HomePage

void main() {
  runApp(const StyleHiveApp());
}

class StyleHiveApp extends StatelessWidget {
  const StyleHiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StyleHive',
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomePage(),  // Use HomePage from home_page.dart
    );
  }
}

/// End of document

///
/// Unused imports:
/// 


//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'dart:convert';
//import 'package:flutter/services.dart' show rootBundle;
//import 'dart:io';
//import 'package:path_provider/path_provider.dart';

//import 'package:json_editor_flutter/json_editor_flutter.dart';


//import 'pages/profile_page.dart'; // Import ProfilePage
//import 'pages/shop_page.dart'; // Import ShopPage 