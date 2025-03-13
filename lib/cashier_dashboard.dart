import 'package:flutter/material.dart';
import 'database_helper.dart'; //
import 'package:logging/logging.dart';

final _log = Logger('CashierDashboard');

class CashierDashboard extends StatefulWidget {
  final String username; // Change to username to identify the cashier

  const CashierDashboard({super.key, required this.username});

  @override
  CashierDashboardState createState() => CashierDashboardState();
}

class CashierDashboardState extends State<CashierDashboard> {
  String? selectedSubCategory;
  List<String> categories = [];
  Map<String, List<String>> subCategories = {};
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> sizes = [];
  String? cashierName; // Add cashierName variable
  bool _isLoadingCashierName = true; // Add loading indicator

  @override
  void initState() {
    super.initState();
    _fetchCashierName(widget.username); // Fetch cashier name on init
    _fetchCategoriesAndSubCategories();
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

    setState(() {
      products = productList;
      sizes = sizeList;
    });

    // Debug prints
    _log.info('Fetched products: $products');
    _log.info('Fetched sizes: $sizes');
  }

  Future<void> _fetchAddInsForProducts() async {
    // Implement the logic to fetch add-ins for products
    // This is a placeholder implementation
    await Future.delayed(Duration(seconds: 1));
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

  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration - REMOVED as cashierName is now fetched
    final String businessLogo = 'assets/logo.png';
    final String businessName = 'Demo Business Name';

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
                Text(businessName, style: TextStyle(fontSize: 20)),
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
                : Text('Cashier: $cashierName', style: TextStyle(fontSize: 20)),
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
            child:
                selectedSubCategory == null
                    ? Center(child: Text('Select a sub-category'))
                    : FutureBuilder(
                      future: _fetchAddInsForProducts(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error fetching add-ins'));
                        } else {
                          return ProductSelectionArea(
                            products: products,
                            sizes: sizes,
                          );
                        }
                      },
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

  const ProductSelectionArea({
    super.key,
    required this.products,
    required this.sizes,
  });

  @override
  ProductSelectionAreaState createState() => ProductSelectionAreaState();
}

class ProductSelectionAreaState extends State<ProductSelectionArea> {
  final Map<int, String?> selectedSizes = {};
  final Map<String, int> quantities = {}; // Key format: productId_size
  final Map<int, TextEditingController> quantityControllers = {};
  Map<int, List<Map<String, dynamic>>> addInsList = {};
  Map<int, Set<int>> selectedAddIns = {};
  bool isLoadingAddIns = true;

  @override
  void initState() {
    super.initState();
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
      final controller = TextEditingController(text: '0');
      quantityControllers[product['id']] = controller;

      // Initialize quantities for each product and size
      for (var size in productSizes) {
        quantities['${product['id']}_${size['size']}'] = 0;
      }

      // Initialize selectedAddIns for each product
      selectedAddIns[product['id']] = <int>{};
    }

    // Fetch add-ins when the widget is initialized
    _fetchAddInsForProducts();
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    for (final controller in quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchAddInsForProducts() async {
    if (!isLoadingAddIns) {
      return; // Return if already loaded
    }

    setState(() {
      isLoadingAddIns = true;
    });

    final dbHelper = DatabaseHelper();

    try {
      final fetchedAddIns = await dbHelper.fetchAddInsForProducts(
        widget.products,
      );

      setState(() {
        addInsList = fetchedAddIns;
        isLoadingAddIns = false;
      });

      // Debug prints
      _log.info('Fetched add-ins: $addInsList');
    } catch (e) {
      _log.severe('Error fetching add-ins: $e');
      setState(() {
        isLoadingAddIns = false;
      });
    }
  }

  // Helper method to update quantity based on product and selected size
  void _updateQuantity(int productId, int change) {
    setState(() {
      String size = selectedSizes[productId] ?? 'Regular';
      String key = '${productId}_$size';

      // Get current quantity with null safety
      int currentQuantity = quantities[key] ?? 0;

      // Apply change and ensure it's not negative
      int newQuantity =
          (currentQuantity + change) < 0 ? 0 : currentQuantity + change;

      // Update quantity map and controller
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
        )['price'];

    totalPrice += (sizePrice ?? 0) * quantity;

    // Add add-in prices
    final selectedProductAddIns = selectedAddIns[productId] ?? {};
    for (final addInId in selectedProductAddIns) {
      final addIn = addInsList[productId]?.firstWhere(
        (addIn) => addIn['id'] == addInId,
        orElse: () => {'price': 0},
      );
      totalPrice += (addIn?['price'] ?? 0);
    }

    return totalPrice;
  }

  Widget _buildAddIns(Map<String, dynamic> product) {
    final productId = product['id'];
    final productAddIns = addInsList[productId] ?? [];

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            widget.products.map((product) {
              final productId = product['id'];
              final productSizes =
                  widget.sizes
                      .where((size) => size['product_id'] == productId)
                      .toList();
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
                                style: TextStyle(fontSize: 20),
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
                                      controller:
                                          quantityControllers[productId],
                                      readOnly: true,
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
                                        selectedSizes[productId] = size['size'];

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
                            onPressed: () {
                              // Handle add to cart
                            },
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
    );
  }
}

void main() {
  runApp(MaterialApp(home: CashierDashboard(username: 'cashier1')));
}
