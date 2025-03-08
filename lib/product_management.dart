import 'package:flutter/material.dart';
import 'db_helper.dart';
<<<<<<< HEAD
import 'dart:io'; // Import dart:io for File
import 'package:image_picker/image_picker.dart'; // Add this import
import 'package:logging/logging.dart'; // Add logging import
=======
>>>>>>> 1965fe9401bb27d4ae63f0637ac354a6032385ea

class ProductManagement extends StatefulWidget {
  const ProductManagement({super.key}); // Convert key to super parameter
  @override
  ProductManagementState createState() => ProductManagementState();
}

<<<<<<< HEAD
class ProductManagementState extends State<ProductManagement>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _subCategories = [];
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _sizes = [];
  List<Map<String, dynamic>> _addIns = [];
  final Logger _logger = Logger('ProductManagement'); // Initialize logger
=======
class ProductManagementState extends State<ProductManagement> with SingleTickerProviderStateMixin {
  final dbHelper = DBHelper();
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  late TabController _tabController;
>>>>>>> 1965fe9401bb27d4ae63f0637ac354a6032385ea

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _tabController = TabController(
      length: 5,
      vsync: this,
    ); // Ensure length matches the number of tabs and children
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      _categories = await _dbHelper.getCategories();
      _subCategories = await _dbHelper.getSubCategories();
      _products = await _dbHelper.getProducts();
      _sizes = await _dbHelper.getSizes();
      _addIns = await _dbHelper.getAddIns();
      setState(() {});
    } catch (e) {
      _logger.severe('Error loading data: $e'); // Use logger instead of print
    }
  }

  Future<void> _editCategory(int id, String newName) async {
    await _dbHelper.updateCategory({'id': id, 'name': newName});
    _loadData();
  }

  Future<void> _deleteCategory(int id) async {
    await _dbHelper.deleteCategory(id);
    _loadData();
  }

  Future<void> _editSubCategory(int id, String newName, String newImage) async {
    await _dbHelper.updateSubCategory({
      'id': id,
      'name': newName,
      'image': newImage.isNotEmpty ? newImage : 'assets/logo.png',
    });
    _loadData();
  }

  Future<void> _deleteSubCategory(int id) async {
    await _dbHelper.deleteSubCategory(id);
    _loadData();
  }

  Future<void> _editProduct(int id, String newName, String newImage) async {
    await _dbHelper.updateProduct({
      'id': id,
      'name': newName,
      'image': newImage.isNotEmpty ? newImage : 'assets/logo.png',
    });
    _loadData();
  }

  Future<void> _deleteProduct(int id) async {
    await _dbHelper.deleteProduct(id);
    _loadData();
  }

  Future<void> _editSize(int id, String newName, double newPrice) async {
    await _dbHelper.updateSize({'id': id, 'name': newName, 'price': newPrice});
    _loadData();
  }

  Future<void> _deleteSize(int id) async {
    await _dbHelper.deleteSize(id);
    _loadData();
  }

  Future<void> _editAddIn(int id, String newName, double newPrice) async {
    await _dbHelper.updateAddIn({'id': id, 'name': newName, 'price': newPrice});
    _loadData();
  }

  Future<void> _deleteAddIn(int id) async {
    await _dbHelper.deleteAddIn(id);
    _loadData();
  }

  void _showEditDialog(
    String title,
    String initialValue,
    Function(String, String) onSave, {
    bool isSubCategory = false,
    bool isProduct = false,
    String? initialImage,
  }) {
    TextEditingController controller = TextEditingController(
      // Renamed _controller to controller
      text: initialValue,
    );
    String? imagePath = initialImage; // Renamed _imagePath to imagePath
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            // Wrap with SingleChildScrollView
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller, // Updated reference
                  decoration: InputDecoration(labelText: 'New Value'),
                ),
                if (isSubCategory || isProduct) ...[
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final pickedFile = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      if (pickedFile != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            imagePath = pickedFile.path; // Updated reference
                          });
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Selected image: ${pickedFile.path}',
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: Text('Pick Image'),
                  ),
                  if (imagePath != null &&
                      File(imagePath!).existsSync()) // Updated reference
                    Image.file(File(imagePath!)) // Updated reference
                  else
                    Image.asset('assets/logo.png'),
                ],
              ],
            ),
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
                onSave(
                  controller.text,
                  imagePath ?? 'assets/logo.png',
                ); // Updated reference
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAddInDialog(
    String title,
    String initialName,
    double initialPrice,
    int initialProductId,
    Function(String, double, int) onSave,
  ) {
    TextEditingController nameController = TextEditingController(
      text: initialName,
    );
    TextEditingController priceController = TextEditingController(
      text: initialPrice.toString(),
    );
    int selectedProductId = initialProductId;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              DropdownButton<int>(
                value: selectedProductId,
                onChanged: (int? newValue) {
                  setState(() {
                    selectedProductId = newValue!;
                  });
                },
                items:
                    _products.map<DropdownMenuItem<int>>((product) {
                      return DropdownMenuItem<int>(
                        value: product['id'],
                        child: Text(product['name']),
                      );
                    }).toList(),
              ),
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
                onSave(
                  nameController.text,
                  double.parse(priceController.text),
                  selectedProductId,
                );
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showSizeDialog(
    String title,
    String initialName,
    double initialPrice,
    int initialProductId,
    Function(String, double, int) onSave,
  ) {
    TextEditingController nameController = TextEditingController(
      text: initialName,
    );
    TextEditingController priceController = TextEditingController(
      text: initialPrice.toString(),
    );
    int selectedProductId = initialProductId;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              DropdownButton<int>(
                value: selectedProductId,
                onChanged: (int? newValue) {
                  setState(() {
                    selectedProductId = newValue!;
                  });
                },
                items:
                    _products.map<DropdownMenuItem<int>>((product) {
                      return DropdownMenuItem<int>(
                        value: product['id'],
                        child: Text(product['name']),
                      );
                    }).toList(),
              ),
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
                onSave(
                  nameController.text,
                  double.parse(priceController.text),
                  selectedProductId,
                );
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
=======
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
>>>>>>> 1965fe9401bb27d4ae63f0637ac354a6032385ea
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      body: Column(
        children: [
          Scaffold(
            appBar: AppBar(
              title: Text('Product Management'),
              automaticallyImplyLeading:
                  false, // This line removes the back button
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'Categories'),
                  Tab(text: 'Sub-Categories'), // Added Sub-Categories tab
                  Tab(text: 'Products'),
                  Tab(text: 'Sizes'),
                  Tab(text: 'Add-Ins'),
                ],
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCategoriesTab(),
                  _buildSubCategoriesTab(), // Added Sub-Categories tab content
                  _buildProductsTab(),
                  _buildSizesTab(),
                  _buildAddInsTab(),
                ],
              ),
            ),
          ),
        ],
