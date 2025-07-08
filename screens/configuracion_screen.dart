import 'dart:convert';
import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';  // Importar el paquete share_plus
import '../services/theme_service.dart';
import '../utils/app_theme.dart';
import '../services/data_service.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

// No necesitamos importar file_picker ya que usaremos file_selector para todas las plataformas

class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSection(
                context,
                'Apariencia',
                [
                  SwitchListTile(
                    title: const Text('Modo Oscuro'),
                    subtitle: const Text('Cambiar entre tema claro y oscuro'),
                    value: themeService.isDarkMode,
                    onChanged: (value) {
                      themeService.toggleDarkMode();
                    },
                    secondary: Icon(
                      themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: AppColors.primaryYellow,
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Menú Inferior'),
                    subtitle: const Text('Cambiar entre menú inferior y menú lateral'),
                    value: themeService.isBottomMenu,
                    onChanged: (value) {
                      themeService.toggleMenuType();
                    },
                    secondary: Icon(
                      themeService.isBottomMenu ? Icons.menu_open : Icons.menu,
                      color: AppColors.primaryYellow,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                'Notificaciones',
                [
                  SwitchListTile(
                    title: const Text('Notificaciones Push'),
                    subtitle: const Text('Habilitar o deshabilitar todas las notificaciones'),
                    value: themeService.enableNotifications,
                    onChanged: (value) {
                      themeService.toggleNotifications();
                    },
                    secondary: Icon(
                      themeService.enableNotifications ? Icons.notifications_active : Icons.notifications_off,
                      color: AppColors.primaryYellow,
                    ),
                  ),
                  if (themeService.enableNotifications) ...[
                    _buildNotificationOption(
                      context,
                      'Mantenimientos vencidos',
                      'Notificar cuando un equipo tenga mantenimiento vencido',
                      true,
                    ),
                    _buildNotificationOption(
                      context,
                      'Mantenimientos próximos',
                      'Notificar cuando un equipo esté próximo a mantenimiento',
                      true,
                    ),
                    _buildNotificationOption(
                      context,
                      'Stock bajo',
                      'Notificar cuando un producto tenga stock bajo',
                      true,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                'Gestión de Datos',
                [
                  ListTile(
                    title: const Text('Exportar Datos'),
                    subtitle: const Text('Guardar todos los datos en un archivo JSON'),
                    leading: const Icon(Icons.upload_file, color: AppColors.primaryYellow),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _exportarDatos(context),
                  ),
                  ListTile(
                    title: const Text('Importar Datos'),
                    subtitle: const Text('Cargar datos desde un archivo JSON'),
                    leading: const Icon(Icons.download_rounded, color: AppColors.primaryYellow),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _importarDatos(context),
                  ),
                  ListTile(
                    title: const Text('Eliminar Datos'),
                    subtitle: const Text('Eliminar datos históricos o filtros'),
                    leading: const Icon(Icons.delete_outline, color: AppColors.error),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _mostrarOpcionesEliminarDatos(context),
                  ),
                  ListTile(
                    title: const Text('Compartir Datos'),
                    subtitle: const Text('Compartir datos a través de otras aplicaciones'),
                    leading: const Icon(Icons.share, color: AppColors.primaryYellow),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _compartirDatos(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                'Acerca de',
                [
                  ListTile(
                    title: const Text('Versión'),
                    subtitle: const Text('1.0.0'),
                    leading: const Icon(Icons.info_outline, color: AppColors.primaryYellow),
                  ),
                  ListTile(
                    title: const Text('ALITO GROUP SRL'),
                    subtitle: const Text('Control de Mantenimiento'),
                    leading: const Icon(Icons.business, color: AppColors.primaryYellow),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationOption(
      BuildContext context,
      String title,
      String subtitle,
      bool initialValue,
      ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: initialValue,
      onChanged: (value) {
        // Aquí se implementaría la lógica para guardar la configuración
      },
      secondary: const Icon(Icons.circle, size: 12, color: AppColors.primaryYellow),
    );
  }

  // Mostrar opciones para eliminar diferentes tipos de datos
  void _mostrarOpcionesEliminarDatos(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Datos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Eliminar Datos Históricos'),
              subtitle: const Text('Eliminar mantenimientos realizados y actualizaciones'),
              leading: const Icon(Icons.history, color: AppColors.error),
              onTap: () {
                Navigator.pop(context);
                _confirmarEliminarDatos(context);
              },
            ),
            ListTile(
              title: const Text('Eliminar Todos los Filtros'),
              subtitle: const Text('Eliminar todos los filtros del inventario'),
              leading: const Icon(Icons.filter_alt, color: AppColors.error),
              onTap: () {
                Navigator.pop(context);
                _confirmarEliminarFiltros(context);
              },
            ),
            ListTile(
              title: const Text('Eliminar Historial de Filtros'),
              subtitle: const Text('Eliminar solo el historial de movimientos de filtros'),
              leading: const Icon(Icons.history_toggle_off, color: AppColors.error),
              onTap: () {
                Navigator.pop(context);
                _confirmarEliminarHistorialFiltros(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportarDatos(BuildContext context) async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final datos = await dataService.exportarTodosLosDatos();
      final jsonString = jsonEncode(datos);

      if (kIsWeb) {
        // Implementación para web (no disponible en este momento)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La exportación de datos no está disponible en la versión web'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Para dispositivos móviles, guardar en el directorio temporal y ofrecer compartir
      if (Platform.isAndroid || Platform.isIOS) {
        final directory = await getTemporaryDirectory();
        final fileName = 'alito_datos_${DateTime.now().millisecondsSinceEpoch}.json';
        final filePath = '${directory.path}/$fileName';

        final file = File(filePath);
        await file.writeAsString(jsonString);

        // Mostrar diálogo para compartir o guardar
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exportación Exitosa'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('¿Qué deseas hacer con el archivo exportado?'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar'),
                      onPressed: () async {
                        Navigator.pop(context);

                        // Guardar en documentos
                        final docsDir = await getApplicationDocumentsDirectory();
                        final savedFilePath = '${docsDir.path}/$fileName';
                        await file.copy(savedFilePath);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Archivo guardado en: $savedFilePath'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryYellow,
                        foregroundColor: AppColors.darkGray,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.share),
                      label: const Text('Compartir'),
                      onPressed: () {
                        Navigator.pop(context);

                        // Compartir el archivo
                        Share.shareXFiles(
                          [XFile(filePath)],
                          subject: 'Datos de ALITO GROUP SRL',
                          text: 'Archivo de datos exportado desde la aplicación de Control de Mantenimiento',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryYellow,
                        foregroundColor: AppColors.darkGray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
        return;
      }

      // Para escritorio, usar file_selector
      try {
        final FileSaveLocation? location = await getSaveLocation(
          suggestedName: 'alito_datos_${DateTime.now().millisecondsSinceEpoch}.json',
          acceptedTypeGroups: [
            const XTypeGroup(
              label: 'JSON',
              extensions: ['json'],
            ),
          ],
        );

        String? path = location?.path;

        if (path != null) {
          final File file = File(path);
          await file.writeAsString(jsonString);

          // Obtener solo el nombre del archivo para mostrar en el mensaje
          final fileName = path.split(Platform.pathSeparator).last;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Datos exportados correctamente como: $fileName'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        throw Exception('Error al guardar el archivo: $e');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al exportar datos: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _importarDatos(BuildContext context) async {
    try {
      if (kIsWeb) {
        // Implementación para web (no disponible en este momento)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La importación de datos no está disponible en la versión web'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Usar file_selector para todas las plataformas
      String? filePath;

      try {
        final XFile? file = await openFile(
          acceptedTypeGroups: [
            const XTypeGroup(
              label: 'JSON',
              extensions: ['json'],
            ),
          ],
        );

        if (file != null) {
          filePath = file.path;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar archivo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (filePath != null) {
        // Leer el contenido del archivo
        final file = File(filePath);
        final String fileContent = await file.readAsString();
        final Map<String, dynamic> datos = jsonDecode(fileContent);

        // Mostrar diálogo de confirmación
        final bool? confirmar = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar Importación'),
            content: const Text(
                'Esta acción reemplazará todos los datos existentes. ¿Está seguro de que desea continuar?'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: AppColors.darkGray,
                ),
                child: const Text('Importar'),
              ),
            ],
          ),
        );

        if (confirmar == true) {
          final dataService = Provider.of<DataService>(context, listen: false);
          await dataService.importarDatosDesdeJSON(datos);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Datos importados correctamente'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        // El usuario canceló la selección
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Importación cancelada'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al importar datos: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _confirmarEliminarDatos(BuildContext context) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text(
            'Esta acción eliminará todos los mantenimientos realizados y actualizaciones de horas/km. '
                'Los equipos, inventarios y mantenimientos programados se mantendrán. '
                '¿Está seguro de que desea continuar?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        final dataService = Provider.of<DataService>(context, listen: false);
        await dataService.eliminarDatosHistoricos();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Datos históricos eliminados correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar datos: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _confirmarEliminarFiltros(BuildContext context) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación de Filtros'),
        content: const Text(
            'Esta acción eliminará TODOS los filtros del inventario permanentemente. '
                'Esta acción no se puede deshacer. '
                '¿Está seguro de que desea continuar?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        final dataService = Provider.of<DataService>(context, listen: false);
        await dataService.eliminarTodosFiltros();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todos los filtros han sido eliminados correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar filtros: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _confirmarEliminarHistorialFiltros(BuildContext context) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación de Historial'),
        content: const Text(
            'Esta acción eliminará todo el historial de movimientos de los filtros. '
                'Los filtros se mantendrán pero perderán su historial de movimientos. '
                '¿Está seguro de que desea continuar?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        final dataService = Provider.of<DataService>(context, listen: false);
        await dataService.eliminarHistorialFiltros();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Historial de filtros eliminado correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar historial de filtros: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _compartirDatos(BuildContext context) async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      final datos = await dataService.exportarTodosLosDatos();
      final jsonString = jsonEncode(datos);

      // Guardar el JSON en un archivo temporal
      final directory = await getTemporaryDirectory();
      final fileName = 'alito_datos_${DateTime.now().millisecondsSinceEpoch}.json';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(jsonString);

      // Compartir el archivo
      final XFile xFile = XFile(filePath);
      await Share.shareXFiles([xFile], text: 'Compartiendo datos de Alito');

      // Eliminar el archivo temporal después de compartir
      await file.delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al compartir datos: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
