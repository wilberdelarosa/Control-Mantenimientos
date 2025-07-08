import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../services/data_service.dart';
import '../../../models/inventario.dart';
import '../../../utils/app_theme.dart';
import '../historial_avanzado_controller.dart';
import 'dialogs.dart';

class InventoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<DataService, HistorialAvanzadoController>(
      builder: (context, dataService, controller, _) {
        final movimientos = controller.getFilteredInventoryMovements(dataService);

        if (movimientos.isEmpty) {
          return const Center(
            child: Text('No hay movimientos de inventario que coincidan con los filtros seleccionados'),
          );
        }

        if (controller.visualizacionMode == 'Lista') {
          return _buildInventoryList(context, movimientos);
        } else if (controller.visualizacionMode == 'Calendario') {
          return _buildInventoryCalendar(context, movimientos);
        } else {
          return _buildInventoryChart(context, movimientos);
        }
      },
    );
  }

  Widget _buildInventoryList(BuildContext context, List<Map<String, dynamic>> movimientos) {
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
            title: Text(inventario.nombre),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fecha: ${DateFormat('dd/MM/yyyy').format(movimiento.fecha)}'),
                Text('${movimiento.tipo}: ${movimiento.cantidad} unidades'),
                Text('Responsable: ${movimiento.responsable}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => showInventoryMovementDetailsDialog(context, inventario, movimiento),
            ),
            isThreeLine: true,
            onTap: () => showInventoryMovementDetailsDialog(context, inventario, movimiento),
          ),
        );
      },
    );
  }

  Widget _buildInventoryCalendar(BuildContext context, List<Map<String, dynamic>> movimientos) {
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
                title: Text(inventario.nombre),
                subtitle: Text(
                  '${movimiento.tipo}: ${movimiento.cantidad} - ${movimiento.responsable}',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () => showInventoryMovementDetailsDialog(context, inventario, movimiento),
              );
            }).toList(),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget _buildInventoryChart(BuildContext context, List<Map<String, dynamic>> movimientos) {
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
          const Text(
            'Movimientos por Tipo de Inventario',
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
                  const Text('Ingresos', style: TextStyle(fontSize: 12)),
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
                  const Text('Egresos', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
