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
  Map<String, dynamic>? _itemBeingEdited; // Track the item being edited

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

    final updatedSubCategories = await Future.wait(
      subCategories.map((subCategory) async {
        final parentCategory = await _dbHelper.fetchCategoryById(
          subCategory['category_id'],
        );
        return {
          ...subCategory,
          'parent_category': parentCategory['name'] ?? 'Unknown',
        };
      }).toList(),
    );

    final updatedProducts = await Future.wait(
      products.map((product) async {
        final subCategory = await _dbHelper.fetchSubCategoryById(
          product['sub_category_id'],
        );
        final parentCategory = await _dbHelper.fetchCategoryById(
          subCategory['category_id'],
        );
        String parentCategoryName = parentCategory['name'] ?? 'Unknown';
        String subCategoryName = subCategory['name'] ?? 'Unknown';

        return {
          ...product,
          'parent_category': parentCategoryName,
          'sub_category': subCategoryName,
        };
      }).toList(),
    );

    setState(() {
      _categories = categories;
      _subCategories = updatedSubCategories;
      _products = updatedProducts;
    });
  }

  Future<void> _showEditDialog(Map<String, dynamic> item) async {
    _itemBeingEdited = item; // Store item for later update
    String? selectedCategory =
        item['parent_category'] != 'Unknown' ? item['parent_category'] : null;
    String? imagePath = item['image'];
    final nameController = TextEditingController(text: item['name']);

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
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
                decoration: const InputDecoration(labelText: 'Parent Category'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final pickedFile = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    imagePath = pickedFile.path;
                  }
                  setState(() {}); // Update UI to show new image
                },
                child: const Text('Pick Image'),
              ),
              if (imagePath != null)
                Image.file(File(imagePath!), width: 100, height: 100),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == true && mounted) {
      // Check if widget is still mounted
      setState(() {
        _itemBeingEdited!['name'] = nameController.text;
        _itemBeingEdited!['parent_category'] = selectedCategory;
        _itemBeingEdited!['image'] = imagePath;
        _itemBeingEdited = null; // Clear the edited item
      });
    }
    nameController.dispose();
  }

  void _addCategory() async {
    String categoryName = '';
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Category'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Category Name'),
            onChanged: (value) {
              categoryName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _dbHelper.insertCategory({'name': categoryName});
      _fetchData();
    }
  }

  void _deleteCategory(int categoryId) async {
    await _dbHelper.deleteCategory(categoryId);
    await _fetchData(); // Ensure data is fetched after deletion
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
                  child: Column(
                    children: [
                      _buildList('Categories', _categories),
                      ElevatedButton(
                        onPressed: _addCategory,
                        child: Text('Add Category'),
                      ),
                    ],
                  ),
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
              subtitle: Text(
                '${item.containsKey('parent_category') ? 'Parent Category: ${item['parent_category']}\n' : ''}${item.containsKey('sub_category') ? 'Sub Category: ${item['sub_category']}' : ''}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditDialog(item),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      if (title == 'Categories') {
                        _deleteCategory(item['id']);
                      } else {
                        // Handle delete action for sub-categories and products
                      }
                    },
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
