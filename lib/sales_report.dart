import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class SalesReport extends StatefulWidget {
  const SalesReport({super.key});
  @override
  SalesReportState createState() => SalesReportState();
}

class SalesReportState extends State<SalesReport> {
  final Logger _logger = Logger('SalesReport');

  @override
  void initState() {
    super.initState();
    _logger.info('SalesReport initialized');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Sales Report by User'),
            // Add more widgets here to display the sales report details
          ],
        ),
      ),
    );
  }
}
