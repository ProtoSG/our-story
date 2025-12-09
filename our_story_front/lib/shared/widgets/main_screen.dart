import 'package:flutter/material.dart';
import 'package:our_story_front/features/home/presentation/home_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../features/notes/presentation/notes_screen.dart';
import '../../features/dates/presentation/dates_screen.dart';
import '../../features/messages/presentation/chat_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  
  const MainScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  
  // Lista de screens principales (sin incluir el bottom nav en cada uno)
  late final List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _screens = [
      const HomeScreen(),
      const NotesScreen(showBottomNav: false),
      const DatesScreen(showBottomNav: false),
      // _buildPlaceholder('Favoritos', '⭐', 'Aquí verás tus momentos favoritos'),
      _buildProfileScreen(),
    ];
  }

  void _onNavTap(int index) {
    if (index == 4) {
      // Botón central - Chat (modal)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatScreen()),
      );
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildPlaceholder(String title, String emoji, String subtitle) {
    return Container(
      decoration: AppTheme.gradientBackground,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2332),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF1A2332).withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.black.withOpacity(0.1),
                ),
              ),
              child: const Text(
                'Próximamente',
                style: TextStyle(
                  color: Color(0xFF1A2332),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileScreen() {
    return Container(
      decoration: AppTheme.gradientBackground,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              const Text(
                '👤',
                style: TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 16),
              const Text(
                'Perfil',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2332),
                ),
              ),
              const SizedBox(height: 48),
              
              // Coming soon
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
                child: const Text(
                  'Opciones de perfil próximamente',
                  style: TextStyle(
                    color: Color(0xFF1A2332),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Container(
        decoration: AppTheme.gradientBackground,
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      // NOTA: Si usas GoRouter con ShellRoute, este archivo ya no es necesario
      // El bottomNavigationBar debe estar en el ShellRoute, no aquí
      bottomNavigationBar: null,
    );
  }
}
