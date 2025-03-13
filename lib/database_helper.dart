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
      version: 2,
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
        email TEXT UNIQUE
      )
    ''');
    await db.execute('''
      CREATE TABLE business_details (
        id INTEGER PRIMARY KEY,
        value TEXT
      )
    ''');
    await _insertInitialCashierData(db);
    await _insertInitialBusinessData(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY,
          username TEXT UNIQUE,
          password TEXT,
          email TEXT UNIQUE
        )
      ''');
    }
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

  Future<String?> getBusinessName() async {
    final db = await database;
    try {
      final result = await db.query(
        'business_details',
        columns: ['value'], // Specify the column to fetch
        where: 'id = ?',
        whereArgs: [1], // Assuming you have a business with ID 1
      );
      return result.isNotEmpty ? result.first['value'] as String? : null;
    } catch (e) {
      developer.log('Error fetching business name: $e');
      return null;
    }
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
    return result.isNotEmpty ? result.first : null;
  }
}
