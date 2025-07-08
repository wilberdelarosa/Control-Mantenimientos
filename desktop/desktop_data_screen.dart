import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../utils/app_theme.dart';
import 'desktop_export_import.dart';
import 'desktop_layout.dart';

class DesktopDataScreen extends StatelessWidget {
  const DesktopDataScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DesktopLayout(
      title: 'Gestión de Datos',
      child: Consumer<DataService>(
        builder: (context, dataService, child) {
          final dataExportImport = DataExportImport(
            dataService: dataService,
            context: context,
          );

          // Obtener el tamaño de la pantalla para hacer el diseño responsive
          final screenWidth = MediaQuery.of(context).size.width;
          final isSmallScreen = screenWidth < 1200;
          final isMediumScreen = screenWidth >= 1200 && screenWidth < 1600;

          // Ajustar el padding según el tamaño de la pantalla
          final horizontalPadding = isSmallScreen ? 16.0 : 24.0;

          return Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestión de Datos',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    // Texto adaptativo
                    fontSize: isSmallScreen ? 24.0 : null,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16.0 : 24.0),

                // Sección de exportación
                _buildSection(
                  context,
                  'Exportación de Datos',
                  [
                    _buildCard(
                      context,
                      'Exportar Todos los Datos',
                      'Guarda todos los datos en un archivo JSON que puede ser importado posteriormente.',
                      Icons.download_rounded,
                      AppColors.primaryYellow,
                          () => dataExportImport.exportAllData(),
                    ),
                    SizedBox(height: isSmallScreen ? 12.0 : 16.0),

                    // Layout adaptativo para las tarjetas
                    _buildResponsiveCardRow(
                      context,
                      isSmallScreen,
                      isMediumScreen,
                      [
                        _buildCard(
                          context,
                          'Exportar Equipos',
                          'Exporta solo los datos de equipos en formato CSV.',
                          Icons.construction,
                          AppColors.primaryYellow,
                              () => dataExportImport.exportToCsv('equipos'),
                        ),
                        _buildCard(
                          context,
                          'Exportar Mantenimientos',
                          'Exporta solo los datos de mantenimientos en formato CSV.',
                          Icons.build,
                          AppColors.primaryYellow,
                              () => dataExportImport.exportToCsv('mantenimientos'),
                        ),
                      ],
                    ),

                    SizedBox(height: isSmallScreen ? 12.0 : 16.0),

                    _buildResponsiveCardRow(
                      context,
                      isSmallScreen,
                      isMediumScreen,
                      [
                        _buildCard(
                          context,
                          'Exportar Inventario',
                          'Exporta solo los datos de inventario en formato CSV.',
                          Icons.inventory_2,
                          AppColors.primaryYellow,
                              () => dataExportImport.exportToCsv('inventario'),
                        ),
                        _buildCard(
                          context,
                          'Exportar Empleados',
                          'Exporta solo los datos de empleados en formato CSV.',
                          Icons.people,
                          AppColors.primaryYellow,
                              () => dataExportImport.exportToCsv('empleados'),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: isSmallScreen ? 24.0 : 32.0),

                // Sección de importación
                _buildSection(
                  context,
                  'Importación de Datos',
                  [
                    _buildCard(
                      context,
                      'Importar Datos',
                      'Carga datos desde un archivo JSON exportado previamente.',
                      Icons.upload_file,
                      AppColors.success,
                          () => dataExportImport.importData(),
                    ),
                  ],
                ),

                SizedBox(height: isSmallScreen ? 24.0 : 32.0),

                // Sección de copias de seguridad
                _buildSection(
                  context,
                  'Copias de Seguridad',
                  [
                    _buildResponsiveCardRow(
                      context,
                      isSmallScreen,
                      isMediumScreen,
                      [
                        _buildCard(
                          context,
                          'Crear Copia de Seguridad',
                          'Crea una copia de seguridad de todos los datos en el directorio de la aplicación.',
                          Icons.backup,
                          AppColors.primaryYellow,
                              () => dataExportImport.createBackup(),
                        ),
                        _buildCard(
                          context,
                          'Restaurar Copia de Seguridad',
                          'Restaura los datos desde una copia de seguridad previa.',
                          Icons.restore,
                          AppColors.warning,
                              () => dataExportImport.restoreFromBackup(),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: isSmallScreen ? 24.0 : 32.0),

                // Sección de limpieza de datos
                _buildSection(
                  context,
                  'Limpieza de Datos',
                  [
                    _buildCard(
                      context,
                      'Eliminar Datos Históricos',
                      'Elimina mantenimientos realizados y actualizaciones de horas/km, manteniendo equipos e inventario.',
                      Icons.delete_sweep,
                      AppColors.error,
                          () => _showDeleteConfirmation(
                        context,
                        'Eliminar Datos Históricos',
                        'Esta acción eliminará todos los mantenimientos realizados y actualizaciones de horas/km. Los equipos, inventarios y mantenimientos programados se mantendrán. ¿Está seguro de que desea continuar?',
                            () async {
                          await dataService.eliminarDatosHistoricos();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Datos históricos eliminados correctamente'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12.0 : 16.0),

                    _buildResponsiveCardRow(
                      context,
                      isSmallScreen,
                      isMediumScreen,
                      [
                        _buildCard(
                          context,
                          'Eliminar Todos los Filtros',
                          'Elimina todos los filtros del inventario permanentemente.',
                          Icons.filter_alt_off,
                          AppColors.error,
                              () => _showDeleteConfirmation(
                            context,
                            'Eliminar Todos los Filtros',
                            'Esta acción eliminará TODOS los filtros del inventario permanentemente. Esta acción no se puede deshacer. ¿Está seguro de que desea continuar?',
                                () async {
                              await dataService.eliminarTodosFiltros();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Todos los filtros han sido eliminados correctamente'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                          ),
                        ),
                        _buildCard(
                          context,
                          'Eliminar Historial de Filtros',
                          'Elimina solo el historial de movimientos de los filtros.',
                          Icons.history_toggle_off,
                          AppColors.error,
                              () => _showDeleteConfirmation(
                            context,
                            'Eliminar Historial de Filtros',
                            'Esta acción eliminará todo el historial de movimientos de los filtros. Los filtros se mantendrán pero perderán su historial de movimientos. ¿Está seguro de que desea continuar?',
                                () async {
                              await dataService.eliminarHistorialFiltros();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Historial de filtros eliminado correctamente'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Construir una sección con título
  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    // Ajustar tamaño de texto según el tamaño de la pantalla
    final isSmallScreen = MediaQuery.of(context).size.width < 1200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 18.0 : null,
          ),
        ),
        SizedBox(height: isSmallScreen ? 12.0 : 16.0),
        ...children,
      ],
    );
  }

  // Construir una tarjeta de acción
  Widget _buildCard(
      BuildContext context,
      String title,
      String description,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    // Ajustar tamaño de texto según el tamaño de la pantalla
    final isSmallScreen = MediaQuery.of(context).size.width < 1200;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: isSmallScreen ? 20.0 : 24.0),
                  SizedBox(width: isSmallScreen ? 8.0 : 12.0),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 14.0 : 16.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 6.0 : 8.0),
              Text(
                description,
                style: TextStyle(
                  color: AppColors.mediumGray,
                  fontSize: isSmallScreen ? 12.0 : 14.0,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construir una fila de tarjetas responsive
  Widget _buildResponsiveCardRow(
      BuildContext context,
      bool isSmallScreen,
      bool isMediumScreen,
      List<Widget> cards,
      ) {
    // En pantallas pequeñas, mostrar las tarjetas en columna
    if (isSmallScreen) {
      return Column(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            cards[i],
            if (i < cards.length - 1) const SizedBox(height: 12.0),
          ],
        ],
      );
    }

    // En pantallas medianas y grandes, mostrar las tarjetas en fila
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          Expanded(child: cards[i]),
          if (i < cards.length - 1) SizedBox(width: isMediumScreen ? 12.0 : 16.0),
        ],
      ],
    );
  }

  // Mostrar diálogo de confirmación para eliminar datos
  void _showDeleteConfirmation(
      BuildContext context,
      String title,
      String message,
      VoidCallback onConfirm,
      ) {
    final isSmallScreen = MediaQuery.of(context).size.width < 1200;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontSize: isSmallScreen ? 18.0 : 20.0,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: isSmallScreen ? 14.0 : 16.0,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
