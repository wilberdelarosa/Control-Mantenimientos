import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/mantenimiento.dart';
import '../models/equipo.dart';
import '../models/inventario.dart';
import '../models/empleado.dart';
import '../utils/app_theme.dart';

class HistorialAvanzadoController {
  // Filtros generales
  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 90)),
    end: DateTime.now(),
  );

  String? selectedFicha;
  String? selectedCategoria;
  String? selectedEmpleado;
  String? selectedTipoActividad;

  // Filtros específicos para inventario
  String? selectedTipoInventario;
  String? selectedCategoriaEquipo;

  // Modo de visualización
  String visualizacionMode = 'Lista'; // 'Lista', 'Gráfico', 'Calendario'

  void clearAllFilters() {
    selectedFicha = null;
    selectedCategoria = null;
    selectedEmpleado = null;
    selectedTipoActividad = null;
    selectedTipoInventario = null;
    selectedCategoriaEquipo = null;
  }

  // Métodos para obtener datos filtrados
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
          'color': AppColors.primaryYellow,
          'data': mantenimiento,
          'ficha': mantenimiento.ficha,
          'empleadoId': mantenimiento.idEmpleado,
        });
      }
    }

    // Agregar actualizaciones de horas/km
    for (var actualizacion in dataService.actualizacionesHorasKm) {
      if (isInDateRange(actualizacion.fecha) &&
          (selectedFicha == null || actualizacion.ficha == selectedFicha) &&
          (selectedTipoActividad == null || selectedTipoActividad == 'Actualización')) {
        final equipo = dataService.obtenerEquipoPorFicha(actualizacion.ficha);

        timelineEvents.add({
          'fecha': actualizacion.fecha,
          'tipo': 'Actualización',
          'titulo': 'Actualización de ${equipo?.nombre ?? actualizacion.ficha}',
          'descripcion': 'Nuevo valor: ${actualizacion.horasKm.toStringAsFixed(0)} horas/km' +
              (actualizacion.incremento != null ? ', Incremento: ${actualizacion.incremento!.toStringAsFixed(0)}' : ''),
          'icono': Icons.update,
          'color': AppColors.success,
          'data': actualizacion,
          'ficha': actualizacion.ficha,
        });
      }
    }

    // Agregar movimientos de inventario
    for (var inventario in dataService.inventarios) {
      if (selectedTipoInventario == null || inventario.tipo == selectedTipoInventario) {
        for (var movimiento in inventario.movimientos) {
          if (isInDateRange(movimiento.fecha) &&
              (selectedTipoActividad == null || selectedTipoActividad == 'Inventario')) {
            timelineEvents.add({
              'fecha': movimiento.fecha,
              'tipo': 'Inventario',
              'titulo': '${movimiento.tipo} de ${inventario.nombre}',
              'descripcion': 'Cantidad: ${movimiento.cantidad}, Responsable: ${movimiento.responsable}, Motivo: ${movimiento.motivo}',
              'icono': movimiento.tipo == 'Ingreso' ? Icons.add_circle : Icons.remove_circle,
              'color': movimiento.tipo == 'Ingreso' ? AppColors.success : AppColors.error,
              'data': {'inventario': inventario, 'movimiento': movimiento},
            });
          }
        }
      }
    }

    // Ordenar eventos por fecha (más recientes primero)
    timelineEvents.sort((a, b) => b['fecha'].compareTo(a['fecha']));

    return timelineEvents;
  }

  List<MantenimientoRealizado> getFilteredMaintenances(DataService dataService) {
    // Filtrar mantenimientos
    var mantenimientosFiltrados = dataService.mantenimientosRealizados
        .where((m) => isInDateRange(m.fechaMantenimiento) &&
        matchesFilters(mantenimiento: m, dataService: dataService))
        .toList();

    // Ordenar por fecha (más recientes primero)
    mantenimientosFiltrados.sort((a, b) => b.fechaMantenimiento.compareTo(a.fechaMantenimiento));

    return mantenimientosFiltrados;
  }

  List<Map<String, dynamic>> getInventoryMovements(DataService dataService) {
    // Recopilar todos los movimientos de inventario
    List<Map<String, dynamic>> movimientos = [];

    for (var inventario in dataService.inventarios) {
      if (selectedTipoInventario == null || inventario.tipo == selectedTipoInventario) {
        if (selectedCategoriaEquipo == null || inventario.categoriaEquipo == selectedCategoriaEquipo) {
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
    movimientos.sort((a, b) => b['movimiento'].fecha.compareTo(a['movimiento'].fecha));

    return movimientos;
  }

  // Métodos para construir vistas
  Widget buildTimelineList(BuildContext context, List<Map<String, dynamic>> events) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.darkGray;

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _showEventDetails(context, event),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: event['color'].withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      event['icono'],
                      color: event['color'],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              event['tipo'],
                              style: TextStyle(
                                color: event['color'],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              formatter.format(event['fecha']),
                              style: TextStyle(
                                color: AppColors.mediumGray,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event['titulo'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event['descripcion'],
                          style: TextStyle(
                            color: AppColors.mediumGray,
                          ),
                        ),
                        if (event['ficha'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Ficha: ${event['ficha']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mediumGray,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildTimelineCalendar(BuildContext context, List<Map<String, dynamic>> events) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.darkGray;

    // Agrupar eventos por fecha
    Map<String, List<Map<String, dynamic>>> eventsByDate = {};

    for (var event in events) {
      final date = DateFormat('yyyy-MM-dd').format(event['fecha']);
      if (!eventsByDate.containsKey(date)) {
        eventsByDate[date] = [];
      }
      eventsByDate[date]!.add(event);
    }

    return ListView.builder(
      itemCount: eventsByDate.length,
      itemBuilder: (context, index) {
        final date = eventsByDate.keys.elementAt(index);
        final dateEvents = eventsByDate[date]!;
        final DateTime parsedDate = DateTime.parse(date);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(parsedDate),
                      style: TextStyle(
                        color: AppColors.darkGray,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${dateEvents.length} evento${dateEvents.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
            ...dateEvents.map((event) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: event['color'].withAlpha(30),
                  child: Icon(
                    event['icono'],
                    color: event['color'],
                    size: 20,
                  ),
                ),
                title: Text(
                  event['titulo'],
                  style: TextStyle(color: textColor),
                ),
                subtitle: Text(
                  '${DateFormat('HH:mm').format(event['fecha'])} - ${event['tipo']}',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: Icon(Icons.chevron_right, color: textColor),
                onTap: () => _showEventDetails(context, event),
              );
            }).toList(),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget buildTimelineChart(BuildContext context, List<Map<String, dynamic>> events) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.darkGray;

    // Agrupar eventos por tipo y por mes
    Map<String, Map<String, int>> eventsByTypeAndMonth = {};

    // Inicializar tipos de eventos
    final eventTypes = ['Mantenimiento', 'Actualización', 'Inventario'];
    for (var type in eventTypes) {
      eventsByTypeAndMonth[type] = {};
    }

    // Obtener rango de meses
    final startMonth = DateTime(dateRange.start.year, dateRange.start.month);
    final endMonth = DateTime(dateRange.end.year, dateRange.end.month);

    // Inicializar todos los meses en el rango
    DateTime currentMonth = startMonth;
    while (currentMonth.isBefore(endMonth) || currentMonth.isAtSameMomentAs(endMonth)) {
      final monthKey = DateFormat('yyyy-MM').format(currentMonth);
      for (var type in eventTypes) {
        eventsByTypeAndMonth[type]![monthKey] = 0;
      }
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    }

    // Contar eventos por tipo y mes
    for (var event in events) {
      final monthKey = DateFormat('yyyy-MM').format(event['fecha']);
      final type = event['tipo'];
      if (eventsByTypeAndMonth.containsKey(type) && eventsByTypeAndMonth[type]!.containsKey(monthKey)) {
        eventsByTypeAndMonth[type]![monthKey] = (eventsByTypeAndMonth[type]![monthKey] ?? 0) + 1;
      }
    }

    // Preparar datos para el gráfico
    List<String> months = eventsByTypeAndMonth[eventTypes.first]!.keys.toList()..sort();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Actividades por Mes',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: events.length > 0 ? null : 10,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final type = eventTypes[rodIndex];
                      final month = months[groupIndex];
                      final count = eventsByTypeAndMonth[type]![month];
                      return BarTooltipItem(
                        '$type: $count',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= months.length) {
                          return const SizedBox.shrink();
                        }
                        final month = months[value.toInt()];
                        final date = DateTime.parse('$month-01');
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('MMM yy').format(date),
                            style: TextStyle(fontSize: 10, color: textColor),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: 10, color: textColor),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  months.length,
                      (monthIndex) {
                    return BarChartGroupData(
                      x: monthIndex,
                      barRods: List.generate(
                        eventTypes.length,
                            (typeIndex) {
                          final type = eventTypes[typeIndex];
                          final count = eventsByTypeAndMonth[type]![months[monthIndex]] ?? 0;

                          Color rodColor;
                          switch (type) {
                            case 'Mantenimiento':
                              rodColor = AppColors.primaryYellow;
                              break;
                            case 'Actualización':
                              rodColor = AppColors.success;
                              break;
                            case 'Inventario':
                              rodColor = AppColors.mediumGray;
                              break;
                            default:
                              rodColor = Colors.blue;
                          }

                          return BarChartRodData(
                            toY: count.toDouble(),
                            color: rodColor,
                            width: 15,
                            borderRadius: BorderRadius.circular(4),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: eventTypes.map((type) {
              Color indicatorColor;
              switch (type) {
                case 'Mantenimiento':
                  indicatorColor = AppColors.primaryYellow;
                  break;
                case 'Actualización':
                  indicatorColor = AppColors.success;
                  break;
                case 'Inventario':
                  indicatorColor = AppColors.mediumGray;
                  break;
                default:
                  indicatorColor = Colors.blue;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: indicatorColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(type, style: TextStyle(fontSize: 12, color: textColor)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildMaintenanceList(BuildContext context, List<MantenimientoRealizado> mantenimientos, DataService dataService) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.darkGray;

    return ListView.builder(
      itemCount: mantenimientos.length,
      itemBuilder: (context, index) {
        final mantenimiento = mantenimientos[index];
        final equipo = dataService.obtenerEquipoPorFicha(mantenimiento.ficha);
        final empleado = dataService.obtenerEmpleadoPorId(mantenimiento.idEmpleado);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryYellow,
              child: Text(
                mantenimiento.ficha.substring(mantenimiento.ficha.length - 2),
                style: TextStyle(color: AppColors.darkGray),
              ),
            ),
            title: Text(
              equipo?.nombre ?? 'Equipo ${mantenimiento.ficha}',
              style: TextStyle(color: textColor),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fecha: ${DateFormat('dd/MM/yyyy').format(mantenimiento.fechaMantenimiento)}'),
                Text('Realizado por: ${empleado?.nombreCompleto ?? 'No asignado'}'),
                Text('Horas/Km: ${mantenimiento.horasKmAlMomento.toStringAsFixed(0)}'),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.info_outline, color: textColor),
              onPressed: () => _showMaintenanceDetails(context, mantenimiento, dataService),
            ),
            isThreeLine: true,
            onTap: () => _showMaintenanceDetails(context, mantenimiento, dataService),
          ),
        );
      },
    );
  }

  Widget buildMaintenanceCalendar(BuildContext context, List<MantenimientoRealizado> mantenimientos, DataService dataService) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.darkGray;

    // Agrupar mantenimientos por fecha
    Map<String, List<MantenimientoRealizado>> mantenimientosByDate = {};

    for (var mantenimiento in mantenimientos) {
      final date = DateFormat('yyyy-MM-dd').format(mantenimiento.fechaMantenimiento);
      if (!mantenimientosByDate.containsKey(date)) {
        mantenimientosByDate[date] = [];
      }
      mantenimientosByDate[date]!.add(mantenimiento);
    }

    return ListView.builder(
      itemCount: mantenimientosByDate.length,
      itemBuilder: (context, index) {
        final date = mantenimientosByDate.keys.elementAt(index);
        final dateMantenimientos = mantenimientosByDate[date]!;
        final DateTime parsedDate = DateTime.parse(date);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(parsedDate),
                      style: TextStyle(
                        color: AppColors.darkGray,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${dateMantenimientos.length} mantenimiento${dateMantenimientos.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
            ...dateMantenimientos.map((mantenimiento) {
              final equipo = dataService.obtenerEquipoPorFicha(mantenimiento.ficha);
              final empleado = dataService.obtenerEmpleadoPorId(mantenimiento.idEmpleado);

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryYellow.withAlpha(30),
                  child: Text(
                    mantenimiento.ficha.substring(mantenimiento.ficha.length - 2),
                    style: TextStyle(color: AppColors.primaryYellow),
                  ),
                ),
                title: Text(
                  equipo?.nombre ?? 'Equipo ${mantenimiento.ficha}',
                  style: TextStyle(color: textColor),
                ),
                subtitle: Text(
                  'Realizado por: ${empleado?.nombreCompleto ?? 'No asignado'} - ${mantenimiento.horasKmAlMomento.toStringAsFixed(0)} hr/km',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: Icon(Icons.chevron_right, color: textColor),
                onTap: () => _showMaintenanceDetails(context, mantenimiento, dataService),
              );
            }).toList(),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget buildMaintenanceChart(BuildContext context, List<MantenimientoRealizado> mantenimientos, DataService dataService) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.darkGray;

    // Gráfico de mantenimientos por equipo
    Map<String, int> mantenimientosPorEquipo = {};

    for (var mantenimiento in mantenimientos) {
      final equipo = dataService.obtenerEquipoPorFicha(mantenimiento.ficha);
      final equipoNombre = equipo?.nombre ?? mantenimiento.ficha;

      if (!mantenimientosPorEquipo.containsKey(equipoNombre)) {
        mantenimientosPorEquipo[equipoNombre] = 0;
      }
      mantenimientosPorEquipo[equipoNombre] = (mantenimientosPorEquipo[equipoNombre] ?? 0) + 1;
    }

    // Ordenar por cantidad de mantenimientos (descendente)
    var sortedEntries = mantenimientosPorEquipo.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Tomar los 10 primeros para el gráfico
    var topEquipos = sortedEntries.take(10).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Mantenimientos por Equipo',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: topEquipos.isNotEmpty ? null : 10,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final equipo = topEquipos[groupIndex].key;
                      final count = topEquipos[groupIndex].value;
                      return BarTooltipItem(
                        '$equipo: $count',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= topEquipos.length) {
                          return const SizedBox.shrink();
                        }
                        final equipo = topEquipos[value.toInt()].key;
                        // Abreviar nombre si es muy largo
                        final nombreCorto = equipo.length > 10
                            ? '${equipo.substring(0, 8)}...'
                            : equipo;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            nombreCorto,
                            style: TextStyle(fontSize: 10, color: textColor),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: 10, color: textColor),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  topEquipos.length,
                      (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: topEquipos[index].value.toDouble(),
                          color: AppColors.primaryYellow,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInventoryList(BuildContext context, List<Map<String, dynamic>> movimientos) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.darkGray;

    return ListView.builder(
      itemCount: movimientos.length,
      itemBuilder: (context, index) {
        final inventario = movimientos[index]['inventario'] as Inventario;
        final movimiento = movimientos[index]['movimiento'] as MovimientoInventario;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: movimiento.tipo == 'Ingreso' ? AppColors.success : AppColors.error,
              child: Icon(
                movimiento.tipo == 'Ingreso' ? Icons.add : Icons.remove,
                color: Colors.white,
              ),
            ),
            title: Text(
              inventario.nombre,
              style: TextStyle(color: textColor),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fecha: ${DateFormat('dd/MM/yyyy').format(movimiento.fecha)}'),
                Text('${movimiento.tipo}: ${movimiento.cantidad} unidades'),
                Text('Responsable: ${movimiento.responsable}'),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.info_outline, color: textColor),
              onPressed: () => _showInventoryMovementDetails(context, inventario, movimiento),
            ),
            isThreeLine: true,
            onTap: () => _showInventoryMovementDetails(context, inventario, movimiento),
          ),
        );
      },
    );
  }

  Widget buildInventoryCalendar(BuildContext context, List<Map<String, dynamic>> movimientos) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.darkGray;

    // Agrupar movimientos por fecha
    Map<String, List<Map<String, dynamic>>> movimientosByDate = {};

    for (var movimientoData in movimientos) {
      final movimiento = movimientoData['movimiento'] as MovimientoInventario;
      final date = DateFormat('yyyy-MM-dd').format(movimiento.fecha);
      if (!movimientosByDate.containsKey(date)) {
        movimientosByDate[date] = [];
      }
      movimientosByDate[date]!.add(movimientoData);
    }

    return ListView.builder(
      itemCount: movimientosByDate.length,
      itemBuilder: (context, index) {
        final date = movimientosByDate.keys.elementAt(index);
        final dateMovimientos = movimientosByDate[date]!;
        final DateTime parsedDate = DateTime.parse(date);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(parsedDate),
                      style: TextStyle(
                        color: AppColors.darkGray,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${dateMovimientos.length} movimiento${dateMovimientos.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
            ...dateMovimientos.map((movimientoData) {
              final inventario = movimientoData['inventario'] as Inventario;
              final movimiento = movimientoData['movimiento'] as MovimientoInventario;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: movimiento.tipo == 'Ingreso' ? AppColors.success.withAlpha(30) : AppColors.error.withAlpha(30),
                  child: Icon(
                    movimiento.tipo == 'Ingreso' ? Icons.add : Icons.remove,
                    color: movimiento.tipo == 'Ingreso' ? AppColors.success : AppColors.error,
                  ),
                ),
                title: Text(
                  inventario.nombre,
                  style: TextStyle(color: textColor),
                ),
                subtitle: Text(
                  '${movimiento.tipo}: ${movimiento.cantidad} - ${movimiento.responsable}',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: Icon(Icons.chevron_right, color: textColor),
                onTap: () => _showInventoryMovementDetails(context, inventario, movimiento),
              );
            }).toList(),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget buildInventoryChart(BuildContext context, List<Map<String, dynamic>> movimientos) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.darkGray;

    // Gráfico de movimientos por tipo de inventario
    Map<String, Map<String, int>> movimientosPorTipo = {};

    // Inicializar tipos
    for (var tipo in Inventario.getTipos()) {
      movimientosPorTipo[tipo] = {'Ingreso': 0, 'Egreso': 0};
    }

    // Contar movimientos
    for (var movimientoData in movimientos) {
      final inventario = movimientoData['inventario'] as Inventario;
      final movimiento = movimientoData['movimiento'] as MovimientoInventario;

      movimientosPorTipo[inventario.tipo]![movimiento.tipo] =
          (movimientosPorTipo[inventario.tipo]![movimiento.tipo] ?? 0) + movimiento.cantidad;
    }

    // Filtrar tipos sin movimientos
    movimientosPorTipo.removeWhere((key, value) => value['Ingreso'] == 0 && value['Egreso'] == 0);

    // Ordenar por cantidad total de movimientos
    var sortedEntries = movimientosPorTipo.entries.toList()
      ..sort((a, b) => (b.value['Ingreso']! + b.value['Egreso']!) - (a.value['Ingreso']! + a.value['Egreso']!));

    // Tomar los 8 primeros para el gráfico
    var topTipos = sortedEntries.take(8).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Movimientos por Tipo de Inventario',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: topTipos.isNotEmpty ? null : 10,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final tipo = topTipos[groupIndex].key;
                      final movimientoTipo = rodIndex == 0 ? 'Ingreso' : 'Egreso';
                      final count = topTipos[groupIndex].value[movimientoTipo];
                      return BarTooltipItem(
                        '$tipo - $movimientoTipo: $count',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= topTipos.length) {
                          return const SizedBox.shrink();
                        }
                        final tipo = topTipos[value.toInt()].key;
                        // Abreviar nombre si es muy largo
                        final nombreCorto = tipo.length > 10
                            ? '${tipo.substring(0, 8)}...'
                            : tipo;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            nombreCorto,
                            style: TextStyle(fontSize: 10, color: textColor),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(fontSize: 10, color: textColor),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  topTipos.length,
                      (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: topTipos[index].value['Ingreso']!.toDouble(),
                          color: AppColors.success,
                          width: 12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        BarChartRodData(
                          toY: topTipos[index].value['Egreso']!.toDouble(),
                          color: AppColors.error,
                          width: 12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('Ingresos', style: TextStyle(fontSize: 12, color: textColor)),
                ],
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('Egresos', style: TextStyle(fontSize: 12, color: textColor)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildStatisticsView(BuildContext context, DataService dataService) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.darkGray;

    // Estadísticas generales
    int totalEquipos = dataService.equipos.where((e) => e.activo).length;
    int totalMantenimientos = dataService.mantenimientosRealizados
        .where((m) => isInDateRange(m.fechaMantenimiento))
        .length;
    int totalMovimientosInventario = dataService.inventarios
        .expand((i) => i.movimientos)
        .where((m) => isInDateRange(m.fecha))
        .length;

    // Equipos con más mantenimientos
    Map<String, int> mantenimientosPorEquipo = {};
    for (var mantenimiento in dataService.mantenimientosRealizados.where((m) => isInDateRange(m.fechaMantenimiento))) {
      final equipo = dataService.obtenerEquipoPorFicha(mantenimiento.ficha);
      final nombre = equipo?.nombre ?? mantenimiento.ficha;
      mantenimientosPorEquipo[nombre] = (mantenimientosPorEquipo[nombre] ?? 0) + 1;
    }

    var topEquipos = mantenimientosPorEquipo.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Empleados con más mantenimientos
    Map<String, int> mantenimientosPorEmpleado = {};
    for (var mantenimiento in dataService.mantenimientosRealizados.where((m) => isInDateRange(m.fechaMantenimiento))) {
      final empleado = dataService.obtenerEmpleadoPorId(mantenimiento.idEmpleado);
      final nombre = empleado?.nombreCompleto ?? 'Desconocido';
      mantenimientosPorEmpleado[nombre] = (mantenimientosPorEmpleado[nombre] ?? 0) + 1;
    }

    var topEmpleados = mantenimientosPorEmpleado.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Productos más utilizados
    Map<String, int> productosMasUtilizados = {};
    for (var mantenimiento in dataService.mantenimientosRealizados.where((m) => isInDateRange(m.fechaMantenimiento))) {
      for (var filtro in mantenimiento.filtrosUtilizados) {
        productosMasUtilizados[filtro.nombre] = (productosMasUtilizados[filtro.nombre] ?? 0) + filtro.cantidad;
      }
    }

    var topProductos = productosMasUtilizados.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas Generales',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),

          // Tarjetas de resumen
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Equipos Activos',
                  totalEquipos.toString(),
                  Icons.construction,
                  AppColors.primaryYellow,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Mantenimientos',
                  totalMantenimientos.toString(),
                  Icons.build,
                  AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Mov. Inventario',
                  totalMovimientosInventario.toString(),
                  Icons.inventory,
                  AppColors.mediumGray,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Empleados',
                  dataService.empleados.where((e) => e.activo).length.toString(),
                  Icons.people,
                  AppColors.primaryYellow,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Text(
            'Equipos con Más Mantenimientos',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: math.min(5, topEquipos.length),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryYellow,
                    child: Text('${index + 1}', style: TextStyle(color: AppColors.darkGray)),
                  ),
                  title: Text(topEquipos[index].key, style: TextStyle(color: textColor)),
                  trailing: Text(
                    '${topEquipos[index].value} mantenimientos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryYellow,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'Empleados con Más Mantenimientos',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: math.min(5, topEmpleados.length),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.success,
                    child: Text('${index + 1}', style: TextStyle(color: Colors.white)),
                  ),
                  title: Text(topEmpleados[index].key, style: TextStyle(color: textColor)),
                  trailing: Text(
                    '${topEmpleados[index].value} mantenimientos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'Productos Más Utilizados',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: math.min(5, topProductos.length),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.mediumGray,
                    child: Text('${index + 1}', style: TextStyle(color: Colors.white)),
                  ),
                  title: Text(topProductos[index].key, style: TextStyle(color: textColor)),
                  trailing: Text(
                    '${topProductos[index].value} unidades',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.mediumGray,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'Eficiencia de Mantenimiento',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildEfficiencyIndicator(
                    context,
                    'Mantenimientos a Tiempo',
                    0.75,
                    AppColors.success,
                  ),
                  const SizedBox(height: 16),
                  _buildEfficiencyIndicator(
                    context,
                    'Mantenimientos Retrasados',
                    0.25,
                    AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  _buildEfficiencyIndicator(
                    context,
                    'Uso de Inventario',
                    0.60,
                    AppColors.primaryYellow,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.darkGray;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.mediumGray,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEfficiencyIndicator(BuildContext context, String label, double value, Color color) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.darkGray;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: textColor)),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          backgroundColor: color.withAlpha(30),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  // Métodos auxiliares
  bool isInDateRange(DateTime date) {
    return (date.isAfter(dateRange.start) || date.isAtSameMomentAs(dateRange.start)) &&
        (date.isBefore(dateRange.end) || date.isAtSameMomentAs(dateRange.end));
  }

  bool matchesFilters({
    MantenimientoRealizado? mantenimiento,
    DataService? dataService,
  }) {
    if (mantenimiento == null || dataService == null) {
      return true;
    }

    // Filtro por ficha
    if (selectedFicha != null && mantenimiento.ficha != selectedFicha) {
      return false;
    }

    // Filtro por categoría
    if (selectedCategoria != null) {
      final equipo = dataService.obtenerEquipoPorFicha(mantenimiento.ficha);
      if (equipo == null || equipo.categoria != selectedCategoria) {
        return false;
      }
    }

    // Filtro por empleado
    if (selectedEmpleado != null) {
      final empleado = dataService.obtenerEmpleadoPorId(mantenimiento.idEmpleado);
      if (empleado == null || empleado.nombreCompleto != selectedEmpleado) {
        return false;
      }
    }

    // Filtro por tipo de actividad
    if (selectedTipoActividad != null && selectedTipoActividad != 'Mantenimiento') {
      return false;
    }

    return true;
  }

  // Métodos para mostrar detalles
  void _showEventDetails(BuildContext context, Map<String, dynamic> event) {
    final tipo = event['tipo'];

    if (tipo == 'Mantenimiento') {
      final dataService = Provider.of<DataService>(context, listen: false);
      _showMaintenanceDetails(context, event['data'], dataService);
    } else if (tipo == 'Actualización') {
      _showUpdateDetails(context, event);
    } else if (tipo == 'Inventario') {
      final inventario = event['data']['inventario'] as Inventario;
      final movimiento = event['data']['movimiento'] as MovimientoInventario;
      _showInventoryMovementDetails(context, inventario, movimiento);
    }
  }

  void _showMaintenanceDetails(BuildContext context, MantenimientoRealizado mantenimiento, DataService dataService) {
    final equipo = dataService.obtenerEquipoPorFicha(mantenimiento.ficha);
    final empleado = dataService.obtenerEmpleadoPorId(mantenimiento.idEmpleado);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.darkGray;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de Mantenimiento', style: TextStyle(color: textColor)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                equipo?.nombre ?? 'Equipo ${mantenimiento.ficha}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text('Ficha: ${mantenimiento.ficha}'),
              Text('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(mantenimiento.fechaMantenimiento)}'),
              Text('Horas/Km: ${mantenimiento.horasKmAlMomento.toStringAsFixed(0)}'),
              Text('Realizado por: ${empleado?.nombreCompleto ?? 'No asignado'}'),
              if (mantenimiento.incrementoDesdeUltimo != null)
                Text('Incremento desde último: ${mantenimiento.incrementoDesdeUltimo!.toStringAsFixed(0)}'),
              const SizedBox(height: 16),
              Text(
                'Filtros Utilizados:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              mantenimiento.filtrosUtilizados.isEmpty
                  ? const Text('Ninguno')
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: mantenimiento.filtrosUtilizados.map((filtro) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text('• ${filtro.nombre} (${filtro.cantidad})'),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Observaciones:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(mantenimiento.observaciones.isEmpty ? 'Sin observaciones' : mantenimiento.observaciones),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showUpdateDetails(BuildContext context, Map<String, dynamic> event) {
    final actualizacion = event['data'] as ActualizacionHorasKm;
    final dataService = Provider.of<DataService>(context, listen: false);
    final equipo = dataService.obtenerEquipoPorFicha(actualizacion.ficha);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.darkGray;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de Actualización', style: TextStyle(color: textColor)),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              equipo?.nombre ?? 'Equipo ${actualizacion.ficha}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text('Ficha: ${actualizacion.ficha}'),
            Text('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(actualizacion.fecha)}'),
            Text('Valor: ${actualizacion.horasKm.toStringAsFixed(0)}'),
            if (actualizacion.incremento != null)
              Text('Incremento: ${actualizacion.incremento!.toStringAsFixed(0)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showInventoryMovementDetails(BuildContext context, Inventario inventario, MovimientoInventario movimiento) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.darkGray;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de Movimiento de Inventario', style: TextStyle(color: textColor)),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              inventario.nombre,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text('Tipo: ${inventario.tipo}'),
            Text('Categoría de Equipo: ${inventario.categoriaEquipo}'),
            Text('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(movimiento.fecha)}'),
            Text('Tipo de Movimiento: ${movimiento.tipo}'),
            Text('Cantidad: ${movimiento.cantidad}'),
            Text('Responsable: ${movimiento.responsable}'),
            Text('Motivo: ${movimiento.motivo}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // Métodos para exportar y reportes
  void exportData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportando datos... Esta función estará disponible próximamente.'),
        backgroundColor: AppColors.primaryYellow,
      ),
    );
  }

  void printReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preparando reporte para imprimir... Esta función estará disponible próximamente.'),
        backgroundColor: AppColors.primaryYellow,
      ),
    );
  }
}
