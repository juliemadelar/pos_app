import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SalesReport extends StatefulWidget {
  const SalesReport({super.key});

  @override
  State<SalesReport> createState() => _SalesReportState();
}

class _SalesReportState extends State<SalesReport> {
  late Future<List<Map<String, dynamic>>> _salesData;

  @override
  void initState() {
    super.initState();
    _salesData = _getSalesData();
  }

  Future<List<Map<String, dynamic>>> _getSalesData() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'product_database.db'),
    );

    // Check if the sales table exists
    final tableExists =
        Sqflite.firstIntValue(
          await database.rawQuery(
            "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='sales';",
          ),
        ) ==
        1;

    if (!tableExists) {
      // Create the sales table if it doesn't exist
      await database.execute('''
        CREATE TABLE sales (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT,
          date TEXT,
          time TEXT,
          orderNumber TEXT,
          username TEXT,
          total REAL
        )
      ''');
    }

    // Query the sales data
    final List<Map<String, dynamic>> salesData = await database.query(
      'sales',
      columns: ['date', 'time', 'username', 'orderNumber', 'total'],
      orderBy: 'orderNumber ASC', // Add this line to sort by order number
    );
    return salesData;
  }

  Future<String> _getUsername(String username) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'product_database.db');
    final database = await openDatabase(path);

    final result = await database.query(
      'users',
      columns: ['name'],
      where: 'username = ?',
      whereArgs: [username],
    );

    if (result.isNotEmpty) {
      return result.first['name'] as String;
    } else {
      return username; // Return username if name not found
    }
  }

  Future<void> _showOrderDetails(String orderNumber) async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'product_databae.db'),
    );

    // Check if the order_details table exists
    final tableExists =
        Sqflite.firstIntValue(
          await database.rawQuery(
            "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='order_details';",
          ),
        ) ==
        1;

    if (!tableExists) {
      // Create the order_details table if it doesn't exist
      await database.execute('''
        CREATE TABLE order_details (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          orderNumber TEXT,
          product TEXT,
          quantity INTEGER,
          price REAL
        )
      ''');
    }

    final orderDetails = await database.query(
      'order_details',
      where: 'orderNumber = ?',
      whereArgs: [orderNumber],
    );

    if (!mounted) return; // Check if the widget is still mounted

    showModalBottomSheet(
      context: this.context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Product',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Quantity',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Divider(),
              ...orderDetails.map((detail) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${detail['product']}'),
                    Text('${detail['quantity']}'),
                    Text('\$${detail['price']}'),
                  ],
                );
              }),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('0.00'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tax', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('0.00'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('0.00'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('0.00'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Amount Paid',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('0.00'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Change', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('0.00'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _salesData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No sales data available.'));
          } else {
            final salesData =
                snapshot.data!; // Use the non-null assertion operator

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Date',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Increase font size
                        ),
                      ),
                      Text(
                        'Time',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Increase font size
                        ),
                      ),
                      Text(
                        'Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Increase font size
                        ),
                      ),
                      Text(
                        'Order Number',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Increase font size
                        ),
                      ),
                      Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Increase font size
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: salesData.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder<String>(
                        future: _getUsername(
                          salesData[index]['username'] as String,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else {
                            final sale = salesData[index];
                            final date = sale['date'] as String?;
                            final time = sale['time'] as String?;
                            if (date == null || time == null) {
                              return const SizedBox.shrink(); // Skip if date or time is null
                            }
                            final username = sale['username'] as String;
                            final name =
                                snapshot.data ??
                                username; // Use fetched name or username
                            final orderNumber = sale['orderNumber'] as String;
                            final totalAmount = sale['total'] as num? ?? 0;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ), // Add margin
                              elevation: 4, // Add elevation for shadow
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12.0),
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      date,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16, // Default font size
                                      ),
                                    ),
                                    Text(
                                      time,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16, // Default font size
                                      ),
                                    ),
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16, // Default font size
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap:
                                          () => _showOrderDetails(orderNumber),
                                      child: Text(
                                        orderNumber,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '\$${totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16, // Default font size
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
