import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class BottomMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const BottomMenu({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Asegurarse de que el índice esté dentro del rango válido
    final validIndex = selectedIndex.clamp(0, 4);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: validIndex,
      onTap: onItemSelected,
      selectedItemColor: AppColors.primaryYellow,
      unselectedItemColor: AppColors.mediumGray,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2),
          label: 'Inventario',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.construction),
          label: 'Equipos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.build_circle),
          label: 'Mant.',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.build),
          label: 'Control',
        ),
      ],
    );
  }
}
