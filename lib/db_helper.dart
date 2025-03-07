import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Specify the path to the sqlite3.dll file
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'my_database.db');

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _onCreate,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sub_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        image TEXT,
        category_id INTEGER,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        image TEXT,
        sub_category_id INTEGER,
        FOREIGN KEY (sub_category_id) REFERENCES sub_categories (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sizes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        price REAL,
        product_id INTEGER,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS add_ins (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        price REAL,
        product_id INTEGER,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS business_details (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        detail TEXT,
        value TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        password TEXT,
        role TEXT,
        name TEXT
      )
    ''');

    // Add initial data
    await addInitialData(db);
  }

  Future<int> insertCategory(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('categories', row);
  }

  Future<int> insertSubCategory(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('sub_categories', row);
  }

  Future<int> insertProduct(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('products', row);
  }

  Future<int> insertSize(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('sizes', row);
  }

  Future<int> insertAddIn(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('add_ins', row);
  }

  Future<int> updateCategory(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update('categories', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateSubCategory(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update('sub_categories', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateProduct(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update('products', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateSize(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update('sizes', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateAddIn(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update('add_ins', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCategory(int id) async {
    Database db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteSubCategory(int id) async {
    Database db = await database;
    return await db.delete('sub_categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteProduct(int id) async {
    Database db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteSize(int id) async {
    Database db = await database;
    return await db.delete('sizes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAddIn(int id) async {
    Database db = await database;
    return await db.delete('add_ins', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    Database db = await database;
    return await db.query('categories');
  }

  Future<void> addCategory(String name) async {
    Database db = await database;
    await db.insert('categories', {'name': name});
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    Database db = await database;
    return await db.query('products');
  }

  Future<List<Map<String, dynamic>>> getSizes() async {
    Database db = await database;
    return await db.query('sizes');
  }

  Future<List<Map<String, dynamic>>> getAddIns() async {
    Database db = await database;
    return await db.query('add_ins');
  }

  Future<List<Map<String, dynamic>>> getSubCategories() async {
    Database db = await database;
    return await db.query('sub_categories');
  }

  Future<String?> getBusinessDetail(String detail) async {
    Database db = await database;
    var result = await db.query('business_details', where: 'detail = ?', whereArgs: [detail]);
    if (result.isNotEmpty) {
      return result.first['value'] as String?;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUser(String username, String password) async {
    Database db = await database;
    var result = await db.query('users', where: 'username = ? AND password = ?', whereArgs: [username, password]);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    Database db = await database;
    var result = await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<void> addInitialData(Database db) async {
    // Add categories
    final int drinksCategoryId = await _insertCategoryIfNotExists(db, 'Drinks');
    final int foodCategoryId = await _insertCategoryIfNotExists(db, 'Food');
    final int otherCategoryId = await _insertCategoryIfNotExists(db, 'Other');

    // Add sub-categories for Drinks
    final int hotCoffeeSubCategoryId = await _insertSubCategoryIfNotExists(db, 'Hot Coffee', 'assets/logo.png', drinksCategoryId);
    final int coldCoffeeSubCategoryId = await _insertSubCategoryIfNotExists(db, 'Cold Coffee', 'assets/logo.png', drinksCategoryId);
    final int milkTeaSubCategoryId = await _insertSubCategoryIfNotExists(db, 'Milk Tea', 'assets/logo.png', drinksCategoryId);

    // Add products for Hot Coffee
    final int cappuccinoProductId = await _insertProductIfNotExists(db, 'Cappuccino', 'assets/logo.png', hotCoffeeSubCategoryId);
    await _insertSizeIfNotExists(db, 'Small', 60.00, cappuccinoProductId);
    await _insertSizeIfNotExists(db, 'Medium', 80.00, cappuccinoProductId);
    await _insertSizeIfNotExists(db, 'Large', 90.00, cappuccinoProductId);
    await _insertAddInIfNotExists(db, 'Cinnamon', 5.00, cappuccinoProductId);
    await _insertAddInIfNotExists(db, 'Brown Sugar', 5.00, cappuccinoProductId);

    final int cafeLatteProductId = await _insertProductIfNotExists(db, 'Cafe Latte', 'assets/logo.png', hotCoffeeSubCategoryId);
    await _insertSizeIfNotExists(db, 'Small', 65.00, cafeLatteProductId);
    await _insertSizeIfNotExists(db, 'Medium', 85.00, cafeLatteProductId);
    await _insertSizeIfNotExists(db, 'Large', 95.00, cafeLatteProductId);
    await _insertAddInIfNotExists(db, 'Vanilla Syrup', 10.00, cafeLatteProductId);
    await _insertAddInIfNotExists(db, 'Caramel Syrup', 10.00, cafeLatteProductId);

    // Add products for Cold Coffee
    final int icedAmericanoProductId = await _insertProductIfNotExists(db, 'Iced Americano', 'assets/logo.png', coldCoffeeSubCategoryId);
    await _insertSizeIfNotExists(db, 'Small', 70.00, icedAmericanoProductId);
    await _insertSizeIfNotExists(db, 'Medium', 90.00, icedAmericanoProductId);
    await _insertSizeIfNotExists(db, 'Large', 100.00, icedAmericanoProductId);
    await _insertAddInIfNotExists(db, 'Extra Shot', 15.00, icedAmericanoProductId);
    await _insertAddInIfNotExists(db, 'Sweet Cream', 10.00, icedAmericanoProductId);

    final int icedMochaProductId = await _insertProductIfNotExists(db, 'Iced Mocha', 'assets/logo.png', coldCoffeeSubCategoryId);
    await _insertSizeIfNotExists(db, 'Small', 80.00, icedMochaProductId);
    await _insertSizeIfNotExists(db, 'Medium', 100.00, icedMochaProductId);
    await _insertSizeIfNotExists(db, 'Large', 110.00, icedMochaProductId);
    await _insertAddInIfNotExists(db, 'Chocolate Drizzle', 8.00, icedMochaProductId);
    await _insertAddInIfNotExists(db, 'Whipped Cream', 10.00, icedMochaProductId);

    // Add products for Milk Tea
    final int classicMilkTeaProductId = await _insertProductIfNotExists(db, 'Classic Milk Tea', 'assets/logo.png', milkTeaSubCategoryId);
    await _insertSizeIfNotExists(db, 'Regular', 85.00, classicMilkTeaProductId);
    await _insertSizeIfNotExists(db, 'Large', 105.00, classicMilkTeaProductId);
    await _insertAddInIfNotExists(db, 'Pearls', 10.00, classicMilkTeaProductId);
    await _insertAddInIfNotExists(db, 'Pudding', 15.00, classicMilkTeaProductId);

    final int wintermelonMilkTeaProductId = await _insertProductIfNotExists(db, 'Wintermelon Milk Tea', 'assets/logo.png', milkTeaSubCategoryId);
    await _insertSizeIfNotExists(db, 'Regular', 90.00, wintermelonMilkTeaProductId);
    await _insertSizeIfNotExists(db, 'Large', 110.00, wintermelonMilkTeaProductId);
    await _insertAddInIfNotExists(db, 'Grass Jelly', 12.00, wintermelonMilkTeaProductId);
    await _insertAddInIfNotExists(db, 'Oreo Crumbs', 18.00, wintermelonMilkTeaProductId);

    // Add sub-categories for Food
    final int pastrySubCategoryId = await _insertSubCategoryIfNotExists(db, 'Pastry', 'assets/logo.png', foodCategoryId);
    final int sandwichesSubCategoryId = await _insertSubCategoryIfNotExists(db, 'Sandwiches', 'assets/logo.png', foodCategoryId);

    // Add products for Pastry
    final int muffinProductId = await _insertProductIfNotExists(db, 'Muffin', 'assets/logo.png', pastrySubCategoryId);
    await _insertSizeIfNotExists(db, 'Price', 50.00, muffinProductId);

    final int croissantProductId = await _insertProductIfNotExists(db, 'Croissant', 'assets/logo.png', pastrySubCategoryId);
    await _insertSizeIfNotExists(db, 'Price', 70.00, croissantProductId);

    // Add products for Sandwiches
    final int hamCheeseProductId = await _insertProductIfNotExists(db, 'Ham and Cheese', 'assets/logo.png', sandwichesSubCategoryId);
    await _insertSizeIfNotExists(db, 'Price', 90.00, hamCheeseProductId);

    final int tunaMeltProductId = await _insertProductIfNotExists(db, 'Tuna Melt', 'assets/logo.png', sandwichesSubCategoryId);
    await _insertSizeIfNotExists(db, 'Price', 100.00, tunaMeltProductId);

    // Add sub-categories for Other
    final int merchandiseSubCategoryId = await _insertSubCategoryIfNotExists(db, 'Merchandise', 'assets/logo.png', otherCategoryId);

    // Add products for Merchandise
    final int tumblerProductId = await _insertProductIfNotExists(db, 'Tumbler', 'assets/logo.png', merchandiseSubCategoryId);
    await _insertSizeIfNotExists(db, 'Small Tumbler (12oz)', 250.00, tumblerProductId);
    await _insertSizeIfNotExists(db, 'Large Tumbler (16oz)', 300.00, tumblerProductId);
    await _insertSizeIfNotExists(db, 'Stainless Steel Tumbler (20oz)', 450.00, tumblerProductId);

    final int mugProductId = await _insertProductIfNotExists(db, 'Mug', 'assets/logo.png', merchandiseSubCategoryId);
    await _insertSizeIfNotExists(db, 'Ceramic Mug (12oz)', 180.00, mugProductId);
    await _insertSizeIfNotExists(db, 'Travel Mug (16oz)', 320.00, mugProductId);

    final int toteBagProductId = await _insertProductIfNotExists(db, 'Tote Bag', 'assets/logo.png', merchandiseSubCategoryId);
    await _insertSizeIfNotExists(db, 'Small Tote Bag', 200.00, toteBagProductId);
    await _insertSizeIfNotExists(db, 'Large Tote Bag', 280.00, toteBagProductId);

    final int keychainProductId = await _insertProductIfNotExists(db, 'Keychain', 'assets/logo.png', merchandiseSubCategoryId);
    await _insertSizeIfNotExists(db, 'Design 1', 80.00, keychainProductId);
    await _insertSizeIfNotExists(db, 'Design 2', 80.00, keychainProductId);

    // Add initial users
    await _insertUserIfNotExists(db, 'admin', 'password123', 'admin', 'Admin');
    await _insertUserIfNotExists(db, 'cashier', 'password123', 'cashier', 'Julie');
  }

  Future<int> _insertCategoryIfNotExists(Database db, String name) async {
    var result = await db.query('categories', where: 'name = ?', whereArgs: [name]);
    if (result.isEmpty) {
      return await db.insert('categories', {'name': name});
    }
    return result.first['id'] as int;
  }

  Future<int> _insertSubCategoryIfNotExists(Database db, String name, String image, int categoryId) async {
    var result = await db.query('sub_categories', where: 'name = ? AND category_id = ?', whereArgs: [name, categoryId]);
    if (result.isEmpty) {
      return await db.insert('sub_categories', {'name': name, 'image': image, 'category_id': categoryId});
    }
    return result.first['id'] as int;
  }

  Future<int> _insertProductIfNotExists(Database db, String name, String image, int subCategoryId) async {
    var result = await db.query('products', where: 'name = ? AND sub_category_id = ?', whereArgs: [name, subCategoryId]);
    if (result.isEmpty) {
      return await db.insert('products', {'name': name, 'image': image, 'sub_category_id': subCategoryId});
    }
    return result.first['id'] as int;
  }

  Future<void> _insertSizeIfNotExists(Database db, String name, double price, int productId) async {
    var result = await db.query('sizes', where: 'name = ? AND product_id = ?', whereArgs: [name, productId]);
    if (result.isEmpty) {
      await db.insert('sizes', {'name': name, 'price': price, 'product_id': productId});
    }
  }

  Future<void> _insertAddInIfNotExists(Database db, String name, double price, int productId) async {
    var result = await db.query('add_ins', where: 'name = ? AND product_id = ?', whereArgs: [name, productId]);
    if (result.isEmpty) {
      await db.insert('add_ins', {'name': name, 'price': price, 'product_id': productId});
    }
  }

  Future<void> _insertUserIfNotExists(Database db, String username, String password, String role, String name) async {
    var result = await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (result.isEmpty) {
      await db.insert('users', {'username': username, 'password': password, 'role': role, 'name': name});
    }
  }

  Future<void> addUser(String name, String username, String password, String role) async {
    Database db = await database;
    await db.insert('users', {'username': username, 'password': password, 'role': role});
  }

  Future<void> updateUser(String username, Map<String, dynamic> values) async {
    Database db = await database;
    await db.update('users', values, where: 'username = ?', whereArgs: [username]);
  }

  Future<void> deleteUser(String username) async {
    Database db = await database;
    await db.delete('users', where: 'username = ?', whereArgs: [username]);
  }

  Future<void> updateBusinessDetail(String detail, String value) async {
    Database db = await database;
    int result = await db.update('business_details', {'value': value}, where: 'detail = ?', whereArgs: [detail]);
    print('Update result for $detail: $result');
  }

  Future<void> createDatabase() async {
    Database db = await database;
    await _onCreate(db, 1);
  }
}
