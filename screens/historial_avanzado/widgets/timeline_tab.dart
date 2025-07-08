import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../services/data_service.dart';
import '../../../utils/app_theme.dart';
import '../historial_avanzado_controller.dart';
import 'dialogs.dart';

class TimelineTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<DataService, HistorialAvanzadoController>(
      builder: (context, dataService, controller, _) {
        final timelineEvents = controller.getTimelineEvents(dataService);

        if (timelineEvents.isEmpty) {
          return const Center(
            child: Text('No hay eventos que coincidan con los filtros seleccionados'),
          );
        }

        if (controller.visualizacionMode == 'Lista') {
          return _buildTimelineList(context, timelineEvents);
        } else if (controller.visualizacionMode == 'Calendario') {
          return _buildTimelineCalendar(context, timelineEvents);
        } else {
          return _buildTimelineChart(context, timelineEvents);
        }
      },
    );
  }

  Widget _buildTimelineList(BuildContext context, List<Map<String, dynamic>> events) {
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
            onTap: () => showEventDetailsDialog(context, event),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
                        if (event['codigoIdentificacion'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Código: ${event['codigoIdentificacion']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mediumGray,
                            ),
                          ),
                        ],
                        if (event['marca'] != null && event['modelo'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Equipo: ${event['marca']} ${event['modelo']}',
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

  Widget _buildTimelineCalendar(BuildContext context, List<Map<String, dynamic>> events) {
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
                title: Text(event['titulo']),
                subtitle: Text(
                  '${DateFormat('HH:mm').format(event['fecha'])} - ${event['tipo']}',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () => showEventDetailsDialog(context, event),
              );
            }).toList(),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget _buildTimelineChart(BuildContext context, List<Map<String, dynamic>> events) {
    // Agrupar eventos por tipo y por mes
    Map<String, Map<String, int>> eventsByTypeAndMonth = {};

    // Inicializar tipos de eventos
    final eventTypes = ['Mantenimiento', 'Actualización', 'Inventario'];
    for (var type in eventTypes) {
      eventsByTypeAndMonth[type] = {};
    }

    // Obtener rango de meses desde el controlador
    final controller = Provider.of<HistorialAvanzadoController>(context, listen: false);
    final startMonth = DateTime(controller.dateRange.start.year, controller.dateRange.start.month);
    final endMonth = DateTime(controller.dateRange.end.year, controller.dateRange.end.month);

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
          const Text(
            'Actividades por Mes',
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
                            style: const TextStyle(fontSize: 10),
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
                    Text(type, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
