import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:json_editor_flutter/json_editor_flutter.dart';

// CartEditorPage to edit cart contents with json_editor_flutter
class CartEditorPage extends StatefulWidget {
  const CartEditorPage({super.key});

  @override
  _CartEditorPageState createState() => _CartEditorPageState();
}

class _CartEditorPageState extends State<CartEditorPage> {
  dynamic cartData = {};

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final cartFile = await _getCartFile();
    if (await cartFile.exists()) {
      final cartJson = await cartFile.readAsString();
      setState(() {
        cartData = json.decode(cartJson);
      });
    }
  }

  Future<File> _getCartFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/cart.json');
  }

  Future<void> _saveCart() async {
    final cartFile = await _getCartFile();
    final updatedCart = json.encode(cartData);
    await cartFile.writeAsString(updatedCart);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart Editor')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: JsonEditor(
          json: json.encode(cartData), // Pass the JSON data as a string
          onChanged: (value) {
            setState(() {
              cartData = json.decode(value); // Update the cartData on changes
            });
          },
          enableMoreOptions: true, // Allows adding or deleting data
          enableKeyEdit: true,     // Enables editing of keys
          enableValueEdit: true,   // Enables editing of values
          themeColor: Colors.blue, // Set theme color
          enableHorizontalScroll: true, // Allow horizontal scroll in tree view
          // Omit the 'editors' list for now until proper types are known.
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveCart, // Save the cart when button is pressed
        child: const Icon(Icons.save),
      ),
    );
  }
}


///
/// Unused imports:
/// 

//import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//import 'package:flutter/services.dart' show rootBundle;

//import 'app_bar.dart';
//import 'shop_page.dart';