// ignore_for_file: avoid_print

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:developer'; // For log
import 'package:mutex/mutex.dart'; // Add mutex dependency
import 'package:logger/logger.dart'; // Add this import

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;
  final Mutex _dbMutex = Mutex(); // Add a mutex for thread safety
  final Logger _logger = Logger(); // Add this line

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    sqfliteFfiInit();
    databaseFactory =
        databaseFactoryFfi; // Ensure this is called before using openDatabase
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'my_database.db');

    // Check if the database exists, if not create it.
    bool exists = await databaseFactory.databaseExists(path);
    if (!exists) {
      print("Database doesn't exist. Creating...");
      try {
        await createDatabase();
        await createAndSaveProductTables();
      } catch (e, stack) {
        log('Error creating or populating database: $e', stackTrace: stack);
      }
    }

    Database db;
    try {
      await _dbMutex.acquire(); // Acquire the mutex before opening the database
      db = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate:
              _onCreate, // onCreate will only be called if the database doesn't exist.
          readOnly: false, // Ensure the database is opened with write access
        ),
      );
      print("Database opened successfully.");
    } catch (e, stack) {
      log('Error opening database: $e', stackTrace: stack);
      rethrow; // Re-throw to let the calling function handle the error.
    } finally {
      _dbMutex.release(); // Release the mutex after opening (or any error)
    }
    return db;
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
  }

  Future<int> insertCategory(Map<String, dynamic> row) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      return await db.insert('categories', row);
    } finally {
      _dbMutex.release();
    }
  }

  Future<int> insertSubCategory(Map<String, dynamic> row) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      return await db.insert('sub_categories', row);
    } finally {
      _dbMutex.release();
    }
  }

  Future<int> insertProduct(Map<String, dynamic> row) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      return await db.insert('products', row);
    } finally {
      _dbMutex.release();
    }
  }

  Future<int> insertSize(Map<String, dynamic> row) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      return await db.insert('sizes', row);
    } finally {
      _dbMutex.release();
    }
  }

  Future<int> insertAddIn(Map<String, dynamic> row) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      return await db.insert('add_ins', row);
    } finally {
      _dbMutex.release();
    }
  }

  Future<int> updateCategory(Map<String, dynamic> row) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      int id = row['id'];
      return await db.update(
        'categories',
        row,
        where: 'id = ?',
        whereArgs: [id],
      );
    } finally {
      _dbMutex.release();
    }
  }

  Future<int> updateSubCategory(Map<String, dynamic> row) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      int id = row['id'];
      return await db.update(
        'sub_categories',
        row,
        where: 'id = ?',
        whereArgs: [id],
      );
    } finally {
      _dbMutex.release();
    }
  }

  Future<int> updateProduct(Map<String, dynamic> row) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      int id = row['id'];
      return await db.update('products', row, where: 'id = ?', whereArgs: [id]);
    } finally {
      _dbMutex.release();
    }
  }

  Future<int> updateSize(Map<String, dynamic> row) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      int id = row['id'];
      return await db.update('sizes', row, where: 'id = ?', whereArgs: [id]);
    } finally {
      _dbMutex.release();
    }
  }

  Future<int> updateAddIn(Map<String, dynamic> row) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      int id = row['id'];
      return await db.update('add_ins', row, where: 'id = ?', whereArgs: [id]);
    } finally {
      _dbMutex.release();
    }
  }

  Future<int> deleteCategory(int id) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
    } finally {
      _dbMutex.release();
    }
  }

  Future<int> deleteSubCategory(int id) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      return await db.delete(
        'sub_categories',
        where: 'id = ?',
        whereArgs: [id],
      );
    } finally {
      _dbMutex.release();
    }
  }

  Future<int> deleteProduct(int id) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      return await db.delete('products', where: 'id = ?', whereArgs: [id]);
    } finally {
      _dbMutex.release();
    }
  }

  Future<int> deleteSize(int id) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      return await db.delete('sizes', where: 'id = ?', whereArgs: [id]);
    } finally {
      _dbMutex.release();
    }
  }

  Future<int> deleteAddIn(int id) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      return await db.delete('add_ins', where: 'id = ?', whereArgs: [id]);
    } finally {
      _dbMutex.release();
    }
  }

  Future<int> deleteSizesByProductId(int productId) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      return await db.delete(
        'sizes',
        where: 'product_id = ?',
        whereArgs: [productId],
      );
    } finally {
      _dbMutex.release();
    }
  }

  Future<int> deleteAddInsByProductId(int productId) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      return await db.delete(
        'add_ins',
        where: 'product_id = ?',
        whereArgs: [productId],
      );
    } finally {
      _dbMutex.release();
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      return await db.query('categories');
    } finally {
      _dbMutex.release();
    }
  }

  Future<void> addCategory(String name) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      await db.insert('categories', {'name': name});
    } finally {
      _dbMutex.release();
    }
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      return await db.query('products');
    } finally {
      _dbMutex.release();
    }
  }

  Future<List<Map<String, dynamic>>> getSizes() async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      return await db.query('sizes');
    } finally {
      _dbMutex.release();
    }
  }

  Future<List<Map<String, dynamic>>> getAddIns() async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      return await db.query('add_ins');
    } finally {
      _dbMutex.release();
    }
  }

  Future<List<Map<String, dynamic>>> getSubCategories() async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      return await db.query('sub_categories');
    } finally {
      _dbMutex.release();
    }
  }

  Future<String?> fetchBusinessDetail(String detail) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      var result = await db.query(
        'business_details',
        where: 'detail = ?',
        whereArgs: [detail],
      );
      if (result.isNotEmpty) {
        return result.first['value'] as String?;
      }
      return null;
    } finally {
      _dbMutex.release();
    }
  }

  Future<Map<String, dynamic>?> getUser(
    String username,
    String password,
  ) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      var result = await db.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, password],
      );
      if (result.isNotEmpty) {
        return result.first;
      }
      return null;
    } finally {
      _dbMutex.release();
    }
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      var result = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );
      if (result.isNotEmpty) {
        return result.first;
      }
      return null;
    } finally {
      _dbMutex.release();
    }
  }

  Future<void> addUser(
    String name,
    String username,
    String password,
    String role,
  ) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      await db.insert('users', {
        'username': username,
        'password': password,
        'role': role,
        'name': name, // Add this line to save the name
      });
    } finally {
      _dbMutex.release();
    }
  }

  Future<void> updateUser(String username, Map<String, dynamic> values) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      await db.update(
        'users',
        values,
        where: 'username = ?',
        whereArgs: [username],
      );
    } finally {
      _dbMutex.release();
    }
  }

  Future<void> deleteUser(String username) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      await db.delete('users', where: 'username = ?', whereArgs: [username]);
    } finally {
      _dbMutex.release();
    }
  }

  Future<void> updateBusinessDetail(String detail, String value) async {
    final db = await database;
    try {
      var result = await db.query(
        'business_details',
        where: 'detail = ?',
        whereArgs: [detail],
      );

      if (result.isEmpty) {
        // Insert if the row doesn't exist
        await db.insert('business_details', {'detail': detail, 'value': value});
        _logger.i('Inserted new business detail: $detail = $value');
      } else {
        // Update if the row exists
        await db.update(
          'business_details',
          {'value': value},
          where: 'detail = ?',
          whereArgs: [detail],
        );
        _logger.i('Updated business detail: $detail = $value');
      }
    } catch (e) {
      _logger.e('Error updating/inserting $detail: $e');
    }
  }

  Future<void> createDatabase() async {
    await _dbMutex.acquire();
    try {
      Database db = await databaseFactory.openDatabase(
        join(await getDatabasesPath(), 'my_database.db'),
        options: OpenDatabaseOptions(version: 1),
      );
      await _onCreate(db, 1);
    } finally {
      _dbMutex.release();
    }
  }

  Future<List<Map<String, dynamic>>> getProductsWithDetails() async {
    await _dbMutex.acquire(); // Acquire mutex before database operation
    try {
      Database db = await database;
      List<Map<String, dynamic>> products = [];

      try {
        products = await db.query('products');

        for (var product in products) {
          int productId = product['id'];

          // Fetch sizes
          try {
            product['sizes'] = await db.query(
              'sizes',
              where: 'product_id = ?',
              whereArgs: [productId],
            );
          } catch (e) {
            print("Error querying sizes for product ID $productId: $e");
          }

          // Fetch add-ins
          try {
            product['addIns'] = await db.query(
              'add_ins',
              where: 'product_id = ?',
              whereArgs: [productId],
            );
          } catch (e) {
            print("Error querying add-ins for product ID $productId: $e");
          }
        }
      } catch (e) {
        print("Error loading products with details: $e");
      }

      return products;
    } catch (e) {
      if (e is UnsupportedError && e.message == 'read-only') {
        throw Exception('Database is in read-only mode');
      } else {
        rethrow; // Re-throw to let the calling function handle the error.
      }
    } finally {
      _dbMutex.release(); // Release mutex after operation
    }
  }

  Future<List<Map<String, dynamic>>> getAllSizes() async {
    Database db = await database;
    return await db.query('sizes');
  }

  Future<List<Map<String, dynamic>>> getAllAddIns() async {
    Database db = await database;
    return await db.query('add_ins');
  }

  Future<void> createAndSaveProductTables() async {
    Database db = await database;

    // Clear existing data
    await db.delete('sizes');
    await db.delete('add_ins');
    await db.delete('products');
    await db.delete('sub_categories');
    await db.delete('categories');

    // Add categories
    final int drinksCategoryId = await _insertCategoryIfNotExists(db, 'Drinks');
    final int foodCategoryId = await _insertCategoryIfNotExists(db, 'Food');
    final int otherCategoryId = await _insertCategoryIfNotExists(db, 'Other');

    // Add sub-categories for Drinks
    final int hotCoffeeSubCategoryId = await _insertSubCategoryIfNotExists(
      db,
      'Hot Coffee',
      'assets/hotcoffee_default.png',
      drinksCategoryId,
    );
    final int coldCoffeeSubCategoryId = await _insertSubCategoryIfNotExists(
      db,
      'Cold Coffee',
      'assets/cold_brew.jpg',
      drinksCategoryId,
    );
    final int milkTeaSubCategoryId = await _insertSubCategoryIfNotExists(
      db,
      'Milk Tea',
      'assets/milktea_default.png',
      drinksCategoryId,
    );

    // Add products for Hot Coffee
    final int cappuccinoProductId = await _insertProductIfNotExists(
      db,
      'Cappuccino',
      'assets/cappuccino.png',
      hotCoffeeSubCategoryId,
    );
    await _insertSizeIfNotExists(db, 'Small', 60.00, cappuccinoProductId);
    await _insertSizeIfNotExists(db, 'Medium', 80.00, cappuccinoProductId);
    await _insertSizeIfNotExists(db, 'Large', 90.00, cappuccinoProductId);
    await _insertAddInIfNotExists(db, 'Cinnamon', 5.00, cappuccinoProductId);
    await _insertAddInIfNotExists(db, 'Brown Sugar', 5.00, cappuccinoProductId);

    final int cafeLatteProductId = await _insertProductIfNotExists(
      db,
      'Cafe Latte',
      'assets/hot_cafe_latte.png',
      hotCoffeeSubCategoryId,
    );
    await _insertSizeIfNotExists(db, 'Small', 65.00, cafeLatteProductId);
    await _insertSizeIfNotExists(db, 'Medium', 85.00, cafeLatteProductId);
    await _insertSizeIfNotExists(db, 'Large', 95.00, cafeLatteProductId);
    await _insertAddInIfNotExists(
      db,
      'Vanilla Syrup',
      10.00,
      cafeLatteProductId,
    );
    await _insertAddInIfNotExists(
      db,
      'Caramel Syrup',
      10.00,
      cafeLatteProductId,
    );

    // Add products for Cold Coffee
    final int icedAmericanoProductId = await _insertProductIfNotExists(
      db,
      'Iced Americano',
      'assets/iced_coffee.jpg',
      coldCoffeeSubCategoryId,
    );
    await _insertSizeIfNotExists(db, 'Small', 70.00, icedAmericanoProductId);
    await _insertSizeIfNotExists(db, 'Medium', 90.00, icedAmericanoProductId);
    await _insertSizeIfNotExists(db, 'Large', 100.00, icedAmericanoProductId);
    await _insertAddInIfNotExists(
      db,
      'Extra Shot',
      15.00,
      icedAmericanoProductId,
    );
    await _insertAddInIfNotExists(
      db,
      'Sweet Cream',
      10.00,
      icedAmericanoProductId,
    );

    final int icedMochaProductId = await _insertProductIfNotExists(
      db,
      'Iced Mocha',
      'assets/iced_mocha.png',
      coldCoffeeSubCategoryId,
    );
    await _insertSizeIfNotExists(db, 'Small', 80.00, icedMochaProductId);
    await _insertSizeIfNotExists(db, 'Medium', 100.00, icedMochaProductId);
    await _insertSizeIfNotExists(db, 'Large', 110.00, icedMochaProductId);
    await _insertAddInIfNotExists(
      db,
      'Chocolate Drizzle',
      8.00,
      icedMochaProductId,
    );
    await _insertAddInIfNotExists(
      db,
      'Whipped Cream',
      10.00,
      icedMochaProductId,
    );

    // Add products for Milk Tea
    final int classicMilkTeaProductId = await _insertProductIfNotExists(
      db,
      'Classic Milk Tea',
      'assets/classic_milktea.jpg',
      milkTeaSubCategoryId,
    );
    await _insertSizeIfNotExists(db, 'Regular', 85.00, classicMilkTeaProductId);
    await _insertSizeIfNotExists(db, 'Large', 105.00, classicMilkTeaProductId);
    await _insertAddInIfNotExists(db, 'Pearls', 10.00, classicMilkTeaProductId);
    await _insertAddInIfNotExists(
      db,
      'Pudding',
      15.00,
      classicMilkTeaProductId,
    );

    final int wintermelonMilkTeaProductId = await _insertProductIfNotExists(
      db,
      'Wintermelon Milk Tea',
      'assets/cold_milktea_wintermelon.png',
      milkTeaSubCategoryId,
    );
    await _insertSizeIfNotExists(
      db,
      'Regular',
      90.00,
      wintermelonMilkTeaProductId,
    );
    await _insertSizeIfNotExists(
      db,
      'Large',
      110.00,
      wintermelonMilkTeaProductId,
    );
    await _insertAddInIfNotExists(
      db,
      'Grass Jelly',
      12.00,
      wintermelonMilkTeaProductId,
    );
    await _insertAddInIfNotExists(
      db,
      'Oreo Crumbs',
      18.00,
      wintermelonMilkTeaProductId,
    );

    // Add sub-categories for Food
    final int pastrySubCategoryId = await _insertSubCategoryIfNotExists(
      db,
      'Pastry',
      'assets/pastry_default.png',
      foodCategoryId,
    );
    final int sandwichesSubCategoryId = await _insertSubCategoryIfNotExists(
      db,
      'Sandwiches',
      'assets/sandwich_default.jpg',
      foodCategoryId,
    );

    // Add products for Pastry
    final int chocoMuffinProductId = await _insertProductIfNotExists(
      db,
      'Choco Muffin',
      'path/to/choco_muffin_image.png',
      pastrySubCategoryId,
    );
    await _insertSizeIfNotExists(db, 'Regular', 80.00, chocoMuffinProductId);

    final int croissantProductId = await _insertProductIfNotExists(
      db,
      'Croissant',
      'path/to/croissant_image.png',
      pastrySubCategoryId,
    );
    await _insertSizeIfNotExists(db, 'Regular', 80.00, croissantProductId);

    // Add products for Sandwiches
    final int hamCheeseProductId = await _insertProductIfNotExists(
      db,
      'Ham and Cheese',
      'path/to/ham_cheese_image.png',
      sandwichesSubCategoryId,
    );
    await _insertSizeIfNotExists(db, 'Regular', 90.00, hamCheeseProductId);

    final int tunaMeltProductId = await _insertProductIfNotExists(
      db,
      'Tuna Melt',
      'path/to/tuna_melt_image.png',
      sandwichesSubCategoryId,
    );
    await _insertSizeIfNotExists(db, 'Regular', 100.00, tunaMeltProductId);

    // Add sub-categories for Other
    final int merchandiseSubCategoryId = await _insertSubCategoryIfNotExists(
      db,
      'Merchandise',
      'assets/keychain.jpg',
      otherCategoryId,
    );

    // Add products for Merchandise
    final int tumblerProductId = await _insertProductIfNotExists(
      db,
      'Tumbler',
      'path/to/tumbler_image.png',
      merchandiseSubCategoryId,
    );
    await _insertSizeIfNotExists(
      db,
      'Small Tumbler (12oz)',
      250.00,
      tumblerProductId,
    );
    await _insertSizeIfNotExists(
      db,
      'Large Tumbler (16oz)',
      300.00,
      tumblerProductId,
    );
    await _insertSizeIfNotExists(
      db,
      'Stainless Steel Tumbler (20oz)',
      450.00,
      tumblerProductId,
    );

    final int mugProductId = await _insertProductIfNotExists(
      db,
      'Mug',
      'path/to/mug_image.png',
      merchandiseSubCategoryId,
    );
    await _insertSizeIfNotExists(
      db,
      'Ceramic Mug (12oz)',
      180.00,
      mugProductId,
    );
    await _insertSizeIfNotExists(db, 'Travel Mug (16oz)', 320.00, mugProductId);

    final int keychainProductId = await _insertProductIfNotExists(
      db,
      'Keychain',
      'path/to/keychain_image.png',
      merchandiseSubCategoryId,
    );
    await _insertSizeIfNotExists(db, 'Design 1', 80.00, keychainProductId);
    await _insertSizeIfNotExists(db, 'Design 2', 80.00, keychainProductId);

    // Add users
    await _insertUserIfNotExists(
      db,
      'cashier1',
      'password123',
      'cashier',
      'Julie',
    );
    await _insertUserIfNotExists(db, 'admin', 'password123', 'admin', 'Admin');
  }

  Future<int> _insertCategoryIfNotExists(Database db, String name) async {
    var result = await db.query(
      'categories',
      where: 'name = ?',
      whereArgs: [name],
    );
    if (result.isEmpty) {
      return await db.insert('categories', {'name': name});
    }
    return result.first['id'] as int;
  }

  Future<int> _insertSubCategoryIfNotExists(
    Database db,
    String name,
    String image,
    int categoryId,
  ) async {
    var result = await db.query(
      'sub_categories',
      where: 'name = ? AND category_id = ?',
      whereArgs: [name, categoryId],
    );
    if (result.isEmpty) {
      return await db.insert('sub_categories', {
        'name': name,
        'image': image,
        'category_id': categoryId,
      });
    }
    return result.first['id'] as int;
  }

  Future<int> _insertProductIfNotExists(
    Database db,
    String name,
    String image,
    int subCategoryId,
  ) async {
    var result = await db.query(
      'products',
      where: 'name = ? AND sub_category_id = ?',
      whereArgs: [name, subCategoryId],
    );
    if (result.isEmpty) {
      return await db.insert('products', {
        'name': name,
        'image': image,
        'sub_category_id': subCategoryId,
      });
    }
    return result.first['id'] as int;
  }

  Future<void> _insertSizeIfNotExists(
    Database db,
    String name,
    double price,
    int productId,
  ) async {
    var result = await db.query(
      'sizes',
      where: 'name = ? AND product_id = ?',
      whereArgs: [name, productId],
    );
    if (result.isEmpty) {
      await db.insert('sizes', {
        'name': name,
        'price': price,
        'product_id': productId,
      });
    }
  }

  Future<void> _insertAddInIfNotExists(
    Database db,
    String name,
    double price,
    int productId,
  ) async {
    var result = await db.query(
      'add_ins',
      where: 'name = ? AND product_id = ?',
      whereArgs: [name, productId],
    );
    if (result.isEmpty) {
      await db.insert('add_ins', {
        'name': name,
        'price': price,
        'product_id': productId,
      });
    }
  }

  Future<void> _insertUserIfNotExists(
    Database db,
    String username,
    String password,
    String role,
    String name,
  ) async {
    var result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (result.isEmpty) {
      await db.insert('users', {
        'username': username,
        'password': password,
        'role': role,
        'name': name, // Add this line to save the name
      });
    }
  }

  Future<bool> hasUsers() async {
    Database db = await database;
    var result = await db.query('users');
    return result.isNotEmpty;
  }

  Future<bool> hasProducts() async {
    Database db = await database;
    var result = await db.query('products');
    return result.isNotEmpty;
  }

  Future<void> insertUsersAndProducts() async {
    Database db = await database;

    // Insert users
    await _insertUserIfNotExists(
      db,
      'cashier1',
      'password123',
      'cashier',
      'Julie',
    );
    await _insertUserIfNotExists(db, 'admin', 'password123', 'admin', 'Admin');

    // Insert categories
    final int drinksCategoryId = await _insertCategoryIfNotExists(db, 'Drinks');
    final int foodCategoryId = await _insertCategoryIfNotExists(db, 'Food');
    final int otherCategoryId = await _insertCategoryIfNotExists(db, 'Other');

    // Insert sub-categories for Drinks
    final int hotCoffeeSubCategoryId = await _insertSubCategoryIfNotExists(
      db,
      'Hot Coffee',
      'path/to/hot_coffee_image.png',
      drinksCategoryId,
    );
    final int coldCoffeeSubCategoryId = await _insertSubCategoryIfNotExists(
      db,
      'Cold Coffee',
      'path/to/cold_coffee_image.png',
      drinksCategoryId,
    );
    final int milkTeaSubCategoryId = await _insertSubCategoryIfNotExists(
      db,
      'Milk Tea',
      'path/to/milk_tea_image.png',
      drinksCategoryId,
    );

    // Insert products for Hot Coffee
    final int cappuccinoProductId = await _insertProductIfNotExists(
      db,
      'Cappuccino',
      'path/to/cappuccino_image.png',
      hotCoffeeSubCategoryId,
    );
    await _insertSizeIfNotExists(db, 'Small', 60.00, cappuccinoProductId);
    await _insertSizeIfNotExists(db, 'Medium', 80.00, cappuccinoProductId);
    await _insertSizeIfNotExists(db, 'Large', 90.00, cappuccinoProductId);
    await _insertAddInIfNotExists(db, 'Cinnamon', 5.00, cappuccinoProductId);
    await _insertAddInIfNotExists(db, 'Brown Sugar', 5.00, cappuccinoProductId);

    final int cafeLatteProductId = await _insertProductIfNotExists(
      db,
      'Cafe Latte',
      'path/to/cafe_latte_image.png',
      hotCoffeeSubCategoryId,
    );
    await _insertSizeIfNotExists(db, 'Small', 65.00, cafeLatteProductId);
    await _insertSizeIfNotExists(db, 'Medium', 85.00, cafeLatteProductId);
    await _insertSizeIfNotExists(db, 'Large', 95.00, cafeLatteProductId);
    await _insertAddInIfNotExists(
      db,
      'Vanilla Syrup',
      10.00,
      cafeLatteProductId,
    );
    await _insertAddInIfNotExists(
      db,
      'Caramel Syrup',
      10.00,
      cafeLatteProductId,
    );

    // Insert products for Cold Coffee
    final int icedAmericanoProductId = await _insertProductIfNotExists(
      db,
      'Iced Americano',
      'path/to/iced_americano_image.png',
      coldCoffeeSubCategoryId,
    );
    await _insertSizeIfNotExists(db, 'Small', 70.00, icedAmericanoProductId);
    await _insertSizeIfNotExists(db, 'Medium', 90.00, icedAmericanoProductId);
    await _insertSizeIfNotExists(db, 'Large', 100.00, icedAmericanoProductId);
    await _insertAddInIfNotExists(
      db,
      'Extra Shot',
      15.00,
      icedAmericanoProductId,
    );
    await _insertAddInIfNotExists(
      db,
      'Sweet Cream',
      10.00,
      icedAmericanoProductId,
    );

    final int icedMochaProductId = await _insertProductIfNotExists(
      db,
      'Iced Mocha',
      'path/to/iced_mocha_image.png',
      coldCoffeeSubCategoryId,
    );
    await _insertSizeIfNotExists(db, 'Small', 80.00, icedMochaProductId);
    await _insertSizeIfNotExists(db, 'Medium', 100.00, icedMochaProductId);
    await _insertSizeIfNotExists(db, 'Large', 110.00, icedMochaProductId);
    await _insertAddInIfNotExists(
      db,
      'Chocolate Drizzle',
      8.00,
      icedMochaProductId,
    );
    await _insertAddInIfNotExists(
      db,
      'Whipped Cream',
      10.00,
      icedMochaProductId,
    );

    // Insert products for Milk Tea
    final int classicMilkTeaProductId = await _insertProductIfNotExists(
      db,
      'Classic Milk Tea',
      'path/to/classic_milk_tea_image.png',
      milkTeaSubCategoryId,
    );
    await _insertSizeIfNotExists(db, 'Regular', 85.00, classicMilkTeaProductId);
    await _insertSizeIfNotExists(db, 'Large', 105.00, classicMilkTeaProductId);
    await _insertAddInIfNotExists(db, 'Pearls', 10.00, classicMilkTeaProductId);
    await _insertAddInIfNotExists(
      db,
      'Pudding',
      15.00,
      classicMilkTeaProductId,
    );

    final int wintermelonMilkTeaProductId = await _insertProductIfNotExists(
      db,
      'Wintermelon Milk Tea',
      'path/to/wintermelon_milk_tea_image.png',
      milkTeaSubCategoryId,
    );
    await _insertSizeIfNotExists(
      db,
      'Regular',
      90.00,
      wintermelonMilkTeaProductId,
    );
    await _insertSizeIfNotExists(
      db,
      'Large',
      110.00,
      wintermelonMilkTeaProductId,
    );
    await _insertAddInIfNotExists(
      db,
      'Grass Jelly',
      12.00,
      wintermelonMilkTeaProductId,
    );
    await _insertAddInIfNotExists(
      db,
      'Oreo Crumbs',
      18.00,
      wintermelonMilkTeaProductId,
    );

    // Insert sub-categories for Food
    final int pastrySubCategoryId = await _insertSubCategoryIfNotExists(
      db,
      'Pastry',
      'path/to/pastry_image.png',
      foodCategoryId,
    );
    final int sandwichesSubCategoryId = await _insertSubCategoryIfNotExists(
      db,
      'Sandwiches',
      'path/to/sandwiches_image.png',
      foodCategoryId,
    );

    // Insert products for Pastry
    final int chocoMuffinProductId = await _insertProductIfNotExists(
      db,
      'Choco Muffin',
      'path/to/choco_muffin_image.png',
      pastrySubCategoryId,
    );
    await _insertSizeIfNotExists(db, 'Regular', 80.00, chocoMuffinProductId);

    final int croissantProductId = await _insertProductIfNotExists(
      db,
      'Croissant',
      'path/to/croissant_image.png',
      pastrySubCategoryId,
    );
    await _insertSizeIfNotExists(db, 'Regular', 80.00, croissantProductId);

    // Insert products for Sandwiches
    final int hamCheeseProductId = await _insertProductIfNotExists(
      db,
      'Ham and Cheese',
      'path/to/ham_cheese_image.png',
      sandwichesSubCategoryId,
    );
    await _insertSizeIfNotExists(db, 'Regular', 90.00, hamCheeseProductId);

    final int tunaMeltProductId = await _insertProductIfNotExists(
      db,
      'Tuna Melt',
      'path/to/tuna_melt_image.png',
      sandwichesSubCategoryId,
    );
    await _insertSizeIfNotExists(db, 'Regular', 100.00, tunaMeltProductId);

    // Insert sub-categories for Other
    final int merchandiseSubCategoryId = await _insertSubCategoryIfNotExists(
      db,
      'Merchandise',
      'path/to/merchandise_image.png',
      otherCategoryId,
    );

    // Insert products for Merchandise
    final int tumblerProductId = await _insertProductIfNotExists(
      db,
      'Tumbler',
      'path/to/tumbler_image.png',
      merchandiseSubCategoryId,
    );
    await _insertSizeIfNotExists(
      db,
      'Small Tumbler (12oz)',
      250.00,
      tumblerProductId,
    );
    await _insertSizeIfNotExists(
      db,
      'Large Tumbler (16oz)',
      300.00,
      tumblerProductId,
    );
    await _insertSizeIfNotExists(
      db,
      'Stainless Steel Tumbler (20oz)',
      450.00,
      tumblerProductId,
    );

    final int mugProductId = await _insertProductIfNotExists(
      db,
      'Mug',
      'path/to/mug_image.png',
      merchandiseSubCategoryId,
    );
    await _insertSizeIfNotExists(
      db,
      'Ceramic Mug (12oz)',
      180.00,
      mugProductId,
    );
    await _insertSizeIfNotExists(db, 'Travel Mug (16oz)', 320.00, mugProductId);

    final int keychainProductId = await _insertProductIfNotExists(
      db,
      'Keychain',
      'path/to/keychain_image.png',
      merchandiseSubCategoryId,
    );
    await _insertSizeIfNotExists(db, 'Design 1', 80.00, keychainProductId);
    await _insertSizeIfNotExists(db, 'Design 2', 80.00, keychainProductId);
  }

  Future<String?> getBusinessDetail(String detail) async {
    final db = await database;
    try {
      final result = await db.query(
        'business_details',
        columns: ['value'],
        where: 'detail = ?',
        whereArgs: [detail],
      );
      if (result.isNotEmpty) {
        return result.first['value'] as String?;
      }
    } catch (e) {
      _logger.e('Error fetching $detail: $e'); // Add logging
    }
    return null;
  }
}
