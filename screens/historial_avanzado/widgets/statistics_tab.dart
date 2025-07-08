import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../../services/data_service.dart';
import '../../../utils/app_theme.dart';
import '../historial_avanzado_controller.dart';

class StatisticsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<DataService, HistorialAvanzadoController>(
      builder: (context, dataService, controller, _) {
        // Estadísticas generales
        int totalEquipos = dataService.equipos.where((e) => e.activo).length;
        int totalMantenimientos = dataService.mantenimientosRealizados
            .where((m) => controller.isInDateRange(m.fechaMantenimiento))
            .length;
        int totalMovimientosInventario = dataService.inventarios
            .expand((i) => i.movimientos)
            .where((m) => controller.isInDateRange(m.fecha))
            .length;

        // Equipos con más mantenimientos
        Map<String, int> mantenimientosPorEquipo = {};
        for (var mantenimiento in dataService.mantenimientosRealizados
            .where((m) => controller.isInDateRange(m.fechaMantenimiento))) {
          final equipo = dataService.obtenerEquipoPorFicha(mantenimiento.ficha);
          final nombre = equipo?.nombre ?? mantenimiento.ficha;
          mantenimientosPorEquipo[nombre] = (mantenimientosPorEquipo[nombre] ?? 0) + 1;
        }

        var topEquipos = mantenimientosPorEquipo.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        // Empleados con más mantenimientos
        Map<String, int> mantenimientosPorEmpleado = {};
        for (var mantenimiento in dataService.mantenimientosRealizados
            .where((m) => controller.isInDateRange(m.fechaMantenimiento))) {
          final empleado = dataService.obtenerEmpleadoPorId(mantenimiento.idEmpleado);
          final nombre = empleado?.nombreCompleto ?? 'Desconocido';
          mantenimientosPorEmpleado[nombre] = (mantenimientosPorEmpleado[nombre] ?? 0) + 1;
        }

        var topEmpleados = mantenimientosPorEmpleado.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        // Productos más utilizados
        Map<String, int> productosMasUtilizados = {};
        for (var mantenimiento in dataService.mantenimientosRealizados
            .where((m) => controller.isInDateRange(m.fechaMantenimiento))) {
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
              const Text(
                'Estadísticas Generales',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 16),

              // Tarjetas de resumen
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Equipos Activos',
                      totalEquipos.toString(),
                      Icons.construction,
                      AppColors.primaryYellow,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
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
                      'Mov. Inventario',
                      totalMovimientosInventario.toString(),
                      Icons.inventory,
                      AppColors.mediumGray,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Empleados',
                      dataService.empleados.where((e) => e.activo).length.toString(),
                      Icons.people,
                      AppColors.primaryYellow,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text(
                'Equipos con Más Mantenimientos',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
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
                      title: Text(topEquipos[index].key),
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
              const Text(
                'Empleados con Más Mantenimientos',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
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
                      title: Text(topEmpleados[index].key),
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
              const Text(
                'Productos Más Utilizados',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
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
                      title: Text(topProductos[index].key),
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
              const Text(
                'Eficiencia de Mantenimiento',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildEfficiencyIndicator(
                        'Mantenimientos a Tiempo',
                        0.75,
                        AppColors.success,
                      ),
                      const SizedBox(height: 16),
                      _buildEfficiencyIndicator(
                        'Mantenimientos Retrasados',
                        0.25,
                        AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      _buildEfficiencyIndicator(
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
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEfficiencyIndicator(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
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
}
