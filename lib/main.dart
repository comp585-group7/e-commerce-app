// ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // basic flutter package
import 'pages/home_page.dart'; // Import HomePage

void main() async {
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
      home: const HomePage(), // Use HomePage from home_page.dart
    );
  }
}

/// End of document
