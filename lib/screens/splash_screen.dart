import 'package:flutter/material.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// Agregamos "with SingleTickerProviderStateMixin" para permitir animaciones
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Configuramos la animación del latido
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // Qué tan rápido late
    )..repeat(reverse: true); // repeat(reverse: true) hace el efecto de palpitar

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    // 2. Temporizador de 3 segundos para cambiar de pantalla
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    });
  }

  @override
  void dispose() {
    // Es muy importante destruir la animación cuando salimos de la pantalla
    // para no gastar memoria del celular.
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3F5),
      // Envolvemos el Stack para forzar el tamaño completo de la pantalla
      body: SizedBox.expand(
        child: Stack(
          children: [
            // --- 1. Contenido Central (Capa base) ---
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: const Text('❤️', style: TextStyle(fontSize: 120)),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Con amor para ti',
                    style: TextStyle(
                      color: Color(0xFFA855F7), // Morado suave
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Fefi',
                        style: TextStyle(
                          color: Color(0xFFFF4B6E), // Rosa/Rojo intenso
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('💞', style: TextStyle(fontSize: 32)),
                    ],
                  ),
                ],
              ),
            ),

            // --- 2. Texto inferior ---
            const Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Iniciando tu espacio seguro...',
                  style: TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // --- 3. Emojis decorativos flotantes (Capa superior) ---
            const Positioned(top: 120, left: 40, child: Text('💖', style: TextStyle(fontSize: 24))),
            const Positioned(top: 220, right: 60, child: Text('✨', style: TextStyle(fontSize: 28))),
            const Positioned(bottom: 280, right: 50, child: Text('💝', style: TextStyle(fontSize: 24))),
            const Positioned(bottom: 180, left: 60, child: Text('💕', style: TextStyle(fontSize: 26))),
          ],
        ),
      ),
    );
  }
}