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

  // --- PASO 1: AL TOCAR UN DÍA, SOLO CAMBIA LA VISTA (NO ABRE EL FORMULARIO) ---
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    provider.changeSelectedDate(selectedDay); // Cambia las transacciones que se ven abajo
    
    setState(() {
      _focusedDay = focusedDay; // Mueve el calendario visualmente
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final txList = provider.transactionsForSelectedDate;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      // --- PASO 2: BOTÓN FLOTANTE CON EL GUARDIÁN DE SEGURIDAD ---
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2C3E50), // Color elegante a juego con tu app
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final selectedDate = DateTime(provider.selectedDate.year, provider.selectedDate.month, provider.selectedDate.day);

          // Si el día seleccionado en el calendario es del futuro, bloqueamos
          if (selectedDate.isAfter(today)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.white),
                    SizedBox(width: 10),
                    Text('No puedes agregar registros en fechas futuras.'),
                  ],
                ),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            // Si es hoy o el pasado, abre el formulario con la fecha del calendario
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddTransactionScreen(
                  initialDate: provider.selectedDate,
                ),
              ),
            ).then((_) {
              setState(() {}); // Refresca al volver
            });
          }
        },
      ),
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
                  
                  Text(
                    '${_meses[_focusedDay.month - 1]} ${_focusedDay.year}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                  ),
                  
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
                headerVisible: false,
                startingDayOfWeek: StartingDayOfWeek.sunday,
                
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
                
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  defaultTextStyle: const TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.w600, fontSize: 16),
                  weekendTextStyle: const TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.w600, fontSize: 16),
                  
                  todayDecoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.rectangle, 
                  ),
                  todayTextStyle: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
                  
                  selectedDecoration: BoxDecoration(
                    color: const Color(0xFFC7D3E1),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  selectedTextStyle: const TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold, fontSize: 16),
                ),
                
                selectedDayPredicate: (day) => isSameDay(provider.selectedDate, day),
                onDaySelected: _onDaySelected, // Usa nuestra función limpia
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
                          
                          secondaryBackground: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
                            child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
                          ),

                          background: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(16)),
                            child: const Icon(Icons.edit, color: Colors.white, size: 30),
                          ),
                          
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
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

                              if (confirmEdit == true) {
                                Future.microtask(() {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => AddTransactionScreen(transaction: tx)),
                                  );
                                });
                              }
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
                          
                          child: Card(
                            elevation: 0,
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
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