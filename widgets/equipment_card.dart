import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../models/equipo.dart';

class EquipmentCard extends StatelessWidget {
  final Equipo equipment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  
  const EquipmentCard({
    Key? key,
    required this.equipment,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                    equipment.ficha,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryYellow,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onEdit,
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  tooltip: 'Eliminar',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              equipment.nombre,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              'Categoría',
              equipment.categoria,
              Icons.category_outlined,
            ),
            _buildInfoRow(
              context,
              'Marca',
              equipment.marca,
              Icons.business_outlined,
            ),
            _buildInfoRow(
              context,
              'Modelo',
              equipment.modelo,
              Icons.model_training,
            ),
            _buildInfoRow(
              context,
              'Número de Serie',
              equipment.numeroSerie,
              Icons.numbers_outlined,
            ),
            if (equipment.placa.isNotEmpty)
              _buildInfoRow(
                context,
                'Placa',
                equipment.placa,
                Icons.directions_car_outlined,
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
    IconData icon,
  ) {
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
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
