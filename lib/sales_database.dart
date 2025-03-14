import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SalesDatabase {
  static final SalesDatabase instance = SalesDatabase._init();

  static Database? _database;

  SalesDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('product_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
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

    await db.execute('''
    CREATE TABLE order_details (
      id $idType,
      orderNumber $textType,
      product $textType,
      quantity $integerType,
      price $realType
    )
    ''');

    await db.execute('''
    CREATE TABLE products (
      product_id $idType,
      product_name $textType,
      base_price $realType
    )
    ''');

    await db.execute('''
    CREATE TABLE add_ins (
      add_in_id $idType,
      add_in_name $textType,
      add_in_price $realType
    )
    ''');

    await db.execute('''
    CREATE TABLE product_add_ins (
      product_add_in_id $idType,
      product_id $integerType,
      add_in_id $integerType,
      FOREIGN KEY (product_id) REFERENCES products (product_id),
      FOREIGN KEY (add_in_id) REFERENCES add_ins (add_in_id)
    )
    ''');

    await db.execute('''
    CREATE TABLE orders (
      order_id $idType,
      order_number $textType,
      order_date $textType,
      order_time $textType,
      name $textType,
      subtotal $realType,
      tax $realType,
      discount $realType,
      total $realType
    )
    ''');

    await db.execute('''
    CREATE TABLE order_items (
      order_item_id $idType,
      order_id $integerType,
      product_id $integerType,
      quantity $integerType,
      FOREIGN KEY (order_id) REFERENCES orders (order_id),
      FOREIGN KEY (product_id) REFERENCES products (product_id)
    )
    ''');

    await db.execute('''
    CREATE TABLE order_item_add_ins (
      order_item_add_in_id $idType,
      order_item_id $integerType,
      add_in_id $integerType,
      FOREIGN KEY (order_item_id) REFERENCES order_items (order_item_id),
      FOREIGN KEY (add_in_id) REFERENCES add_ins (add_in_id)
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

  Future<List<Map<String, dynamic>>> getOrderDetailsWithAddIns(
    String orderNumber,
  ) async {
    final db = await instance.database;
    final orderDetails = await db.query(
      'order_details',
      where: 'orderNumber = ?',
      whereArgs: [orderNumber],
    );

    final batch = db.batch();
    for (final detail in orderDetails) {
      final productId = detail['productId'];
      batch.query('add_ins', where: 'product_id = ?', whereArgs: [productId]);
    }

    final addInsResults = await batch.commit();
    for (int i = 0; i < orderDetails.length; i++) {
      orderDetails[i]['addIns'] = addInsResults[i];
    }

    return orderDetails;
  }

  Future<int> createOrder({
    required String orderNumber,
    required String orderDate,
    required String orderTime,
    required String name,
    required double subtotal,
    required double tax,
    required double discount,
    required double total,
  }) async {
    final db = await instance.database;
    final orderId = await db.insert('orders', {
      'order_number': orderNumber,
      'order_date': orderDate,
      'order_time': orderTime,
      'name': name,
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
    });
    return orderId;
  }

  Future<int> createOrderItem({
    required int orderId,
    required int productId,
    required int quantity,
  }) async {
    final db = await instance.database;
    final orderItemId = await db.insert('order_items', {
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
    });
    return orderItemId;
  }

  Future<void> createOrderItemAddIn({
    required int orderItemId,
    required int addInId,
  }) async {
    final db = await instance.database;
    await db.insert('order_item_add_ins', {
      'order_item_id': orderItemId,
      'add_in_id': addInId,
    });
  }

  static Future<Database> openSalesDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'product_database.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sales (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            time TEXT,
            orderNumber TEXT,
            username TEXT,
            total REAL
          )
        ''');
        await db.execute('''
          CREATE TABLE order_details (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            orderNumber TEXT,
            product TEXT,
            quantity INTEGER,
            price REAL
          )
        ''');
      },
      version: 1,
    );
  }
}
