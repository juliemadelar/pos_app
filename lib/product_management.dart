import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import ImagePicker
import 'db_helper.dart'; // Import DBHelper
import 'package:flutter_bootstrap/flutter_bootstrap.dart'; // Import Bootstrap
import 'dart:io'; // Import dart:io for File

class ProductManagement extends StatefulWidget {
  const ProductManagement({super.key}); // Add named 'key' parameter

  @override
  ProductManagementState createState() => ProductManagementState();
}

class ProductManagementState extends State<ProductManagement> {
  final DBHelper _dbHelper = DBHelper();
  final ImagePicker _picker = ImagePicker(); // Initialize ImagePicker
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _subCategories = [];
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    await _dbHelper.createAndSaveProductTables();
    _fetchData(); // Fetch data after initializing the database
  }

  Future<void> _fetchData() async {
    final categories = await _dbHelper.getCategories();
    final subCategories = await _dbHelper.getSubCategories();
    final products = await _dbHelper.fetchAllProducts();

    setState(() {
      _categories = categories;
      _subCategories =
          subCategories.map((subCategory) {
            final parentCategory = categories.firstWhere(
              (category) => category['id'] == subCategory['parent_id'],
              orElse: () => {'name': 'Unknown'},
            );
            return {...subCategory, 'parent_category': parentCategory['name']};
          }).toList();
      _products = products;
    });
  }

  void _editItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedCategory =
            item['parent_category'] != 'Unknown'
                ? item['parent_category']
                : null;
        String? imagePath = item['image'];
        return AlertDialog(
          title: Text('Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
                controller: TextEditingController(text: item['name']),
                onChanged: (value) {
                  item['name'] = value;
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items:
                    _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category['name'],
                        child: Text(category['name']),
                      );
                    }).toList(),
                onChanged: (value) {
                  selectedCategory = value;
                },
                decoration: InputDecoration(labelText: 'Parent Category'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final pickedFile = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      imagePath = pickedFile.path;
                    });
                  }
                },
                child: Text('Pick Image'),
              ),
              if (imagePath != null)
                Image.file(File(imagePath!), width: 100, height: 100),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  item['parent_category'] = selectedCategory;
                  item['image'] = imagePath;
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: BootstrapContainer(
          fluid: true,
          children: [
            BootstrapRow(
              children: [
                BootstrapCol(
                  sizes: 'col-12',
                  child: _buildList('Categories', _categories),
                ),
                BootstrapCol(
                  sizes: 'col-12',
                  child: _buildList('Sub-Categories', _subCategories),
                ),
                BootstrapCol(
                  sizes: 'col-12',
                  child: _buildList('Products', _products),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(String title, List<Map<String, dynamic>> items) {
    return ExpansionTile(
      title: Text(title),
      children:
          items.map((item) {
            return ListTile(
              leading:
                  item.containsKey('image')
                      ? Image.file(
                        File(item['image']),
                        width: 200,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/placeholder.png', // Replace with your placeholder image
                            width: 200,
                          );
                        },
                      )
                      : null,
              title: Text(item['name']),
              subtitle:
                  item.containsKey('parent_category')
                      ? Text('Parent Category: ${item['parent_category']}')
                      : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _editItem(item);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      // Handle delete action
                    },
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
