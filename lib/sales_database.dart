import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SalesDatabase {
  static final SalesDatabase instance = SalesDatabase._init();

  static Database? _database;

  SalesDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('sales.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
    CREATE TABLE sales (
      id $idType,
      date $textType,
      time $textType,
      username $textType,
      orderNumber $textType,
      productId $integerType,
      productName $textType,
      quantity $integerType,
      price $realType,
      subtotal $realType,
      tax $realType,
      discount $realType,
      total $realType,
      amountPaid $realType,
      change $realType,
      modeOfPayment $textType,
      addInNames TEXT 
    )
    ''');

    await db.execute('''
    CREATE TABLE discounts (
      id $idType,
      date $textType,
      orderNumber $textType,
      discountType $textType,
      referenceNumber $textType
    )
    ''');

    await db.execute('''
    CREATE TABLE users (
      id $idType,
      username $textType,
      name $textType,
      logout_time $textType
    )
    ''');
  }

  Future<void> create({
    required String date,
    required String time,
    required String username,
    required String orderNumber,
    required int productId,
    required String productName,
    required int quantity,
    required double price,
    required double subtotal,
    required double tax,
    required double discount,
    required double total,
    required double amountPaid,
    required double change,
    required String modeOfPayment,
    List<String>? addInNames,
  }) async {
    final db = await instance.database;
    await db.insert('sales', {
      'date': date,
      'time': time,
      'username': username,
      'orderNumber': orderNumber,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'amountPaid': amountPaid,
      'change': change,
      'modeOfPayment': modeOfPayment,
      'addInNames': addInNames?.join(','),
    });
  }

  Future<void> createDiscount({
    required String date,
    required String orderNumber,
    required String discountType,
    required String referenceNumber,
  }) async {
    final db = await instance.database;
    await db.insert('discounts', {
      'date': date,
      'orderNumber': orderNumber,
      'discountType': discountType,
      'referenceNumber': referenceNumber,
    });
  }

  Future<List<Map<String, dynamic>>> readAllSales() async {
    final db = await instance.database;
    return await db.query('sales');
  }

  Future<List<Map<String, dynamic>>> readOrderDetails(
    String orderNumber,
  ) async {
    final db = await instance.database;
    return await db.query(
      'sales',
      where: 'orderNumber = ?',
      whereArgs: [orderNumber],
    );
  }

  Future<String> getUserName(String username) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'product_database.db');
    final db = await openDatabase(path);

    final result = await db.query(
      'users',
      columns: ['name'],
      where: 'username = ?',
      whereArgs: [username],
    );

    if (result.isNotEmpty) {
      return result.first['name'] as String;
    } else {
      throw Exception('User not found');
    }
  }
}
