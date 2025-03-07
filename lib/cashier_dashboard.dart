import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'login_page.dart'; // Import login page
import 'dart:io'; // Import dart:io for File
import 'package:intl/intl.dart'; // Import for date and time formatting

class CashierDashboard extends StatefulWidget {
  @override
  _CashierDashboardState createState() => _CashierDashboardState();
}

class _CashierDashboardState extends State<CashierDashboard> {
  _CashierDashboardState(); // Add unnamed constructor

  final DBHelper _dbHelper = DBHelper();
  String businessName = '';
  String businessLogoPath = '';
  String businessAddress = '';
  String businessContact = '';
  String businessTaxId = '';
  String cashierName = '';
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _subCategories = [];
  int? _selectedSubCategoryId;
  String? _selectedSize;
  List<String> _selectedAddIns = [];
  double _totalPrice = 0.0;
  List<Map<String, dynamic>> _orderItems = [];
  int _orderNumber = 1;
  double _subtotal = 0.0;
  double _tax = 0.0;
  double _totalPaid = 0.0;
  double _change = 0.0;
  double _total = 0.0;

  // Added this to show a loading indicator while waiting for database.
  bool _isLoading = true;

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
      await _loadProductsWithDetails(); // Ensure products are loaded from the database
      print(_products); // Debugging: print the contents of _products
    } catch (e) {
      print('Error loading data: $e');
      // Handle error appropriately, maybe show an error message
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  Future<void> _loadBusinessDetails() async {
    try {
      businessName = await _dbHelper.getBusinessDetail('name') ?? 'Demo Business';
      businessLogoPath = await _dbHelper.getBusinessDetail('logo') ?? 'assets/logo.png';
      businessAddress = await _dbHelper.getBusinessDetail('address') ?? '123 Demo Street';
      businessContact = await _dbHelper.getBusinessDetail('contact') ?? '123-456-7890';
      businessTaxId = await _dbHelper.getBusinessDetail('tax_id') ?? 'TAX123456';
      setState(() {});
    } catch (e) {
      print('Error loading business details: $e');
    }
  }

  Future<void> _loadCashierName() async {
    try {
      var user = await _dbHelper.getUserByUsername('cashier');
      if (user != null) {
        cashierName = user['name'];
        setState(() {});
      }
    } catch (e) {
      print('Error loading cashier name: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      _categories = await _dbHelper.getCategories();
      print('Categories loaded: $_categories'); // Debug statement
      setState(() {});
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _loadSubCategories() async {
    try {
      _subCategories = await _dbHelper.getSubCategories();
      print('SubCategories loaded: $_subCategories'); // Debug statement
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
      print('Error loading sub-categories: $e');
    }
  }

  Future<void> _loadProductsWithDetails() async {
    try {
      _products = await _dbHelper.getProductsWithDetails();
      print('Products loaded: $_products'); // Debug statement
      setState(() {});
    } catch (e) {
      print('Error loading products with details: $e');
      // Handle specific error types if needed
    }
  }

  List<Map<String, dynamic>> _getSubCategoriesByCategory(int categoryId) {
    return _subCategories.where((subCategory) => subCategory['category_id'] == categoryId).toList();
  }

  List<Map<String, dynamic>> _getProductsBySubCategory(int subCategoryId) {
    print("Selected SubCategory ID: $subCategoryId"); // Debugging: print selected sub-category ID
    return _products.where((product) => product['sub_category_id'] == subCategoryId).toList();
  }

  void _updateTotalPrice(Map<String, dynamic> product) {
    double basePrice = 0.0;
    if (_selectedSize != null) {
      final size = (product['sizes'] as List).firstWhere((size) => size['name'] == _selectedSize);
      basePrice = size['price'];
    }
    double addInsPrice = _selectedAddIns.fold(0.0, (sum, addInName) {
      final addIn = (product['addIns'] as List).firstWhere((addIn) => addIn['name'] == addInName);
      return sum + addIn['price'];
    });
    setState(() {
      _totalPrice = basePrice + addInsPrice;
    });
  }

  void _addToOrder(Map<String, dynamic> product) {
    setState(() {
      _orderItems.add({
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
    _subtotal = _orderItems.fold(0.0, (sum, item) => sum + item['price']);
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

  void _printInvoice() {
    // Handle invoice printing and sales recording
    // For now, just reset the order
    setState(() {
      _orderItems.clear();
      _orderNumber++;
      _subtotal = 0.0;
      _tax = 0.0;
      _totalPaid = 0.0;
      _change = 0.0;
      _total = 0.0;
    });
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
                      )
                    : Container(),
                SizedBox(width: 10), // Adjust spacing between logo and name
                Text(businessName), // Business name
                SizedBox(width: 40), // Adjust spacing between name and search box
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45, // Adjust width to 30%
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
            Text('$cashierName'), // Cashier name
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
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
                              final subCategories = _getSubCategoriesByCategory(category['id']);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedSubCategoryId = null;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                        children: subCategories.map((subCategory) {
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedSubCategoryId = subCategory['id'];
                                              });
                                            },
                                            child: Container(
                                              width: double.infinity, // Use maximum width of the left column
                                              height: 100,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                image: DecorationImage(
                                                  image: FileImage(File(subCategory['image'] ?? 'assets/logo.png')),
                                                  fit: BoxFit.cover,
                                                ),
                                                border: Border.all(
                                                  color: _selectedSubCategoryId == subCategory['id'] ? Colors.red : Colors.transparent,
                                                  width: 3,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  subCategory['name'],
                                                  style: TextStyle(
                                                    fontSize: 20, // Increase font size
                                                    color: Colors.white,
                                                    backgroundColor: Colors.black54,
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
                                MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to login page
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
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator()) // Show loading indicator
                        : _products.isEmpty
                            ? Center(child: Text('No products available.')) // Show message if no products
                            : _buildProductList(), // Show all products list
                  ),
                ),
                // 25% width column
                Expanded(
                  flex: 5,
                  child: Container(
                    color: Colors.white, // Make background color white like a receipt
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
                                    )
                                  : Container(),
                              Text(businessAddress),
                              Text(businessContact),
                              Text('VAT Reg TIN: $businessTaxId'),
                              Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}'),
                                  Text('Time: ${DateFormat('hh:mm a').format(DateTime.now())}'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            itemCount: _orderItems.length,
                            itemBuilder: (context, index) {
                              final item = _orderItems[index];
                              return ListTile(
                                title: Text('- ${item['name']}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Amount: ${item['quantity']}'),
                                    if (item['size'] != null) Text('Size: ${item['size']}'),
                                    if (item['addIns'] != null && item['addIns'].isNotEmpty)
                                      Text('Add-Ins: ${item['addIns'].join(', ')}'),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Subtotal:'),
                                  Text('PHP ${_subtotal.toStringAsFixed(2)}'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Taxes:'),
                                  Text('PHP ${_tax.toStringAsFixed(2)}'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total Paid:'),
                                  Text('PHP ${_totalPaid.toStringAsFixed(2)}'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Change:'),
                                  Text('PHP ${_change.toStringAsFixed(2)}'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      TextEditingController _amountController = TextEditingController();
                                      return AlertDialog(
                                        title: Text('Enter Amount Paid'),
                                        content: TextField(
                                          controller: _amountController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(labelText: 'Amount'),
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
                                              _payByCash(double.parse(_amountController.text));
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

  Widget _buildProductList() {
    if (_selectedSubCategoryId == null) {
      return Center(child: Text('Select a sub-category.'));
    }

    final productList = _getProductsBySubCategory(_selectedSubCategoryId!);

    if (productList.isEmpty) {
      return Center(child: Text('No products available for this sub-category.'));
    }

    // ... rest of your _buildProductList function
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
                      File(product['image']),
                      width: 80, // Reduce width by 20px
                    ),
                    SizedBox(width: 10),
                    Text(product['name']),
                    Spacer(),
                    Column(
                      children: [
                        SizedBox(
                          width: 100, // Provide a finite width constraint
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Quantity',
                            ),
                          ),
                        ),
                        if (product['sizes'] != null && (product['sizes'] as List).isNotEmpty) 
                          // Conditional size display
                          DropdownButton<String>(
                            hint: Text('Size'),
                            value: _selectedSize,
                            items: (product['sizes'] as List).map<DropdownMenuItem<String>>((size) {
                              return DropdownMenuItem<String>(
                                value: size['name'],
                                child: Text(size['name']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSize = value;
                                _updateTotalPrice(product);
                              });
                            },
                          )
                        else 
                          Text('No sizes available'), // Indicate if sizes are missing
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                if (product['addIns'] != null && (product['addIns'] as List).isNotEmpty) // Conditional add-in display
                  Wrap(
                    spacing: 10,
                    children: (product['addIns'] as List).map<Widget>((addIn) {
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
                            _updateTotalPrice(product);
                          });
                        },
                      );
                    }).toList(),
                  )
                else
                  Text('No add-ins available'), // Indicate if add-ins are missing
                SizedBox(height: 10),
                Row(
                  children: [
                    Text('Price: \$${_totalPrice.toStringAsFixed(2)}'), // Format price
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
}
