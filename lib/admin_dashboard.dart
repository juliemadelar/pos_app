import 'package:flutter/material.dart';
import 'product_management.dart'; // Import the ProductManagement widget
import 'business_details.dart'; // Import BusinessDetailsForm
import 'user_management.dart'; // Import UserManagement
import 'sales_report.dart'; // Import SalesReport
import 'login_page.dart'; // Import LoginPage

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Widget _selectedPage = ProductManagement(); // Default page

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
                        title: Text('Product Management', style: TextStyle(color: Colors.black)),
                        onTap: () => _selectPage(ProductManagement()),
                      ),
                      ListTile(
                        title: Text('Business Details', style: TextStyle(color: Colors.black)),
                        onTap: () => _selectPage(BusinessDetailsForm()),
                      ),
                      ListTile(
                        title: Text('User Management', style: TextStyle(color: Colors.black)),
                        onTap: () => _selectPage(UserManagement()),
                      ),
                      ListTile(
                        title: Text('Sales Report', style: TextStyle(color: Colors.black)),
                        onTap: () => _selectPage(SalesReport()),
                      ),
                      Spacer(),
                      ListTile(
                        title: Text('Log Out', style: TextStyle(color: Colors.black)),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
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
                    child: _selectedPage,
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
