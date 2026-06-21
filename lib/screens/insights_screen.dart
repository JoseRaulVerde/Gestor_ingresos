import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/category_model.dart';
import '../widget/transaction_detail_modal.dart';
import 'add_transaction_screen.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  // Variable de estado para controlar si se muestran los números o los asteriscos
  bool _isBalanceVisible = true;

  // Función auxiliar para enmascarar el texto si el ojito está cerrado
  String _maskValue(String realValue) {
    return _isBalanceVisible ? realValue : '••••';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final recentTx = provider.recentTransactions;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Encabezado con el botón del Ojito ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Finances', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                      Text('Summary of my income/expenses', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                  // Botón interactivo del ojo
                  IconButton(
                    icon: Icon(
                      _isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: const Color(0xFF2C3E50),
                      size: 26,
                    ),
                    onPressed: () {
                      // Cambia el estado y redibuja la pantalla al presionar
                      setState(() {
                        _isBalanceVisible = !_isBalanceVisible;
                      });
                    },
                  ),
                ],
              ),
            ),

            // --- Tarjeta de Balance Principal ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2C3E50),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TOTAL BALANCE', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 5),
                  Text(
                    _maskValue('\$${provider.totalBalance.toStringAsFixed(2)}'), // <-- Balance enmascarado
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const Divider(color: Colors.white24, height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Ingresos
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.trending_up, color: Colors.white70, size: 16),
                              SizedBox(width: 5),
                              Text('Income', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _maskValue('\$${provider.totalIncome.toStringAsFixed(2)}'), // <-- Ingresos enmascarados
                            style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      // Gastos
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.trending_down, color: Colors.white70, size: 16),
                              SizedBox(width: 5),
                              Text('Expenses', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _maskValue('\$${provider.totalExpense.toStringAsFixed(2)}'), // <-- Gastos enmascarados
                            style: const TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Título de transacciones recientes
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            ),

            // Lista de transacciones recientes
            Expanded(
              child: recentTx.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text(
                          'You have no records yet. Start by adding one!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: recentTx.length,
                      itemBuilder: (context, index) {
                        final tx = recentTx[index];
                        final categoryName = provider.categories
                            .firstWhere((cat) => cat.id == tx.categoryId, orElse: () => CategoryModel(name: 'Unknown'))
                            .name;

                        return ListTile(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => TransactionDetailModal(
                                transaction: tx,
                                categoryName: categoryName,
                              ),
                            );
                          },
                          leading: CircleAvatar(
                            backgroundColor: tx.isIncome ? Colors.green[100] : Colors.red[100],
                            child: Icon(tx.isIncome ? Icons.arrow_upward : Icons.arrow_downward, color: tx.isIncome ? Colors.green : Colors.red),
                          ),
                          title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(categoryName),
                          trailing: Text(
                            // Enmascaramos también el dinero de las filas individuales si el ojo está cerrado
                            _maskValue('${tx.isIncome ? "+" : "-"}\$${tx.amount.toStringAsFixed(2)}'), 
                            style: TextStyle(fontWeight: FontWeight.bold, color: tx.isIncome ? Colors.green : Colors.red, fontSize: 16),
                          ),
                        );
                      },
                    ),
            ),

            // Botón Agregar Registro
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A65C8),
                  minimumSize: const Size.fromHeight(55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTransactionScreen()));
                },
                child: const Text('+ Add Record', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}