import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import ImagePicker
import 'db_helper.dart'; // Import DBHelper
import 'dart:io'; // Import dart:io for File
import 'components/category_list.dart'; // Import CategoryList
import 'components/sub_category_list.dart'; // Import SubCategoryList
import 'components/product_list.dart'; // Import ProductList
import 'components/size_list.dart'; // Import SizeList

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

class ProductManagementState extends State<ProductManagement>
    with SingleTickerProviderStateMixin {
  final DBHelper _dbHelper = DBHelper();
  final ImagePicker _picker = ImagePicker(); // Initialize ImagePicker
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _subCategories = [];
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _addIns = [];
  List<Map<String, dynamic>> _sizes = []; // Add sizes list
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
    ); // Update length to 5
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDatabase();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeDatabase() async {
    await _dbHelper.createAndSaveProductTables();
    _fetchData(); // Fetch data after initializing the database
  }

  Future<void> _fetchData() async {
    final categories = await _dbHelper.getCategories();
    final subCategories = await _dbHelper.getSubCategories();
    final products = await _dbHelper.fetchAllProducts();
    final addIns = await _dbHelper.getAddIns();
    final sizes = await _dbHelper.getAllSizes(); // Fetch sizes for all products

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

    final updatedAddIns = await Future.wait(
      addIns.map((addIn) async {
        final parentProduct = await _dbHelper.fetchProductById(
          addIn['product_id']!,
        );
        return {
          ...addIn,
          'parent_product': parentProduct?['name'] ?? 'Unknown',
        };
      }).toList(),
    );

    if (mounted) {
      setState(() {
        _categories = categories;
        _subCategories = updatedSubCategories;
        _products = updatedProducts;
        _addIns = updatedAddIns;
        _sizes = sizes; // Update sizes list
      });
    }
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

    if (result == true && mounted) {
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
                  if (mounted) {
                    setState(() {}); // Update UI to show new image
                  }
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
                  if (mounted) {
                    setState(() {}); // Update UI to show new image
                  }
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

  void _addAddIn() async {
    String addInName = '';
    int? selectedProductId;
    double? price;
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Add-In'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Add-In Name'),
                onChanged: (value) {
                  addInName = value;
                },
              ),
              DropdownButtonFormField<int>(
                value: selectedProductId,
                items:
                    _products.map((product) {
                      return DropdownMenuItem<int>(
                        value: product['id'],
                        child: Text(product['name']),
                      );
                    }).toList(),
                onChanged: (value) {
                  selectedProductId = value;
                },
                decoration: const InputDecoration(labelText: 'Parent Product'),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  price = double.tryParse(value);
                },
              ),
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
      await _dbHelper.insertAddIn({
        'name': addInName,
        'product_id': selectedProductId,
        'price': price,
      });
      _fetchData(); // Ensure data is fetched after adding
    }
  }

  void _showEditDialog(Map<String, dynamic> item, String type) async {
    String newName = item['name'];
    int? selectedCategoryId =
        type == 'subcategory' ? item['category_id'] : null;
    int? selectedProductId = type == 'add-in' ? item['product_id'] : null;
    double? price = type == 'add-in' ? item['price'] : null;
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
              if (type == 'add-in')
                DropdownButtonFormField<int>(
                  value: selectedProductId,
                  items:
                      _products.map((product) {
                        return DropdownMenuItem<int>(
                          value: product['id'],
                          child: Text(product['name']),
                        );
                      }).toList(),
                  onChanged: (value) => selectedProductId = value,
                  decoration: const InputDecoration(
                    labelText: 'Parent Product',
                  ),
                ),
              if (type == 'add-in')
                TextField(
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: price?.toString()),
                  onChanged: (value) => price = double.tryParse(value),
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
                    if (mounted) {
                      setState(() {}); // Update UI to show new image
                    }
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
        case 'add-in':
          await _dbHelper.updateAddIn({
            'id': item['id'],
            'name': newName,
            'product_id': item['product_id'],
            'price': item['price'],
          });
          break;
        case 'size':
          String newSize = item['size'] ?? '';
          double? newPrice = item['price'];
          final result = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Edit Size'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: 'Size'),
                      controller: TextEditingController(text: newSize),
                      onChanged: (value) => newSize = value,
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(
                        text: newPrice?.toString(),
                      ),
                      onChanged: (value) => newPrice = double.tryParse(value),
                    ),
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
            await _dbHelper.updateSize(item['id'], {
              'size': newSize,
              'price': newPrice,
              'product_id': item['product_id'], // Ensure product_id is included
            });
            _fetchData();
          }
          break;
      }
      _fetchData();
    }
    _fetchData();
  }

  void _deleteSize(int sizeId) async {
    await _dbHelper.deleteSize(sizeId);
    await _fetchData(); // Ensure data is fetched after deletion
  }

  void _addSize() async {
    String sizeName = '';
    double? price;
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Size'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Size Name'),
                onChanged: (value) {
                  sizeName = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  price = double.tryParse(value);
                },
              ),
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
      await _dbHelper.insertSize({'size': sizeName, 'price': price});
      _fetchData();
    }
  }

  void _showProductDetails(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(product['name']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (product['image'] != null)
                Image.file(File(product['image']), width: 100, height: 100),
              Text('Category: ${product['parent_category']}'),
              Text('Sub-Category: ${product['sub_category']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Management'),
        automaticallyImplyLeading: false, // Remove the back button
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Categories'),
            Tab(text: 'Sub-Categories'),
            Tab(text: 'Products'),
            Tab(text: 'Add-Ins'),
            Tab(text: 'Sizes'), // Add Sizes tab
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return TabBarView(
            controller: _tabController,
            children: [
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Add this line
                    children: [
                      CategoryList(
                        categories: _categories,
                        onEdit: (item) => _showEditDialog(item, 'category'),
                        onDelete: _deleteCategory,
                        itemBuilder:
                            (context, item) => ListTile(
                              title: Text(item['name']),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed:
                                        () => _showEditDialog(item, 'category'),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed:
                                        () => _deleteCategory(item['id']),
                                  ),
                                ],
                              ),
                            ),
                      ),
                      ElevatedButton(
                        onPressed: _addCategory,
                        child: Text('Add Category'),
                      ),
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Add this line
                    children: [
                      SubCategoryList(
                        subCategories: _subCategories,
                        onEdit: (item) => _showEditDialog(item, 'subcategory'),
                        onDelete: _deleteSubCategory,
                        itemBuilder:
                            (context, item) => ListTile(
                              title: Text(item['name']),
                              subtitle: Text(
                                'Parent Category: ${item['parent_category']}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed:
                                        () => _showEditDialog(
                                          item,
                                          'subcategory',
                                        ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed:
                                        () => _deleteSubCategory(item['id']),
                                  ),
                                ],
                              ),
                            ),
                      ),
                      ElevatedButton(
                        onPressed: _addSubCategory,
                        child: Text('Add Sub-Category'),
                      ),
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Add this line
                    children: [
                      ProductList(
                        products: _products,
                        onEdit: (item, _) {
                          _showEditDialog(item, 'product');
                        },
                        onDelete: _deleteProduct,
                        onViewDetails:
                            _showProductDetails, // Add onViewDetails callback
                        itemBuilder:
                            (context, item) => ListTile(
                              title: Text(item['name']),
                              subtitle: Text(
                                'Sub-Category: ${item['sub_category']}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed:
                                        () => _showEditDialog(item, 'product'),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => _deleteProduct(item['id']),
                                  ),
                                ],
                              ),
                              onTap: () => _showProductDetails(item),
                            ),
                      ),
                      ElevatedButton(
                        onPressed: _addProduct,
                        child: Text('Add Product'),
                      ),
                    ],
                  ),
                ),
              ),
              ListView.builder(
                itemCount: _addIns.length,
                itemBuilder: (context, index) {
                  final addIn = _addIns[index];
                  return ListTile(
                    title: Text(addIn['name']),
                    subtitle: Text('Price: \$${addIn['price']}'),
                    trailing: Text(
                      'Parent Product: ${addIn['parent_product']}',
                    ),
                  );
                },
              ),
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Add this line
                    children: [
                      SizesList(
                        // productId: 1, // Provide a valid productId
                        sizesList: _sizes,
                        onEdit: (item) => _showEditDialog(item, 'size'),
                        onDelete: (id) => _deleteSize(id),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _addCategory();
          } else if (_tabController.index == 1) {
            _addSubCategory();
          } else if (_tabController.index == 2) {
            _addProduct();
          } else if (_tabController.index == 3) {
            _addAddIn();
          } else if (_tabController.index == 4) {
            _addSize(); // Add this line to handle adding sizes
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
