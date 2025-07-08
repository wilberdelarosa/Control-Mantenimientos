import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/data_service.dart';
import '../models/mantenimiento.dart';
import '../models/equipo.dart'; // Añadido para resolver 'Undefined name Equipo'
import '../utils/app_theme.dart';
import '../models/inventario.dart';

class ControlMantenimientoScreen extends StatefulWidget {
  const ControlMantenimientoScreen({Key? key}) : super(key: key);

  @override
  _ControlMantenimientoScreenState createState() => _ControlMantenimientoScreenState();
}

class _ControlMantenimientoScreenState extends State<ControlMantenimientoScreen> {
  String _searchQuery = '';
  String _selectedCategoria = 'Todos';
  String _selectedStatusFilter = 'Todos'; // Todos, Vencido, Próximo, Al día
  String _selectedUpdateFilter = 'Todos'; // Todos, Recientes, Antiguos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Mantenimiento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.update),
            tooltip: 'Actualización Semanal',
            onPressed: () => _showActualizacionSemanalDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: _buildMantenimientosList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 12),
          const Text('Filtrar por Categoría:', style: TextStyle(fontWeight: FontWeight.bold)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Todos', _selectedCategoria, (val) => _selectedCategoria = val),
                ...Equipo.getCategorias().map((categoria) => _buildFilterChip(categoria, _selectedCategoria, (val) => _selectedCategoria = val)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text('Filtrar por Estado:', style: TextStyle(fontWeight: FontWeight.bold)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Todos', _selectedStatusFilter, (val) => _selectedStatusFilter = val),
                _buildFilterChip('Vencido', _selectedStatusFilter, (val) => _selectedStatusFilter = val),
                _buildFilterChip('Próximo', _selectedStatusFilter, (val) => _selectedStatusFilter = val),
                _buildFilterChip('Al día', _selectedStatusFilter, (val) => _selectedStatusFilter = val),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text('Filtrar por Actualización:', style: TextStyle(fontWeight: FontWeight.bold)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Todos', _selectedUpdateFilter, (val) => _selectedUpdateFilter = val),
                _buildFilterChip('Actualizado < 7 días', _selectedUpdateFilter, (val) => _selectedUpdateFilter = val),
                _buildFilterChip('No actualizado > 7 días', _selectedUpdateFilter, (val) => _selectedUpdateFilter = val),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String groupValue, Function(String) onSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: groupValue == label,
        onSelected: (selected) {
          setState(() {
            if (selected) {
              onSelected(label);
            }
          });
        },
        backgroundColor: AppColors.lightGray.withAlpha(51),
        selectedColor: AppColors.primaryYellow,
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

        // Aplicar filtro de estado
        if (_selectedStatusFilter != 'Todos') {
          mantenimientosFiltrados = mantenimientosFiltrados.where((m) {
            switch (_selectedStatusFilter) {
              case 'Vencido':
                return m.status == MantenimientoStatus.Vencido;
              case 'Próximo':
                return m.status == MantenimientoStatus.Proximo;
              case 'Al día':
                return m.status == MantenimientoStatus.AlDia;
              default:
                return true;
            }
          }).toList();
        }

        // Aplicar filtro de actualización
        if (_selectedUpdateFilter != 'Todos') {
          mantenimientosFiltrados = mantenimientosFiltrados.where((m) {
            switch (_selectedUpdateFilter) {
              case 'Actualizado < 7 días':
                return m.actualizadoRecientemente;
              case 'No actualizado > 7 días':
                return !m.actualizadoRecientemente;
              default:
                return true;
            }
          }).toList();
        }

        // Aplicar búsqueda
        if (_searchQuery.isNotEmpty) {
          mantenimientosFiltrados = mantenimientosFiltrados.where((mantenimiento) =>
          mantenimiento.ficha.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              mantenimiento.nombreEquipo.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
        }

        if (mantenimientosFiltrados.isEmpty) {
          return const Center(
            child: Text('No se encontraron mantenimientos con los filtros seleccionados'),
          );
        }

        return ListView.builder(
          itemCount: mantenimientosFiltrados.length,
          itemBuilder: (context, index) {
            final mantenimiento = mantenimientosFiltrados[index];

            // Obtener el empleado asignado (en este caso, podríamos usar el último mantenimiento)
            String empleadoAsignado = 'No asignado';
            final mantenimientosRealizados = dataService.obtenerMantenimientosRealizadosPorFicha(mantenimiento.ficha);
            if (mantenimientosRealizados.isNotEmpty) {
              final ultimoMantenimiento = mantenimientosRealizados.first; // Ya está ordenado por fecha descendente
              final empleado = dataService.obtenerEmpleadoPorId(ultimoMantenimiento.idEmpleado);
              if (empleado != null) {
                empleadoAsignado = empleado.nombreCompleto;
              }
            }

            // Obtener la última actualización
            final fechaFormateada = DateFormat('dd/MM/yyyy').format(mantenimiento.fechaUltimaActualizacion);
            final ultimaActualizacion = 'Actualizado: $fechaFormateada';


            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(mantenimiento),
                  child: Text(
                    mantenimiento.ficha.substring(mantenimiento.ficha.length - 2),
                    style: TextStyle(color: AppColors.darkGray),
                  ),
                ),
                title: Text(mantenimiento.nombreEquipo),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ficha: ${mantenimiento.ficha} | Operador: $empleadoAsignado'),
                    Text(ultimaActualizacion, style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: mantenimiento.actualizadoRecientemente ? AppColors.success : AppColors.mediumGray)),
                    Text(
                      'Actual: ${mantenimiento.horasKmActuales.toStringAsFixed(0)} ${mantenimiento.tipoMantenimiento == 'Horas' ? 'hr' : 'km'} | Restante: ${mantenimiento.horasKmRestante?.toStringAsFixed(0) ?? 'N/A'} ${mantenimiento.tipoMantenimiento == 'Horas' ? 'hr' : 'km'}',
                      style: TextStyle(
                        color: _getStatusColor(mantenimiento),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.update),
                      onPressed: () => _showActualizacionForm(context, mantenimiento),
                    ),
                    IconButton(
                      icon: const Icon(Icons.build),
                      onPressed: () => _showMantenimientoForm(context, mantenimiento),
                    ),
                  ],
                ),
                onTap: () => _showMantenimientoDetails(context, mantenimiento, dataService),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(MantenimientoProgramado mantenimiento) {
    switch (mantenimiento.status) {
      case MantenimientoStatus.Vencido:
        return AppColors.error;
      case MantenimientoStatus.Proximo:
        return AppColors.warning;
      case MantenimientoStatus.AlDia:
        return AppColors.success;
      case MantenimientoStatus.NoCalculado:
        return AppColors.mediumGray;
    }
  }

  void _showActualizacionSemanalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualización Semanal'),
        content: const Text('¿Desea realizar la actualización semanal de todos los equipos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showActualizacionSemanalForm(context);
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _showActualizacionSemanalForm(BuildContext context) {
    final dataService = Provider.of<DataService>(context, listen: false);
    final equiposActivos = dataService.equipos.where((e) => e.activo).toList();

    // Crear un mapa para almacenar los valores de horas/km para cada equipo
    final Map<String, TextEditingController> controllers = {};
    for (var equipo in equiposActivos) {
      final mantenimiento = dataService.obtenerMantenimientoProgramadoPorFicha(equipo.ficha);
      controllers[equipo.ficha] = TextEditingController(
        text: mantenimiento?.horasKmActuales.toString() ?? '0',
      );
    }

    // Fecha de actualización
    DateTime fechaActualizacion = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Actualización Semanal - ${DateFormat('dd/MM/yyyy').format(fechaActualizacion)}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selector de fecha
              ListTile(
                title: const Text('Fecha de Actualización'),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy').format(fechaActualizacion),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
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
              const Divider(),
              ...equiposActivos.map((equipo) {
                final mantenimiento = dataService.obtenerMantenimientoProgramadoPorFicha(equipo.ficha);
                final String tipoUnidad = mantenimiento?.tipoMantenimiento == 'Horas' ? 'hr' : 'km';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text('${equipo.ficha} - ${equipo.nombre}'),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: controllers[equipo.ficha],
                          decoration: InputDecoration(
                            labelText: tipoUnidad,
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
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
              // Guardar las actualizaciones
              for (var equipo in equiposActivos) {
                final controller = controllers[equipo.ficha];
                if (controller != null && controller.text.isNotEmpty) {
                  final nuevoValor = double.tryParse(controller.text);
                  if (nuevoValor != null) {
                    await dataService.actualizarHorasKmSemanal(
                      equipo.ficha,
                      nuevoValor,
                      fechaActualizacion,
                    );
                  }
                }
              }

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Actualización semanal completada'),
                  backgroundColor: AppColors.success,
                ),
              );

              setState(() {}); // Actualizar la UI
            },
            child: const Text('Guardar'),
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
    final TextEditingController empleadoManualController = TextEditingController();
    int? selectedEmpleadoId;
    DateTime fechaActualizacion = DateTime.now();

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
                  DateFormat('dd/MM/yyyy').format(fechaActualizacion),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
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
                      DropdownButtonFormField<int?>(
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
                            empleadoManualController.text = '';
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      const Text('O ingrese manualmente:'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: empleadoManualController,
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
                final nuevoValor = double.parse(horasKmActualesController.text);

                await dataService.actualizarHorasKmSemanal(
                  mantenimiento.ficha,
                  nuevoValor,
                  fechaActualizacion,
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Actualización registrada'),
                    backgroundColor: AppColors.success,
                  ),
                );

                setState(() {}); // Actualizar la UI
              }
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _showMantenimientoForm(BuildContext context, MantenimientoProgramado mantenimiento) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController horasKmController = TextEditingController(
      text: mantenimiento.horasKmActuales.toString(),
    );
    final TextEditingController observacionesController = TextEditingController();
    final TextEditingController empleadoManualController = TextEditingController();
    int? selectedEmpleadoId;
    final List<FiltroUtilizado> filtrosSeleccionados = [];
    DateTime fechaMantenimiento = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Registrar Mantenimiento'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      controller: horasKmController,
                      decoration: InputDecoration(
                        labelText: '${mantenimiento.tipoMantenimiento} al momento',
                        suffixText: mantenimiento.tipoMantenimiento == 'Horas' ? 'hr' : 'km',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese las ${mantenimiento.tipoMantenimiento.toLowerCase()}';
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
                      title: const Text('Fecha de Mantenimiento'),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy').format(fechaMantenimiento),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final fecha = await showDatePicker(
                            context: context,
                            initialDate: fechaMantenimiento,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (fecha != null) {
                            setState(() {
                              fechaMantenimiento = fecha;
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
                            const Text('Empleado que realizó el mantenimiento'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int?>(
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
                                setState(() {
                                  selectedEmpleadoId = value;
                                  if (value != null) {
                                    empleadoManualController.text = '';
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            const Text('O ingrese manualmente:'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: empleadoManualController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre del empleado o empresa',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  setState(() {
                                    selectedEmpleadoId = null;
                                  });
                                }
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Filtros utilizados:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Consumer<DataService>(
                      builder: (context, dataService, child) {
                        // Obtener inventario de filtros para la categoría del equipo
                        final equipo = dataService.obtenerEquipoPorFicha(mantenimiento.ficha);
                        if (equipo == null) {
                          return const Text('No se encontró el equipo');
                        }

                        final filtrosDisponibles = dataService.inventarios
                            .where((i) => i.activo && i.categoriaEquipo == equipo.categoria)
                            .toList();

                        if (filtrosDisponibles.isEmpty) {
                          return const Text('No hay filtros disponibles para este equipo');
                        }

                        // Mostrar filtros seleccionados
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Lista de filtros seleccionados
                            if (filtrosSeleccionados.isNotEmpty) ...[
                              Card(
                                color: AppColors.primaryYellow.withAlpha(30),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Filtros seleccionados:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      ...filtrosSeleccionados.map((filtro) {
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 4.0),
                                          child: Row(
                                            children: [
                                              Text('${filtro.nombre}: ${filtro.cantidad}'),
                                              const Spacer(),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline, size: 18),
                                                onPressed: () {
                                                  setState(() {
                                                    filtrosSeleccionados.removeWhere((f) => f.idInventario == filtro.idInventario);
                                                  });
                                                },
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Dropdown para seleccionar filtros
                            DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: 'Agregar filtro',
                                border: OutlineInputBorder(),
                              ),
                              items: filtrosDisponibles.map((filtro) {
                                return DropdownMenuItem<int>(
                                  value: filtro.id!,
                                  child: Text('${filtro.nombre} (Disponible: ${filtro.cantidad})'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  final filtro = filtrosDisponibles.firstWhere((f) => f.id == value);

                                  // Verificar si ya está seleccionado
                                  final existente = filtrosSeleccionados.indexWhere((f) => f.idInventario == value);

                                  if (existente == -1 && filtro.cantidad > 0) {
                                    setState(() {
                                      filtrosSeleccionados.add(
                                        FiltroUtilizado(
                                          idInventario: filtro.id!,
                                          nombre: filtro.nombre,
                                          cantidad: 1,
                                        ),
                                      );
                                    });
                                  }
                                }
                              },
                            ),

                            const SizedBox(height: 16),

                            // Ajustar cantidades de filtros seleccionados
                            ...filtrosSeleccionados.map((filtro) {
                              final inventario = filtrosDisponibles.firstWhere(
                                    (i) => i.id == filtro.idInventario,
                                orElse: () => Inventario(
                                  id: filtro.idInventario,
                                  nombre: filtro.nombre,
                                  tipo: 'Desconocido',
                                  categoriaEquipo: equipo.categoria,
                                  cantidad: 0,
                                ),
                              );

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(filtro.nombre),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: filtro.cantidad > 1
                                          ? () {
                                        setState(() {
                                          filtro.cantidad--;
                                        });
                                      }
                                          : null,
                                    ),
                                    Text(
                                      filtro.cantidad.toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: filtro.cantidad < inventario.cantidad
                                          ? () {
                                        setState(() {
                                          filtro.cantidad++;
                                        });
                                      }
                                          : null,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: observacionesController,
                      decoration: const InputDecoration(
                        labelText: 'Observaciones',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
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
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final dataService = Provider.of<DataService>(context, listen: false);

                    // Determinar el ID del empleado
                    int empleadoId = -1;
                    if (selectedEmpleadoId != null) {
                      empleadoId = selectedEmpleadoId!;
                    } else if (empleadoManualController.text.isNotEmpty) {
                      // Crear un empleado temporal o usar uno existente con nombre similar
                      // Por simplicidad, usamos un ID negativo para indicar que es un empleado externo
                      empleadoId = -1;
                    }

                    final mantenimientoRealizado = MantenimientoRealizado(
                      ficha: mantenimiento.ficha,
                      fechaMantenimiento: fechaMantenimiento,
                      horasKmAlMomento: double.parse(horasKmController.text),
                      idEmpleado: empleadoId,
                      filtrosUtilizados: filtrosSeleccionados,
                      observaciones: observacionesController.text +
                          (empleadoManualController.text.isNotEmpty ?
                          '\nRealizado por: ${empleadoManualController.text}' : ''),
                    );

                    await dataService.agregarMantenimientoRealizado(mantenimientoRealizado);

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mantenimiento registrado correctamente'),
                        backgroundColor: AppColors.success,
                      ),
                    );

                    this.setState(() {}); // Actualizar la UI
                  }
                },
                child: const Text('Registrar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showMantenimientoDetails(BuildContext context, MantenimientoProgramado mantenimiento, DataService dataService) {
    // Obtener historial de mantenimientos
    final mantenimientosRealizados = dataService.obtenerMantenimientosRealizadosPorFicha(mantenimiento.ficha);

    // Obtener historial de actualizaciones
    final actualizaciones = dataService.obtenerHistorialActualizacionesPorFicha(mantenimiento.ficha);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.mediumGray,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        mantenimiento.nombreEquipo,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Ficha: ${mantenimiento.ficha}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatusIndicator(mantenimiento),
                          const Spacer(),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.update),
                            label: const Text('Actualizar'),
                            onPressed: () {
                              Navigator.pop(context);
                              _showActualizacionForm(context, mantenimiento);
                            },
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.build),
                            label: const Text('Mantenimiento'),
                            onPressed: () {
                              Navigator.pop(context);
                              _showMantenimientoForm(context, mantenimiento);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                TabBar(
                  tabs: [
                    Tab(text: 'Mantenimientos'),
                    Tab(text: 'Actualizaciones'),
                  ],
                  labelColor: AppColors.primaryYellow,
                  indicatorColor: AppColors.primaryYellow,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Pestaña de Mantenimientos
                      mantenimientosRealizados.isEmpty
                          ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No hay mantenimientos registrados'),
                        ),
                      )
                          : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: mantenimientosRealizados.length,
                        itemBuilder: (context, index) {
                          final mantenimientoRealizado = mantenimientosRealizados[index];
                          final empleado = dataService.obtenerEmpleadoPorId(mantenimientoRealizado.idEmpleado);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Fecha: ${DateFormat('dd/MM/yyyy').format(mantenimientoRealizado.fechaMantenimiento)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${mantenimientoRealizado.horasKmAlMomento.toStringAsFixed(0)} ${mantenimiento.tipoMantenimiento == 'Horas' ? 'hr' : 'km'}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (mantenimientoRealizado.incrementoDesdeUltimo != null)
                                    Text(
                                      'Incremento: ${mantenimientoRealizado.incrementoDesdeUltimo!.toStringAsFixed(0)} ${mantenimiento.tipoMantenimiento == 'Horas' ? 'hr' : 'km'} desde el último mantenimiento',
                                      style: TextStyle(
                                        color: AppColors.mediumGray,
                                        fontSize: 12,
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Text('Realizado por: ${empleado?.nombreCompleto ?? 'Desconocido'}'),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Filtros utilizados:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  mantenimientoRealizado.filtrosUtilizados.isEmpty
                                      ? const Text('Ninguno')
                                      : Column(
                                    children: mantenimientoRealizado.filtrosUtilizados.map((filtro) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 4.0),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.check, size: 16),
                                            const SizedBox(width: 4),
                                            Text('${filtro.nombre} (${filtro.cantidad})'),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  if (mantenimientoRealizado.observaciones.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Observaciones:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(mantenimientoRealizado.observaciones),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Pestaña de Actualizaciones
                      actualizaciones.isEmpty
                          ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No hay actualizaciones registradas'),
                        ),
                      )
                          : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: actualizaciones.length,
                        itemBuilder: (context, index) {
                          final actualizacion = actualizaciones[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              title: Text(
                                '${actualizacion.horasKm.toStringAsFixed(0)} ${mantenimiento.tipoMantenimiento == 'Horas' ? 'hr' : 'km'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Fecha: ${DateFormat('dd/MM/yyyy').format(actualizacion.fecha)}'),
                                  if (actualizacion.incremento != null)
                                    Text(
                                      'Incremento: ${actualizacion.incremento!.toStringAsFixed(0)} ${mantenimiento.tipoMantenimiento == 'Horas' ? 'hr' : 'km'}',
                                      style: TextStyle(
                                        color: AppColors.primaryYellow,
                                      ),
                                    ),
                                ],
                              ),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.lightGray,
                                child: Icon(
                                  Icons.update,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIndicator(MantenimientoProgramado mantenimiento) {
    final Color color = _getStatusColor(mantenimiento);
    String status = 'Normal';

    if (mantenimiento.horasKmRestante == null) {
      status = 'No calculado';
    } else if (mantenimiento.horasKmRestante! <= 0) {
      status = 'Vencido';
    } else if (mantenimiento.tipoMantenimiento == 'Horas' && mantenimiento.horasKmRestante! <= 50) {
      status = 'Próximo';
    } else if (mantenimiento.tipoMantenimiento == 'Kilómetros' && mantenimiento.horasKmRestante! <= 500) {
      status = 'Próximo';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(51),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                'Restante: ${mantenimiento.horasKmRestante?.toStringAsFixed(0) ?? 'N/A'} ${mantenimiento.tipoMantenimiento == 'Horas' ? 'hr' : 'km'}',
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
