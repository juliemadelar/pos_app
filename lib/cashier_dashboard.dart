// ignore_for_file: unused_local_variable, unused_element

import 'package:flutter/material.dart';
import 'login_page.dart'; // Import login page
// Import dart:io for File
// Import for date and time formatting
// Import logging package

class CashierDashboard extends StatelessWidget {
  const CashierDashboard({super.key});

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cashier Dashboard'),
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: Center(child: Text('Welcome to the Cashier Dashboard!')),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: ElevatedButton(
            onPressed: () => _logout(context),
            child: Text('Log Out'),
          ),
        ),
      ),
    );
  }
}
