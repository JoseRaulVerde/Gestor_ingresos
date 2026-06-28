import 'package:flutter/material.dart';
import 'package:gestor_ingresos/widget/payment_methods_chart.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../models/category_model.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  Color _getColor(int index) {
    const colors = [Color(0xFF4A65C8), Color(0xFFF39C12), Color(0xFF2ECC71), Color(0xFFE74C3C), Color(0xFF9B59B6), Color(0xFF1ABC9C)];
    return colors[index % colors.length];
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '\$${(number / 1000000).toStringAsFixed(1)}M'; // Ejemplo: $10.0M
    } else if (number >= 1000) {
      return '\$${(number / 1000).toStringAsFixed(1)}K';   // Ejemplo: $15.5K
    }
    return '\$${number.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final expensesData = provider.expensesByCategory;
    final weeklyData = provider.currentWeekExpenses;
    final savingsPct = provider.savingsPercentage;
    final totalIncome = provider.totalIncome;
    final totalExpense = provider.totalExpense;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text('Mis Reportes', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
              ),
              const PaymentMethodsChart(),

              // ==========================================
              // GRÁFICA 1: TASA DE AHORRO (SAVINGS RATE)
              // ==========================================
              _buildSectionTitle('Savings vs Expenses'),
              Card(
                color: Colors.white, // <-- SOLUCIONADO: Cambiado 'backgroundColor' por 'color'
                elevation: 0,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Alínea la tarjeta con el resto del diseño
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      // Lado izquierdo: Gráfico circular (Dona)
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Renderiza una dona estética basada en los porcentajes reales
                            PieChart(
                              PieChartData(
                                sectionsSpace: 0,
                                centerSpaceRadius: 42,
                                startDegreeOffset: -90,
                                sections: [
                                  PieChartSectionData(
                                    color: Colors.green,
                                    value: savingsPct.clamp(0.0, 100.0),
                                    title: '',
                                    radius: 14,
                                  ),
                                  PieChartSectionData(
                                    color: Colors.redAccent,
                                    value: (100.0 - savingsPct).clamp(0.0, 100.0),
                                    title: '',
                                    radius: 14,
                                  ),
                                ],
                              ),
                            ),
                            // Texto centralizador de información
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${savingsPct.toStringAsFixed(1)}%',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                                ),
                                const Text(
                                  'Saved',
                                  style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      
                      // Lado derecho: Indicadores de texto blindados contra desbordamientos con Expanded
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Fila de Ingresos
                            Row(
                              children: [
                                const Icon(Icons.circle, color: Colors.green, size: 14),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Total Income', 
                                    style: TextStyle(color: Colors.grey, fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  _formatNumber(totalIncome),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2C3E50)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            // Fila de Gastos
                            Row(
                              children: [
                                const Icon(Icons.circle, color: Colors.redAccent, size: 14),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Total Expense', 
                                    style: TextStyle(color: Colors.grey, fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  _formatNumber(totalExpense),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2C3E50)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ==========================================
              // GRÁFICA 2: TENDENCIA SEMANAL (BARRAS)
              // ==========================================
              _buildSectionTitle('This Week\'s Expenses'),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.fromLTRB(10, 30, 20, 10),
                height: 250,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: weeklyData.reduce((a, b) => a > b ? a : b) + 50, 
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                            if (value.toInt() >= 0 && value.toInt() < days.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(days[value.toInt()], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    barGroups: List.generate(7, (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: weeklyData[index],
                            color: const Color(0xFF4A65C8),
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
                          )
                        ],
                      );
                    }),
                  ),
                ),
              ),

              // ==========================================
              // GRÁFICA 3: GASTOS POR CATEGORÍA
              // ==========================================
              if (expensesData.isNotEmpty) ...[
                _buildSectionTitle('Expenses by Category'),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 50,
                            sections: expensesData.entries.toList().asMap().entries.map((entry) {
                              final index = entry.key;
                              final amount = entry.value.value;
                              return PieChartSectionData(
                                color: _getColor(index),
                                value: amount,
                                title: '', 
                                radius: 30,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...expensesData.entries.toList().asMap().entries.map((entry) {
                        final index = entry.key;
                        final categoryId = entry.value.key;
                        final amount = entry.value.value;
                        final categoryName = provider.categories.firstWhere((cat) => cat.id == categoryId, orElse: () => CategoryModel(name: 'Unknown')).name;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _buildLegendIndicator(_getColor(index), categoryName, _formatNumber(amount)),
                        );
                      }),
                    ],
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
    );
  }

  Widget _buildLegendIndicator(Color color, String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          ],
        ),
        Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
      ],
    );
  }
}