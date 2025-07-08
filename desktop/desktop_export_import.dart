import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import '../services/data_service.dart';
import '../utils/app_theme.dart';

class DataExportImport {
  final DataService dataService;
  final BuildContext context;

  DataExportImport({required this.dataService, required this.context});

  // Exportar todos los datos a JSON
  Future<void> exportAllData() async {
    try {
      final datos = await dataService.exportarTodosLosDatos();
      final jsonString = jsonEncode(datos);

      // Usar file_selector para guardar el archivo
      final String fileName = 'alito_datos_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';

      final FileSaveLocation? location = await getSaveLocation(
        suggestedName: fileName,
        acceptedTypeGroups: [
          const XTypeGroup(
            label: 'JSON',
            extensions: ['json'],
          ),
        ],
      );

      if (location != null) {
        final File file = File(location.path);
        await file.writeAsString(jsonString);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Datos exportados correctamente a: ${location.path}'),
            backgroundColor: AppColors.success,
          ),
        );
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

  // Importar datos desde JSON
  Future<void> importData() async {
    try {
      // Usar file_selector para abrir el archivo
      final XFile? file = await openFile(
        acceptedTypeGroups: [
          const XTypeGroup(
            label: 'JSON',
            extensions: ['json'],
          ),
        ],
      );

      if (file != null) {
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
          await dataService.importarDatosDesdeJSON(datos);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Datos importados correctamente'),
              backgroundColor: AppColors.success,
            ),
          );
        }
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

  // Exportar a CSV
  Future<void> exportToCsv(String type) async {
    try {
      List<List<dynamic>> data = [];
      String fileName = '';

      // Preparar datos según el tipo
      switch (type) {
        case 'equipos':
          data = _prepareEquiposData();
          fileName = 'equipos';
          break;
        case 'mantenimientos':
          data = _prepareMantenimientosData();
          fileName = 'mantenimientos';
          break;
        case 'inventario':
          data = _prepareInventarioData();
          fileName = 'inventario';
          break;
        case 'empleados':
          data = _prepareEmpleadosData();
          fileName = 'empleados';
          break;
        default:
          throw Exception('Tipo de exportación no válido');
      }

      // Convertir a CSV
      final String csvData = _convertToCsv(data);

      // Guardar archivo
      final String fullFileName = '${fileName}_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';

      final FileSaveLocation? location = await getSaveLocation(
        suggestedName: fullFileName,
        acceptedTypeGroups: [
          const XTypeGroup(
            label: 'CSV',
            extensions: ['csv'],
          ),
        ],
      );

      if (location != null) {
        final File file = File(location.path);
        await file.writeAsString(csvData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Datos exportados correctamente a: ${location.path}'),
            backgroundColor: AppColors.success,
          ),
        );
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

  // Preparar datos de equipos para CSV
  List<List<dynamic>> _prepareEquiposData() {
    // Encabezados
    final headers = [
      'ID', 'Ficha', 'Nombre', 'Marca', 'Modelo',
      'Número de Serie', 'Placa', 'Categoría', 'Activo'
    ];

    // Datos
    final rows = dataService.equipos.map((equipo) => [
      equipo.id,
      equipo.ficha,
      equipo.nombre,
      equipo.marca,
      equipo.modelo,
      equipo.numeroSerie,
      equipo.placa,
      equipo.categoria,
      equipo.activo ? 'Sí' : 'No',
    ]).toList();

    // Combinar encabezados y datos
    return [headers, ...rows];
  }

  // Preparar datos de mantenimientos para CSV
  List<List<dynamic>> _prepareMantenimientosData() {
    // Encabezados
    final headers = [
      'ID', 'Ficha', 'Equipo', 'Fecha', 'Horas/Km',
      'Empleado', 'Observaciones'
    ];

    // Datos
    final rows = dataService.mantenimientosRealizados.map((mantenimiento) {
      final equipo = dataService.obtenerEquipoPorFicha(mantenimiento.ficha);
      final empleado = dataService.obtenerEmpleadoPorId(mantenimiento.idEmpleado);

      return [
        mantenimiento.id,
        mantenimiento.ficha,
        equipo?.nombre ?? 'Desconocido',
        DateFormat('dd/MM/yyyy').format(mantenimiento.fechaMantenimiento),
        mantenimiento.horasKmAlMomento,
        empleado?.nombreCompleto ?? 'Desconocido',
        mantenimiento.observaciones,
      ];
    }).toList();

    // Combinar encabezados y datos
    return [headers, ...rows];
  }

  // Preparar datos de inventario para CSV
  List<List<dynamic>> _prepareInventarioData() {
    // Encabezados
    final headers = [
      'ID', 'Nombre', 'Tipo', 'Categoría de Equipo',
      'Cantidad', 'Activo', 'Código', 'Proveedor'
    ];

    // Datos
    final rows = dataService.inventarios.map((inventario) => [
      inventario.id,
      inventario.nombre,
      inventario.tipo,
      inventario.categoriaEquipo,
      inventario.cantidad,
      inventario.activo ? 'Sí' : 'No',
      inventario.codigoIdentificacion ?? '',
      inventario.empresaSuplidora ?? '',
    ]).toList();

    // Combinar encabezados y datos
    return [headers, ...rows];
  }

  // Preparar datos de empleados para CSV
  List<List<dynamic>> _prepareEmpleadosData() {
    // Encabezados
    final headers = [
      'ID', 'Nombre', 'Apellido', 'Categoría',
      'Cargo', 'Fecha de Nacimiento', 'Activo'
    ];

    // Datos
    final rows = dataService.empleados.map((empleado) => [
      empleado.id,
      empleado.nombre,
      empleado.apellido,
      empleado.categoria,
      empleado.cargo,
      DateFormat('dd/MM/yyyy').format(empleado.fechaNacimiento),
      empleado.activo ? 'Sí' : 'No',
    ]).toList();

    // Combinar encabezados y datos
    return [headers, ...rows];
  }

  // Convertir datos a formato CSV
  String _convertToCsv(List<List<dynamic>> data) {
    return data.map((row) {
      return row.map((cell) {
        // Escapar comas y comillas
        if (cell.toString().contains(',') || cell.toString().contains('"')) {
          return '"${cell.toString().replaceAll('"', '""')}"';
        }
        return cell.toString();
      }).join(',');
    }).join('\n');
  }

  // Crear copia de seguridad automática
  Future<void> createBackup() async {
    try {
      final datos = await dataService.exportarTodosLosDatos();
      final jsonString = jsonEncode(datos);

      // Crear directorio de backups si no existe
      final appDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${appDir.path}/alito_backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      // Crear archivo de backup con fecha y hora
      final String fileName = 'backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';
      final File file = File('${backupDir.path}/$fileName');
      await file.writeAsString(jsonString);

      // Eliminar backups antiguos (mantener solo los últimos 5)
      final List<FileSystemEntity> backups = await backupDir.list().toList();
      backups.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

      if (backups.length > 5) {
        for (int i = 5; i < backups.length; i++) {
          await backups[i].delete();
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copia de seguridad creada: $fileName'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear copia de seguridad: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Restaurar desde copia de seguridad
  Future<void> restoreFromBackup() async {
    try {
      // Obtener directorio de backups
      final appDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${appDir.path}/alito_backups');

      if (!await backupDir.exists()) {
        throw Exception('No hay copias de seguridad disponibles');
      }

      // Listar backups disponibles
      final List<FileSystemEntity> backups = await backupDir.list().toList();
      if (backups.isEmpty) {
        throw Exception('No hay copias de seguridad disponibles');
      }

      // Ordenar por fecha (más recientes primero)
      backups.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

      // Mostrar diálogo para seleccionar backup
      final String? selectedBackup = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Seleccionar Copia de Seguridad'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: backups.length,
              itemBuilder: (context, index) {
                final file = File(backups[index].path);
                final fileName = file.path.split('/').last;
                final date = file.statSync().modified;

                return ListTile(
                  title: Text(fileName),
                  subtitle: Text(DateFormat('dd/MM/yyyy HH:mm:ss').format(date)),
                  onTap: () => Navigator.pop(context, file.path),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      );

      if (selectedBackup != null) {
        // Leer el archivo seleccionado
        final File file = File(selectedBackup);
        final String fileContent = await file.readAsString();
        final Map<String, dynamic> datos = jsonDecode(fileContent);

        // Mostrar diálogo de confirmación
        final bool? confirmar = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar Restauración'),
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
                child: const Text('Restaurar'),
              ),
            ],
          ),
        );

        if (confirmar == true) {
          await dataService.importarDatosDesdeJSON(datos);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Datos restaurados correctamente'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al restaurar copia de seguridad: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
