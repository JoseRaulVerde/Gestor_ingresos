import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../database/db_helper.dart';

class GoalProvider with ChangeNotifier {
  List<GoalModel> _goals = [];
  List<GoalModel> get goals => _goals;

  Future<void> fetchGoals() async {
    final dbHelper = DatabaseHelper.instance;
    final db = await dbHelper.database;
    
    // 1. Traemos las metas base de la BD
    final rawGoals = await dbHelper.getGoals();
    
    // 2. Calculamos dinámicamente el "currentAmount" leyendo las transacciones reales
    for (var goal in rawGoals) {
      final res = await db.rawQuery('''
        SELECT SUM(amount) as total FROM transactions 
        WHERE categoryId = ? 
        AND isIncome = ?
        AND date >= ? 
        AND date <= ?
      ''', [
        goal.categoryId, 
        goal.isExpenseMeta ? 0 : 1, // 0 si busca gastos, 1 si busca ingresos
        goal.startDate.toIso8601String(), 
        goal.endDate.toIso8601String()
      ]);

      double totalActual = (res.first['total'] as num?)?.toDouble() ?? 0.0;
      goal.currentAmount = totalActual;
    }

    _goals = rawGoals;
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
}