import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final Object? error;
  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('An error occurred: ${error ?? "Unknown error"}'),
      ),
    );
  }
}
