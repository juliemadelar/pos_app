import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SizesList extends StatefulWidget {
  const SizesList({super.key});

  @override
  SizesListState createState() => SizesListState();
}

class SizesListState extends State<SizesList> {
  List<Map<String, dynamic>> _sizes = [];

  @override
  void initState() {
    super.initState();
    _fetchSizes();
  }

  Future<void> _fetchSizes() async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'product_database.db'),
    );

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('sizes');

    final updatedSizes = await Future.wait(
      maps.map((size) async {
        final parentProduct = await db.query(
          'products',
          where: 'id = ?',
          whereArgs: [size['product_id']],
        );
        return {
          ...size,
          'parent_product':
              parentProduct.isNotEmpty
                  ? parentProduct.first['name']
                  : 'Unknown',
          'price': size['price'], // Include price
        };
      }).toList(),
    );

    setState(() {
      _sizes = updatedSizes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar removed
      body: ListView.builder(
        itemCount: _sizes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_sizes[index]['size'] ?? 'Unknown Size'),
            subtitle: Text(
              'Parent Product: ${_sizes[index]['parent_product'] ?? 'Unknown'}\nPrice: \$${_sizes[index]['price']}', // Include price
            ),
          );
        },
      ),
    );
  }
}
