import 'package:flutter/material.dart';
import 'database_helper.dart'; //

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
                      return ExpansionTile(
                        title: Text(
                          category,
                          style: TextStyle(
                            color: Colors.black,
                          ), // Changed to black for visibility
                        ),
                        children:
                            subCategories[category]!.map((subCategory) {
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
                            }).toList(),
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
                        // Handle logout
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
  final Map<String, int> quantities = {}; // Modified to include size
  final Map<int, TextEditingController> quantityControllers =
      {}; // Add this line

  @override
  void initState() {
    super.initState();
    // Set default size to "Regular" if available
    for (var product in widget.products) {
      final productSizes =
          widget.sizes
              .where((size) => size['product_id'] == product['id'])
              .toList();
      if (productSizes.any((size) => size['size'] == 'Regular')) {
        selectedSizes[product['id']] = 'Regular';
      }
      // Initialize quantity to 0 for each product and size combination
      for (var size in productSizes) {
        quantities['${product['id']}_${size['size']}'] = 0;
      }
      quantityControllers[product['id']] = TextEditingController(
        text: '0',
      ); // Initialize controller
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration
    final String productImage =
        'assets/placeholder.png'; // Replace with database call
    final List<String> addIns = [
      'Add-In 1',
      'Add-In 2',
    ]; // Replace with database call

    return Container(
      width: MediaQuery.of(context).size.width * 0.55,
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            widget.products.map((product) {
              final productSizes =
                  widget.sizes
                      .where((size) => size['product_id'] == product['id'])
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
                                    onPressed: () {
                                      setState(() {
                                        String size =
                                            selectedSizes[product['id']] ??
                                            'Regular';
                                        if ((quantities['${product['id']}_$size'] ??
                                                0) >
                                            0) {
                                          quantities['${product['id']}_$size'] =
                                              (quantities['${product['id']}_$size'] ??
                                                  0) -
                                              1;
                                          quantityControllers[product['id']]!
                                                  .text =
                                              quantities['${product['id']}_$size']
                                                  .toString(); // Update controller
                                        }
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    width: 50, // Ensure bounded width
                                    child: TextField(
                                      decoration: InputDecoration(
                                        labelText: 'Quantity',
                                        border: OutlineInputBorder(),
                                      ),
                                      textAlign: TextAlign.center,
                                      controller:
                                          quantityControllers[product['id']], // Use controller
                                      readOnly: true, // Make it read-only
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        String size =
                                            selectedSizes[product['id']] ??
                                            'Regular';
                                        quantities['${product['id']}_$size'] =
                                            (quantities['${product['id']}_$size'] ??
                                                0) +
                                            1;
                                        quantityControllers[product['id']]!
                                                .text =
                                            quantities['${product['id']}_$size']
                                                .toString(); // Update controller
                                      });
                                    },
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
                                        selectedSizes[product['id']] =
                                            size['size'];
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          selectedSizes[product['id']] ==
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
                      // Row 2
                      Wrap(
                        spacing: 10,
                        children:
                            addIns.map((String addIn) {
                              return FilterChip(
                                label: Text(addIn),
                                onSelected: (bool selected) {
                                  // Handle add-in selection
                                },
                              );
                            }).toList(),
                      ),
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
