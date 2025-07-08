import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';
import '../models/mantenimiento.dart';

class RecentMaintenanceCard extends StatelessWidget {
  final MantenimientoRealizado maintenance;
  final String equipmentName;
  final String? employeeName;
  final VoidCallback? onTap;

  const RecentMaintenanceCard({
    Key? key,
    required this.maintenance,
    required this.equipmentName,
    this.employeeName,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    equipmentName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatDateTime(maintenance.fechaMantenimiento),
                      style: TextStyle(
                        color: AppColors.primaryYellow,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.engineering_outlined,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    employeeName ?? 'No asignado',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Spacer(),
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
                      '${maintenance.horasKmAlMomento.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryYellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (maintenance.observaciones.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    maintenance.observaciones,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mediumGray,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return dateFormat.format(date);
  }
}
