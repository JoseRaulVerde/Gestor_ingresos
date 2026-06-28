import 'package:gestor_ingresos/models/goal_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/payment_method_model.dart'; // Asegúrate de tener este import

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    // Cambiamos a v6 para asegurar que la tabla transactions se cree con el nuevo campo
    _database = await _initDB('gestor_ingresos_v7.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNull = 'TEXT';
    const boolType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const integerTypeNull = 'INTEGER'; // Agregamos este tipo para el método de pago opcional

    // 1. Crear Tabla Categorías
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id $idType,
        name $textType
      )
    ''');

    // 2. Crear Tabla Transacciones (AHORA INCLUYE paymentMethodId)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions (
        id $idType,
        title $textType,
        description $textTypeNull,
        amount $realType,
        date $textType,
        isIncome $boolType,
        categoryId $integerType,
        paymentMethodId $integerTypeNull, 
        createdAt $textType,
        updatedAt $textType,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE,
        FOREIGN KEY (paymentMethodId) REFERENCES payment_methods (id) ON DELETE SET NULL
      )
    ''');

    // 3. Crear Tabla Metas v7 (Con rangos de tiempo y tipo de límite)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        categoryId INTEGER NOT NULL,
        targetAmount REAL NOT NULL,
        currentAmount REAL NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        isExpenseMeta INTEGER NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // 3. Crear Tabla Metas (Blindada con IF NOT EXISTS)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        categoryId INTEGER NOT NULL,
        amount REAL NOT NULL
      )
    ''');
    
    // 4. Crear Tabla Métodos de Pago
    await db.execute('''
      CREATE TABLE IF NOT EXISTS payment_methods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT
      )
    ''');

    // Insertar métodos por defecto (Opcional)
    List<String> defaultMethods = ['Efectivo', 'Tarjeta de Débito', 'Tarjeta de Crédito', 'Transferencia'];
    for (String method in defaultMethods) {
      await db.insert('payment_methods', {'name': method, 'icon': '💳'});
    }

    // Insertar categorías por defecto
    List<String> defaultCategories = [
      'Salary/Income',
      'Groceries',
      'Transport',
      'Shopping',
      'Entertainment',
      'Utilities',
      'Food & Dining',
      'Health & Fitness',
      'Others'
    ];

    for (String category in defaultCategories) {
      await db.insert('categories', {'name': category});
    }
  }

  // --- Métodos CRUD para Categorías ---
  Future<List<CategoryModel>> getCategories() async {
    final db = await instance.database;
    final result = await db.query('categories');
    return result.map((json) => CategoryModel.fromMap(json)).toList();
  }

  // --- Métodos CRUD para Transacciones ---
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await instance.database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Métodos CRUD para Metas (GOALS) ---
  Future<int> insertGoal(GoalModel goal) async {
    final db = await instance.database;
    return await db.insert('goals', goal.toMap());
  }

  Future<List<GoalModel>> getGoals() async {
    final db = await instance.database;
    final maps = await db.query('goals');
    return maps.map((map) => GoalModel.fromMap(map)).toList();
  }

  Future<int> deleteGoal(int id) async {
    final db = await instance.database;
    return await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // ==========================================
  // CRUD PARA MÉTODOS DE PAGO
  // ==========================================

  Future<int> insertPaymentMethod(PaymentMethodModel method) async {
    final db = await instance.database;
    return await db.insert('payment_methods', method.toMap());
  }

  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final db = await instance.database;
    final result = await db.query('payment_methods', orderBy: 'name ASC');
    return result.map((json) => PaymentMethodModel.fromMap(json)).toList();
  }

  Future<int> updatePaymentMethod(PaymentMethodModel method) async {
    final db = await instance.database;
    return await db.update(
      'payment_methods',
      method.toMap(),
      where: 'id = ?',
      whereArgs: [method.id],
    );
  }

  Future<int> deletePaymentMethod(int id) async {
    final db = await instance.database;
    return await db.delete(
      'payment_methods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}