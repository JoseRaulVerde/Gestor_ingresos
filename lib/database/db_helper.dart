import 'package:gestor_ingresos/models/goal_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    // Cambiamos a v3 para ignorar cualquier intento fallido guardado por Android
    _database = await _initDB('gestor_ingresos_v4.db');
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

    // 1. Crear Tabla Categorías
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id $idType,
        name $textType
      )
    ''');

    // 2. Crear Tabla Transacciones (Corregida sin duplicados y blindada)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions (
        id $idType,
        title $textType,
        description $textTypeNull,
        amount $realType,
        date $textType,
        isIncome $boolType,
        categoryId $integerType,
        createdAt $textType,
        updatedAt $textType,
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

    // 4. Insertar categorías por defecto
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
}