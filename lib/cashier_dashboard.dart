import 'package:flutter/material.dart';

class CashierDashboard extends StatefulWidget {
  const CashierDashboard({super.key}); // Add named 'key' parameter

  @override
  CashierDashboardState createState() => CashierDashboardState();
}

class CashierDashboardState extends State<CashierDashboard> {
  String? selectedSubCategory;

  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration
    final String businessLogo = 'assets/logo.png'; // Replace with database call
    final String businessName =
        'Demo Business Name'; // Replace with database call
    final String cashierName = 'John Doe'; // Replace with user login data
    final List<String> categories = [
      'Category 1',
      'Category 2',
    ]; // Replace with database call
    final Map<String, List<String>> subCategories = {
      'Category 1': ['Sub 1', 'Sub 2'],
      'Category 2': ['Sub 3', 'Sub 4'],
    }; // Replace with database call

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
                          style: TextStyle(color: Colors.white),
                        ),
                        children:
                            subCategories[category]!.map((subCategory) {
                              return ListTile(
                                title: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: AssetImage(
                                        'assets/placeholder.png',
                                      ), // Replace with actual icon
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Text(
                                    subCategory,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedSubCategory = subCategory;
                                  });
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
                    : ProductSelectionArea(subCategory: selectedSubCategory!),
          ),
        ],
      ),
    );
  }
}

class ProductSelectionArea extends StatelessWidget {
  final String subCategory;

  const ProductSelectionArea({super.key, required this.subCategory});

  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration
    final String productImage =
        'assets/product.png'; // Replace with database call
    final String productName = 'Demo Product'; // Replace with database call
    final double productPrice = 10.0; // Replace with database call
    final List<String> sizes = [
      'Small',
      'Medium',
      'Large',
    ]; // Replace with database call
    final List<String> addIns = [
      'Add-In 1',
      'Add-In 2',
    ]; // Replace with database call

    return Container(
      width: MediaQuery.of(context).size.width * 0.55,
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1
          Row(
            children: [
              Image.asset(productImage, width: 100),
              SizedBox(width: 10),
              Text(productName, style: TextStyle(fontSize: 20)),
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
                    items:
                        sizes.map((String size) {
                          return DropdownMenuItem<String>(
                            value: size,
                            child: Text(size),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      // Handle size selection
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
                'Price: \$${productPrice.toStringAsFixed(2)}',
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
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: CashierDashboard()));
}
