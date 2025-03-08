import 'package:flutter/material.dart';
import 'product_management.dart'; // Import the ProductManagement widget
import 'business_details.dart'; // Import BusinessDetailsForm
import 'user_management.dart'; // Import UserManagement
import 'sales_report.dart'; // Import SalesReport
import 'login_page.dart'; // Import LoginPage

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key}); // Convert 'key' to a super parameter
  @override
  AdminDashboardState createState() => AdminDashboardState(); // Make the state class public
}

class AdminDashboardState extends State<AdminDashboard> {
  // Rename to make it public
  Widget _selectedPage = ProductManagement(); // Default page
  final List<Map<String, dynamic>> _orderItems = []; // Use the field
  final List<String> _selectedAddIns = []; // Use the field

  @override
  void initState() {
    super.initState();
    // Remove the incorrect usage of productList getter
    // ProductManagement productManager = ProductManagement();
    // print(productManager.productList); // Correct: Accessing via public getter
  }

  void _selectPage(Widget page) {
    setState(() {
      _selectedPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.greenAccent,
            child: Text(
              'Admin Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                // Left pane menu
                Container(
                  width: 400,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.lightGreenAccent, Colors.greenAccent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          'Product Management',
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () => _selectPage(ProductManagement()),
                      ),
                      ListTile(
                        title: Text(
                          'Business Details',
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () => _selectPage(BusinessDetailsForm()),
                      ),
                      ListTile(
                        title: Text(
                          'User Management',
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () => _selectPage(UserManagement()),
                      ),
                      ListTile(
                        title: Text(
                          'Sales Report',
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () => _selectPage(SalesReport()),
                      ),
                      Spacer(),
                      ListTile(
                        title: Text(
                          'Log Out',
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Right pane content
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Expanded(child: _selectedPage),
                        // Display order items
                        if (_orderItems.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order Items',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ..._orderItems.map(
                                  (item) => ListTile(
                                    title: Text(item['name']),
                                    subtitle: Text(
                                      'Quantity: ${item['quantity']}',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Display selected add-ins
                        if (_selectedAddIns.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selected Add-Ins',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ..._selectedAddIns.map(
                                  (addIn) => ListTile(title: Text(addIn)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
