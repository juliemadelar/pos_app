import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer' as developer;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'product_database.db');
    return await openDatabase(
      path,
      version: 6, // Increased version number to trigger upgrade
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE sub_categories (
        id INTEGER PRIMARY KEY,
        category_id INTEGER,
        name TEXT,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        sub_category_id INTEGER,
        name TEXT,
        image TEXT,
        FOREIGN KEY (sub_category_id) REFERENCES sub_categories (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE child_sizes (
        id INTEGER PRIMARY KEY,
        product_id INTEGER,
        size TEXT,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE add_ins (
        id INTEGER PRIMARY KEY,
        product_id INTEGER,
        name TEXT,
        price REAL,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE sizes (
        id INTEGER PRIMARY KEY,
        product_id INTEGER,
        size TEXT,
        price REAL,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE cashiers (
        id INTEGER PRIMARY KEY,
        name TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        username TEXT UNIQUE,
        password TEXT,
        email TEXT UNIQUE,
        logout_time TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE business_details (
        id INTEGER PRIMARY KEY,
        value TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE login_details (
        id INTEGER PRIMARY KEY,
        username TEXT,
        login_time TEXT,
        name TEXT,
        logout_time TEXT
      )
    ''');
    await _insertInitialCashierData(db);
    await _insertInitialBusinessData(db);
  }

  Future<void> _updateDatabaseSchema(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    try {
      if (oldVersion < 5) {
        await db.execute('''
          ALTER TABLE users ADD COLUMN logout_time TEXT;
        ''');
      }
      // Add other upgrade logic as needed for future versions
    } catch (e) {
      developer.log('Error upgrading database schema: $e');
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    developer.log('Upgrading database from $oldVersion to $newVersion');
    await _updateDatabaseSchema(db, oldVersion, newVersion);
  }

  Future<void> _insertInitialCashierData(Database db) async {
    await db.insert(
      'cashiers',
      {'id': 1, 'name': 'Default Cashier Name'}, // Replace with actual name
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _insertInitialBusinessData(Database db) async {
    const String businessName = 'My Business Name'; // Define the business name
    await db.insert(
      'business_details',
      {'id': 1, 'value': businessName}, // Use the defined business name
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getCategoryList() async {
    Database db = await database;
    return await db.query('categories');
  }

  Future<List<Map<String, dynamic>>> getSubCategoryList(int categoryId) async {
    Database db = await database;
    return await db.query(
      'sub_categories',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
  }

  Future<List<Map<String, dynamic>>> getProductList(int subCategoryId) async {
    Database db = await database;
    return await db.query(
      'products',
      where: 'sub_category_id = ?',
      whereArgs: [subCategoryId],
    );
  }

  Future<List<Map<String, dynamic>>> getChildSizesList(int productId) async {
    Database db = await database;
    return await db.query(
      'child_sizes',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  Future<List<Map<String, dynamic>>> getAddInList(int productId) async {
    Database db = await database;
    return await db.query(
      'add_ins',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  Future<List<Map<String, dynamic>>> getSizeList(int productId) async {
    Database db = await database;
    return await db.query(
      'sizes',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  Future<List<Map<String, dynamic>>> getProductListBySubCategory(
    String subCategoryName,
  ) async {
    Database db = await database;
    return await db.rawQuery(
      '''
      SELECT p.id, p.name, p.image, p.sub_category_id
      FROM products p
      JOIN sub_categories sc ON p.sub_category_id = sc.id
      WHERE sc.name = ?
    ''',
      [subCategoryName],
    );
  }

  Future<List<Map<String, dynamic>>> getSizeListByProductId(
    int productId,
  ) async {
    Database db = await database;
    return await db.query(
      'sizes',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  Future<List<Map<String, dynamic>>> getAddInsByProductId(int productId) async {
    final db = await database;
    return await db.query(
      'add_ins',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  Future<Map<int, List<Map<String, dynamic>>>> fetchAddInsForProducts(
    List<Map<String, dynamic>> products,
  ) async {
    final db = await database;
    final batch = db.batch();
    final addInsMap = <int, List<Map<String, dynamic>>>{};

    for (final product in products) {
      final productId = product['id'];
      batch.query('add_ins', where: 'product_id = ?', whereArgs: [productId]);
    }

    final results = await batch.commit();
    for (int i = 0; i < products.length; i++) {
      addInsMap[products[i]['id']] = results[i] as List<Map<String, dynamic>>;
    }
    return addInsMap;
  }

  Future<String?> getCashierName() async {
    final db = await database;
    final result = await db.query(
      'cashiers',
      where: 'id = ?',
      whereArgs: [1], // Assuming you have a cashier with ID 1
    );
    return result.isNotEmpty ? result.first['name'] as String? : null;
  }

  Future<String?> getBusinessDetail(int id) async {
    final db = await database;
    final result = await db.query(
      'business_details',
      columns: ['value'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first['value'] as String?;
    }
    return null;
  }

  Future<String?> getBusinessName() async {
    return getBusinessDetail(1);
  }

  Future<String?> getBusinessAddress() async {
    return getBusinessDetail(2);
  }

  Future<String?> getContactNumber() async {
    return getBusinessDetail(3);
  }

  Future<String?> getTaxId() async {
    return getBusinessDetail(4);
  }

  Future<String?> getBusinessLogoLocation() async {
    final db = await database;
    try {
      final result = await db.query(
        'business_details',
        columns: ['value'],
        where: 'id = ?',
        whereArgs: [5],
      );
      return result.isNotEmpty ? result.first['value'] as String? : null;
    } catch (e) {
      developer.log('Error fetching business logo: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUserDetails(int userId) async {
    Database db = await database;
    return await db.query('users', where: 'id = ?', whereArgs: [userId]);
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    Database db = await database;
    return await db.query('users');
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    developer.log('Query result for username $username: $result'); // Debug log
    if (result.isNotEmpty) {
      developer.log('User found: ${result.first}'); // Debug log
      return result.first;
    } else {
      developer.log('User not found for username: $username'); // Debug log
      return null;
    }
  }

  Future<void> updateLogoutTime(String username) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'login_details',
      {'logout_time': now},
      where: 'username = ? AND logout_time IS NULL',
      whereArgs: [username],
    );
  }

  Future<void> updateLogoutTimeWithCustomTime(
    String username,
    String logoutTime,
  ) async {
    final db = await database;
    await db.update(
      'login_details',
      {'logout_time': logoutTime},
      where: 'username = ?',
      whereArgs: [username],
    );
    developer.log('Logout time updated for $username'); // Debug log
  }

  Future<void> recordLoginTime(String username) async {
    final db = await database;
    final user = await getUserByUsername(username);
    if (user != null) {
      await db.insert('login_details', {
        'username': username,
        'login_time': DateTime.now().toIso8601String(),
        'name': user['name'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> recordLogoutTime(String username) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    developer.log('Updating logout time for $username at $now');
    final rowsAffected = await db.update(
      'login_details',
      {'logout_time': now},
      where: 'username = ? AND logout_time IS NULL',
      whereArgs: [username],
    );
    developer.log(
      'Logout time recorded for $username, rows affected: $rowsAffected',
    );
  }

  Future<double> getTaxValue() async {
    final db = await database;
    final result = await db.query(
      'business_details',
      columns: ['value'],
      where: 'id = ?',
      whereArgs: [9],
    );

    if (result.isNotEmpty) {
      return double.tryParse(result.first['value'] as String) ?? 0.0;
    } else {
      return 0.0;
    }
  }
}
