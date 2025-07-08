import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../screens/inventario_screen.dart';
import '../screens/equipos_screen.dart';
import '../screens/mantenimiento_programado_screen.dart';
import '../screens/control_mantenimiento_screen.dart';
import '../screens/empleados_screen.dart';
import '../screens/configuracion_screen.dart';
import '../screens/categorias_screen.dart';
import '../screens/historial_avanzado_screen.dart';
import '../desktop/desktop_data_screen.dart'; // Importar la nueva pantalla

class MenuDrawer extends StatelessWidget {
  final bool isDesktop;

  const MenuDrawer({Key? key, this.isDesktop = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isDesktop
        ? _buildDesktopMenu(context)
        : Drawer(
      child: _buildMenuItems(context),
    );
  }

  Widget _buildDesktopMenu(BuildContext context) {
    return _buildMenuItems(context);
  }

  Widget _buildMenuItems(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        if (!isDesktop)
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primaryYellow,
            ),
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
        _buildMenuItem(
          context,
          'Panel de Control',
          Icons.dashboard,
          0,
        ),
        _buildMenuItem(
          context,
          'Inventario',
          Icons.inventory_2,
          1,
        ),
        _buildMenuItem(
          context,
          'Equipos',
          Icons.construction,
          2,
        ),
        _buildMenuItem(
          context,
          'Administrador de Mantenimiento',
          Icons.build_circle,
          3,
        ),
        _buildMenuItem(
          context,
          'Control de Mantenimiento',
          Icons.build,
          4,
        ),
        _buildMenuItem(
          context,
          'Empleados',
          Icons.people,
          5,
        ),
        _buildMenuItem(
          context,
          'Historial Avanzado',
          Icons.history,
          8,
        ),
        // Nuevo elemento para la versión de escritorio
        if (isDesktop)
          _buildMenuItem(
            context,
            'Importar/Exportar Datos',
            Icons.import_export,
            9,
          ),
        const Divider(),
        _buildMenuItem(
          context,
          'Configuración',
          Icons.settings,
          6,
        ),
      ],
    );
  }

  Widget _buildMenuItem(
      BuildContext context,
      String title,
      IconData icon,
      int index,
      ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        if (!isDesktop) {
          Navigator.pop(context);
        }

        // Navigate to the appropriate screen based on index
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/');
            break;
          case 1:
            Navigator.push(context, MaterialPageRoute(builder: (context) => const InventarioScreen()));
            break;
          case 2:
            Navigator.push(context, MaterialPageRoute(builder: (context) => const EquiposScreen()));
            break;
          case 3:
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MantenimientoProgramadoScreen()));
            break;
          case 4:
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ControlMantenimientoScreen()));
            break;
          case 5:
            Navigator.push(context, MaterialPageRoute(builder: (context) => const EmpleadosScreen()));
            break;
          case 6:
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfiguracionScreen()));
            break;
          case 7:
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoriasScreen()));
            break;
          case 8:
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HistorialAvanzadoScreen()));
            break;
          case 9:
            if (isDesktop) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DesktopDataScreen()));
            }
            break;
        }
      },
    );
  }
}
