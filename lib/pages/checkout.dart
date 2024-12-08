import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html; // Used for web navigation on web platform

// Update this to your actual backend URL
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
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Total: \$${widget.totalAmount.toStringAsFixed(2)}',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                await makePayment();
              },
              child: Text(
                'Pay Now',
                style: textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      if (kIsWeb) {
        // On Web, redirect to Stripe Checkout page
        final checkoutUrl = await createCheckoutSession(widget.totalAmount);
        html.window.location.href = checkoutUrl;
      } else {
        // On Mobile or Desktop, use Payment Sheet
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
      debugPrint('Error during payment: $e');
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
      debugPrint('Error displaying payment sheet: $e');
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

  Future<String> createCheckoutSession(double amount) async {
    int amountInCents = (amount * 100).toInt();

    final response = await http.post(
      Uri.parse('$backendUrl/create-checkout-session'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amountInCents, 'currency': 'usd'}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['url'];
    } else {
      throw Exception('Failed to create checkout session: ${response.body}');
    }
  }
}
