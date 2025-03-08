import 'package:flutter/material.dart';
import 'db_helper.dart';

class ProductManagement extends StatefulWidget {
  @override
  ProductManagementState createState() => ProductManagementState();
}

class ProductManagementState extends State<ProductManagement> with SingleTickerProviderStateMixin {
  final dbHelper = DBHelper();
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final List<Map<String, dynamic>> products = await dbHelper.getProductsWithDetails();
    final List<Map<String, dynamic>> categories = await dbHelper.getCategories();
    setState(() {
      _products = products;
      _categories = categories;
      _tabController = TabController(length: _categories.length, vsync: this);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Management'),
        automaticallyImplyLeading: false,
        bottom: _isLoading
            ? null
            : TabBar(
                controller: _tabController,
                tabs: _categories.map((category) => Tab(text: category['name'])).toList(),
              ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? Center(child: Text('No products available'))
              : TabBarView(
                  controller: _tabController,
                  children: _categories.map((category) => _buildProductTable(category['name'])).toList(),
                ),
    );
  }

  Widget _buildProductTable(String category) {
    List<Map<String, dynamic>> filteredProducts = _products.where((product) => product['category'] == category).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Sub-Category')),
          DataColumn(label: Text('Product')),
          DataColumn(label: Text('Size')),
          DataColumn(label: Text('Price')),
          DataColumn(label: Text('Image')), // Added Image column
        ],
        rows: filteredProducts.expand((product) {
          List<Map<String, dynamic>> sizes = product['sizes'] ?? [];
          return sizes.map((size) {
            return DataRow(cells: [
              DataCell(Text(product['sub_category_id'].toString())),
              DataCell(Text(product['name'])),
              DataCell(Text(size['name'])),
              DataCell(Text('\$${size['price']}')),
              DataCell(Image.asset(product['image'] ?? 'assets/logo.png')), // Use default image if none provided
            ]);
          }).toList();
        }).toList(),
      ),
    );
  }
}

