import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/data_service.dart';
import '../models/equipo.dart';
import '../models/mantenimiento.dart'; // Añadir esta importación
import '../utils/app_theme.dart';
import '../widgets/equipment_card.dart';

class DesktopEquiposScreen extends StatefulWidget {
  const DesktopEquiposScreen({Key? key}) : super(key: key);

  @override
  _DesktopEquiposScreenState createState() => _DesktopEquiposScreenState();
}

class _DesktopEquiposScreenState extends State<DesktopEquiposScreen> {
  String _searchQuery = '';
  String _selectedCategoria = 'Todos';
  Equipo? _selectedEquipo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Panel izquierdo: Lista de equipos
        Expanded(
          flex: 2,
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSearchAndFilter(),
                Expanded(
                  child: _buildEquiposList(),
                ),
              ],
            ),
          ),
        ),

        // Panel derecho: Detalles del equipo seleccionado
        Expanded(
          flex: 3,
          child: Card(
            margin: const EdgeInsets.all(16),
            child: _selectedEquipo != null
                ? _buildEquipoDetails()
                : const Center(
              child: Text('Seleccione un equipo para ver sus detalles'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por ficha o nombre...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('Filtrar por: '),
                const SizedBox(width: 8),
                _buildFilterChip('Todos'),
                ...Equipo.getCategorias().map((categoria) => _buildFilterChip(categoria)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String categoria) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(categoria),
        selected: _selectedCategoria == categoria,
        onSelected: (selected) {
          setState(() {
            _selectedCategoria = selected ? categoria : 'Todos';
            // Resetear equipo seleccionado al cambiar filtro
            _selectedEquipo = null;
          });
        },
        backgroundColor: AppColors.lightGray.withAlpha(51),
        selectedColor: AppColors.primaryYellow,
      ),
    );
  }

  Widget _buildEquiposList() {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        // Filtrar equipos
        var equiposFiltrados = dataService.equipos.where((equipo) => equipo.activo).toList();

        // Aplicar filtro de categoría
        if (_selectedCategoria != 'Todos') {
          equiposFiltrados = equiposFiltrados.where((equipo) => equipo.categoria == _selectedCategoria).toList();
        }

        // Aplicar búsqueda
        if (_searchQuery.isNotEmpty) {
          equiposFiltrados = equiposFiltrados.where((equipo) =>
          equipo.ficha.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              equipo.nombre.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
        }

        if (equiposFiltrados.isEmpty) {
          return const Center(
            child: Text('No se encontraron equipos'),
          );
        }

        return ListView.builder(
          itemCount: equiposFiltrados.length,
          itemBuilder: (context, index) {
            final equipo = equiposFiltrados[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryYellow,
                  child: Text(
                    equipo.ficha.substring(equipo.ficha.length - 2),
                    style: TextStyle(color: AppColors.darkGray),
                  ),
                ),
                title: Text(equipo.nombre),
                subtitle: Text('Ficha: ${equipo.ficha} | Categoría: ${equipo.categoria}'),
                selected: _selectedEquipo?.id == equipo.id,
                selectedTileColor: AppColors.primaryYellow.withOpacity(0.1),
                onTap: () {
                  setState(() {
                    _selectedEquipo = equipo;
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEquipoDetails() {
    if (_selectedEquipo == null) return const SizedBox.shrink();

    return Consumer<DataService>(
      builder: (context, dataService, child) {
        // Obtener mantenimientos del equipo
        final mantenimientosProgramados = dataService.mantenimientosProgramados
            .where((m) => m.ficha == _selectedEquipo!.ficha && m.activo)
            .toList();

        final mantenimientosRealizados = dataService.mantenimientosRealizados
            .where((m) => m.ficha == _selectedEquipo!.ficha)
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado con acciones
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedEquipo!.nombre,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Ficha: ${_selectedEquipo!.ficha}',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    onPressed: () => _showEquipoForm(context, _selectedEquipo),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('Eliminar'),
                    onPressed: () => _showDeleteConfirmation(context, _selectedEquipo!),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Detalles del equipo
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información General',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('Marca', _selectedEquipo!.marca),
                      _buildDetailRow('Modelo', _selectedEquipo!.modelo),
                      _buildDetailRow('Número de Serie', _selectedEquipo!.numeroSerie),
                      _buildDetailRow('Placa', _selectedEquipo!.placa),
                      _buildDetailRow('Categoría', _selectedEquipo!.categoria),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Mantenimiento programado
              if (mantenimientosProgramados.isNotEmpty) ...[
                const Text(
                  'Mantenimiento Programado',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: mantenimientosProgramados.map((mantenimiento) {
                        final isHourMaintenance = mantenimiento.tipoMantenimiento == 'Horas';
                        final isOverdue = mantenimiento.horasKmRestante != null && mantenimiento.horasKmRestante! <= 0;
                        final isNearDue = !isOverdue && mantenimiento.horasKmRestante != null &&
                            (isHourMaintenance ? mantenimiento.horasKmRestante! <= 50 : mantenimiento.horasKmRestante! <= 500);

                        // Determine status color
                        Color statusColor = AppColors.success;
                        if (isOverdue) {
                          statusColor = AppColors.error;
                        } else if (isNearDue) {
                          statusColor = AppColors.warning;
                        }

                        return Column(
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
                                Text(
                                  'Tipo: ${mantenimiento.tipoMantenimiento}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow('Valor Actual', '${mantenimiento.horasKmActuales.toStringAsFixed(0)} ${mantenimiento.tipoMantenimiento}'),
                            _buildDetailRow('Frecuencia', '${mantenimiento.frecuencia.toStringAsFixed(0)} ${mantenimiento.tipoMantenimiento}'),
                            _buildDetailRow('Próximo Mantenimiento', mantenimiento.proximoMantenimiento != null
                                ? '${mantenimiento.proximoMantenimiento!.toStringAsFixed(0)} ${mantenimiento.tipoMantenimiento}'
                                : 'No calculado'),
                            _buildDetailRow('Restante', mantenimiento.horasKmRestante != null
                                ? '${mantenimiento.horasKmRestante!.toStringAsFixed(0)} ${mantenimiento.tipoMantenimiento}'
                                : 'No calculado',
                                textColor: statusColor),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.update),
                                  label: const Text('Actualizar'),
                                  onPressed: () => _showActualizacionForm(context, mantenimiento),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.build),
                                  label: const Text('Realizar Mantenimiento'),
                                  onPressed: () => _showMantenimientoForm(context, mantenimiento),
                                ),
                              ],
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ] else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Este equipo no tiene mantenimiento programado',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Programar Mantenimiento'),
                          onPressed: () => _showProgramarMantenimientoForm(context, _selectedEquipo!),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Historial de mantenimientos
              const Text(
                'Historial de Mantenimientos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              if (mantenimientosRealizados.isEmpty) ...[
                Card(
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text('No hay mantenimientos registrados para este equipo'),
                    ),
                  ),
                ),
              ] else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: mantenimientosRealizados.map((mantenimiento) {
                        final empleado = dataService.obtenerEmpleadoPorId(mantenimiento.idEmpleado);

                        return ListTile(
                          title: Text('Fecha: ${_formatDate(mantenimiento.fechaMantenimiento)}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Horas/Km: ${mantenimiento.horasKmAlMomento.toStringAsFixed(0)}'),
                              Text('Realizado por: ${empleado?.nombreCompleto ?? 'No asignado'}'),
                              if (mantenimiento.observaciones.isNotEmpty)
                                Text('Observaciones: ${mantenimiento.observaciones}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed: () => _showMantenimientoDetails(context, mantenimiento, dataService),
                          ),
                          isThreeLine: true,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: textColor != null ? TextStyle(color: textColor) : null,
            ),
          ),
        ],
      ),
    );
  }

  // Métodos para mostrar formularios
  void _showEquipoForm(BuildContext context, [Equipo? equipo]) {
    // Implementar formulario de edición de equipo
    // Puedes reutilizar el código de equipos_screen.dart
  }

  void _showDeleteConfirmation(BuildContext context, Equipo equipo) {
    // Implementar confirmación de eliminación
    // Puedes reutilizar el código de equipos_screen.dart
  }

  void _showActualizacionForm(BuildContext context, MantenimientoProgramado mantenimiento) {
    // Implementar formulario de actualización
    // Puedes reutilizar el código de control_mantenimiento_screen.dart
  }

  void _showMantenimientoForm(BuildContext context, MantenimientoProgramado mantenimiento) {
    // Implementar formulario de mantenimiento
    // Puedes reutilizar el código de control_mantenimiento_screen.dart
  }

  void _showProgramarMantenimientoForm(BuildContext context, Equipo equipo) {
    // Implementar formulario para programar mantenimiento
    // Puedes reutilizar el código de mantenimiento_programado_screen.dart
  }

  void _showMantenimientoDetails(BuildContext context, MantenimientoRealizado mantenimiento, DataService dataService) {
    // Implementar detalles de mantenimiento
    // Puedes reutilizar el código de control_mantenimiento_screen.dart
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
