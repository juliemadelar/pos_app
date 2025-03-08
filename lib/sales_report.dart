import 'package:flutter/material.dart';

class SalesReport extends StatefulWidget {
  const SalesReport({super.key}); // Added named 'key' parameter
  @override
  SalesReportState createState() => SalesReportState(); // Changed _SalesReportState to SalesReportState
}

class SalesReportState extends State<SalesReport> {
  // Changed _SalesReportState to SalesReportState
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sales Report')),
      body: Center(child: Text('Sales data will be displayed here.')),
    );
  }
}
