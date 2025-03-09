import 'package:flutter/material.dart';
import 'db_helper.dart'; // Import DBHelper

class ProductManagement extends StatefulWidget {
  const ProductManagement({super.key}); // Add named 'key' parameter

  @override
  ProductManagementState createState() => ProductManagementState();
}

class ProductManagementState extends State<ProductManagement> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _subCategories = [];
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final categories = await _dbHelper.getCategories();
    final subCategories = await _dbHelper.getSubCategories();
    final products = await _dbHelper.fetchAllProducts();

    setState(() {
      _categories = categories;
      _subCategories = subCategories;
      _products = products;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildList('Categories', _categories),
          _buildList('Sub-Categories', _subCategories),
          _buildList('Products', _products),
        ],
      ),
    );
  }

  Widget _buildList(String title, List<Map<String, dynamic>> items) {
    return ExpansionTile(
      title: Text(title),
      children:
          items.map((item) {
            return ListTile(title: Text(item['name']));
          }).toList(),
    );
  }
}
