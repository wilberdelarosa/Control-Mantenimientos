import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/data_service.dart';
import '../../models/mantenimiento.dart';
import '../../models/equipo.dart';
import '../../models/inventario.dart';
import '../../models/empleado.dart';

/// Controller class for the HistorialAvanzadoScreen
/// Manages state and business logic separated from the UI
class HistorialAvanzadoController with ChangeNotifier {
  // Filtros generales
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 90)),
    end: DateTime.now(),
  );
  
  String? _selectedFicha;
  String? _selectedCategoria;
  String? _selectedEmpleado;
  String? _selectedTipoActividad;
  
  // Filtros específicos para inventario
  String? _selectedTipoInventario;
  String? _selectedCategoriaEquipo;
  String? _selectedMarca;
  String? _selectedModelo;
  
  // Modo de visualización
  String _visualizacionMode = 'Lista'; // 'Lista', 'Gráfico', 'Calendario'
  
  // Getters
  DateTimeRange get dateRange => _dateRange;
  String? get selectedFicha => _selectedFicha;
  String? get selectedCategoria => _selectedCategoria;
  String? get selectedEmpleado => _selectedEmpleado;
  String? get selectedTipoActividad => _selectedTipoActividad;
  String? get selectedTipoInventario => _selectedTipoInventario;
  String? get selectedCategoriaEquipo => _selectedCategoriaEquipo;
  String? get selectedMarca => _selectedMarca;
  String? get selectedModelo => _selectedModelo;
  String get visualizacionMode => _visualizacionMode;
  
  // Setters with notification
  void setDateRange(DateTimeRange range) {
    _dateRange = range;
    notifyListeners();
  }
  
  void setSelectedFicha(String? value) {
    _selectedFicha = value;
    notifyListeners();
  }
  
  void setSelectedCategoria(String? value) {
    _selectedCategoria = value;
    notifyListeners();
  }
  
  void setSelectedEmpleado(String? value) {
    _selectedEmpleado = value;
    notifyListeners();
  }
  
  void setSelectedTipoActividad(String? value) {
    _selectedTipoActividad = value;
    notifyListeners();
  }
  
  void setSelectedTipoInventario(String? value) {
    _selectedTipoInventario = value;
    notifyListeners();
  }
  
  void setSelectedCategoriaEquipo(String? value) {
    _selectedCategoriaEquipo = value;
    notifyListeners();
  }
  
  void setSelectedMarca(String? value) {
    _selectedMarca = value;
    notifyListeners();
  }
  
  void setSelectedModelo(String? value) {
    _selectedModelo = value;
    notifyListeners();
  }
  
  void setVisualizacionMode(String value) {
    _visualizacionMode = value;
    notifyListeners();
  }
  
  void clearFilters() {
    _selectedFicha = null;
    _selectedCategoria = null;
    _selectedEmpleado = null;
    _selectedTipoActividad = null;
    _selectedTipoInventario = null;
    _selectedCategoriaEquipo = null;
    _selectedMarca = null;
    _selectedModelo = null;
    notifyListeners();
  }
  
  // Business logic methods
  bool isInDateRange(DateTime date) {
    return (date.isAfter(_dateRange.start) || date.isAtSameMomentAs(_dateRange.start)) &&
        (date.isBefore(_dateRange.end) || date.isAtSameMomentAs(_dateRange.end));
  }
  
  bool matchesFilters({
    MantenimientoRealizado? mantenimiento,
    DataService? dataService,
  }) {
    if (mantenimiento == null || dataService == null) {
      return true;
    }
    
    // Filtro por ficha
    if (_selectedFicha != null && mantenimiento.ficha != _selectedFicha) {
      return false;
    }
    
    // Filtro por categoría
    if (_selectedCategoria != null) {
      final equipo = dataService.obtenerEquipoPorFicha(mantenimiento.ficha);
      if (equipo == null || equipo.categoria != _selectedCategoria) {
        return false;
      }
    }
    
    // Filtro por empleado
    if (_selectedEmpleado != null) {
      final empleado = dataService.obtenerEmpleadoPorId(mantenimiento.idEmpleado);
      if (empleado == null || empleado.nombreCompleto != _selectedEmpleado) {
        return false;
      }
    }
    
    // Filtro por tipo de actividad
    if (_selectedTipoActividad != null && _selectedTipoActividad != 'Mantenimiento') {
      return false;
    }
    
    // Filtro por marca
    if (_selectedMarca != null) {
      final equipo = dataService.obtenerEquipoPorFicha(mantenimiento.ficha);
      if (equipo == null || equipo.marca != _selectedMarca) {
        return false;
      }
    }
    
    // Filtro por modelo
    if (_selectedModelo != null) {
      final equipo = dataService.obtenerEquipoPorFicha(mantenimiento.ficha);
      if (equipo == null || equipo.modelo != _selectedModelo) {
        return false;
      }
    }
    
    return true;
  }
  
  // Data processing methods for charts and statistics
  List<Map<String, dynamic>> getTimelineEvents(DataService dataService) {
    List<Map<String, dynamic>> timelineEvents = [];
    
    // Agregar mantenimientos realizados
    for (var mantenimiento in dataService.mantenimientosRealizados) {
      if (isInDateRange(mantenimiento.fechaMantenimiento) &&
          matchesFilters(mantenimiento: mantenimiento, dataService: dataService)) {
        final equipo = dataService.obtenerEquipoPorFicha(mantenimiento.ficha);
        final empleado = dataService.obtenerEmpleadoPorId(mantenimiento.idEmpleado);
        
        timelineEvents.add({
          'fecha': mantenimiento.fechaMantenimiento,
          'tipo': 'Mantenimiento',
          'titulo': 'Mantenimiento de ${equipo?.nombre ?? mantenimiento.ficha}',
          'descripcion': 'Realizado por ${empleado?.nombreCompleto ?? 'Desconocido'} a las ${mantenimiento.horasKmAlMomento.toStringAsFixed(0)} horas/km',
          'icono': Icons.build,
          'color': Colors.amber,
          'data': mantenimiento,
          'ficha': mantenimiento.ficha,
          'empleadoId': mantenimiento.idEmpleado,
          'marca': equipo?.marca,
          'modelo': equipo?.modelo,
        });
      }
    }
    
    // Agregar actualizaciones de horas/km
    for (var actualizacion in dataService.actualizacionesHorasKm) {
      if (isInDateRange(actualizacion.fecha) &&
          (_selectedFicha == null || actualizacion.ficha == _selectedFicha) &&
          (_selectedTipoActividad == null || _selectedTipoActividad == 'Actualización')) {
        final equipo = dataService.obtenerEquipoPorFicha(actualizacion.ficha);
        
        // Verificar filtros de marca y modelo
        if (_selectedMarca != null && (equipo?.marca != _selectedMarca)) {
          continue;
        }
        
        if (_selectedModelo != null && (equipo?.modelo != _selectedModelo)) {
          continue;
        }
        
        timelineEvents.add({
          'fecha': actualizacion.fecha,
          'tipo': 'Actualización',
          'titulo': 'Actualización de ${equipo?.nombre ?? actualizacion.ficha}',
          'descripcion': 'Nuevo valor: ${actualizacion.horasKm.toStringAsFixed(0)} horas/km' +
              (actualizacion.incremento != null ? ', Incremento: ${actualizacion.incremento!.toStringAsFixed(0)}' : ''),
          'icono': Icons.update,
          'color': Colors.green,
          'data': actualizacion,
          'ficha': actualizacion.ficha,
          'marca': equipo?.marca,
          'modelo': equipo?.modelo,
        });
      }
    }
    
    // Agregar movimientos de inventario
    for (var inventario in dataService.inventarios) {
      if (_selectedTipoInventario == null || inventario.tipo == _selectedTipoInventario) {
        // Verificar filtros de marca y modelo para inventario
        if (_selectedMarca != null && !inventario.marcasCompatibles.contains(_selectedMarca) && inventario.marcasCompatibles.isNotEmpty) {
          continue;
        }
        
        if (_selectedModelo != null && !inventario.modelosCompatibles.contains(_selectedModelo) && inventario.modelosCompatibles.isNotEmpty) {
          continue;
        }
        
        for (var movimiento in inventario.movimientos) {
          if (isInDateRange(movimiento.fecha) &&
              (_selectedTipoActividad == null || _selectedTipoActividad == 'Inventario')) {
            timelineEvents.add({
              'fecha': movimiento.fecha,
              'tipo': 'Inventario',
              'titulo': '${movimiento.tipo} de ${inventario.nombre}',
              'descripcion': 'Cantidad: ${movimiento.cantidad}, Responsable: ${movimiento.responsable}, Motivo: ${movimiento.motivo}',
              'icono': movimiento.tipo == 'Ingreso' ? Icons.add_circle : Icons.remove_circle,
              'color': movimiento.tipo == 'Ingreso' ? Colors.green : Colors.red,
              'data': {'inventario': inventario, 'movimiento': movimiento},
              'codigoIdentificacion': inventario.codigoIdentificacion,
              'empresaSuplidora': inventario.empresaSuplidora,
            });
          }
        }
      }
    }
    
    // Ordenar eventos por fecha (más recientes primero)
    timelineEvents.sort((a, b) => b['fecha'].compareTo(a['fecha']));
    
    return timelineEvents;
  }
  
  List<MantenimientoRealizado> getFilteredMantenimientos(DataService dataService) {
    return dataService.mantenimientosRealizados
        .where((m) => isInDateRange(m.fechaMantenimiento) && 
                      matchesFilters(mantenimiento: m, dataService: dataService))
        .toList()
      ..sort((a, b) => b.fechaMantenimiento.compareTo(a.fechaMantenimiento));
  }
  
  List<Map<String, dynamic>> getFilteredInventoryMovements(DataService dataService) {
    List<Map<String, dynamic>> movimientos = [];
    
    for (var inventario in dataService.inventarios) {
      if (_selectedTipoInventario == null || inventario.tipo == _selectedTipoInventario) {
        if (_selectedCategoriaEquipo == null || inventario.categoriaEquipo == _selectedCategoriaEquipo) {
          for (var movimiento in inventario.movimientos) {
            if (isInDateRange(movimiento.fecha)) {
              movimientos.add({
                'inventario': inventario,
                'movimiento': movimiento,
              });
            }
          }
        }
      }
    }
    
    // Ordenar por fecha (más recientes primero)
    movimientos.sort((a, b) => 
        (b['movimiento'] as MovimientoInventario).fecha.compareTo(
            (a['movimiento'] as MovimientoInventario).fecha));
    
    return movimientos;
  }
  
  // Helper methods for date formatting
  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}
