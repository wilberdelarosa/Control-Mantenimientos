import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'file_utils.dart';
import '../services/data_service.dart';
import '../models/equipo.dart';
import '../models/mantenimiento.dart';
import '../models/inventario.dart';
import '../models/empleado.dart';

class ExportUtils {
  /// Exporta datos a un archivo CSV
  static Future<void> exportToCsv({
    required BuildContext context,
    required String fileName,
    required List<List<dynamic>> data,
  }) async {
    try {
      // Convertir datos a formato CSV
      final csvData = data.map((row) => row.join(',')).join('\n');

      // Guardar archivo
      final filePath = await FileUtils.saveFile(
        bytes: utf8.encode(csvData),
        suggestedName: '$fileName.csv',
        allowedExtensions: ['csv'],
        dialogTitle: 'Guardar archivo CSV',
      );

      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Archivo guardado en: $filePath'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al exportar datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Exporta equipos a CSV
  static Future<void> exportEquipos({
    required BuildContext context,
    required DataService dataService,
  }) async {
    final equipos = dataService.equipos;

    // Encabezados
    final headers = [
      'ID', 'Ficha', 'Nombre', 'Marca', 'Modelo',
      'Número de Serie', 'Placa', 'Categoría', 'Activo'
    ];

    // Datos
    final rows = equipos.map((equipo) => [
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
    final data = [headers, ...rows];

    // Exportar
    await exportToCsv(
      context: context,
      fileName: 'equipos_${DateFormat('yyyyMMdd').format(DateTime.now())}',
      data: data,
    );
  }

  /// Exporta mantenimientos a CSV
  static Future<void> exportMantenimientos({
    required BuildContext context,
    required DataService dataService,
  }) async {
    final mantenimientos = dataService.mantenimientosRealizados;

    // Encabezados
    final headers = [
      'ID', 'Ficha', 'Equipo', 'Fecha', 'Horas/Km',
      'Empleado', 'Observaciones'
    ];

    // Datos
    final rows = mantenimientos.map((mantenimiento) {
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
    final data = [headers, ...rows];

    // Exportar
    await exportToCsv(
      context: context,
      fileName: 'mantenimientos_${DateFormat('yyyyMMdd').format(DateTime.now())}',
      data: data,
    );
  }

  /// Exporta inventario a CSV
  static Future<void> exportInventario({
    required BuildContext context,
    required DataService dataService,
  }) async {
    final inventarios = dataService.inventarios;

    // Encabezados
    final headers = [
      'ID', 'Nombre', 'Tipo', 'Categoría de Equipo',
      'Cantidad', 'Activo'
    ];

    // Datos
    final rows = inventarios.map((inventario) => [
      inventario.id,
      inventario.nombre,
      inventario.tipo,
      inventario.categoriaEquipo,
      inventario.cantidad,
      inventario.activo ? 'Sí' : 'No',
    ]).toList();

    // Combinar encabezados y datos
    final data = [headers, ...rows];

    // Exportar
    await exportToCsv(
      context: context,
      fileName: 'inventario_${DateFormat('yyyyMMdd').format(DateTime.now())}',
      data: data,
    );
  }
}
