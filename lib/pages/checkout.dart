import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Only available on web. If building for mobile, this import will be inert.
import 'dart:html' as html;

const String backendUrl = 'https://ecommerce-backend2-qqsc.onrender.com';

class CheckoutPage extends StatefulWidget {
  final double totalAmount;

  const CheckoutPage({Key? key, required this.totalAmount}) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  Map<String, dynamic>? paymentIntentData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Total: \$${widget.totalAmount.toStringAsFixed(2)}',
              style:
                  const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await makePayment();
              },
              child: const Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      if (kIsWeb) {
        // On web, Payment Sheet is not supported. Use Stripe Checkout instead.
        final checkoutUrl = await createCheckoutSession(widget.totalAmount);
        // Redirect the user to the Checkout page
        html.window.location.href = checkoutUrl;
      } else {
        // On mobile (iOS/Android), use Payment Sheet
        paymentIntentData = await createPaymentIntent(
          widget.totalAmount.toString(),
          'usd',
        );

        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntentData!['clientSecret'],
            merchantDisplayName: 'StyleHive',
          ),
        );

        await displayPaymentSheet();
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    }
  }

  Future<void> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful!')),
      );
    } on StripeException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment cancelled')),
      );
    } catch (e) {
      print('Error displaying payment sheet: $e');
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency) async {
    try {
      int amountInCents = (double.parse(amount) * 100).toInt();

      final response = await http.post(
        Uri.parse('$backendUrl/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amountInCents, 'currency': currency}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create payment intent: ${response.body}');
      }
    } catch (err) {
      throw Exception('Error creating payment intent: $err');
    }
  }

  // New method for creating a Checkout Session on web
  Future<String> createCheckoutSession(double amount) async {
    // Convert amount to cents for Stripe
    int amountInCents = (amount * 100).toInt();

    final response = await http.post(
      Uri.parse('$backendUrl/create-checkout-session'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amountInCents, 'currency': 'usd'}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['url']; // Expecting your backend to return { "url": "..." }
    } else {
      throw Exception('Failed to create checkout session: ${response.body}');
    }
  }
}
