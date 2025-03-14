import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'sales_database.dart';

class SalesReport extends StatefulWidget {
  const SalesReport({super.key});
  @override
  SalesReportState createState() => SalesReportState();
}

class SalesReportState extends State<SalesReport> {
  final Logger _logger = Logger('SalesReport');
  List<Map<String, dynamic>> _sales = [];

  @override
  void initState() {
    super.initState();
    _logger.info('SalesReport initialized');
    _fetchSales();
  }

  Future<void> _fetchSales() async {
    try {
      final sales = await SalesDatabase.instance.readAllSales();
      setState(() {
        _sales = sales;
      });
    } catch (e) {
      _logger.severe('Error fetching sales: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading sales data.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_sales.isEmpty)
                const CircularProgressIndicator()
              else
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          Text('Order Number'),
                          Text('Date'),
                          Text('Username'),
                          Text('Product ID'),
                          Text('Product Name'),
                          Text('Quantity'),
                          Text('Price'),
                          Text('Subtotal'),
                          Text('Tax'),
                          Text('Discount'),
                          Text('Total'),
                          Text('Amount Paid'),
                          Text('Change'),
                          Text('Mode of Payment'),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 400, // Define a fixed height for the ListView
                      child: ListView.builder(
                        itemCount: _sales.length,
                        itemBuilder: (context, index) {
                          final sale = _sales[index];
                          return ListTile(
                            title: Text('Order Number: ${sale['orderNumber']}'),
                            subtitle: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Text('Date: ${sale['date']}  '),
                                  Text('Username: ${sale['username']}  '),
                                  Text('Product ID: ${sale['productId']}  '),
                                  Text(
                                    'Product Name: ${sale['productName']}  ',
                                  ),
                                  Text('Quantity: ${sale['quantity']}  '),
                                  Text('Price: ${sale['price']}  '),
                                  Text('Subtotal: ${sale['subtotal']}  '),
                                  Text('Tax: ${sale['tax']}  '),
                                  Text('Discount: ${sale['discount']}  '),
                                  Text('Total: ${sale['total']}  '),
                                  Text('Amount Paid: ${sale['amountPaid']}  '),
                                  Text('Change: ${sale['change']}  '),
                                  Text(
                                    'Mode of Payment: ${sale['modeOfPayment']}',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
