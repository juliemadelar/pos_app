import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    return await openDatabase(path, version: 1, onCreate: _onCreate);
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
}
