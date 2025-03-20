import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:developer'; // Import for logging

void main() async {
  // Initialize FFI
  sqfliteFfiInit();
  // Set the database factory
  databaseFactory = databaseFactoryFfi;
  // ...existing code...
}

class SalesDatabase {
  static final SalesDatabase instance = SalesDatabase._init();

  static Database? _database;

  SalesDatabase._init() {
    // Initialize FFI and set the database factory
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('product_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    log('Database path: $path'); // Log the calculated path

    try {
      log('Attempting to open database...');
      final db = await openDatabase(
        path,
        version: 5, // Ensure version is incremented to reflect schema changes
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
        onDowngrade: _onDowngrade, //Added onDowngrade
        onOpen: (db) {
          log('Database opened successfully.');
        },
      );
      log('Database opened successfully.');
      return db;
    } catch (e, stack) {
      log('Critical error initializing database: $e', stackTrace: stack);
      rethrow; // Rethrow so the error propagates
    }
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    try {
      log('Creating table: products');
      await db.execute('''
      CREATE TABLE products (
        product_id $idType,
        product_name $textType,
        base_price $realType
      )
      ''');
      log('Table created: products');
    } catch (e, stack) {
      log('Error creating table products: $e', stackTrace: stack);
      rethrow;
    }

    try {
      log('Creating table: add_ins');
      await db.execute('''
      CREATE TABLE add_ins (
        add_in_id $idType,
        add_in_name $textType,
        add_in_price $realType
      )
      ''');
      log('Table created: add_ins');
    } catch (e, stack) {
      log('Error creating table add_ins: $e', stackTrace: stack);
      rethrow;
    }

    try {
      log('Creating table: order_item_add_ins');
      await db.execute('''
      CREATE TABLE order_item_add_ins (
        order_item_add_in_id $idType,
        order_item_id $integerType,
        add_in_id $integerType,
        FOREIGN KEY (order_item_id) REFERENCES order_items (order_item_id),
        FOREIGN KEY (add_in_id) REFERENCES add_ins (add_in_id)
      )
      ''');
      log('Table created: order_item_add_ins');
    } catch (e, stack) {
      log('Error creating table order_item_add_ins: $e', stackTrace: stack);
      rethrow;
    }

    try {
      log('Creating table: orders');
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
      log('Table created: orders');
    } catch (e, stack) {
      log('Error creating table orders: $e', stackTrace: stack);
      rethrow;
    }

    try {
      log('Creating table: order_items');
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
      log('Table created: order_items');
    } catch (e, stack) {
      log('Error creating table order_items: $e', stackTrace: stack);
      rethrow;
    }

    try {
      log('Creating table: product_add_ins');
      await db.execute('''
      CREATE TABLE product_add_ins (
        product_add_in_id $idType,
        product_id $integerType,
        add_in_id $integerType,
        FOREIGN KEY (product_id) REFERENCES products (product_id),
        FOREIGN KEY (add_in_id) REFERENCES add_ins (add_in_id)
      )
      ''');
      log('Table created: product_add_ins');
    } catch (e, stack) {
      log('Error creating table product_add_ins: $e', stackTrace: stack);
      rethrow;
    }

    try {
      log('Creating table: sales');
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
        addInNames $textType
      )
      ''');
      log('Table created: sales');
    } catch (e, stack) {
      log('Error creating table sales: $e', stackTrace: stack);
      rethrow;
    }

    try {
      log('Creating table: discounts');
      await db.execute('''
      CREATE TABLE discounts (
        id $idType,
        date $textType,
        orderNumber $textType,
        discountType $textType,
        referenceNumber $textType
      )
      ''');
      log('Table created: discounts');
    } catch (e, stack) {
      log('Error creating table discounts: $e', stackTrace: stack);
      rethrow;
    }

    try {
      log('Creating table: users');
      await db.execute('''
      CREATE TABLE users (
        id $idType,
        username $textType,
        name $textType,
        logout_time $textType
      )
      ''');
      log('Table created: users');
    } catch (e, stack) {
      log('Error creating table users: $e', stackTrace: stack);
      rethrow;
    }

    try {
      log('Creating table: order_details');
      await db.execute('''
      CREATE TABLE order_details (
        id $idType,
        orderNumber $textType,
        product $textType,
        quantity $integerType,
        price $realType
      )
      ''');
      log('Table created: order_details');
    } catch (e, stack) {
      log('Error creating table order_details: $e', stackTrace: stack);
      rethrow;
    }
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // This condition should check whether the oldVersion supports the sales table. If it doesn't, it should create it.
      try {
        log('Upgrading database from version $oldVersion to $newVersion');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS sales (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            time TEXT NOT NULL,
            username TEXT NOT NULL,
            orderNumber TEXT NOT NULL,
            productId INTEGER NOT NULL,
            productName TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            price REAL NOT NULL,
            subtotal REAL NOT NULL,
            tax REAL NOT NULL,
            discount REAL NOT NULL,
            total REAL NOT NULL,
            amountPaid REAL NOT NULL,
            change REAL NOT NULL,
            modeOfPayment TEXT NOT NULL,
            addInNames TEXT
          )
        ''');
        log('Database upgraded successfully');
      } catch (e) {
        log('Error upgrading database: $e');
        rethrow;
      }
    }
  }

  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    log('Downgrading database from version $oldVersion to $newVersion');
    // Instead of deleting, handle the downgrade gracefully. You might need to create a migration script. For a simple fix try:
    await _createDB(db, newVersion); // Recreate the database. Use with caution.
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
    final db = await SalesDatabase.instance.database; // Await here!
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

  Future<void> deleteOrder(int orderId) async {
    final db = await instance.database;

    // Delete order item add-ins
    await db.delete(
      'order_item_add_ins',
      where:
          'order_item_id IN (SELECT order_item_id FROM order_items WHERE order_id = ?)',
      whereArgs: [orderId],
    );

    // Delete order items
    await db.delete('order_items', where: 'order_id = ?', whereArgs: [orderId]);

    // Delete the order
    await db.delete('orders', where: 'order_id = ?', whereArgs: [orderId]);
  }

  Future<void> deleteAndReinitializeDatabase() async {
    if (_database != null) {
      await _database!.close();
    }
    _database = await _initDB('product_database.db');
  }
}
