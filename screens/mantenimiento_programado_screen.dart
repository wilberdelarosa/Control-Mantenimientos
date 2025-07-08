import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/mantenimiento.dart';
import '../models/equipo.dart';
import '../utils/app_theme.dart';
import '../widgets/maintenance_card.dart';
import '../widgets/alert_card.dart';

class MantenimientoProgramadoScreen extends StatefulWidget {
  const MantenimientoProgramadoScreen({Key? key}) : super(key: key);

  @override
  _MantenimientoProgramadoScreenState createState() => _MantenimientoProgramadoScreenState();
}

class _MantenimientoProgramadoScreenState extends State<MantenimientoProgramadoScreen> {
  String _searchQuery = '';
  String _selectedCategoria = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrador de Mantenimiento'),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildExplanationCard(),
                  _buildMantenimientosList(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMantenimientoForm(context),
        child: const Icon(Icons.add),
        backgroundColor: AppColors.primaryYellow,
        foregroundColor: AppColors.darkGray,
      ),
    );
  }

  Widget _buildExplanationCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.primaryYellow.withAlpha(100), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primaryYellow,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Suscripción a Mantenimiento',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Aquí puede suscribir equipos a un programa de mantenimiento y establecer la frecuencia con la que se deben realizar los mantenimientos.',
                style: TextStyle(
                  color: AppColors.mediumGray,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _showMantenimientoForm(context),
                icon: Icon(Icons.add_circle_outline),
                label: Text('Suscribir Equipo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: AppColors.darkGray,
                ),
              ),
            ],
          ),
        ),
      ),
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
              prefixIcon: const Icon(Icons.search_outlined),
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
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.3),
        child: FilterChip(
          label: Text(
            categoria,
            overflow: TextOverflow.ellipsis,
          ),
          selected: _selectedCategoria == categoria,
          onSelected: (selected) {
            setState(() {
              _selectedCategoria = selected ? categoria : 'Todos';
            });
          },
          backgroundColor: AppColors.lightGray.withAlpha(51),
          selectedColor: AppColors.primaryYellow,
        ),
      ),
    );
  }

  Widget _buildMantenimientosList() {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        // Filtrar mantenimientos programados
        var mantenimientosFiltrados = dataService.mantenimientosProgramados
            .where((mantenimiento) => mantenimiento.activo)
            .toList();

        // Aplicar filtro de categoría
        if (_selectedCategoria != 'Todos') {
          // Obtener fichas de equipos de la categoría seleccionada
          final fichasCategoria = dataService.equipos
              .where((equipo) => equipo.categoria == _selectedCategoria && equipo.activo)
              .map((equipo) => equipo.ficha)
              .toList();

          mantenimientosFiltrados = mantenimientosFiltrados
              .where((mantenimiento) => fichasCategoria.contains(mantenimiento.ficha))
              .toList();
        }

        // Aplicar búsqueda
        if (_searchQuery.isNotEmpty) {
          mantenimientosFiltrados = mantenimientosFiltrados.where((mantenimiento) =>
          mantenimiento.ficha.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              mantenimiento.nombreEquipo.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
        }

        if (mantenimientosFiltrados.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text('No se encontraron mantenimientos programados'),
            ),
          );
        }

        return Column(
          children: mantenimientosFiltrados.map((mantenimiento) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: _getStatusColor(mantenimiento).withAlpha(100), width: 1),
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
                              mantenimiento.ficha,
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
                              color: _getStatusColor(mantenimiento).withAlpha(30),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              mantenimiento.horasKmRestante != null && mantenimiento.horasKmRestante! <= 0
                                  ? 'Vencido'
                                  : mantenimiento.horasKmRestante != null &&
                                  ((mantenimiento.tipoMantenimiento == 'Horas' && mantenimiento.horasKmRestante! <= 50) ||
                                      (mantenimiento.tipoMantenimiento == 'Kilómetros' && mantenimiento.horasKmRestante! <= 500))
                                  ? 'Próximo'
                                  : 'Al día',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(mantenimiento),
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _showMantenimientoForm(context, mantenimiento),
                            tooltip: 'Editar',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outlined),
                            onPressed: () => _showDeleteConfirmation(context, mantenimiento),
                            tooltip: 'Eliminar',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mantenimiento.nombreEquipo,
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
                        mantenimiento.tipoMantenimiento == 'Horas' ? 'Horas (HR)' : 'Kilómetros (KM)',
                        Icons.category_outlined,
                      ),
                      _buildInfoRow(
                        context,
                        'Valor Actual',
                        '${mantenimiento.horasKmActuales.toStringAsFixed(0)} ${mantenimiento.tipoMantenimiento}',
                        Icons.speed_outlined,
                      ),
                      _buildInfoRow(
                        context,
                        'Último Mantenimiento',
                        mantenimiento.horasKmUltimoMantenimiento != null
                            ? '${mantenimiento.horasKmUltimoMantenimiento!.toStringAsFixed(0)} ${mantenimiento.tipoMantenimiento}'
                            : 'N/A',
                        Icons.history_outlined,
                      ),
                      _buildInfoRow(
                        context,
                        'Fecha Último Mantenimiento',
                        mantenimiento.fechaUltimoMantenimiento != null
                            ? _formatDate(mantenimiento.fechaUltimoMantenimiento!)
                            : 'No registrado',
                        Icons.calendar_today_outlined,
                      ),
                      _buildInfoRow(
                        context,
                        'Frecuencia',
                        '${mantenimiento.frecuencia.toStringAsFixed(0)} ${mantenimiento.tipoMantenimiento}',
                        Icons.repeat_outlined,
                      ),
                      _buildInfoRow(
                        context,
                        'Próximo Mantenimiento',
                        mantenimiento.proximoMantenimiento != null
                            ? '${mantenimiento.proximoMantenimiento!.toStringAsFixed(0)} ${mantenimiento.tipoMantenimiento}'
                            : 'No calculado',
                        Icons.update_outlined,
                      ),
                      _buildInfoRow(
                        context,
                        'Restante',
                        mantenimiento.horasKmRestante != null
                            ? '${mantenimiento.horasKmRestante!.toStringAsFixed(0)} ${mantenimiento.tipoMantenimiento}'
                            : 'No calculado',
                        Icons.trending_down_outlined,
                        textColor: _getStatusColor(mantenimiento),
                      ),
                      const SizedBox(height: 16),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _showMantenimientoDetails(context, mantenimiento),
                            icon: const Icon(Icons.history_outlined),
                            label: const Text('Ver Historial'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryYellow,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => _showActualizacionForm(context, mantenimiento),
                            icon: const Icon(Icons.update_outlined),
                            label: const Text('Actualizar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryYellow,
                              foregroundColor: AppColors.darkGray,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
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
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showMantenimientoForm(BuildContext context, [MantenimientoProgramado? mantenimiento]) {
    final formKey = GlobalKey<FormState>();
    String? selectedFicha;
    String? nombreEquipo;
    String selectedTipoMantenimiento = mantenimiento?.tipoMantenimiento ?? MantenimientoProgramado.getTiposMantenimiento().first;
    final TextEditingController horasKmActualesController = TextEditingController(
      text: mantenimiento?.horasKmActuales.toString() ?? '',
    );
    final TextEditingController horasKmUltimoMantenimientoController = TextEditingController(
      text: mantenimiento?.horasKmUltimoMantenimiento?.toString() ?? '',
    );
    final TextEditingController frecuenciaController = TextEditingController(
      text: mantenimiento?.frecuencia.toString() ?? '',
    );
    DateTime? fechaUltimoMantenimiento = mantenimiento?.fechaUltimoMantenimiento;

    // Si es edición, preseleccionar la ficha
    if (mantenimiento != null) {
      selectedFicha = mantenimiento.ficha;
      nombreEquipo = mantenimiento.nombreEquipo;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(mantenimiento == null ? 'Suscribir Equipo a Mantenimiento' : 'Editar Mantenimiento Programado'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<DataService>(
                  builder: (context, dataService, child) {
                    // Obtener equipos activos
                    final equipos = dataService.equipos.where((e) => e.activo).toList();

                    // Filtrar por categoría si está seleccionada
                    final equiposFiltrados = _selectedCategoria != 'Todos'
                        ? equipos.where((e) => e.categoria == _selectedCategoria).toList()
                        : equipos;

                    return DropdownButtonFormField<String>(
                      value: selectedFicha,
                      decoration: const InputDecoration(
                        labelText: 'Ficha',
                        border: OutlineInputBorder(),
                      ),
                      items: equiposFiltrados.map((equipo) {
                        return DropdownMenuItem<String>(
                          value: equipo.ficha,
                          child: Text('${equipo.ficha} - ${equipo.nombre}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedFicha = value;
                        // Autocompletar el nombre del equipo
                        final equipo = dataService.obtenerEquipoPorFicha(value!);
                        if (equipo != null) {
                          nombreEquipo = equipo.nombre;
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor seleccione una ficha';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedTipoMantenimiento,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Mantenimiento',
                    border: OutlineInputBorder(),
                  ),
                  items: MantenimientoProgramado.getTiposMantenimiento().map((tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedTipoMantenimiento = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: horasKmActualesController,
                  decoration: InputDecoration(
                    labelText: 'Horas/Km Actuales',
                    suffixText: selectedTipoMantenimiento == 'Horas' ? 'hr' : 'km',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese las horas/km actuales';
                    }
                    final numero = double.tryParse(value);
                    if (numero == null || numero < 0) {
                      return 'Ingrese un número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: horasKmUltimoMantenimientoController,
                  decoration: InputDecoration(
                    labelText: 'Horas/Km del Último Mantenimiento',
                    suffixText: selectedTipoMantenimiento == 'Horas' ? 'hr' : 'km',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final numero = double.tryParse(value);
                      if (numero == null || numero < 0) {
                        return 'Ingrese un número válido';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: frecuenciaController,
                  decoration: InputDecoration(
                    labelText: 'Frecuencia',
                    suffixText: selectedTipoMantenimiento == 'Horas' ? 'hr' : 'km',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese la frecuencia';
                    }
                    final numero = double.tryParse(value);
                    if (numero == null || numero <= 0) {
                      return 'Ingrese un número válido mayor a 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Fecha de Último Mantenimiento (opcional)'),
                  subtitle: Text(
                    fechaUltimoMantenimiento != null
                        ? '${fechaUltimoMantenimiento!.day}/${fechaUltimoMantenimiento!.month}/${fechaUltimoMantenimiento!.year}'
                        : 'No establecida',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today_outlined),
                    onPressed: () async {
                      final fecha = await showDatePicker(
                        context: context,
                        initialDate: fechaUltimoMantenimiento ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (fecha != null) {
                        setState(() {
                          fechaUltimoMantenimiento = fecha;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate() && selectedFicha != null && nombreEquipo != null) {
                final dataService = Provider.of<DataService>(context, listen: false);

                final newMantenimiento = MantenimientoProgramado(
                  id: mantenimiento?.id,
                  ficha: selectedFicha!,
                  nombreEquipo: nombreEquipo!,
                  tipoMantenimiento: selectedTipoMantenimiento,
                  horasKmActuales: double.parse(horasKmActualesController.text),
                  fechaUltimaActualizacion: DateTime.now(),
                  frecuencia: double.parse(frecuenciaController.text),
                  fechaUltimoMantenimiento: fechaUltimoMantenimiento,
                  horasKmUltimoMantenimiento: horasKmUltimoMantenimientoController.text.isNotEmpty
                      ? double.parse(horasKmUltimoMantenimientoController.text)
                      : null,
                  activo: true,
                );

                if (mantenimiento == null) {
                  dataService.agregarMantenimientoProgramado(newMantenimiento);
                } else {
                  dataService.actualizarMantenimientoProgramado(newMantenimiento);
                }

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(mantenimiento == null ? 'Equipo suscrito a mantenimiento' : 'Mantenimiento actualizado'),
                    backgroundColor: AppColors.success,
                  ),
                );

                // Actualizar la UI
                setState(() {});
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: AppColors.darkGray,
            ),
            child: Text(mantenimiento == null ? 'Suscribir' : 'Actualizar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, MantenimientoProgramado mantenimiento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Mantenimiento Programado'),
        content: Text('¿Está seguro que desea eliminar el mantenimiento programado para ${mantenimiento.nombreEquipo} (${mantenimiento.ficha})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final dataService = Provider.of<DataService>(context, listen: false);
              dataService.eliminarMantenimientoProgramado(mantenimiento.id!);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mantenimiento programado eliminado'),
                  backgroundColor: AppColors.success,
                ),
              );

              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showActualizacionForm(BuildContext context, MantenimientoProgramado mantenimiento) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController horasKmActualesController = TextEditingController(
      text: mantenimiento.horasKmActuales.toString(),
    );
    final TextEditingController empleadoController = TextEditingController();
    DateTime fechaActualizacion = DateTime.now();
    int? selectedEmpleadoId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Actualizar ${mantenimiento.tipoMantenimiento}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ficha: ${mantenimiento.ficha}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Equipo: ${mantenimiento.nombreEquipo}'),
              const SizedBox(height: 16),
              TextFormField(
                controller: horasKmActualesController,
                decoration: InputDecoration(
                  labelText: '${mantenimiento.tipoMantenimiento} Actuales',
                  suffixText: mantenimiento.tipoMantenimiento == 'Horas' ? 'hr' : 'km',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese las ${mantenimiento.tipoMantenimiento.toLowerCase()} actuales';
                  }
                  final numero = double.tryParse(value);
                  if (numero == null || numero < 0) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Fecha de Actualización'),
                subtitle: Text(
                  '${fechaActualizacion.day}/${fechaActualizacion.month}/${fechaActualizacion.year}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today_outlined),
                  onPressed: () async {
                    final fecha = await showDatePicker(
                      context: context,
                      initialDate: fechaActualizacion,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (fecha != null) {
                      setState(() {
                        fechaActualizacion = fecha;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              Consumer<DataService>(
                builder: (context, dataService, child) {
                  // Obtener empleados activos
                  final empleados = dataService.empleados.where((e) => e.activo).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Empleado (opcional)'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int?>(
                              value: selectedEmpleadoId,
                              decoration: const InputDecoration(
                                labelText: 'Seleccionar empleado',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('Sin empleado'),
                                ),
                                ...empleados.map((empleado) {
                                  return DropdownMenuItem<int?>(
                                    value: empleado.id,
                                    child: Text('${empleado.nombreCompleto} (${empleado.categoria})'),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                selectedEmpleadoId = value;
                                if (value != null) {
                                  final empleado = dataService.obtenerEmpleadoPorId(value);
                                  if (empleado != null) {
                                    empleadoController.text = '';
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('O ingrese manualmente:'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: empleadoController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del empleado o empresa',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            selectedEmpleadoId = null;
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final dataService = Provider.of<DataService>(context, listen: false);

                final updatedMantenimiento = MantenimientoProgramado(
                  id: mantenimiento.id,
                  ficha: mantenimiento.ficha,
                  nombreEquipo: mantenimiento.nombreEquipo,
                  tipoMantenimiento: mantenimiento.tipoMantenimiento,
                  horasKmActuales: double.parse(horasKmActualesController.text),
                  fechaUltimaActualizacion: fechaActualizacion,
                  frecuencia: mantenimiento.frecuencia,
                  fechaUltimoMantenimiento: mantenimiento.fechaUltimoMantenimiento,
                  horasKmUltimoMantenimiento: mantenimiento.horasKmUltimoMantenimiento,
                  activo: true,
                );

                dataService.actualizarMantenimientoProgramado(updatedMantenimiento);

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Actualización registrada'),
                    backgroundColor: AppColors.success,
                  ),
                );

                // Actualizar la UI
                setState(() {});
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: AppColors.darkGray,
            ),
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _showMantenimientoDetails(BuildContext context, MantenimientoProgramado mantenimiento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(mantenimiento.nombreEquipo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('Ficha', mantenimiento.ficha),
            _buildDetailItem('Tipo de Mantenimiento', mantenimiento.tipoMantenimiento),
            _buildDetailItem(
              '${mantenimiento.tipoMantenimiento} Actuales',
              '${mantenimiento.horasKmActuales.toStringAsFixed(0)} ${mantenimiento.tipoMantenimiento == 'Horas' ? 'hr' : 'km'}',
            ),
            _buildDetailItem(
              'Frecuencia',
              '${mantenimiento.frecuencia.toStringAsFixed(0)} ${mantenimiento.tipoMantenimiento == 'Horas' ? 'hr' : 'km'}',
            ),
            _buildDetailItem(
              'Fecha de Última Actualización',
              _formatDate(mantenimiento.fechaUltimaActualizacion),
            ),
            _buildDetailItem(
              'Fecha de Último Mantenimiento',
              mantenimiento.fechaUltimoMantenimiento != null
                  ? _formatDate(mantenimiento.fechaUltimoMantenimiento!)
                  : 'No registrado',
            ),
            _buildDetailItem(
              'Horas/Km del Último Mantenimiento',
              mantenimiento.horasKmUltimoMantenimiento != null
                  ? '${mantenimiento.horasKmUltimoMantenimiento!.toStringAsFixed(0)} ${mantenimiento.tipoMantenimiento == 'Horas' ? 'hr' : 'km'}'
                  : 'No registrado',
            ),
            _buildDetailItem(
              'Próximo Mantenimiento',
              mantenimiento.proximoMantenimiento != null
                  ? '${mantenimiento.proximoMantenimiento!.toStringAsFixed(0)} ${mantenimiento.tipoMantenimiento == 'Horas' ? 'hr' : 'km'}'
                  : 'No calculado',
            ),
            _buildDetailItem(
              '${mantenimiento.tipoMantenimiento} Restantes',
              mantenimiento.horasKmRestante != null
                  ? '${mantenimiento.horasKmRestante!.toStringAsFixed(0)} ${mantenimiento.tipoMantenimiento == 'Horas' ? 'hr' : 'km'}'
                  : 'No calculado',
              textColor: _getStatusColor(mantenimiento),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showActualizacionForm(context, mantenimiento);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: AppColors.darkGray,
            ),
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textColor != null ? TextStyle(color: textColor, fontWeight: FontWeight.bold) : null,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(MantenimientoProgramado mantenimiento) {
    if (mantenimiento.horasKmRestante == null) {
      return AppColors.mediumGray;
    }

    if (mantenimiento.horasKmRestante! <= 0) {
      return AppColors.error;
    }

    if (mantenimiento.tipoMantenimiento == 'Horas' && mantenimiento.horasKmRestante! <= 50) {
      return AppColors.warning;
    }

    if (mantenimiento.tipoMantenimiento == 'Kilómetros' && mantenimiento.horasKmRestante! <= 500) {
      return AppColors.warning;
    }

    return AppColors.success;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
