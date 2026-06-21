import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import 'insights_screen.dart';
import 'home_screen.dart';
import 'reports_screen.dart';
import 'goals_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const InsightsScreen(),
    const HomeScreen(),
    const GoalsScreen(),
    const ReportsScreen(), 
  ];

  @override
  void initState() {
    super.initState();
    // ¡LA MAGIA ESTÁ AQUÍ! 
    // Cargamos los datos de la BD apenas se abre la aplicación, antes de mostrar cualquier pantalla.
    Future.microtask(() {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      provider.fetchCategories();
      provider.fetchGoals();
      provider.fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Insights'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'Goals'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Reports'),
        ],
      ),
    );
  }
}