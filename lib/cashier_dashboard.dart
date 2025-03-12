import 'package:flutter/material.dart';
import 'database_helper.dart'; //
import 'package:logging/logging.dart';

final _log = Logger('CashierDashboard');

class CashierDashboard extends StatefulWidget {
  const CashierDashboard({super.key}); //

  @override
  CashierDashboardState createState() => CashierDashboardState();
}

class CashierDashboardState extends State<CashierDashboard> {
  String? selectedSubCategory;
  List<String> categories = [];
  Map<String, List<String>> subCategories = {};
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> sizes = [];

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration
    final String businessLogo = 'assets/logo.png'; // Replace with database call
    final String businessName =
        'Demo Business Name'; // Replace with database call
    final String cashierName = 'John Doe'; // Replace with user login data

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back button
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
            Text('Cashier: $cashierName', style: TextStyle(fontSize: 20)),
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
                              ), // Changed to black for visibility
                            ),
                          ),
                          ...subCategories[category]!.map((subCategory) {
                            return ListTile(
                              title: Text(
                                subCategory,
                                style: TextStyle(
                                  color: Colors.black,
                                ), // Changed to black for visibility
                              ),
                              onTap: () {
                                setState(() {
                                  selectedSubCategory = subCategory;
                                });
                                _fetchProducts(subCategory);
                              },
                            );
                          }),
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
                    : ProductSelectionArea(products: products, sizes: sizes),
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
    Map<int, List<Map<String, dynamic>>> fetchedAddIns = {};

    for (var product in widget.products) {
      final productId = product['id'];
      // Fetch add-ins from add_ins table
      final addIns = await dbHelper.getAddInList(productId);
      fetchedAddIns[productId] = addIns;

      // Initialize empty set for selected add-ins
      if (selectedAddIns[productId] == null) {
        selectedAddIns[productId] = <int>{};
      }
    }

    setState(() {
      addInsList = fetchedAddIns;
      isLoadingAddIns = false;
    });

    // Debug prints
    _log.info('Fetched add-ins: $addInsList');
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
      return SizedBox(height: 0);
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
                      // Row 3
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Handle add to cart
                            },
                            child: Text(
                              'Add to Cart (\$${productSizes.isNotEmpty ? productSizes.first['price'].toStringAsFixed(2) : '0.00'})',
                            ),
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
  runApp(MaterialApp(home: CashierDashboard()));
}
