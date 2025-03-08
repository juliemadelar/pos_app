// ignore_for_file: unused_local_variable, unused_element

import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'login_page.dart'; // Import login page
import 'dart:io'; // Import dart:io for File
import 'package:intl/intl.dart'; // Import for date and time formatting
import 'package:logging/logging.dart'; // Import logging package

class CashierDashboard extends StatefulWidget {
  const CashierDashboard({super.key}); // Convert 'key' to a super parameter
  @override
  CashierDashboardState createState() => CashierDashboardState(); // Make the type public
}

class CashierDashboardState extends State<CashierDashboard> {
  // Make the type public
  // Add unnamed constructor
  CashierDashboardState() {
    // Initialization code if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back button
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Corner
            Row(
              children: [
                businessLogoPath.isNotEmpty
                    ? Image.file(
                      File(businessLogoPath), // Business logo
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.error,
                        ); // Show error icon if image fails to load
                      },
                    )
                    : Image.asset(
                      'assets/logo.png', // Default logo
                      height: 100,
                    ),
                SizedBox(width: 10), // Adjust spacing between logo and name
                Text(businessName), // Business name
                SizedBox(
                  width: 40,
                ), // Adjust spacing between name and search box
                SizedBox(
                  width:
                      MediaQuery.of(context).size.width *
                      0.45, // Adjust width to 30%
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search product by name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ],
            ),
            // Right Corner
            Text(cashierName), // Display cashier name
          ],
        ),
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(),
              ) // Show loading indicator
              : Row(
                children: [
                  // 25% width column
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: Colors.blue[50],
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: _categories.length,
                              itemBuilder: (context, index) {
                                final category = _categories[index];
                                final subCategories =
                                    _getSubCategoriesByCategory(category['id']);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategoryId = category['id'];
                                      _selectedSubCategoryId = null;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          category['name'],
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children:
                                              subCategories.map((subCategory) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _selectedSubCategoryId =
                                                          subCategory['id'];
                                                    });
                                                  },
                                                  child: Container(
                                                    width:
                                                        double
                                                            .infinity, // Use maximum width of the left column
                                                    height: 100,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      image: DecorationImage(
                                                        image: FileImage(
                                                          File(
                                                            subCategory['image'] ??
                                                                _getDefaultImage(
                                                                  subCategory['id'],
                                                                ),
                                                          ),
                                                        ),
                                                        onError: (
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          _logger.severe(
                                                            'Error loading sub-category image: $error',
                                                          );
                                                        },
                                                        fit: BoxFit.cover,
                                                      ),
                                                      border: Border.all(
                                                        color:
                                                            _selectedSubCategoryId ==
                                                                    subCategory['id']
                                                                ? Colors.red
                                                                : Colors
                                                                    .transparent,
                                                        width: 3,
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        subCategory['name'],
                                                        style: TextStyle(
                                                          fontSize:
                                                              20, // Increase font size
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis, // Prevent overflow
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            LoginPage(), // Navigate to login page
                                  ),
                                );
                              },
                              child: Text('Log Out'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 75% width column
                  Expanded(
                    flex: 8,
                    child: Container(
                      color: Colors.blue[100],
                      child:
                          _selectedSubCategoryId != null
                              ? _buildProductList() // Ensure this is only called after loading completes
                              : Center(child: Text('Select a sub-category')),
                    ),
                  ),
                  // 25% width column
                  Expanded(
                    flex: 5,
                    child: Container(
                      color:
                          Colors
                              .white, // Make background color white like a receipt
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                businessLogoPath.isNotEmpty
                                    ? Image.file(
                                      File(businessLogoPath), // Business logo
                                      height: 200,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Icon(
                                          Icons.error,
                                        ); // Show error icon if image fails to load
                                      },
                                    )
                                    : Container(),
                                Text(businessAddress),
                                Text(businessContact),
                                Text('VAT Reg TIN: $businessTaxId'),
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                                    ),
                                    Text(
                                      'Time: ${DateFormat('hh:mm a').format(DateTime.now())}',
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Cashier Name: $cashierName'),
                                    Text('Order Number: $_orderNumber'),
                                  ],
                                ),
                                Divider(),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: orderItems.length,
                              itemBuilder: (context, index) {
                                final item = orderItems[index];
                                return ListTile(
                                  title: Text('- ${item['name']}'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Amount: ${item['quantity']}'),
                                      if (item['size'] != null)
                                        Text('Size: ${item['size']}'),
                                      if (item['addIns'] != null &&
                                          item['addIns'].isNotEmpty)
                                        Text(
                                          'Add-Ins: ${item['addIns'].join(', ')}',
                                        ),
                                      Text('Price: \$${item['price']}'),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          Divider(),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Subtotal:'),
                                    Text('PHP ${_subtotal.toStringAsFixed(2)}'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Taxes:'),
                                    Text('PHP ${_tax.toStringAsFixed(2)}'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total Paid:'),
                                    Text(
                                      'PHP ${_totalPaid.toStringAsFixed(2)}',
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Change:'),
                                    Text('PHP ${_change.toStringAsFixed(2)}'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total:'),
                                    Text('PHP ${_total.toStringAsFixed(2)}'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Show calculator for cash payment
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        TextEditingController amountController =
                                            TextEditingController();
                                        return AlertDialog(
                                          title: Text('Enter Amount Paid'),
                                          content: TextField(
                                            controller: amountController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              labelText: 'Amount',
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
                                                _payByCash(
                                                  double.parse(
                                                    amountController.text,
                                                  ),
                                                );
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Pay'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(Icons.attach_money),
                                  label: Text('Pay By Cash'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _payByCard,
                                  icon: Icon(Icons.credit_card),
                                  label: Text('Pay By Card'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _printInvoice,
                                  icon: Icon(Icons.print),
                                  label: Text('Invoice Printing'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  final DBHelper _dbHelper = DBHelper();
  String businessName = '';
  String businessLogoPath = '';
  String businessAddress = '';
  String businessContact = '';
  String businessTaxId = '';
  String cashierName = ''; // Initialize cashierName
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _subCategories = [];
  int? _selectedCategoryId;
  int? _selectedSubCategoryId;
  String? _selectedSize;
  final List<String> _selectedAddIns = [];
  double _totalPrice = 0.0;
  List<Map<String, dynamic>> orderItems = [];
  int _orderNumber = 1;
  double _subtotal = 0.0;
  double _tax = 0.0;
  double _totalPaid = 0.0;
  double _change = 0.0;
  double _total = 0.0;

  // Added this to show a loading indicator while waiting for database.
  bool _isLoading = true;

  // Initialize logger
  final Logger _logger = Logger('CashierDashboard');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _loadBusinessDetails();
      await _loadCashierName();
      await _loadCategories();
      await _loadSubCategories();
      await _loadProductsWithDetails();
      _logger.info(_products); // Use logger instead of print
    } catch (e) {
      _logger.severe('Error loading data: $e');
      // Handle error appropriately, maybe show an error message
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  Future<void> _loadBusinessDetails() async {
    try {
      businessName =
          await _dbHelper.getBusinessDetail('name') ?? 'Demo Business';
      businessLogoPath =
          await _dbHelper.getBusinessDetail('logo') ?? 'assets/logo.png';
      businessAddress =
          await _dbHelper.getBusinessDetail('address') ?? '123 Demo Street';
      businessContact =
          await _dbHelper.getBusinessDetail('contact') ?? '123-456-7890';
      businessTaxId =
          await _dbHelper.getBusinessDetail('tax_id') ?? 'TAX123456';
      setState(() {});
    } catch (e) {
      _logger.severe('Error loading business details: $e');
    }
  }

  Future<void> _loadCashierName() async {
    try {
      var user = await _dbHelper.getUserByUsername(
        'cashier',
      ); // Fetch cashier details
      if (user != null) {
        setState(() {
          cashierName = user['name']; // Set cashier name
        });
      }
    } catch (e) {
      _logger.severe('Error loading cashier name: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      _categories = await _dbHelper.getCategories();
      _logger.info(
        'Categories loaded: $_categories',
      ); // Use logger instead of print
      setState(() {});
    } catch (e) {
      _logger.severe('Error loading categories: $e');
      setState(() {
        _categories = []; // Set categories to empty list on error
      });
    }
  }

  Future<void> _loadSubCategories() async {
    try {
      _subCategories = await _dbHelper.getSubCategories();
      _logger.info(
        'SubCategories loaded: $_subCategories',
      ); // Use logger instead of print
      if (_subCategories.isNotEmpty) {
        // Select the first sub-category that has products
        for (var subCategory in _subCategories) {
          if (_getProductsBySubCategory(subCategory['id']).isNotEmpty) {
            _selectedSubCategoryId = subCategory['id'];
            break;
          }
        }
        // If no sub-category with products is found, select the first sub-category
        _selectedSubCategoryId ??= _subCategories.first['id'];
      }
      setState(() {});
    } catch (e) {
      _logger.severe('Error loading sub-categories: $e');
      setState(() {
        _subCategories = []; // Set sub-categories to empty list on error
      });
    }
  }

  Future<void> _loadProductsWithDetails() async {
    try {
      _products = await _dbHelper.getProductsWithDetails();

      for (var product in _products) {
        int productId = product['id'];

        // Log sizes
        if (product['sizes'] != null &&
            product['sizes'] is List &&
            (product['sizes'] as List).isNotEmpty) {
          // Sizes fetched successfully
        } else {
          _logger.info(
            "Product ${product['name']} has no sizes",
          ); // Use logger instead of print
        }

        // Log add-ins
        if (product['addIns'] != null &&
            product['addIns'] is List &&
            (product['addIns'] as List).isNotEmpty) {
          // Add-ins fetched successfully
        } else {
          _logger.info(
            "Product ${product['name']} has no add-ins",
          ); // Use logger instead of print
        }
      }

      setState(() {});
    } catch (e) {
      if (e is UnsupportedError && e.message == 'read-only') {
        _logger.severe(
          'Error loading products with details: Read-only operation not supported',
        );
      } else {
        _logger.severe('Error loading products with details: $e');
      }
      setState(() {
        _products = []; // Set products to empty list on error
      });
    }
  }

  List<Map<String, dynamic>> _getSubCategoriesByCategory(int categoryId) {
    return _subCategories
        .where((subCategory) => subCategory['category_id'] == categoryId)
        .toList();
  }

  List<Map<String, dynamic>> _getProductsByCategory(int categoryId) {
    return _products
        .where((product) => product['category_id'] == categoryId)
        .toList();
  }

  List<Map<String, dynamic>> _getProductsBySubCategory(int subCategoryId) {
    _logger.info(
      "Selected SubCategory ID: $subCategoryId",
    ); // Debugging: log selected sub-category ID
    return _products
        .where((product) => product['sub_category_id'] == subCategoryId)
        .toList();
  }

  void _updateTotalPrice(Map<String, dynamic> product, String? size) {
    double basePrice = 0.0;
    if (_selectedSize != null) {
      final size = (product['sizes'] as List).firstWhere(
        (size) => size['name'] == _selectedSize,
      );
      basePrice = size['price'];
    }

    double addInsPrice = _selectedAddIns.fold(0.0, (sum, addInName) {
      final addIn = (product['addIns'] as List).firstWhere(
        (addIn) => addIn['name'] == addInName,
      );
      return sum + addIn['price'];
    });
    setState(() {
      _totalPrice = basePrice + addInsPrice;
    });
  }

  void _addToOrder(Map<String, dynamic> product) {
    setState(() {
      orderItems.add({
        'name': product['name'],
        'quantity': 1,
        'size': _selectedSize,
        'addIns': List.from(_selectedAddIns),
        'price': _totalPrice,
      });
      _selectedSize = null;
      _selectedAddIns.clear();
      _totalPrice = 0.0;
      _calculateTotals();
    });
  }

  void _calculateTotals() {
    _subtotal = orderItems.fold(0.0, (sum, item) => sum + item['price']);
    _tax = _subtotal * 0.12; // Assuming 12% tax rate
    _total = _subtotal + _tax;
    _change = _totalPaid - _total;
    setState(() {});
  }

  void _payByCash(double amountPaid) {
    setState(() {
      _totalPaid = amountPaid;
      _change = _totalPaid - _total;
    });
  }

  void _payByCard() {
    setState(() {
      _totalPaid = _total;
      _change = 0.0;
    });
  }

  Widget _buildProductList() {
    final productList =
        _selectedCategoryId != null
            ? _getProductsByCategory(_selectedCategoryId!)
            : _getProductsBySubCategory(_selectedSubCategoryId!);

    if (productList.isEmpty) {
      return Center(
        child: Text('No products available for this category or sub-category.'),
      );
    }

    return ListView.builder(
      itemCount: productList.length,
      itemBuilder: (context, index) {
        final product = productList[index];
        return Card(
          margin: EdgeInsets.all(10),
          elevation: 5, // Add shadow
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.file(
                      File(product['image'] ?? 'assets/logo.png'),
                      width: 80, // Reduce width by 20px
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.error,
                        ); // Show error icon if image fails to load
                      },
                    ),
                    SizedBox(width: 10),
                    Text(product['name']),
                    Spacer(),
                    Column(
                      children: [
                        SizedBox(
                          width: 100, // Provide a finite width constraint
                          child: TextField(
                            decoration: InputDecoration(labelText: 'Quantity'),
                          ),
                        ),
                        if (product['sizes'] != null &&
                            (product['sizes'] as List)
                                .isNotEmpty) // Conditional size display
                          DropdownButton<String>(
                            hint: Text('Size'),
                            value: _selectedSize,
                            items:
                                (product['sizes'] as List)
                                    .map<DropdownMenuItem<String>>((size) {
                                      return DropdownMenuItem<String>(
                                        value: size['name'],
                                        child: Text(size['name']),
                                      );
                                    })
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSize = value;
                                _updateTotalPrice(product, _selectedSize);
                              });
                            },
                          )
                        else
                          Text(
                            'No sizes available',
                          ), // Indicate if sizes are missing
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                if (product['addIns'] != null &&
                    (product['addIns'] as List)
                        .isNotEmpty) // Conditional add-in display
                  Wrap(
                    spacing: 10,
                    children:
                        (product['addIns'] as List).map<Widget>((addIn) {
                          return FilterChip(
                            label: Text(addIn['name']),
                            selected: _selectedAddIns.contains(addIn['name']),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedAddIns.add(addIn['name']);
                                } else {
                                  _selectedAddIns.remove(addIn['name']);
                                }
                                _updateTotalPrice(product, _selectedSize);
                              });
                            },
                          );
                        }).toList(),
                  )
                else
                  Text(
                    'No add-ins available',
                  ), // Indicate if add-ins are missing
                SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'Price: \$${_totalPrice.toStringAsFixed(2)}',
                    ), // Format price
                    Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        _addToOrder(product);
                      },
                      child: Text('Add to Cart'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _printInvoice() {
    // Handle invoice printing and sales recording
    // For now, just reset the order
    setState(() {
      orderItems.clear();
      _orderNumber++;
      _subtotal = 0.0;
      _tax = 0.0;
      _totalPaid = 0.0;
      _change = 0.0;
      _total = 0.0;
    });
  }

  Widget buildContent(BuildContext context) {
    final productList =
        _selectedCategoryId != null
            ? _getProductsByCategory(_selectedCategoryId!)
            : _getProductsBySubCategory(_selectedSubCategoryId!);

    if (productList.isEmpty) {
      return Center(
        child: Text('No products available for this category or sub-category.'),
      );
    }

    return ListView.builder(
      itemCount: productList.length,
      itemBuilder: (context, index) {
        final product = productList[index];
        return Card(
          margin: EdgeInsets.all(10),
          elevation: 5, // Add shadow
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.file(
                      File(product['image'] ?? 'assets/logo.png'),
                      width: 80, // Reduce width by 20px
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.error,
                        ); // Show error icon if image fails to load
                      },
                    ),
                    SizedBox(width: 10),
                    Text(product['name']),
                    Spacer(),
                    Column(
                      children: [
                        SizedBox(
                          width: 100, // Provide a finite width constraint
                          child: TextField(
                            decoration: InputDecoration(labelText: 'Quantity'),
                          ),
                        ),
                        if (product['sizes'] != null &&
                            (product['sizes'] as List)
                                .isNotEmpty) // Conditional size display
                          DropdownButton<String>(
                            hint: Text('Size'),
                            value: _selectedSize,
                            items:
                                (product['sizes'] as List)
                                    .map<DropdownMenuItem<String>>((size) {
                                      return DropdownMenuItem<String>(
                                        value: size['name'],
                                        child: Text(size['name']),
                                      );
                                    })
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSize = value;
                                _updateTotalPrice(product, _selectedSize);
                              });
                            },
                          )
                        else
                          Text(
                            'No sizes available',
                          ), // Indicate if sizes are missing
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                if (product['addIns'] != null &&
                    (product['addIns'] as List)
                        .isNotEmpty) // Conditional add-in display
                  Wrap(
                    spacing: 10,
                    children:
                        (product['addIns'] as List).map<Widget>((addIn) {
                          return FilterChip(
                            label: Text(addIn['name']),
                            selected: _selectedAddIns.contains(addIn['name']),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedAddIns.add(addIn['name']);
                                } else {
                                  _selectedAddIns.remove(addIn['name']);
                                }
                                _updateTotalPrice(product, _selectedSize);
                              });
                            },
                          );
                        }).toList(),
                  )
                else
                  Text(
                    'No add-ins available',
                  ), // Indicate if add-ins are missing
                SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'Price: \$${_totalPrice.toStringAsFixed(2)}',
                    ), // Format price
                    Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        _addToOrder(product);
                      },
                      child: Text('Add to Cart'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getDefaultImage(int subCategoryId) {
    switch (subCategoryId) {
      case 1:
        return 'assets/hotcoffee_default.png';
      case 2:
        return 'assets/icedcoffee_default.jpg';
      case 3:
        return 'assets/pastry_default.png';
      case 4:
        return 'assets/sandwich_default.png';
      case 5:
        return 'assets/merchandise_default.png';
      default:
        return 'assets/logo.png';
    }
  }
}
