// ignore_for_file: unused_local_variable, unused_element

import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'login_page.dart'; // Import login page
import 'dart:io'; // Import dart:io for File
import 'package:intl/intl.dart'; // Import for date and time formatting
import 'package:logging/logging.dart'; // Import logging package

class CashierDashboard extends StatelessWidget {
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
