import 'package:flutter/material.dart';
// Add this import
import 'product_management.dart' as pm;
import 'business_details.dart';
import 'user_management.dart';
import 'sales_report.dart' as sr;
import 'login_page.dart';
// Add this import
import 'login_report.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  AdminDashboardState createState() => AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard> {
  Widget _selectedPage = pm.ProductManagement();
  final List<Map<String, dynamic>> _orderItems = [];
  final List<String> _selectedAddIns = [];

  void _selectPage(Widget page) {
    if (mounted) {
      setState(() {
        _selectedPage = page;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Navigation Pane (Bootstrap-like sidebar)
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: Colors.grey[200], // Light grey background like Bootstrap
              border: Border(right: BorderSide(color: Colors.grey[300]!)),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.green, // Bootstrap primary color
                  ),
                  child: Text(
                    'Admin Panel',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.shopping_cart),
                  title: Text('Product Management'),
                  onTap: () => _selectPage(pm.ProductManagement()),
                ),
                ListTile(
                  leading: Icon(Icons.business),
                  title: Text('Business Details'),
                  onTap: () => _selectPage(BusinessDetailsForm()),
                ),
                ListTile(
                  leading: Icon(Icons.people),
                  title: Text('User Management'),
                  onTap: () => _selectPage(UserManagement()),
                ),
                ListTile(
                  leading: Icon(Icons.bar_chart),
                  title: Text('Sales Report'),
                  onTap: () => _selectPage(sr.SalesReport()),
                ),
                // Add this ListTile
                ListTile(
                  leading: Icon(Icons.login),
                  title: Text('Login Report'),
                  onTap: () => _selectPage(LoginReport()),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Log Out'),
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
          // Main Content Area (Bootstrap-like content area)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Title (Bootstrap-like heading)
                  Text(
                    _getPageTitle(_selectedPage),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  // Content Area
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha((0.3 * 255).toInt()),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: _selectedPage,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Order Items and Add-Ins (Bootstrap-like panels)
                  if (_orderItems.isNotEmpty || _selectedAddIns.isNotEmpty)
                    Row(
                      children: [
                        if (_orderItems.isNotEmpty)
                          Expanded(
                            child: _buildPanel(
                              'Order Items',
                              _orderItems
                                  .map(
                                    (item) => ListTile(
                                      title: Text(item['name']),
                                      subtitle: Text(
                                        'Quantity: ${item['quantity']}',
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        if (_selectedAddIns.isNotEmpty)
                          Expanded(
                            child: _buildPanel(
                              'Selected Add-Ins',
                              _selectedAddIns
                                  .map((addIn) => ListTile(title: Text(addIn)))
                                  .toList(),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel(String title, List<Widget> items) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.3 * 255).toInt()),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ...items,
        ],
      ),
    );
  }

  String _getPageTitle(Widget page) {
    if (page is pm.ProductManagement) {
      return 'Product Management';
    } else if (page is BusinessDetailsForm) {
      return 'Business Details';
    } else if (page is UserManagement) {
      return 'User Management';
    } else if (page is sr.SalesReport) {
      return 'Sales Report';
    } else if (page is LoginReport) {
      return 'Login Report';
    } else {
      return 'Dashboard';
    }
  }
}
