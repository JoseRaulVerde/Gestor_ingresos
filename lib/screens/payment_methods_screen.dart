import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payment_method_provider.dart';
import '../models/payment_method_model.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  void _showForm(BuildContext context, [PaymentMethodModel? method]) {
    final nameController = TextEditingController(text: method?.name ?? '');
    final iconController = TextEditingController(text: method?.icon ?? '💳');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(method == null ? 'Nuevo Método' : 'Editar Método', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nombre (Ej. Efectivo)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: iconController,
                decoration: InputDecoration(labelText: 'Emoji (Ej. 💵)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50), // <-- Corregido
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: const Color(0xFF2C3E50),
                ),
                onPressed: () {
                  if (nameController.text.isEmpty) return;

                  final provider = Provider.of<PaymentMethodProvider>(context, listen: false);
                  if (method == null) {
                    provider.addPaymentMethod(nameController.text, iconController.text);
                  } else {
                    method.name = nameController.text;
                    method.icon = iconController.text;
                    provider.updatePaymentMethod(method);
                  }
                  Navigator.of(context).pop();
                },
                child: Text(method == null ? 'Guardar' : 'Actualizar', style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Métodos de Pago', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<PaymentMethodProvider>(
        builder: (context, provider, child) {
          if (provider.paymentMethods.isEmpty) {
            return const Center(child: Text('No hay métodos registrados.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.paymentMethods.length,
            itemBuilder: (context, index) {
              final method = provider.paymentMethods[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[50],
                    child: Text(method.icon ?? '💳', style: const TextStyle(fontSize: 20)),
                  ),
                  title: Text(method.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => _showForm(context, method),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          provider.deletePaymentMethod(method.id!);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Método eliminado')));
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2C3E50),
        onPressed: () => _showForm(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}