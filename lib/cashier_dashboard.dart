import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // Add this line for input formatter

final _log = Logger('CashierDashboard');

class CashierDashboard extends StatefulWidget {
  final String username; // Change to username to identify the cashier

  const CashierDashboard({super.key, required this.username});

  @override
  CashierDashboardState createState() => CashierDashboardState();
}

late CashierDashboardState _dashboardState;

class CashierDashboardState extends State<CashierDashboard> {
  String? selectedSubCategory;
  List<String> categories = [];
  Map<String, List<String>> subCategories = {};
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> sizes = [];
  final Map<int, String?> selectedSizes = {}; // Add selectedSizes variable
  final Map<String, int> quantities = {}; // Add this line
  String? cashierName; // Add cashierName variable
  bool _isLoadingCashierName = true; // Add loading indicator
  String? businessName; // Add businessName variable
  bool _isLoadingBusinessName = true; // Add loading indicator for business name
  final Map<int, Set<int>> selectedAddIns = {}; // Add this line
  Map<int, List<Map<String, dynamic>>> addInsList = {}; // Add this line
  bool isLoadingAddIns = true; // Add this line
  List<Map<String, dynamic>> orderDetails =
      []; // Create a list to store the order details

  CashierDashboardState() {
    _dashboardState = this;
  }

  @override
  void initState() {
    super.initState();
    _fetchCashierName(widget.username); // Fetch cashier name on init
    _fetchBusinessName(); // Fetch business name on init
    _fetchCategoriesAndSubCategories();
    _fetchAddInsForProducts(); // Initialize addInsList
  }

  Future<void> _fetchCategoriesAndSubCategories() async {
    final dbHelper = DatabaseHelper();
    final categoryList = await dbHelper.getCategoryList();
    final subCategoryMap = <String, List<String>>{};

    for (var category in categoryList) {
      final subCategoryList = await dbHelper.getSubCategoryList(category['id']);
      subCategoryMap[category['name']] =
          subCategoryList
              .map<String>((subCategory) => subCategory['name'] as String)
              .toList();
    }

    setState(() {
      categories =
          categoryList.map((category) => category['name'] as String).toList();
      subCategories = subCategoryMap;

      // Load the first product list based on the first sub-category
      if (categories.isNotEmpty &&
          subCategories[categories.first]!.isNotEmpty) {
        selectedSubCategory = subCategories[categories.first]!.first;
        _fetchProducts(selectedSubCategory!);
      }
    });
  }

  Future<void> _fetchProducts(String subCategory) async {
    final dbHelper = DatabaseHelper();
    final productList = await dbHelper.getProductListBySubCategory(subCategory);
    final sizeList = <Map<String, dynamic>>[];

    for (var product in productList) {
      final sizes = await dbHelper.getSizeListByProductId(product['id']);
      sizeList.addAll(sizes);
    }

    if (!mounted) return; // Prevent setState call if widget is disposed
    setState(() {
      products = productList;
      sizes = sizeList;
    });
    await _fetchAddInsForProducts(); // New line added here

    // Debug prints
    _log.info('Fetched products: $products');
    _log.info('Fetched sizes: $sizes');
  }

  Future<void> _fetchAddInsForProducts() async {
    final dbHelper = DatabaseHelper();
    try {
      final fetchedAddIns = await dbHelper.fetchAddInsForProducts(products);
      setState(() {
        addInsList = fetchedAddIns;
        isLoadingAddIns = false; // Ensure loading flag is set to false
      });
      _log.info('Fetched add-ins: $addInsList');
    } catch (e) {
      _log.severe('Error fetching add-ins: $e');
    }
  }

