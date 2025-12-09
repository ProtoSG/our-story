import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final Widget child;

  const CustomBottomNavBar({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final int currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/chat');
        },
        shape: CircleBorder(),
        backgroundColor: AppColors.accentPrimaryLight,
        child: Icon(Icons.chat_bubble_rounded,
          size: 35,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      extendBody: true,
      bottomNavigationBar: BottomAppBar(
        elevation: 1,
        height: 60,
        color: AppColors.backgroundCardLight.withValues(alpha: 0.85),
        shape: CircularNotchedRectangle(),
        notchMargin: 10,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildNavItem(
              context: context,
              icon: Icons.home_rounded,
              route: '/home',
              isActive: currentIndex == 0,
            ),
            _buildNavItem(
              context: context,
              icon: Icons.note_rounded,
              route: '/notes',
              isActive: currentIndex == 1,
            ),
            // Botón central (acción principal)
            SizedBox(width: 18),
            _buildNavItem(
              context: context,
              icon: Icons.calendar_today_rounded,
              route: '/dates',
              isActive: currentIndex == 2,
            ),
            _buildNavItem(
              context: context,
              icon: Icons.person_rounded,
              route: '/profile',
              isActive: currentIndex == 3,
            ),
          ],
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/notes')) return 1;
    if (location.startsWith('/dates')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String route,
    required bool isActive,
  }) {
    return IconButton(
      onPressed: () {
        context.go(route);
      },
      icon: Icon(icon,
        color: isActive
            ? AppColors.accentPrimaryLight
            : AppColors.accentSecondaryLight,
        size: 30,
      ),
    );
  }

}
