import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // basic flutter package
import 'pages/home_page.dart'; // Import HomePage

// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';

void main() async {
  //
  WidgetsFlutterBinding.ensureInitialized();

  // checks if platform is web or not, either Android or Apple
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyDJryKyP4A4nmEIPLSNB_prakcH1syqpzw",
            authDomain: "booklite-bfbdf.firebaseapp.com",
            databaseURL: "https://booklite-bfbdf-default-rtdb.firebaseio.com",
            projectId: "booklite-bfbdf",
            storageBucket: "booklite-bfbdf.appspot.com",
            messagingSenderId: "954069129873",
            appId: "1:954069129873:web:4bf6289429fb77c3c53d30",
            measurementId: "G-ZYRYWQCQWV"));
  } else {
    await Firebase.initializeApp();
  }

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
