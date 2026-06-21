import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/goal_model.dart';
import '../models/category_model.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  String _getCategoryIcon(String name) {
    switch (name) {
      case 'Salary/Income': return '💰';
      case 'Groceries': return '🛒';
      case 'Transport': return '🚗';
      case 'Shopping': return '🛍️';
      case 'Entertainment': return '🎬';
      case 'Utilities': return '💡';
      default: return '📦';
    }
  }

  // Modal para agregar una nueva meta
  void _showAddGoalModal(BuildContext context, TransactionProvider provider) {
    CategoryModel? selectedCategory;
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, top: 20, left: 20, right: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('New Monthly Budget', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  // Selector de categoría (Dropdown)
                  DropdownButtonFormField<CategoryModel>(
                    decoration: InputDecoration(
                      labelText: 'Select Category',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: provider.categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text('${_getCategoryIcon(cat.name)} ${cat.name}'));
                    }).toList(),
                    onChanged: (val) => setState(() => selectedCategory = val),
                  ),
                  const SizedBox(height: 15),

                  // Monto Límite
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Max Budget Amount',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botón Guardar
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (selectedCategory != null && amountController.text.isNotEmpty) {
                        provider.addGoal(GoalModel(
                          categoryId: selectedCategory!.id!,
                          amount: double.parse(amountController.text),
                        ));
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Save Budget', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final goals = provider.goals;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text('Monthly Goals', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            ),
            Expanded(
              child: goals.isEmpty
                  ? const Center(child: Text('No budgets set. Tap + to add one.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: goals.length,
                      itemBuilder: (context, index) {
                        final goal = goals[index];
                        final category = provider.categories.firstWhere((cat) => cat.id == goal.categoryId, orElse: () => CategoryModel(name: 'Unknown'));
                        
                        // Lógica de progreso
                        final spent = provider.getSpentAmountForCategoryThisMonth(goal.categoryId);
                        final progress = (spent / goal.amount).clamp(0.0, 1.0);
                        final isOverBudget = spent > goal.amount;

                        return Dismissible(
                          key: Key(goal.id.toString()),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => provider.deleteGoal(goal.id!),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${_getCategoryIcon(category.name)} ${category.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text('\$${spent.toStringAsFixed(0)} / \$${goal.amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, color: isOverBudget ? Colors.red : Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Barra de progreso animada
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 10,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(isOverBudget ? Colors.redAccent : Colors.blueAccent),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (isOverBudget)
                                  const Text('Te colgaste bebe te pasaste de la meta!😢', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4A65C8),
        onPressed: () => _showAddGoalModal(context, provider),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}