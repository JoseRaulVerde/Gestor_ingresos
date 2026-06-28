import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/payment_method_model.dart'; // <-- NUEVO IMPORT
import '../providers/transaction_provider.dart';
import '../providers/payment_method_provider.dart'; // <-- NUEVO IMPORT
import 'payment_methods_screen.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction; // Si esto llega con datos, es modo Edición
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
  PaymentMethodModel? _selectedPaymentMethod; // <-- NUEVA VARIABLE
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
      
      // Buscamos la categoría y método de pago original usando los Providers
      Future.microtask(() {
        final txProvider = Provider.of<TransactionProvider>(context, listen: false);
        final pmProvider = Provider.of<PaymentMethodProvider>(context, listen: false);
        
        setState(() {
          // Cargar Categoría
          _selectedCategory = txProvider.categories.firstWhere(
            (cat) => cat.id == widget.transaction!.categoryId,
            orElse: () => txProvider.categories.first,
          );

          // Cargar Método de Pago si existe
          if (widget.transaction!.paymentMethodId != null && pmProvider.paymentMethods.isNotEmpty) {
            _selectedPaymentMethod = pmProvider.paymentMethods.firstWhere(
              (pm) => pm.id == widget.transaction!.paymentMethodId,
              orElse: () => pmProvider.paymentMethods.first,
            );
          }
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

  // --- MODAL PARA SELECCIONAR CATEGORÍA ---
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

  // --- NUEVO: MODAL PARA SELECCIONAR MÉTODO DE PAGO ---
  // --- MODAL PARA SELECCIONAR MÉTODO DE PAGO ---
  void _showPaymentMethodPicker(BuildContext context, List<PaymentMethodModel> methods) {
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
                    const Text('Select Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: methods.length,
                  itemBuilder: (ctx, index) {
                    final method = methods[index];
                    final isSelected = _selectedPaymentMethod?.id == method.id;
                    return ListTile(
                      leading: Text(method.icon ?? '💳', style: const TextStyle(fontSize: 24)),
                      title: Text(method.name, style: const TextStyle(fontSize: 16)),
                      trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                      onTap: () {
                        setState(() => _selectedPaymentMethod = method);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
              
              // --- NUEVO: BOTÓN PARA IR AL CRUD DE MÉTODOS ---
              const Divider(),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(ctx); // Primero cerramos este modal
                  // Y abrimos tu pantalla del CRUD
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()),
                  );
                },
                icon: const Icon(Icons.settings, color: Color(0xFF2C3E50)),
                label: const Text(
                  'Agregar metodo de pago', 
                  style: TextStyle(color: Color(0xFF2C3E50), fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    final pmProvider = Provider.of<PaymentMethodProvider>(context); // <-- CONECTAMOS EL PROVIDER NUEVO
    final isEditing = widget.transaction != null;

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

              // Campo de Monto
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(labelText: 'Amount', prefixText: '\$ ', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                validator: (val) => (double.tryParse(val!) == null) ? 'Invalid amount' : null,
              ),
              const SizedBox(height: 15),

              // Campo de Título
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                validator: (val) => val!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 15),

              // Selector de Categoría
              GestureDetector(
                onTap: () => _showCategoryPicker(context, txProvider.categories),
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

              // --- NUEVO: SELECTOR DE MÉTODO DE PAGO (SOLO SE MUESTRA SI ES GASTO) ---
              if (!_isIncome) ...[
                GestureDetector(
                  onTap: () => _showPaymentMethodPicker(context, pmProvider.paymentMethods),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedPaymentMethod == null 
                              ? 'Select Payment Method' 
                              : '${_selectedPaymentMethod!.icon ?? '💳'}  ${_selectedPaymentMethod!.name}', 
                          style: TextStyle(fontSize: 16, color: _selectedPaymentMethod == null ? Colors.grey[600] : Colors.black87),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],

              // Campo de Notas
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: InputDecoration(labelText: 'Notes (Optional)', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 40),

              // Botón Guardar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _isIncome ? Colors.green[700] : const Color(0xFFB53B2E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // Validación: Si es gasto, obligamos a que elija un método de pago
                  if (_formKey.currentState!.validate() && _selectedCategory != null) {
                    if (!_isIncome && _selectedPaymentMethod == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, selecciona un método de pago.')),
                      );
                      return;
                    }

                    final tx = TransactionModel(
                      id: widget.transaction?.id,
                      title: _titleController.text,
                      amount: double.parse(_amountController.text),
                      description: _descriptionController.text,
                      date: widget.transaction?.date ?? _selectedDate, 
                      isIncome: _isIncome,
                      categoryId: _selectedCategory!.id!,
                      paymentMethodId: _isIncome ? null : _selectedPaymentMethod!.id, // <-- GUARDAMOS EL ID DEL MÉTODO
                      createdAt: widget.transaction?.createdAt ?? DateTime.now(),
                      updatedAt: DateTime.now(),
                    );
                    
                    if (isEditing) {
                      txProvider.updateTransaction(tx);
                    } else {
                      txProvider.addTransaction(tx);
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