import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';
import '../models/mantenimiento.dart';

class MaintenanceCard extends StatelessWidget {
  final MantenimientoProgramado maintenance;
  final VoidCallback? onPerformMaintenance;
  final VoidCallback? onViewHistory;
  
  const MaintenanceCard({
    Key? key,
    required this.maintenance,
    this.onPerformMaintenance,
    this.onViewHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isHourMaintenance = maintenance.tipoMantenimiento == 'Horas';
    final isOverdue = maintenance.horasKmRestante != null && maintenance.horasKmRestante! <= 0;
    final isNearDue = !isOverdue && maintenance.horasKmRestante != null && 
      (isHourMaintenance ? maintenance.horasKmRestante! <= 50 : maintenance.horasKmRestante! <= 500);
    
    // Determine status color
    Color statusColor = AppColors.success;
    if (isOverdue) {
      statusColor = AppColors.error;
    } else if (isNearDue) {
      statusColor = AppColors.warning;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withAlpha(100), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryYellow.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    maintenance.ficha,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryYellow,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isOverdue 
                      ? 'Vencido' 
                      : isNearDue 
                        ? 'Próximo' 
                        : 'Al día',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.history_outlined),
                  onPressed: onViewHistory,
                  tooltip: 'Ver historial',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              maintenance.nombreEquipo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Maintenance Details
            _buildInfoRow(
              context,
              'Tipo',
              isHourMaintenance ? 'Horas (HR)' : 'Kilómetros (KM)',
              Icons.category_outlined,
            ),
            _buildInfoRow(
              context,
              'Valor Actual',
              '${maintenance.horasKmActuales.toStringAsFixed(0)} ${maintenance.tipoMantenimiento}',
              Icons.speed_outlined,
            ),
            _buildInfoRow(
              context,
              'Último Mantenimiento',
              maintenance.horasKmUltimoMantenimiento != null 
                ? '${maintenance.horasKmUltimoMantenimiento!.toStringAsFixed(0)} ${maintenance.tipoMantenimiento}'
                : 'N/A',
              Icons.history_outlined,
            ),
            _buildInfoRow(
              context,
              'Fecha Último Mantenimiento',
              maintenance.fechaUltimoMantenimiento != null
                ? DateFormat('dd/MM/yyyy').format(maintenance.fechaUltimoMantenimiento!)
                : 'No registrado',
              Icons.calendar_today_outlined,
            ),
            _buildInfoRow(
              context,
              'Frecuencia',
              '${maintenance.frecuencia.toStringAsFixed(0)} ${maintenance.tipoMantenimiento}',
              Icons.repeat_outlined,
            ),
            _buildInfoRow(
              context,
              'Próximo Mantenimiento',
              maintenance.proximoMantenimiento != null
                ? '${maintenance.proximoMantenimiento!.toStringAsFixed(0)} ${maintenance.tipoMantenimiento}'
                : 'No calculado',
              Icons.update_outlined,
            ),
            _buildInfoRow(
              context,
              'Restante',
              maintenance.horasKmRestante != null
                ? '${maintenance.horasKmRestante!.toStringAsFixed(0)} ${maintenance.tipoMantenimiento}'
                : 'No calculado',
              Icons.trending_down_outlined,
              textColor: statusColor,
            ),
            const SizedBox(height: 16),
            
            // Perform Maintenance Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPerformMaintenance,
                icon: const Icon(Icons.build_outlined),
                label: const Text('Realizar Mantenimiento'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: AppColors.darkGray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.mediumGray,
          ),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: TextStyle(
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
