import 'package:flutter/material.dart';
import '../widget/transaction_detail_modal.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/transaction_provider.dart';
import '../models/category_model.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();

  // Nombres de los meses en español
  final List<String> _meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      provider.fetchTransactions();
      provider.fetchCategories();
      setState(() {
        _focusedDay = provider.selectedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final txList = provider.transactionsForSelectedDate;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), // Fondo gris muy claro de tu imagen
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // --- ENCABEZADO PERSONALIZADO (Mes y Botones) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón Izquierda
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: const Icon(Icons.arrow_left, color: Colors.blueGrey),
                    ),
                  ),
                  
                  // Título del Mes
                  Text(
                    '${_meses[_focusedDay.month - 1]} ${_focusedDay.year}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                  ),
                  
                  // Botón Derecha
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: const Icon(Icons.arrow_right, color: Colors.blueGrey),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- CONTENEDOR BLANCO DEL CALENDARIO ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.only(top: 10, bottom: 20, left: 10, right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                currentDay: DateTime.now(),
                headerVisible: false, // Ocultamos el header feo por defecto
                startingDayOfWeek: StartingDayOfWeek.sunday,
                
                // Traducimos los días de la semana manualmente
                calendarBuilders: CalendarBuilders(
                  dowBuilder: (context, day) {
                    const days = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
                    return Center(
                      child: Text(
                        days[day.weekday - 1],
                        style: const TextStyle(color: Color(0xFF9EABB8), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    );
                  },
                ),
                
                // Estilos del calendario para igualar tu imagen
                // Estilos del calendario para igualar tu imagen
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  defaultTextStyle: const TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.w600, fontSize: 16),
                  weekendTextStyle: const TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.w600, fontSize: 16),
                  
                  // Agregamos shape: BoxShape.rectangle aquí
                  todayDecoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.rectangle, 
                  ),
                  todayTextStyle: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
                  
                  // Agregamos shape: BoxShape.rectangle aquí también
                  selectedDecoration: BoxDecoration(
                    color: const Color(0xFFC7D3E1),
                    shape: BoxShape.rectangle, // <--- ESTA ES LA LÍNEA MÁGICA
                    borderRadius: BorderRadius.circular(14),
                  ),
                  selectedTextStyle: const TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold, fontSize: 16),
                ),
                
                selectedDayPredicate: (day) => isSameDay(provider.selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  // 1. Le avisa al Provider la nueva fecha
                  provider.changeSelectedDate(selectedDay); 
                  
                  // 2. Mueve visualmente el calendario a esa fecha
                  setState(() {
                    _focusedDay = focusedDay; 
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
              ),
            ),
            const SizedBox(height: 30),

            // --- TÍTULO DE LA LISTA ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                isSameDay(provider.selectedDate, DateTime.now())
                    ? 'Movimientos de Hoy'
                    : 'Movimientos del ${provider.selectedDate.day} de ${_meses[provider.selectedDate.month - 1]}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
              ),
            ),
            const SizedBox(height: 10),

            // --- LISTA DE TRANSACCIONES ---
            Expanded(
              child: txList.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay transacciones registradas en esta fecha.',
                        style: TextStyle(color: Color(0xFF9EABB8), fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: txList.length,
                      itemBuilder: (context, index) {
                        final tx = txList[index];
                        final categoryName = provider.categories
                            .firstWhere((cat) => cat.id == tx.categoryId, orElse: () => CategoryModel(name: 'Unknown'))
                            .name;

                        return Dismissible(
                          key: Key(tx.id.toString()),
                          direction: DismissDirection.horizontal, 
                          
                          // --- FONDO SECUNDARIO (Derecha a Izquierda -> BORRAR) ---
                          secondaryBackground: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
                            child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
                          ),

                          // --- FONDO PRINCIPAL (Izquierda a Derecha -> EDITAR) ---
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(16)),
                            child: const Icon(Icons.edit, color: Colors.white, size: 30),
                          ),
                          
                          // LÓGICA DE CONFIRMACIÓN CON MODALES
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              // MODAL PARA BORRAR
                              return await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    title: const Text('Confirmar eliminación', style: TextStyle(fontWeight: FontWeight.bold)),
                                    content: Text('¿Seguro que quieres eliminar el registro "${tx.title}"?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else if (direction == DismissDirection.startToEnd) {
                              // MODAL PARA EDITAR
                              final bool? confirmEdit = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    title: const Text('Confirmar edición', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                                    content: Text('¿Deseas editar el registro "${tx.title}"?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text('Editar', style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  );
                                },
                              );

                              // Si el usuario presiona "Editar" en el modal
                              if (confirmEdit == true) {
                                // Ignoramos el error de BuildContext usando un pequeño retraso
                                Future.microtask(() {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => AddTransactionScreen(transaction: tx)),
                                  );
                                });
                              }
                              // Siempre devolvemos false para que la tarjeta no se borre visualmente de la lista
                              return false; 
                            }
                            return false;
                          },
                          
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              provider.deleteTransaction(tx.id!);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registro "${tx.title}" eliminado')));
                            }
                          },
                          
                          // --- LA TARJETA ORIGINAL INTACTA ---
                          child: Card(
                            elevation: 0,
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              // --- NUEVO: EVENTO ON TAP PARA VER DETALLES ---
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => TransactionDetailModal(
                                    transaction: tx,
                                    categoryName: categoryName,
                                  ),
                                );
                              },
                              // ----------------------------------------------
                              leading: CircleAvatar(
                                backgroundColor: tx.isIncome ? Colors.green[50] : Colors.red[50],
                                child: Icon(tx.isIncome ? Icons.arrow_upward : Icons.arrow_downward, color: tx.isIncome ? Colors.green : Colors.red),
                              ),
                              title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                              subtitle: Text(categoryName, style: const TextStyle(color: Colors.grey)),
                              trailing: Text('${tx.isIncome ? "+" : "-"}\$${tx.amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: tx.isIncome ? Colors.green : Colors.red)),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}