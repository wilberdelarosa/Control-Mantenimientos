import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/menu_drawer.dart';

class DesktopLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;

  const DesktopLayout({
    Key? key,
    required this.child,
    required this.title,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Menú lateral fijo
          Container(
            width: 250,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.primaryYellow,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.darkGray,
                        child: Icon(
                          Icons.construction,
                          color: AppColors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'ALITO GROUP SRL',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        ),
                      ),
                      Text(
                        'Control de Mantenimiento',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: MenuDrawer(isDesktop: true),
                ),
              ],
            ),
          ),
          // Separador vertical
          Container(
            width: 1,
            color: Theme.of(context).dividerColor,
          ),
          // Contenido principal
          Expanded(
            child: Column(
              children: [
                // Barra de título personalizada
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (actions != null) ...actions!,
                    ],
                  ),
                ),
                // Contenido
                Expanded(
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