  Future<void> _fetchCashierName(String username) async {
    final dbHelper = DatabaseHelper();
    try {
      final userDetails = await dbHelper.getUserByUsername(username);
      setState(() {
        cashierName = userDetails != null ? userDetails['name'] : null;
        _isLoadingCashierName = false; // Update loading state
      });
    } catch (e) {
      _log.severe('Error fetching cashier name: $e');
      setState(() {
        _isLoadingCashierName = false; // Update loading state even on error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading cashier name.')),
        );
      });
    }
  }

  Future<void> _fetchBusinessName() async {
    final dbHelper = DatabaseHelper();
    try {
      final name = await dbHelper.getBusinessName();
      setState(() {
        businessName = name;
        _isLoadingBusinessName = false; // Update loading state
      });
    } catch (e) {
      _log.severe('Error fetching business name: $e');
      setState(() {
        _isLoadingBusinessName = false; // Update loading state even on error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading business name.')),
        );
      });
    }
  }

  double _calculateTotalPrice() {
    double totalPrice = 0;
    for (final order in orderDetails) {
      totalPrice += order['price'];
    }
    return totalPrice;
  }

  void _addToCart(
    int productId,
    String size,
    int quantity,
    double price,
    String productName,
    Set<int> selectedAddIns,
    List<String> addInNames, // Add this line
  ) {
    // Calculate total price excluding add-ins
    double totalPrice = price * quantity; // Calculate total price

    setState(() {
      //Added product_id to the orderDetails map
      orderDetails.add({
        'product': productName,
        'size': size,
        'quantity': quantity,
        'price': totalPrice,
        'addIns':
            selectedAddIns.toList(), // Add selected addIns to the order details
        'product_id': productId,
        'addInNames': addInNames, // Add this line
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final String businessLogo = 'assets/logo.png';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Corner
            Row(
              children: [
                Image.asset(businessLogo, height: 100),
                SizedBox(width: 10),
                _isLoadingBusinessName
                    ? CircularProgressIndicator()
                    : businessName == null || businessName?.isEmpty == true
                    ? Text(
                      'Business Name Not Found',
                      style: TextStyle(fontSize: 20),
                    )
                    : Text(businessName!, style: TextStyle(fontSize: 20)),
                SizedBox(width: 40),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search product by name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            // Right Corner
            // Use the fetched cashierName here
            _isLoadingCashierName
                ? CircularProgressIndicator()
                : cashierName == null
                ? Text('Cashier: Not Found', style: TextStyle(fontSize: 20))
                : Text('$cashierName', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
      body: Row(
        children: [
          // Left Column
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            color: Colors.grey[200],
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      String category = categories[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(
                              category,
                              style: TextStyle(
                                color: Colors.black,
                                shadows: [
                                  Shadow(
                                    offset: Offset(1.0, 1.0),
                                    blurRadius: 3.0,
                                    color: Colors.grey,
                                  ),
                                ],
                              ), // Changed to black for visibility
                            ),
                          ),
                          // Wrap sub-category menu in a container with white background
                          Container(
                            color: Colors.white,
                            child: Column(
                              children:
                                  subCategories[category]!.map((subCategory) {
                                    return ListTile(
                                      title: Center(
                                        // Align text to center
                                        child: Text(
                                          subCategory,
                                          style: TextStyle(
                                            color: Colors.black,
                                            shadows: [
                                              Shadow(
                                                offset: Offset(1.0, 1.0),
                                                blurRadius: 3.0,
                                                color: Colors.grey,
                                              ),
                                            ],
                                          ), // Changed to black for visibility
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          selectedSubCategory = subCategory;
                                        });
                                        _fetchProducts(subCategory);
                                      },
                                    );
                                  }).toList(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // Log Out Button
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate back to login page
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: Text('Log Out'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main Content Area
          Expanded(
            child: Row(
              children: [
                // Main Content Area
                Expanded(
                  flex: 3, // 55% width
                  child: Column(
                    children: [
                      Expanded(
                        child:
                            selectedSubCategory == null
                                ? Center(child: Text('Select a sub-category'))
                                : ProductSelectionArea(
                                  products: products,
                                  sizes: sizes,
                                  addInsList:
                                      addInsList, // Pass addInsList to ProductSelectionArea
                                ),
                      ),
                      // Removed the bottom tab containing total price and cart icon
                    ],
                  ),
                ),
                // New Right Column
                Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  color: Colors.grey[300],
                  child: Container(
                    color: Colors.white, // Add white background
                    padding: EdgeInsets.all(
                      10,
                    ), // Add padding for better appearance
                    child: Column(
                      children: [
                        // Business Logo
                        Image.asset(businessLogo, height: 100),
                        SizedBox(height: 10),
                        // Business Name
                        Text(
                          businessName ?? 'Business Name',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        // Business Address
                        Text('Business Address'),
                        // Business Contact Number
                        Text('Contact Number: 123-456-7890'),
                        // VAT Reg TIN
                        Text('VAT Reg TIN: 123456789'),
                        Divider(),
                        // Date and Time
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Date: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Time: ${TimeOfDay.now().format(context)}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        // Order Number
                        Text(
                          'Order Number: 12345',
                          style: TextStyle(fontSize: 16),
                        ),
                        Divider(),
                        // Order Details
                        Expanded(
                          child: ListView.builder(
                            itemCount:
                                orderDetails.length, // Use orderDetails length
                            itemBuilder: (context, index) {
                              final orderItem =
                                  orderDetails[index]; // Get Item from list
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    title: Text(
                                      '${orderItem['size']} ${orderItem['product']} x ${orderItem['quantity']}',
                                    ),
                                    trailing: Text(
                                      '\$${(orderItem['price'] - orderItem['addIns'].fold(0, (sum, addInId) {
                                            final addIn = addInsList[orderItem['product_id']]?.firstWhere((addIn) => addIn['id'] == addInId, orElse: () => {'price': 0});
                                            return sum + (addIn?['price'] ?? 0);
                                          })).toStringAsFixed(2)}',
                                    ),
                                  ),
                                  if (orderItem['addInNames'] != null &&
                                      orderItem['addInNames'].isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children:
                                          orderItem['addInNames'].map<Widget>((
                                            addInName,
                                          ) {
                                            final addIn =
                                                addInsList[orderItem['product_id']]
                                                    ?.firstWhere(
                                                      (addIn) =>
                                                          addIn['name'] ==
                                                          addInName,
                                                      orElse:
                                                          () => {'price': 0},
                                                    );
                                            return ListTile(
                                              title: Text(
                                                'Add-Ins: $addInName',
                                              ),
                                              trailing: Text(
                                                '\$${addIn?['price'].toStringAsFixed(2)}',
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                        Divider(),
                        // Subtotal
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Subtotal:', style: TextStyle(fontSize: 16)),
                            Text('\$0.00', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        // Tax
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Tax:', style: TextStyle(fontSize: 16)),
                            Text('\$0.00', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        // Discount
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Discount:', style: TextStyle(fontSize: 16)),
                            Text('\$0.00', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${_calculateTotalPrice().toStringAsFixed(2)}', // Calculate total here
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Amount Paid
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Amount Paid:',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text('\$0.00', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        // Change
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Change:', style: TextStyle(fontSize: 16)),
                            Text('\$0.00', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductSelectionArea extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> sizes;
  final Map<int, List<Map<String, dynamic>>> addInsList; // Add this line

  const ProductSelectionArea({
    super.key,
    required this.products,
    required this.sizes,
    required this.addInsList, // Add this line
  });

  @override
  ProductSelectionAreaState createState() => ProductSelectionAreaState();
}

class ProductSelectionAreaState extends State<ProductSelectionArea> {
  final Map<int, String?> selectedSizes = {};
  final Map<String, int> quantities = {}; // Key format: productId_size
  final Map<int, TextEditingController> quantityControllers = {};
  Map<int, Set<int>> selectedAddIns = {};
  bool isLoadingAddIns = true;

  @override
  void initState() {
    super.initState();
    _log.info(
      'widget.sizes in ProductSelectionArea: ${widget.sizes}',
    ); // << Added log
    // Initialize quantities and controllers for all products
    for (var product in widget.products) {
      final productSizes =
          widget.sizes
              .where((size) => size['product_id'] == product['id'])
              .toList();

      // Set default size to "Regular" if available
      String defaultSize = 'Regular';
      if (productSizes.any((size) => size['size'] == defaultSize)) {
        selectedSizes[product['id']] = defaultSize;
      } else if (productSizes.isNotEmpty) {
        selectedSizes[product['id']] = productSizes.first['size'];
      }

      // Initialize quantity controller with 0
      final controller = TextEditingController();
      quantityControllers[product['id']] = controller;

      // Initialize quantities for each product and size
      for (var size in productSizes) {
        quantities['${product['id']}_${size['size']}'] = 0;
        controller.text = '0';
      }

      // Initialize selectedAddIns for each product
      selectedAddIns[product['id']] = <int>{};
    }
    setState(() {
      isLoadingAddIns = false; // Ensure loading flag is set to false
    });
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    for (final controller in quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Helper method to update quantity based on product and selected size
  void _updateQuantity(int productId, int change) {
    setState(() {
      String size = selectedSizes[productId] ?? 'Regular';
      String key = '${productId}_$size';

      int currentQuantity = quantities[key] ?? 0;
      int newQuantity =
          (currentQuantity + change) < 0 ? 0 : currentQuantity + change;

      quantities[key] = newQuantity;
      quantityControllers[productId]?.text = newQuantity.toString();
    });
  }

  double _calculateTotalPrice(int productId) {
    double totalPrice = 0;
    final selectedSize =
        selectedSizes[productId] ?? 'Regular'; // Simplified size selection
    final key = '${productId}_$selectedSize'; // Correct key formation
    final quantity = quantities[key] ?? 0;

    // Find the price for the selected size
    final sizePrice =
        widget.sizes.firstWhere(
          (size) =>
              size['product_id'] == productId && size['size'] == selectedSize,
          orElse: () => {'price': 0},
        )['price'] ??
        0; // Using ?? here

    totalPrice += sizePrice * quantity;

    // Add add-in prices
    final selectedProductAddIns = selectedAddIns[productId] ?? {};
    for (final addInId in selectedProductAddIns) {
      final addIn = widget.addInsList[productId]?.firstWhere(
        (addIn) => addIn['id'] == addInId,
        orElse: () => {'price': 0},
      );
      totalPrice += (addIn?['price'] ?? 0); // Using ?? here
    }

    return totalPrice;
  }

  void _addToCart(int productId) {
    final selectedSize = selectedSizes[productId] ?? 'Regular';
    final key = '${productId}_$selectedSize';
    final quantity = quantities[key] ?? 0;

    if (quantity > 0) {
      final product = widget.products.firstWhere(
        (product) => product['id'] == productId,
      );
      // Find the price for the selected size
      final sizePrice =
          widget.sizes.firstWhere(
            (size) =>
                size['product_id'] == productId && size['size'] == selectedSize,
            orElse: () => {'price': 0},
          )['price'] ??
          0.0;

      // Calculate total price including add-ins
      double totalPrice = sizePrice * quantity;
      final selectedProductAddIns = selectedAddIns[productId] ?? {};
      List<String> addInNames = []; // Add this line
      // ...existing code...
      for (final addInId in selectedProductAddIns) {
        final addIn = widget.addInsList[productId]?.firstWhere(
          (addIn) => addIn['id'] == addInId,
          orElse: () => {'name': 'Unknown', 'price': 0},
        );
        totalPrice += (addIn?['price'] ?? 0);
        addInNames.add(addIn?['name'] ?? 'Unknown'); // Collect add-in names
      }

      _dashboardState._addToCart(
        productId,
        selectedSize,
        quantity,
        totalPrice, // Use the properly handled total price
        product['name'],
        selectedAddIns[productId]!,
        addInNames, // Pass add-in names to the parent's _addToCart method
      ); // Call the parent's _addToCart method

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product['name']} added to cart')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a quantity greater than 0')),
      );
    }
  }

  Widget _buildAddIns(Map<String, dynamic> product) {
    final productId = product['id'];
    final productAddIns = widget.addInsList[productId] ?? [];

    if (productAddIns.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add-ins:', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Wrap(
            spacing: 10,
            children:
                productAddIns.map((addIn) {
                  return FilterChip(
                    label: Text(
                      '${addIn['name']} (\$${addIn['price'].toStringAsFixed(2)})',
                    ),
                    selected:
                        selectedAddIns[productId]?.contains(addIn['id']) ??
                        false,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selectedAddIns[productId] == null) {
                          selectedAddIns[productId] = {};
                        }

                        if (selected) {
                          selectedAddIns[productId]!.add(addIn['id']);
                        } else {
                          selectedAddIns[productId]!.remove(addIn['id']);
                        }
                      });
                    },
                  );
                }).toList(),
          ),
        ],
      );
    } else {
      return SizedBox.shrink(); // Using shrink() for empty state
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration
    final String productImage =
        'assets/placeholder.png'; // Replace with database call

    return Container(
      width: MediaQuery.of(context).size.width * 0.55,
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        // Wrap Column with SingleChildScrollView
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              widget.products.map((product) {
                final productId = product['id'];
                final productSizes =
                    widget.sizes
                        .where((size) => size['product_id'] == productId)
                        .toList();
                final selectedProductAddIns = selectedAddIns[productId] ?? {};

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1
                        Row(
                          children: [
                            Image.asset(productImage, width: 100),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight.bold, // Make font bold
                                    shadows: [
                                      Shadow(
                                        offset: Offset(1.0, 1.0),
                                        blurRadius: 3.0,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                                // Display selected add-ins below the product name
                                if (selectedProductAddIns.isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children:
                                        selectedProductAddIns.map((addInId) {
                                          final addIn = widget
                                              .addInsList[productId]
                                              ?.firstWhere(
                                                (addIn) =>
                                                    addIn['id'] == addInId,
                                                orElse:
                                                    () => {
                                                      'name': 'Unknown',
                                                      'price': 0,
                                                    },
                                              );
                                          return Text(
                                            '${addIn?['name']} (\$${addIn?['price'].toStringAsFixed(2)})',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed:
                                          () => _updateQuantity(productId, -1),
                                    ),
                                    SizedBox(
                                      width: 50, // Ensure bounded width
                                      child: TextField(
                                        decoration: InputDecoration(
                                          labelText: 'Qty',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 0,
                                          ),
                                        ),
                                        textAlign: TextAlign.center,
                                        controller: quantityControllers
                                            .putIfAbsent(
                                              productId,
                                              () => TextEditingController(
                                                text: '0',
                                              ),
                                            ), // Ensure controller is initialized
                                        onChanged: (value) {
                                          // Update quantity in the map
                                          String size =
                                              selectedSizes[productId] ??
                                              'Regular';
                                          String key = '${productId}_$size';
                                          quantities[key] =
                                              int.tryParse(value) ?? 0;
                                        },
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ], // Ensure only digits are allowed
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed:
                                          () => _updateQuantity(productId, 1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Spacer(),
                            Wrap(
                              spacing: 10,
                              alignment: WrapAlignment.end,
                              direction: Axis.vertical,
                              children:
                                  productSizes.map((size) {
                                    return ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedSizes[productId] =
                                              size['size'];

                                          // Update quantity controller to show selected size quantity
                                          String key =
                                              '${productId}_${size['size']}';
                                          int qty = quantities[key] ?? 0;
                                          quantityControllers[productId]?.text =
                                              qty.toString();
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            selectedSizes[productId] ==
                                                    size['size']
                                                ? Colors.blue
                                                : Colors.grey,
                                      ),
                                      child: Text(
                                        '${size['size']} (\$${size['price'].toStringAsFixed(2)})',
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        // Row 2 - Add-ins
                        if (isLoadingAddIns)
                          Center(child: CircularProgressIndicator())
                        else
                          _buildAddIns(product),
                        SizedBox(height: 20),
                        // Row 3 - Add Price Calculation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total: \$${_calculateTotalPrice(productId).toStringAsFixed(2)}',
                            ),
                            ElevatedButton(
                              onPressed: () => _addToCart(product['id']),
                              child: Text('Add to Cart'),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Add other providers here if needed
      ],
      child: MaterialApp(
        home: CashierDashboard(username: 'cashier1'),
        // ...existing code...
      ),
    ),
  );
}
