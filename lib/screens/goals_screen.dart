import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Para formatear las fechas visualmente
import '../providers/transaction_provider.dart';
import '../providers/goal_provider.dart';
import '../models/goal_model.dart';
import '../models/category_model.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  void initState() {
    super.initState();
    // Cargamos las metas al abrir la pantalla
    Future.microtask(() => Provider.of<GoalProvider>(context, listen: false).fetchGoals());
  }

  String _getCategoryIcon(String name) {
    switch (name) {
      case 'Salary/Income': return '💰';
      case 'Groceries': return '🛒';
      case 'Transport': return '🚗';
      case 'Shopping': return '🛍️';
      case 'Entertainment': return '🎬';
      case 'Utilities': return '💡';
      case 'Food & Dining': return '🍽️';
      case 'Health & Fitness': return '🏋️‍♂️';
      default: return '📦';
    }
  }

  // --- MODAL ACTUALIZADO PARA LA NUEVA VERSIÓN DE METAS ---
  void _showAddGoalModal(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);
    
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    CategoryModel? selectedCategory;
    
    bool isExpenseMeta = true; // Por defecto es Presupuesto de Gasto
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 30)); // Por defecto 30 días

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom, 
                top: 20, left: 20, right: 20
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nueva Meta / Presupuesto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    
                    // 1. Selector de Tipo (Gasto o Ingreso)
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => isExpenseMeta = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(color: isExpenseMeta ? Colors.redAccent : Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                              child: Center(child: Text('Presupuesto (Gasto)', style: TextStyle(color: isExpenseMeta ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => isExpenseMeta = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(color: !isExpenseMeta ? Colors.green : Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                              child: Center(child: Text('Meta (Ingreso)', style: TextStyle(color: !isExpenseMeta ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // 2. Título de la meta
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(labelText: 'Título (Ej. Viaje, Supermercado)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                    const SizedBox(height: 15),
                    
                    // 3. Selector de categoría
                    DropdownButtonFormField<CategoryModel>(
                      decoration: InputDecoration(labelText: 'Categoría', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      items: txProvider.categories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text('${_getCategoryIcon(cat.name)} ${cat.name}'));
                      }).toList(),
                      onChanged: (val) => setModalState(() => selectedCategory = val),
                    ),
                    const SizedBox(height: 15),

                    // 4. Monto Límite
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Monto Límite / Meta', prefixText: '\$ ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                    const SizedBox(height: 15),

                    // 5. Selector de Fechas
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(context: context, initialDate: startDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
                              if (date != null) setModalState(() => startDate = date);
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(labelText: 'Inicio', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                              child: Text(DateFormat('dd/MM/yyyy').format(startDate)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(context: context, initialDate: endDate, firstDate: startDate, lastDate: DateTime(2030));
                              if (date != null) setModalState(() => endDate = date);
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(labelText: 'Fin', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                              child: Text(DateFormat('dd/MM/yyyy').format(endDate)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Botón Guardar
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: const Color(0xFF4A65C8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (selectedCategory != null && amountController.text.isNotEmpty && titleController.text.isNotEmpty) {
                          goalProvider.addGoal(GoalModel(
                            title: titleController.text,
                            categoryId: selectedCategory!.id!,
                            targetAmount: double.parse(amountController.text),
                            startDate: startDate,
                            endDate: endDate,
                            isExpenseMeta: isExpenseMeta,
                          ));
                          Navigator.pop(ctx);
                        }
                      },
                      child: const Text('Guardar Meta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context);
    final txProvider = Provider.of<TransactionProvider>(context);
    final goals = goalProvider.goals;

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
                        final category = txProvider.categories.firstWhere((cat) => cat.id == goal.categoryId, orElse: () => CategoryModel(name: 'Unknown'));
                        
                        // Cálculos base
                        final progress = goal.targetAmount > 0 ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0) : 0.0;
                        final isOverBudget = goal.isExpenseMeta && (goal.currentAmount > goal.targetAmount);
                        final daysLeft = goal.endDate.difference(DateTime.now()).inDays;

                        // ==========================================
                        // LA MAGIA DE LOS COLORES DINÁMICOS
                        // ==========================================
                        Color barColor;
                        if (goal.isExpenseMeta) {
                          // Lógica para PRESUPUESTOS (Gastos)
                          if (progress >= 1.0) {
                            barColor = Colors.redAccent; // ¡Rojo! Te pasaste del límite
                          } else if (progress >= 0.8) {
                            barColor = Colors.orangeAccent; // ¡Naranja! Peligro, vas al 80% o más
                          } else {
                            barColor = Colors.green; // ¡Verde! Estás a salvo y tienes margen
                          }
                        } else {
                          // Lógica para METAS (Ingresos / Ahorros)
                          if (progress >= 1.0) {
                            barColor = Colors.amber; // ¡Dorado! Meta completada con éxito
                          } else if (daysLeft < 0) {
                            barColor = Colors.redAccent; // ¡Rojo! Se acabó el tiempo y no lograste la meta
                          } else {
                            barColor = Colors.blueAccent; // ¡Azul! En progreso, a tiempo
                          }
                        }
                        // ==========================================

                        return Dismissible(
                          key: Key(goal.id.toString()),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => goalProvider.deleteGoal(goal.id!),
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
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        Text('${_getCategoryIcon(category.name)} ${category.name}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                      ],
                                    ),
                                    Text('\$${goal.currentAmount.toStringAsFixed(0)} / \$${goal.targetAmount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, color: isOverBudget ? Colors.red : Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                
                                // Barra de progreso con el color dinámico
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 10,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(barColor), // <-- AQUÍ APLICAMOS EL COLOR
                                  ),
                                ),
                                const SizedBox(height: 8),
                                
                               // --- Textos inferiores (Ahora en Columna para evitar desbordes) ---
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // Alinea todo a la izquierda
                                children: [
                                  Text(
                                    daysLeft < 0 ? "Finalizado" : "⏳ Faltan $daysLeft días",
                                    style: TextStyle(
                                      color: daysLeft <= 3 && daysLeft >= 0 ? Colors.orange : Colors.grey[600], 
                                      fontSize: 12, 
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  
                                  // Este espacio solo se agrega si vamos a mostrar un mensaje abajo
                                  if (isOverBudget || (!goal.isExpenseMeta && progress >= 1.0))
                                    const SizedBox(height: 6),
                                    
                                  // Tu épico mensaje de regaño o felicitación
                                  if (isOverBudget)
                                    const Text(
                                      'Te colgaste bebe te pasaste de la meta! 😢', 
                                      style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)
                                    )
                                  else if (!goal.isExpenseMeta && progress >= 1.0)
                                    const Text(
                                      '¡Lo lograste! 🏆', 
                                      style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)
                                    ),
                                ],
                              ),
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
        onPressed: () => _showAddGoalModal(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}