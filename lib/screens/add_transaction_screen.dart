import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction; // Si esto llega con datos, es modo Edición
  // 1. Agregamos esta variable para recibir la fecha del calendario
  final DateTime? initialDate;

  const AddTransactionScreen({super.key, this.transaction, this.initialDate});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _selectedDate;
  
  CategoryModel? _selectedCategory;
  bool _isIncome = false; 

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    // Si abrimos la pantalla para EDITAR, pre-llenamos los datos:
    if (widget.transaction != null) {
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _descriptionController.text = widget.transaction!.description ?? '';
      _isIncome = widget.transaction!.isIncome;
      
      // Buscamos la categoría original usando el Provider
      Future.microtask(() {
        final provider = Provider.of<TransactionProvider>(context, listen: false);
        setState(() {
          _selectedCategory = provider.categories.firstWhere(
            (cat) => cat.id == widget.transaction!.categoryId,
            orElse: () => provider.categories.first,
          );
        });
      });
    }
  }

  String _getCategoryIcon(String categoryName) {
    switch (categoryName) {
      case 'Salary/Income': return '💰';
      case 'Groceries': return '🛒';
      case 'Transport': return '🚗';
      case 'Shopping': return '🛍️';
      case 'Entertainment': return '🎬';
      case 'Food & Dining': return '🍽️';
      case 'Health & Fitness': return '💪';
      case 'Utilities': return '💡';
      default: return '📦';
    }
  }

  void _showCategoryPicker(BuildContext context, List<CategoryModel> categories) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext ctx) {
        return Container(
          padding: const EdgeInsets.only(top: 16, bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Select a category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (ctx, index) {
                    final cat = categories[index];
                    final isSelected = _selectedCategory?.id == cat.id;
                    return ListTile(
                      leading: Text(_getCategoryIcon(cat.name), style: const TextStyle(fontSize: 24)),
                      title: Text(cat.name, style: const TextStyle(fontSize: 16)),
                      trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                      onTap: () {
                        setState(() => _selectedCategory = cat);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final isEditing = widget.transaction != null; // ¿Estamos editando?

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'New Transaction', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Selector Gasto vs Ingreso
              Container(
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isIncome = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(color: !_isIncome ? const Color(0xFFB53B2E) : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                          child: Center(child: Text('Expense', style: TextStyle(color: !_isIncome ? Colors.white : Colors.grey[700], fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isIncome = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(color: _isIncome ? Colors.green[700] : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                          child: Center(child: Text('Income', style: TextStyle(color: _isIncome ? Colors.white : Colors.grey[700], fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(labelText: 'Amount', prefixText: '\$ ', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                validator: (val) => (double.tryParse(val!) == null) ? 'Invalid amount' : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                validator: (val) => val!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 15),

              GestureDetector(
                onTap: () => _showCategoryPicker(context, provider.categories),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_selectedCategory == null ? 'Select a category' : '${_getCategoryIcon(_selectedCategory!.name)}  ${_selectedCategory!.name}', style: TextStyle(fontSize: 16, color: _selectedCategory == null ? Colors.grey[600] : Colors.black87)),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: InputDecoration(labelText: 'Notes (Optional)', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _isIncome ? Colors.green[700] : const Color(0xFFB53B2E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate() && _selectedCategory != null) {
                    final tx = TransactionModel(
                      id: widget.transaction?.id, // <-- Mantiene el ID si estamos editando
                      title: _titleController.text,
                      amount: double.parse(_amountController.text),
                      description: _descriptionController.text,
                      date: widget.transaction?.date ?? _selectedDate,
                      isIncome: _isIncome,
                      categoryId: _selectedCategory!.id!,
                      createdAt: widget.transaction?.createdAt ?? DateTime.now(),
                      updatedAt: DateTime.now(),
                    );
                    
                    if (isEditing) {
                      provider.updateTransaction(tx);
                    } else {
                      provider.addTransaction(tx);
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(isEditing ? 'Update Transaction' : 'Save Transaction', style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}