import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ProductManagement extends StatefulWidget {
  const ProductManagement({super.key});

  @override
  ProductManagementState createState() => ProductManagementState();
}

class ProductManagementState extends State<ProductManagement> {
  List<String> categories = [];
  Database? _database;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'product_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE categories(id INTEGER PRIMARY KEY, name TEXT)',
        );
      },
      version: 1,
    );
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final List<Map<String, dynamic>> maps = await _database!.query(
        'categories',
      );

      // Convert the List<Map<String, dynamic>> into a List<String>
      List<String> fetchedCategories = List.generate(maps.length, (i) {
        return maps[i]['name'];
      });

      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      if (e is UnsupportedError) {
        print('Error querying categories: ${e.message}');
      } else {
        rethrow;
      }
    }
  }

  Future<void> fetchSizesForProduct(int productId) async {
    try {
      // Query sizes for the product
    } catch (e) {
      if (e is UnsupportedError) {
        print('Error querying sizes for product ID $productId: ${e.message}');
      } else {
        rethrow;
      }
    }
  }

  Future<void> fetchAddInsForProduct(int productId) async {
    try {
      // Query add-ins for the product
    } catch (e) {
      if (e is UnsupportedError) {
        print('Error querying add-ins for product ID $productId: ${e.message}');
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
        appBar: AppBar(
          title: Text('Product Management'),
          automaticallyImplyLeading: false, // Remove the back button
          bottom:
              categories.isNotEmpty
                  ? TabBar(
                    tabs:
                        categories
                            .map((category) => Tab(text: category))
                            .toList(),
                  )
                  : null,
        ),
        body:
            categories.isNotEmpty
                ? TabBarView(
                  children:
                      categories
                          .map(
                            (category) =>
                                Center(child: Text('$category Content')),
                          )
                          .toList(),
                )
                : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
