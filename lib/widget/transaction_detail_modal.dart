import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- NUEVO IMPORT
import '../models/transaction_model.dart';
import '../providers/payment_method_provider.dart'; // <-- NUEVO IMPORT

class TransactionDetailModal extends StatelessWidget {
  final TransactionModel transaction;
  final String categoryName;

  const TransactionDetailModal({
    super.key,
    required this.transaction,
    required this.categoryName,
  });

  // Mapeo de emojis para mantener la consistencia visual
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
      default: return '📦'; // Others
    }
  }

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF2C3E50);
    // Formato de fecha básico: DD/MM/AAAA
    final dateStr = "${transaction.date.day}/${transaction.date.month}/${transaction.date.year}";

    // --- LÓGICA PARA OBTENER EL MÉTODO DE PAGO ---
    final pmProvider = Provider.of<PaymentMethodProvider>(context, listen: false);
    String? paymentMethodDisplay;
    
    if (transaction.paymentMethodId != null) {
      try {
        final pm = pmProvider.paymentMethods.firstWhere((p) => p.id == transaction.paymentMethodId);
        paymentMethodDisplay = '${pm.icon ?? '💳'}  ${pm.name}';
      } catch (e) {
        paymentMethodDisplay = '💳  Unknown'; // Por si el método fue borrado
      }
    }
    // ---------------------------------------------

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Encabezado: Etiqueta de tipo y botón de cerrar ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: transaction.isIncome ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      transaction.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                      color: transaction.isIncome ? Colors.green : Colors.red,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      transaction.isIncome ? 'INCOME' : 'EXPENSE',
                      style: TextStyle(
                        color: transaction.isIncome ? Colors.green[700] : Colors.red[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // --- Monto Principal ---
          Text(
            '${transaction.isIncome ? "+" : "-"}\$${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: transaction.isIncome ? Colors.green[700] : const Color(0xFFB53B2E),
            ),
          ),
          const SizedBox(height: 4),

          // --- Título del movimiento ---
          Text(
            transaction.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
          ),
          const Divider(height: 30, color: Colors.black12),

          // --- Fila: Categoría ---
          _buildDetailRow('Category', '${_getCategoryIcon(categoryName)}  $categoryName'),
          const SizedBox(height: 12),

          // --- NUEVA FILA: Método de Pago (Solo si existe) ---
          if (paymentMethodDisplay != null) ...[
            _buildDetailRow('Payment Method', paymentMethodDisplay),
            const SizedBox(height: 12),
          ],

          // --- Fila: Fecha ---
          _buildDetailRow('Date Recorded', dateStr),
          const SizedBox(height: 20),

          // --- Caja de Notas / Descripción ---
          const Text(
            'Notes',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              (transaction.description == null || transaction.description!.isEmpty)
                  ? 'No additional descriptions provided.'
                  : transaction.description!,
              style: TextStyle(
                color: transaction.description == null ? Colors.grey : textColor,
                fontSize: 14,
                height: 1.4,
                fontStyle: transaction.description == null ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para crear las filas estructuradas de información
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}