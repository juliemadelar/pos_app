// ignore_for_file: unused_local_variable, unused_element

import 'package:flutter/material.dart';
// Import login page
// Import dart:io for File
// Import for date and time formatting
// Import logging package

class CashierDashboard extends StatelessWidget {
  const CashierDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cashier Dashboard'),
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: Center(child: Text('Welcome to the Cashier Dashboard!')),
    );
  }
}
