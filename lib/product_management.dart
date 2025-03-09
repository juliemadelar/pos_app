import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import ImagePicker
import 'db_helper.dart'; // Import DBHelper
import 'package:flutter_bootstrap/flutter_bootstrap.dart'; // Import Bootstrap
import 'dart:io'; // Import dart:io for File
import 'components/category_list.dart'; // Import CategoryList
import 'components/sub_category_list.dart'; // Import SubCategoryList
import 'components/product_list.dart'; // Import ProductList

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

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
        return {
          ...product,
          'sub_category': subCategory['name'] ?? 'Unknown',
          'parent_category': parentCategory['name'] ?? 'Unknown',
        };
      }).toList(),
    );

    setState(() {
      _categories = categories;
      _subCategories = updatedSubCategories;
      _products = updatedProducts;
    });
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

  void _addSubCategory() async {
    String subCategoryName = '';
    int? selectedCategoryId;
    String? imagePath;
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Sub-Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Sub-Category Name',
                ),
                onChanged: (value) {
                  subCategoryName = value;
                },
              ),
              DropdownButtonFormField<int>(
                value: selectedCategoryId,
                items:
                    _categories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category['id'],
                        child: Text(category['name']),
                      );
                    }).toList(),
                onChanged: (value) {
                  selectedCategoryId = value;
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

    if (result == true) {
      await _dbHelper.insertSubCategory({
        'name': subCategoryName,
        'category_id': selectedCategoryId,
        'image': imagePath,
      });
      _fetchData();
    }
  }

  void _deleteSubCategory(int subCategoryId) async {
    await _dbHelper.deleteSubCategory(subCategoryId);
    await _fetchData(); // Ensure data is fetched after deletion
  }

  void _addProduct() async {
    String productName = '';
    int? selectedSubCategoryId;
    String? imagePath;
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Product Name'),
                onChanged: (value) {
                  productName = value;
                },
              ),
              DropdownButtonFormField<int>(
                value: selectedSubCategoryId,
                items:
                    _subCategories.map((subCategory) {
                      return DropdownMenuItem<int>(
                        value: subCategory['id'],
                        child: Text(subCategory['name']),
                      );
                    }).toList(),
                onChanged: (value) {
                  selectedSubCategoryId = value;
                },
                decoration: const InputDecoration(labelText: 'Sub-Category'),
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

    if (result == true) {
      await _dbHelper.insertProduct({
        'name': productName,
        'sub_category_id': selectedSubCategoryId,
        'image': imagePath,
      });
      _fetchData();
    }
  }

  void _deleteProduct(int productId) async {
    await _dbHelper.deleteProduct(productId);
    await _fetchData(); // Ensure data is fetched after deletion
  }

  void _showEditDialog(Map<String, dynamic> item, String type) async {
    String newName = item['name'];
    int? selectedCategoryId =
        type == 'subcategory' ? item['category_id'] : null;
    String? imagePath = type == 'subcategory' ? item['image'] : null;

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit ${type.capitalize()}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: '${type.capitalize()} Name',
                ),
                controller: TextEditingController(text: newName),
                onChanged: (value) => newName = value,
              ),
              if (type == 'subcategory')
                DropdownButtonFormField<int>(
                  value: selectedCategoryId,
                  items:
                      _categories.map((category) {
                        return DropdownMenuItem<int>(
                          value: category['id'],
                          child: Text(category['name']),
                        );
                      }).toList(),
                  onChanged: (value) => selectedCategoryId = value,
                  decoration: const InputDecoration(
                    labelText: 'Parent Category',
                  ),
                ),
              if (type == 'subcategory')
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

    if (result == true) {
      switch (type) {
        case 'category':
          await _dbHelper.updateCategory({'id': item['id'], 'name': newName});
          break;
        case 'subcategory':
          await _dbHelper.updateSubCategory({
            'id': item['id'],
            'name': newName,
            'category_id': selectedCategoryId,
            'image': imagePath,
          });
          break;
        case 'product':
          await _dbHelper.updateProduct({'id': item['id'], 'name': newName});
          break;
      }
      _fetchData();
    }
    _fetchData();
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
                      CategoryList(
                        categories: _categories,
                        onEdit: (item) => _showEditDialog(item, 'category'),
                        onDelete: _deleteCategory,
                      ),
                      ElevatedButton(
                        onPressed: _addCategory,
                        child: Text('Add Category'),
                      ),
                    ],
                  ),
                ),
                BootstrapCol(
                  sizes: 'col-12',
                  child: Column(
                    children: [
                      SubCategoryList(
                        subCategories: _subCategories,
                        onEdit: (item) => _showEditDialog(item, 'subcategory'),
                        onDelete: _deleteSubCategory,
                      ),
                      ElevatedButton(
                        onPressed: _addSubCategory,
                        child: Text('Add Sub-Category'),
                      ),
                    ],
                  ),
                ),
                BootstrapCol(
                  sizes: 'col-12',
                  child: Column(
                    children: [
                      ProductList(
                        products: _products,
                        onEdit: (item, _) => _showEditDialog(item, 'product'),
                        onDelete: _deleteProduct,
                      ),
                      ElevatedButton(
                        onPressed: _addProduct,
                        child: Text('Add Product'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
