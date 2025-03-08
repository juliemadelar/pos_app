import 'package:flutter/material.dart';
import 'db_helper.dart'; // Import DBHelper
import 'package:logging/logging.dart';

class ProductManagement extends StatefulWidget {
  const ProductManagement({super.key});

  @override
  ProductManagementState createState() => ProductManagementState();
}

class ProductManagementState extends State<ProductManagement> {
  List<Map<String, dynamic>> categories = [];
  Map<String, List<Map<String, dynamic>>> subCategories = {};
  Map<String, List<Map<String, dynamic>>> products = {};
  final DBHelper _dbHelper = DBHelper(); // Instance of DBHelper
  final Logger _logger = Logger('ProductManagement');

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _dbHelper.initializeDatabase();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final List<Map<String, dynamic>> fetchedCategories =
          await _dbHelper.getCategories();

      setState(() {
        categories = fetchedCategories;
      });

      for (var category in categories) {
        fetchSubCategories(category['name']);
      }
    } catch (e) {
      if (e is UnsupportedError) {
        _logger.severe('Error querying categories: ${e.message}');
      } else {
        rethrow;
      }
    }
  }

  Future<void> fetchSubCategories(String category) async {
    try {
      final List<Map<String, dynamic>> fetchedSubCategories =
          await _dbHelper.getSubCategories();

      setState(() {
        subCategories[category] = fetchedSubCategories;
      });

      for (var subCategory in fetchedSubCategories) {
        fetchProducts(category, subCategory['name']);
      }
    } catch (e) {
      if (e is UnsupportedError) {
        _logger.severe(
          'Error querying sub-categories for category $category: ${e.message}',
        );
      } else {
        rethrow;
      }
    }
  }

  Future<void> fetchProducts(String category, String subCategory) async {
    try {
      final List<Map<String, dynamic>> fetchedProducts = await _dbHelper
          .getProducts(category, subCategory);

      setState(() {
        products[subCategory] = fetchedProducts;
      });
    } catch (e) {
      if (e is UnsupportedError) {
        _logger.severe(
          'Error querying products for sub-category $subCategory: ${e.message}',
        );
      } else {
        rethrow;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        body:
            categories.isNotEmpty
                ? TabBarView(
                  children:
                      categories.map((category) {
                        return Column(
                          children: [
                            Text('${category['name']} Content'),
                            Expanded(
                              child: ListView.builder(
                                itemCount:
                                    subCategories[category['name']]?.length ??
                                    0,
                                itemBuilder: (context, index) {
                                  var subCategory =
                                      subCategories[category['name']]![index];
                                  return ExpansionTile(
                                    title: Text(subCategory['name']),
                                    children:
                                        products[subCategory['name']]?.map((
                                          product,
                                        ) {
                                          return ListTile(
                                            title: Text(product['name']),
                                          );
                                        }).toList() ??
                                        [],
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                )
                : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
