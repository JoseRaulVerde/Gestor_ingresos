import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../models/goal_model.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  DateTime _selectedDate = DateTime.now();

  List<TransactionModel> get transactions => _transactions;
  List<GoalModel> _goals = [];
  List<GoalModel> get goals => _goals;
  List<CategoryModel> get categories => _categories;
  DateTime get selectedDate => _selectedDate;

  // Filtra las transacciones para que coincidan EXACTAMENTE con el día seleccionado
  List<TransactionModel> get transactionsForSelectedDate {
    return _transactions.where((tx) {
      return tx.date.year == _selectedDate.year &&
             tx.date.month == _selectedDate.month &&
             tx.date.day == _selectedDate.day;
    }).toList();
  }

  // Cambiar la fecha seleccionada en el calendario
  void changeSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Cargar categorías desde la Base de Datos
  Future<void> fetchCategories() async {
    _categories = await DatabaseHelper.instance.getCategories();
    notifyListeners();
  }

  // Cargar transacciones desde la Base de Datos
  Future<void> fetchTransactions() async {
    _transactions = await DatabaseHelper.instance.getAllTransactions();
    notifyListeners();
  }

  // Agregar una nueva transacción
  Future<void> addTransaction(TransactionModel transaction) async {
    await DatabaseHelper.instance.insertTransaction(transaction);
    await fetchTransactions(); // Recargar la lista de transacciones
  }
  // --- NUEVOS CÁLCULOS PARA EL DASHBOARD ---
  double get totalIncome {
    return _transactions.where((tx) => tx.isIncome).fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get totalExpense {
    return _transactions.where((tx) => !tx.isIncome).fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get totalBalance {
    return totalIncome - totalExpense;
  }

  // Obtener solo las últimas 5 transacciones para el resumen
  List<TransactionModel> get recentTransactions {
    return _transactions.take(5).toList();
  }
  // --- LÓGICA PARA REPORTES ---
  
  // Total de gastos (solo para calcular porcentajes)
  double get totalExpensesOnly {
    return _transactions.where((tx) => !tx.isIncome).fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // Agrupar los gastos por ID de categoría
  Map<int, double> get expensesByCategory {
    Map<int, double> data = {};
    for (var tx in _transactions.where((t) => !t.isIncome)) {
      data[tx.categoryId] = (data[tx.categoryId] ?? 0) + tx.amount;
    }
    return data;
  }
  // --- NUEVAS LÓGICAS PARA REPORTES AVANZADOS ---

  // 1. Porcentaje de Ahorro
  double get savingsPercentage {
    if (totalIncome == 0) return 0.0;
    double savings = totalIncome - totalExpense;
    if (savings <= 0) return 0.0; // Gastaste más de lo que ganaste
    return (savings / totalIncome) * 100;
  }

  // 2. Gastos de la semana actual (Lunes a Domingo)
  List<double> get currentWeekExpenses {
    // Crea una lista de 7 días (Lunes=0, ..., Domingo=6) empezando en 0.0
    List<double> week = List.filled(7, 0.0);
    DateTime now = DateTime.now();
    // Encontrar el Lunes de esta semana
    DateTime startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));

    for (var tx in _transactions.where((t) => !t.isIncome)) {
      // Si la transacción ocurrió en esta semana, la sumamos al día correspondiente
      if (tx.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          tx.date.isBefore(startOfWeek.add(const Duration(days: 7)))) {
        week[tx.date.weekday - 1] += tx.amount;
      }
    }
    return week;
  }
  // Eliminar transacción y actualizar pantalla
  Future<void> deleteTransaction(int id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    await fetchTransactions(); // Vuelve a cargar todo para que la gráfica y listas se actualicen
  }
  // Actualizar transacción y refrescar pantalla
  Future<void> updateTransaction(TransactionModel transaction) async {
    await DatabaseHelper.instance.updateTransaction(transaction);
    await fetchTransactions(); 
  }

  // --- LÓGICA DE METAS Y PRESUPUESTOS ---
  
  Future<void> fetchGoals() async {
    _goals = await DatabaseHelper.instance.getGoals();
    notifyListeners();
  }

  Future<void> addGoal(GoalModel goal) async {
    await DatabaseHelper.instance.insertGoal(goal);
    await fetchGoals();
  }

  Future<void> deleteGoal(int id) async {
    await DatabaseHelper.instance.deleteGoal(id);
    await fetchGoals();
  }

  // Calcula cuánto has gastado en una categoría ESPECÍFICAMENTE ESTE MES
  double getSpentAmountForCategoryThisMonth(int categoryId) {
    final now = DateTime.now();
    return _transactions.where((tx) {
      return !tx.isIncome && 
             tx.categoryId == categoryId && 
             tx.date.month == now.month && 
             tx.date.year == now.year;
    }).fold(0.0, (sum, tx) => sum + tx.amount);
  }
}