=======
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
>>>>>>> 1965fe9401bb27d4ae63f0637ac354a6032385ea
      ),
    );
  }
}

<<<<<<< HEAD
  Widget _buildCategoriesTab() {
    return Column(
      children: [
        SizedBox(
          width: 500,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Category Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(
                  'Actions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              return Container(
                width: 500,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: ListTile(
                  title: Text(_categories[index]['name']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditDialog(
                            'Edit Category',
                            _categories[index]['name'],
                            (newName, _) => _editCategory(
                              _categories[index]['id'],
                              newName,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteCategory(_categories[index]['id']);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // Add category logic
          },
          child: Text('Add Category'),
        ),
      ],
    );
  }

  Widget _buildSubCategoriesTab() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                'Sub-Category Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: 300,
              child: Text(
                'Image',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Actions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _subCategories.length,
            itemBuilder: (context, index) {
              final subCategory = _subCategories[index];
              final category = _categories.firstWhere(
                (category) => category['id'] == subCategory['category_id'],
              );
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(category['name']),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(subCategory['name']),
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: Image.file(
                        File(subCategory['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _showEditDialog(
                                'Edit Sub-Category',
                                subCategory['name'],
                                (newName, newImage) => _editSubCategory(
                                  subCategory['id'],
                                  newName,
                                  newImage,
                                ),
                                isSubCategory: true,
                                initialImage: subCategory['image'],
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteSubCategory(subCategory['id']);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // Add sub-category logic
          },
          child: Text('Add Sub-Category'),
        ),
      ],
    );
  }

  Widget _buildProductsTab() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'Product Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: 300,
              child: Text(
                'Image',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Sub-Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Actions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _products.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_products[index]['name']),
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: Image.file(
                        File(_products[index]['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _subCategories.firstWhere(
                            (subCategory) =>
                                subCategory['id'] ==
                                _products[index]['sub_category_id'],
                          )['name'],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _showEditDialog(
                                'Edit Product',
                                _products[index]['name'],
                                (newName, newImage) => _editProduct(
                                  _products[index]['id'],
                                  newName,
                                  newImage,
                                ),
                                isProduct: true,
                                initialImage: _products[index]['image'],
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteProduct(_products[index]['id']);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // Add product logic
          },
          child: Text('Add Product'),
        ),
      ],
    );
  }

  Widget _buildAddInsTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _addIns.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: ListTile(
                  title: Text(_addIns[index]['name']),
                  subtitle: Text(
                    'Product: ${_products.firstWhere((product) => product['id'] == _addIns[index]['product_id'])['name']}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showAddInDialog(
                            'Edit Add-In',
                            _addIns[index]['name'],
                            _addIns[index]['price'],
                            _addIns[index]['product_id'],
                            (newName, newPrice, newProductId) => _editAddIn(
                              _addIns[index]['id'],
                              newName,
                              newPrice,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteAddIn(_addIns[index]['id']);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _showAddInDialog(
              'Add Add-In',
              '',
              0.0,
              _products.isNotEmpty ? _products.first['id'] : 0,
              (name, price, productId) => _addAddIn(name, price, productId),
            );
          },
          child: Text('Add Add-In'),
        ),
      ],
    );
  }

  Widget _buildSizesTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _sizes.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: ListTile(
                  title: Text(_sizes[index]['name']),
                  subtitle: Text(
                    'Product: ${_products.firstWhere((product) => product['id'] == _sizes[index]['product_id'])['name']}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showSizeDialog(
                            'Edit Size',
                            _sizes[index]['name'],
                            _sizes[index]['price'],
                            _sizes[index]['product_id'],
                            (newName, newPrice, newProductId) => _editSize(
                              _sizes[index]['id'],
                              newName,
                              newPrice,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteSize(_sizes[index]['id']);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _showSizeDialog(
              'Add Size',
              '',
              0.0,
              _products.isNotEmpty ? _products.first['id'] : 0,
              (name, price, productId) => _addSize(name, price, productId),
            );
          },
          child: Text('Add Size'),
        ),
      ],
    );
  }

  Future<void> _addAddIn(String name, double price, int productId) async {
    await _dbHelper.insertAddIn({
      'name': name,
      'price': price,
      'product_id': productId,
    });
    _loadData();
  }

  // Removed duplicate _editAddIn method

  Future<void> _addSize(String name, double price, int productId) async {
    await _dbHelper.insertSize({
      'name': name,
      'price': price,
      'product_id': productId,
    });
    _loadData();
  }
}
=======
>>>>>>> 1965fe9401bb27d4ae63f0637ac354a6032385ea
