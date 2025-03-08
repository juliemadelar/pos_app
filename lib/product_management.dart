import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:logging/logging.dart';

class ProductManagement extends StatefulWidget {
  const ProductManagement({super.key});

  @override
  ProductManagementState createState() => ProductManagementState();
}

class ProductManagementState extends State<ProductManagement> {
  List<String> categories = [];
  Map<String, List<String>> subCategories = {};
  Map<String, List<String>> products = {};
  Database? _database;
  final Logger _logger = Logger('ProductManagement');

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

      for (String category in categories) {
        fetchSubCategories(category);
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
      // Query sub-categories for the category
      final List<Map<String, dynamic>> maps = await _database!.query(
        'sub_categories',
        where: 'category = ?',
        whereArgs: [category],
      );

      List<String> fetchedSubCategories = List.generate(maps.length, (i) {
        return maps[i]['name'];
      });

      setState(() {
        subCategories[category] = fetchedSubCategories;
      });

      for (String subCategory in fetchedSubCategories) {
        fetchProducts(subCategory);
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

  Future<void> fetchProducts(String subCategory) async {
    try {
      // Query products for the sub-category
      final List<Map<String, dynamic>> maps = await _database!.query(
        'products',
        where: 'sub_category = ?',
        whereArgs: [subCategory],
      );

      List<String> fetchedProducts = List.generate(maps.length, (i) {
        return maps[i]['name'];
      });

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
                            Text('$category Content'),
                            Expanded(
                              child: ListView.builder(
                                itemCount: subCategories[category]?.length ?? 0,
                                itemBuilder: (context, index) {
                                  String subCategory =
                                      subCategories[category]![index];
                                  return ExpansionTile(
                                    title: Text(subCategory),
                                    children:
                                        products[subCategory]?.map((product) {
                                          return ListTile(title: Text(product));
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
