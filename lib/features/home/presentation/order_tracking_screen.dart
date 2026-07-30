import 'package:flutter/material.dart';
import 'package:flutter_application_1/shared/widgets/app_app_bar.dart';
import 'package:flutter_application_1/shared/widgets/app_loader.dart';

/// Screen for tracking order status in real-time
class OrderTrackingScreen extends StatefulWidget {

  const OrderTrackingScreen({super.key, required this.orderId});
  final String orderId;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: Text('Track Order')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLoader(),
            const SizedBox(height: 16),
            Text('Tracking order: ${widget.orderId}'),
            const SizedBox(height: 8),
            const Text('Real-time tracking will be implemented here'),
          ],
        ),
      ),
    );
  }
}
