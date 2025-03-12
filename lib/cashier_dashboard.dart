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
  _ProductSelectionAreaState createState() => _ProductSelectionAreaState();
}

class _ProductSelectionAreaState extends State<ProductSelectionArea> {
  final Map<int, String?> selectedSizes = {};

  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration
    final String productImage =
        'assets/product.png'; // Replace with database call
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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1
                  Row(
                    children: [
                      Image.asset(productImage, width: 100),
                      SizedBox(width: 10),
                      Text(product['name'], style: TextStyle(fontSize: 20)),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Quantity',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),
                          DropdownButton<String>(
                            hint: Text('Select Size'),
                            value: selectedSizes[product['id']],
                            items:
                                productSizes.map((size) {
                                  return DropdownMenuItem<String>(
                                    value: size['name'],
                                    child: Text(
                                      '${size['name']} (\$${size['price'].toStringAsFixed(2)})',
                                    ),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedSizes[product['id']] = newValue;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Row 2
                  Text('Add-Ins Options', style: TextStyle(fontSize: 16)),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Price: \$${productSizes.isNotEmpty ? productSizes.first['price'].toStringAsFixed(2) : '0.00'}',
                        style: TextStyle(fontSize: 20),
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
              );
            }).toList(),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: CashierDashboard()));
}
