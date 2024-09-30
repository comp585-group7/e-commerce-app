import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // Root widget of your application.
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basic Navigation App',
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/second': (context) => const SecondPage(),
      },
    );
  }
}

class LandingPage extends StatelessWidget {
  // This is the landing page.
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landing Page'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Go to Second Page'),
          onPressed: () {
            Navigator.pushNamed(context, '/second');
          },
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  // This is the second page with a button to navigate back.
  const SecondPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Page'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Back to Landing Page'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
