// ignore_for_file: avoid_print

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer'; // For log
import 'package:mutex/mutex.dart'; // Add mutex dependency
import 'package:logger/logger.dart'; // Add this import

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }
}

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;
  final Mutex _dbMutex = Mutex(); // Add a mutex for thread safety
  final Logger _logger = Logger(); // Add this line

  Future<void> initializeDatabase() async {
    if (_database != null) return;

    _database = await openDatabase(
      join(await getDatabasesPath(), 'product_database.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE categories(id INTEGER PRIMARY KEY, name TEXT)',
        );
        await db.execute(
          'CREATE TABLE sub_categories(id INTEGER PRIMARY KEY, name TEXT, image TEXT, category_id INTEGER, FOREIGN KEY (category_id) REFERENCES categories(id))',
        );
        await db.execute(
          'CREATE TABLE products(id INTEGER PRIMARY KEY, name TEXT, image TEXT, sub_category_id INTEGER, FOREIGN KEY (sub_category_id) REFERENCES sub_categories(id))',
        );
        await db.execute(
          'CREATE TABLE add_ins (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, price REAL, product_id INTEGER, FOREIGN KEY (product_id) REFERENCES products (id))',
        );
        await db.execute(
          'CREATE TABLE business_details (id INTEGER PRIMARY KEY AUTOINCREMENT, detail TEXT, value TEXT)',
        );
        await db.execute(
          'CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password TEXT, role TEXT, name TEXT)',
        );
        await db.execute(
          'CREATE TABLE login_details(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, login_time TEXT, name TEXT, logout_time TEXT)', // Add this line
        );
      },
      version: 2, // Update the version number
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            ALTER TABLE login_details ADD COLUMN logout_time TEXT
          ''');
        }
        if (oldVersion < 3) {
          // Add this block
          await db.execute('''
            ALTER TABLE users ADD COLUMN logout_time TEXT
          ''');
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    return await _database!.query('categories');
  }

  Future<List<Map<String, dynamic>>> getSubCategoriesByCategory(
    String category,
  ) async {
    return await _database!.query(
      'sub_categories',
      where: 'category = ?',
      whereArgs: [category],
    );
  }

  Future<List<Map<String, dynamic>>> getProducts(
    String category,
    String subCategory,
  ) async {
    return await _database!.query(
      'products',
      where: 'category = ? AND sub_category = ?',
      whereArgs: [category, subCategory],
    );
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(
      dbPath,
      'product_database.db',
    ); // Ensure consistent database name

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
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sizes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER,
        size TEXT,
        price REAL,
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS login_details (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        login_time TEXT,
        name TEXT,
        logout_time TEXT // Add this line
      )
    ''');

    // Insert initial data
    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
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
    await _insertAddInIfNotExists(db, 'Cinnamon', 5.00, cappuccinoProductId);
    await _insertAddInIfNotExists(db, 'Brown Sugar', 5.00, cappuccinoProductId);

    await _insertSizeIfNotExists(db, 'Regular', 40.00, cappuccinoProductId);
    await _insertSizeIfNotExists(db, 'Medium', 60.00, cappuccinoProductId);
    await _insertSizeIfNotExists(db, 'Large', 80.00, cappuccinoProductId);

    final int cafeLatteProductId = await _insertProductIfNotExists(
      db,
      'Cafe Latte',
      'assets/cafe_latte.jpg',
      hotCoffeeSubCategoryId,
    );
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

    await _insertSizeIfNotExists(db, 'Regular', 40.00, cafeLatteProductId);
    await _insertSizeIfNotExists(db, 'Medium', 60.00, cafeLatteProductId);
    await _insertSizeIfNotExists(db, 'Large', 80.00, cafeLatteProductId);

    // Add products for Cold Coffee
    final int icedAmericanoProductId = await _insertProductIfNotExists(
      db,
      'Iced Americano',
      'assets/iced_coffee.jpg',
      coldCoffeeSubCategoryId,
    );
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

    await _insertSizeIfNotExists(db, 'Regular', 40.00, icedAmericanoProductId);
    await _insertSizeIfNotExists(db, 'Medium', 60.00, icedAmericanoProductId);
    await _insertSizeIfNotExists(db, 'Large', 80.00, icedAmericanoProductId);

    final int icedMochaProductId = await _insertProductIfNotExists(
      db,
      'Iced Mocha',
      'assets/iced_mocha.png',
      coldCoffeeSubCategoryId,
    );
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

    await _insertSizeIfNotExists(db, 'Regular', 40.00, icedMochaProductId);
    await _insertSizeIfNotExists(db, 'Medium', 60.00, icedMochaProductId);
    await _insertSizeIfNotExists(db, 'Large', 80.00, icedMochaProductId);

    // Add products for Milk Tea
    final int classicMilkTeaProductId = await _insertProductIfNotExists(
      db,
      'Classic Milk Tea',
      'assets/classic_milktea.jpg',
      milkTeaSubCategoryId,
    );
    await _insertAddInIfNotExists(db, 'Pearls', 10.00, classicMilkTeaProductId);
    await _insertAddInIfNotExists(
      db,
      'Pudding',
      15.00,
      classicMilkTeaProductId,
    );

    await _insertSizeIfNotExists(db, 'Regular', 40.00, classicMilkTeaProductId);
    await _insertSizeIfNotExists(db, 'Medium', 60.00, classicMilkTeaProductId);
    await _insertSizeIfNotExists(db, 'Large', 80.00, classicMilkTeaProductId);

    final int wintermelonMilkTeaProductId = await _insertProductIfNotExists(
      db,
      'Wintermelon Milk Tea',
      'assets/cold_milktea_wintermelon.png',
      milkTeaSubCategoryId,
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

    await _insertSizeIfNotExists(
      db,
      'Regular',
      40.00,
      wintermelonMilkTeaProductId,
    );
    await _insertSizeIfNotExists(
      db,
      'Medium',
      60.00,
      wintermelonMilkTeaProductId,
    );
    await _insertSizeIfNotExists(
      db,
      'Large',
      80.00,
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
    final int chocomuffinProductID = await _insertProductIfNotExists(
      db,
      'Choco Muffin',
      'assets/choco_muffin_image.png', // Corrected image path
      pastrySubCategoryId,
    );

    await _insertSizeIfNotExists(db, 'Regular', 50.00, chocomuffinProductID);

    // Add products for Sandwiches
    final int hamandcheeseProductID = await _insertProductIfNotExists(
      db,
      'Ham and Cheese',
      'assets/ham_cheese_image.png', // Ensure this path is correct
      sandwichesSubCategoryId,
    );

    await _insertSizeIfNotExists(db, 'Regular', 50.00, hamandcheeseProductID);

    final int tunameltProductID = await _insertProductIfNotExists(
      db,
      'Tuna Melt',
      'assets/tuna_melt.jpg',
      sandwichesSubCategoryId,
    );

    await _insertSizeIfNotExists(db, 'Regular', 50.00, tunameltProductID);

    // Add sub-categories for Other
    final int merchandiseSubCategoryId = await _insertSubCategoryIfNotExists(
      db,
      'Merchandise',
      'assets/keychain.jpg',
      otherCategoryId,
    );

    // Add products for Merchandise
    final int mugProductID = await _insertProductIfNotExists(
      db,
      'Mug',
      'assets/mug.jpg',
      merchandiseSubCategoryId,
    );

    await _insertSizeIfNotExists(db, 'Regular', 40.00, mugProductID);
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

  Future<int> deleteAddIn(int id) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      return await db.delete('add_ins', where: 'id = ?', whereArgs: [id]);
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

  Future<List<Map<String, dynamic>>> fetchAllProducts() async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      return await db.query('products');
    } finally {
      _dbMutex.release();
    }
  }

  Future<List<Map<String, dynamic>>> getAddIns() async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      return await db.query('add_ins'); // Fetch data from add_ins table
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
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
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
        join(
          await getDatabasesPath(),
          'product_database.db',
        ), // Ensure consistent database name
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

  Future<void> createAndSaveProductTables() async {
    await _dbMutex.acquire();
    try {
      Database db = await database;

      await db.execute('''
        CREATE TABLE IF NOT EXISTS sizes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          product_id INTEGER,
          size TEXT,
          price REAL,
          FOREIGN KEY (product_id) REFERENCES products(id)
        )
      ''');

      // Clear existing data
      await db.delete('add_ins');
      await db.delete('products');
      await db.delete('sub_categories');
      await db.delete('categories');

      // Add categories
      final int drinksCategoryId = await _insertCategoryIfNotExists(
        db,
        'Drinks',
      );
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
      await _insertAddInIfNotExists(db, 'Cinnamon', 5.00, cappuccinoProductId);
      await _insertAddInIfNotExists(
        db,
        'Brown Sugar',
        5.00,
        cappuccinoProductId,
      );

      await _insertSizeIfNotExists(db, 'Regular', 40.00, cappuccinoProductId);
      await _insertSizeIfNotExists(db, 'Medium', 60.00, cappuccinoProductId);
      await _insertSizeIfNotExists(db, 'Large', 80.00, cappuccinoProductId);

      final int cafeLatteProductId = await _insertProductIfNotExists(
        db,
        'Cafe Latte',
        'assets/hot_cafe_latte.png',
        hotCoffeeSubCategoryId,
      );
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

      await _insertSizeIfNotExists(db, 'Regular', 40.00, cafeLatteProductId);
      await _insertSizeIfNotExists(db, 'Medium', 60.00, cafeLatteProductId);
      await _insertSizeIfNotExists(db, 'Large', 80.00, cafeLatteProductId);

      // Add products for Cold Coffee
      final int icedAmericanoProductId = await _insertProductIfNotExists(
        db,
        'Iced Americano',
        'assets/iced_coffee.jpg',
        coldCoffeeSubCategoryId,
      );
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

      await _insertSizeIfNotExists(
        db,
        'Regular',
        40.00,
        icedAmericanoProductId,
      );
      await _insertSizeIfNotExists(db, 'Medium', 60.00, icedAmericanoProductId);
      await _insertSizeIfNotExists(db, 'Large', 80.00, icedAmericanoProductId);

      final int icedMochaProductId = await _insertProductIfNotExists(
        db,
        'Iced Mocha',
        'assets/iced_mocha.png',
        coldCoffeeSubCategoryId,
      );
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

      await _insertSizeIfNotExists(db, 'Regular', 40.00, icedMochaProductId);
      await _insertSizeIfNotExists(db, 'Medium', 60.00, icedMochaProductId);
      await _insertSizeIfNotExists(db, 'Large', 80.00, icedMochaProductId);

      // Add products for Milk Tea
      final int classicMilkTeaProductId = await _insertProductIfNotExists(
        db,
        'Classic Milk Tea',
        'assets/classic_milktea.jpg',
        milkTeaSubCategoryId,
      );
      await _insertAddInIfNotExists(
        db,
        'Pearls',
        10.00,
        classicMilkTeaProductId,
      );
      await _insertAddInIfNotExists(
        db,
        'Pudding',
        15.00,
        classicMilkTeaProductId,
      );

      await _insertSizeIfNotExists(
        db,
        'Regular',
        40.00,
        classicMilkTeaProductId,
      );
      await _insertSizeIfNotExists(
        db,
        'Medium',
        60.00,
        classicMilkTeaProductId,
      );
      await _insertSizeIfNotExists(db, 'Large', 80.00, classicMilkTeaProductId);

      final int wintermelonMilkTeaProductId = await _insertProductIfNotExists(
        db,
        'Wintermelon Milk Tea',
        'assets/cold_milktea_wintermelon.png',
        milkTeaSubCategoryId,
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

      await _insertSizeIfNotExists(
        db,
        'Regular',
        40.00,
        wintermelonMilkTeaProductId,
      );
      await _insertSizeIfNotExists(
        db,
        'Medium',
        60.00,
        wintermelonMilkTeaProductId,
      );
      await _insertSizeIfNotExists(
        db,
        'Large',
        80.00,
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
      final int chocomuffinProductID = await _insertProductIfNotExists(
        db,
        'Choco Muffin',
        'assets/choco_muffin_image.png', // Corrected image path
        pastrySubCategoryId,
      );

      await _insertSizeIfNotExists(db, 'Regular', 50.00, chocomuffinProductID);

      // Add products for Sandwiches
      final int hamandcheeseProductID = await _insertProductIfNotExists(
        db,
        'Ham and Cheese',
        'assets/ham_cheese_image.png', // Ensure this path is correct
        sandwichesSubCategoryId,
      );

      await _insertSizeIfNotExists(db, 'Regular', 50.00, hamandcheeseProductID);

      final int tunameltProductID = await _insertProductIfNotExists(
        db,
        'Tuna Melt',
        'assets/tuna_melt.jpg',
        sandwichesSubCategoryId,
      );

      await _insertSizeIfNotExists(db, 'Regular', 50.00, tunameltProductID);

      // Add sub-categories for Other
      final int merchandiseSubCategoryId = await _insertSubCategoryIfNotExists(
        db,
        'Merchandise',
        'assets/keychain.jpg',
        otherCategoryId,
      );

      // Add products for Merchandise
      final int mugProductID = await _insertProductIfNotExists(
        db,
        'Mug',
        'assets/mug.jpg',
        merchandiseSubCategoryId,
      );

      await _insertSizeIfNotExists(db, 'Regular', 40.00, mugProductID);

      // Add users
      await _insertUserIfNotExists(
        db,
        'cashier1',
        'password123',
        'cashier',
        'Julie',
      );
      await _insertUserIfNotExists(
        db,
        'admin',
        'password123',
        'admin',
        'Admin',
      );
    } finally {
      _dbMutex.release();
    }
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
      'assets/hot_brewed_coffee.jpg',
      drinksCategoryId,
    );
    final int coldCoffeeSubCategoryId = await _insertSubCategoryIfNotExists(
      db,
      'Cold Coffee',
      'assets/iced_coffee.jpg',
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
      'assets/cappuccino.jpg',
      hotCoffeeSubCategoryId,
    );
    await _insertAddInIfNotExists(db, 'Cinnamon', 5.00, cappuccinoProductId);
    await _insertAddInIfNotExists(db, 'Brown Sugar', 5.00, cappuccinoProductId);

    final int cafeLatteProductId = await _insertProductIfNotExists(
      db,
      'Cafe Latte',
      'assets/cafe_latte.jpg',
      hotCoffeeSubCategoryId,
    );
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
      'assets/cold_brew.jpg',
      coldCoffeeSubCategoryId,
    );
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
    await _insertProductIfNotExists(
      db,
      'Choco Muffin',
      'assets/choco_muffin_image.png', // Corrected image path
      pastrySubCategoryId,
    );

    // Insert products for Sandwiches
    await _insertProductIfNotExists(
      db,
      'Ham and Cheese',
      'assets/ham_cheese_image.png', // Ensure this path is correct
      sandwichesSubCategoryId,
    );

    await _insertProductIfNotExists(
      db,
      'Tuna Melt',
      'assets/tuna_melt.jpg',
      sandwichesSubCategoryId,
    );

    // Insert sub-categories for Other
    final int merchandiseSubCategoryId = await _insertSubCategoryIfNotExists(
      db,
      'Merchandise',
      'assets/keychain.jpg',
      otherCategoryId,
    );

    // Insert products for Merchandise
    await _insertProductIfNotExists(
      db,
      'Mug',
      'assets/mug.jpg',
      merchandiseSubCategoryId,
    );
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

  Future<void> updateLogoutTime(String username, String logoutTime) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      await db.update(
        'login_details',
        {'logout_time': logoutTime},
        where: 'username = ? AND logout_time IS NULL',
        whereArgs: [username],
      );
    } finally {
      _dbMutex.release();
    }
  }

  Future<void> insertLoginDetail(String username, String loginTime) async {
    await _dbMutex.acquire();
    try {
      Database db = await database;
      // Fetch the user's name from the users table
      final user = await db.query(
        'users',
        columns: ['name'],
        where: 'username = ?',
        whereArgs: [username],
      );
      final name = user.isNotEmpty ? user.first['name'] : 'N/A';

      await db.insert('login_details', {
        'username': username,
        'login_time': loginTime,
        'name': name, // Include the name in the login_details table
        'logout_time': null, // Initialize logout_time as null
      });
    } finally {
      _dbMutex.release();
    }
  }

  Future<Map<String, dynamic>?> getCategoryById(int id) async {
    final db = await database;
    final result = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getSubCategoryById(int id) async {
    final db = await database;
    final result = await db.query(
      'sub_categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<Map<String, dynamic>> fetchCategoryById(int id) async {
    final db = await database;
    final result = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : {};
  }

  Future<Map<String, dynamic>> fetchSubCategoryById(int id) async {
    final db = await database;
    final result = await db.query(
      'sub_categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : {};
  }

  Future<void> updateCategories(List<Category> categories) async {
    // Implement the logic to update categories in the database
    // Example:
    final db = await database;
    for (var category in categories) {
      await db.update(
        'categories',
        category.toMap(),
        where: 'id = ?',
        whereArgs: [category.id],
      );
    }
  }

  Future<List<Map<String, dynamic>>> getAddInList(String productId) async {
    final db = await database;
    return await db.query(
      'add_in_list',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  Future<String?> getProductName(int productId) async {
    final db = await database;
    final product = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [productId],
    );
    return product.isNotEmpty ? product.first['name'] as String? : null;
  }

  // Added this function to fetch AddIns by product ID
  Future<List<Map<String, dynamic>>> getAddInsByProductId(int productId) async {
    await _dbMutex.acquire();
    try {
      final db = await database;
      return await db.query(
        'add_ins',
        where: 'product_id = ?',
        whereArgs: [productId],
      );
    } finally {
      _dbMutex.release();
    }
  }

  Future<Map<String, dynamic>?> fetchProductById(int id) async {
    final db = await database;
    final result = await db.query('products', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getSizes(int productId) async {
    await _dbMutex.acquire();
    try {
      final db = await database;
      return await db.query(
        'sizes',
        where: 'product_id = ?',
        whereArgs: [productId],
      );
    } finally {
      _dbMutex.release();
    }
  }

  Future<void> deleteSize(int sizeId) async {
    final db = await database;
    await db.delete('sizes', where: 'id = ?', whereArgs: [sizeId]);
  }

  Future<List<Map<String, dynamic>>> getAllSizes() async {
    // Implement the method to fetch all sizes from the database
    // Example implementation:
    final db = await database;
    final List<Map<String, dynamic>> sizes = await db.query('sizes');
    return sizes;
  }

  Future<void> updateSize(int sizeId, Map<String, dynamic> values) async {
    await _dbMutex.acquire();
    try {
      final db = await database;
      await db.update('sizes', values, where: 'id = ?', whereArgs: [sizeId]);
    } finally {
      _dbMutex.release();
    }
  }

  Future<void> insertSize(Map<String, dynamic> size) async {
    final db = await database;
    await db.insert('sizes', size);
  }

  Future<void> _insertSizeIfNotExists(
    Database db,
    String size,
    double price,
    int productId,
  ) async {
    var result = await db.query(
      'sizes',
      where: 'product_id = ? AND size = ?',
      whereArgs: [productId, size],
    );
    if (result.isEmpty) {
      await db.insert('sizes', {
        'product_id': productId,
        'size': size,
        'price': price,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getLoginDetails() async {
    await _dbMutex.acquire();
    try {
      final db = await database;
      return await db.query('login_details');
    } finally {
      _dbMutex.release();
    }
  }
}
