import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../services/data_service.dart';
import '../../../models/mantenimiento.dart';
import '../../../models/inventario.dart';
import '../../../utils/app_theme.dart';

void showEventDetailsDialog(BuildContext context, Map<String, dynamic> event) {
  final tipo = event['tipo'];

  if (tipo == 'Mantenimiento') {
    final dataService = Provider.of<DataService>(context, listen: false);
    showMaintenanceDetailsDialog(context, event['data'], dataService);
  } else if (tipo == 'Actualización') {
    showUpdateDetailsDialog(context, event);
  } else if (tipo == 'Inventario') {
    final inventario = event['data']['inventario'] as Inventario;
    final movimiento = event['data']['movimiento'] as MovimientoInventario;
    showInventoryMovementDetailsDialog(context, inventario, movimiento);
  }
}

void showMaintenanceDetailsDialog(BuildContext context, MantenimientoRealizado mantenimiento, DataService dataService) {
  final equipo = dataService.obtenerEquipoPorFicha(mantenimiento.ficha);
  final empleado = dataService.obtenerEmpleadoPorId(mantenimiento.idEmpleado);
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Detalles de Mantenimiento'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              equipo?.nombre ?? 'Equipo ${mantenimiento.ficha}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
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
            const Text(
              'Filtros Utilizados:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
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
            const Text(
              'Observaciones:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
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

void showUpdateDetailsDialog(BuildContext context, Map<String, dynamic> event) {
  final actualizacion = event['data'] as ActualizacionHorasKm;
  final dataService = Provider.of<DataService>(context, listen: false);
  final equipo = dataService.obtenerEquipoPorFicha(actualizacion.ficha);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Detalles de Actualización'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            equipo?.nombre ?? 'Equipo ${actualizacion.ficha}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
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

void showInventoryMovementDetailsDialog(BuildContext context, Inventario inventario, MovimientoInventario movimiento) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Detalles de Movimiento de Inventario'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            inventario.nombre,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
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
