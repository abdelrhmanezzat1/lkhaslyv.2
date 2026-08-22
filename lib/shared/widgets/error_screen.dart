import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/custom_app_bar.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, this.error});
  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: Text('Error')),
      body: Center(
        child: Text('An error occurred: ${error ?? "Unknown error"}'),
      ),
    );
  }
}
