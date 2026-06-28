import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/payment_method_provider.dart';
import '../models/transaction_model.dart';

class PaymentMethodsChart extends StatefulWidget {
  const PaymentMethodsChart({super.key});

  @override
  State<PaymentMethodsChart> createState() => _PaymentMethodsChartState();
}

class _PaymentMethodsChartState extends State<PaymentMethodsChart> {
  // Filtro por defecto: 7 días
  int _selectedDays = 7; 

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    final pmProvider = Provider.of<PaymentMethodProvider>(context);

    // 1. Lógica para filtrar transacciones por fecha y que sean SOLO GASTOS
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: _selectedDays));
    
    final filteredTxs = txProvider.transactions.where((tx) {
      return !tx.isIncome && tx.date.isAfter(startDate);
    }).toList();

    // 2. Lógica para agrupar los gastos por Método de Pago
    Map<int, double> expensesByMethod = {};
    for (var tx in filteredTxs) {
      // Si la transacción tiene un método de pago asignado
      if (tx.paymentMethodId != null) {
        expensesByMethod[tx.paymentMethodId!] = 
            (expensesByMethod[tx.paymentMethodId!] ?? 0) + tx.amount;
      }
    }

    // 3. Preparar los datos para la gráfica
    List<PieChartSectionData> pieSections = [];
    List<Color> colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal];
    int colorIndex = 0;

    expensesByMethod.forEach((methodId, totalAmount) {
      final method = pmProvider.paymentMethods.firstWhere(
        (m) => m.id == methodId, 
        // fallback por si se borró el método
        orElse: () => pmProvider.paymentMethods.first 
      );
      
      pieSections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: totalAmount,
          title: '\$${totalAmount.toStringAsFixed(0)}',
          radius: 60,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
      colorIndex++;
    });

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- ENCABEZADO Y FILTRO DE DÍAS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gastos por Método',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<int>(
                    value: _selectedDays,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 7, child: Text('7 Días')),
                      DropdownMenuItem(value: 15, child: Text('15 Días')),
                      DropdownMenuItem(value: 30, child: Text('30 Días')),
                      DropdownMenuItem(value: 60, child: Text('60 Días')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedDays = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- GRÁFICA DE PASTEL ---
            if (pieSections.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40.0),
                child: Text('No hay gastos en este periodo.', style: TextStyle(color: Colors.grey)),
              )
            else
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: pieSections,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // --- DESCRIPCIÓN (LEYENDAS) ---
            if (pieSections.isNotEmpty)
              Wrap(
                spacing: 15,
                runSpacing: 10,
                children: expensesByMethod.entries.map((entry) {
                  final methodId = entry.key;
                  final method = pmProvider.paymentMethods.firstWhere((m) => m.id == methodId);
                  
                  // Buscar el color correspondiente que usamos arriba
                  final index = expensesByMethod.keys.toList().indexOf(methodId);
                  final color = colors[index % colors.length];

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(radius: 6, backgroundColor: color),
                      const SizedBox(width: 5),
                      Text('${method.icon} ${method.name}', style: const TextStyle(fontSize: 14)),
                    ],
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}