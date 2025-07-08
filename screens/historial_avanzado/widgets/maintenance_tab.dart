import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../services/data_service.dart';
import '../../../models/mantenimiento.dart';
import '../../../utils/app_theme.dart';
import '../historial_avanzado_controller.dart';
import 'dialogs.dart';

class MaintenanceTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<DataService, HistorialAvanzadoController>(
      builder: (context, dataService, controller, _) {
        final mantenimientosFiltrados = controller.getFilteredMantenimientos(dataService);

        if (mantenimientosFiltrados.isEmpty) {
          return const Center(
            child: Text('No hay mantenimientos que coincidan con los filtros seleccionados'),
          );
        }

        if (controller.visualizacionMode == 'Lista') {
          return _buildMaintenanceList(context, mantenimientosFiltrados, dataService);
        } else if (controller.visualizacionMode == 'Calendario') {
          return _buildMaintenanceCalendar(context, mantenimientosFiltrados, dataService);
        } else {
          return _buildMaintenanceChart(context, mantenimientosFiltrados, dataService);
        }
      },
    );
  }

  Widget _buildMaintenanceList(
    BuildContext context, 
    List<MantenimientoRealizado> mantenimientos, 
    DataService dataService
  ) {
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
            title: Text(equipo?.nombre ?? 'Equipo ${mantenimiento.ficha}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fecha: ${DateFormat('dd/MM/yyyy').format(mantenimiento.fechaMantenimiento)}'),
                Text('Realizado por: ${empleado?.nombreCompleto ?? 'No asignado'}'),
                Text('Horas/Km: ${mantenimiento.horasKmAlMomento.toStringAsFixed(0)}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => showMaintenanceDetailsDialog(context, mantenimiento, dataService),
            ),
            isThreeLine: true,
            onTap: () => showMaintenanceDetailsDialog(context, mantenimiento, dataService),
          ),
        );
      },
    );
  }

  Widget _buildMaintenanceCalendar(
    BuildContext context, 
    List<MantenimientoRealizado> mantenimientos, 
    DataService dataService
  ) {
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
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                        color: AppColors.darkGray, // Contraste para modo claro
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
                title: Text(equipo?.nombre ?? 'Equipo ${mantenimiento.ficha}'),
                subtitle: Text(
                  'Realizado por: ${empleado?.nombreCompleto ?? 'No asignado'} - ${mantenimiento.horasKmAlMomento.toStringAsFixed(0)} hr/km',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () => showMaintenanceDetailsDialog(context, mantenimiento, dataService),
              );
            }).toList(),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget _buildMaintenanceChart(
    BuildContext context, 
    List<MantenimientoRealizado> mantenimientos, 
    DataService dataService
  ) {
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
          const Text(
            'Mantenimientos por Equipo',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
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
                            style: const TextStyle(fontSize: 10),
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
                            style: const TextStyle(fontSize: 10),
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
}
