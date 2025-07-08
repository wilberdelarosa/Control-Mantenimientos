import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/data_service.dart';
import '../utils/app_theme.dart';
import '../controllers/historial_avanzado_controller.dart';
import '../models/equipo.dart';
import '../models/inventario.dart';

class HistorialAvanzadoScreen extends StatefulWidget {
  const HistorialAvanzadoScreen({Key? key}) : super(key: key);

  @override
  _HistorialAvanzadoScreenState createState() => _HistorialAvanzadoScreenState();
}

class _HistorialAvanzadoScreenState extends State<HistorialAvanzadoScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late HistorialAvanzadoController _controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _controller = HistorialAvanzadoController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final contrastTextColor = isDarkMode ? AppColors.white : AppColors.darkGray;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial Avanzado'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: contrastTextColor,
          tabs: const [
            Tab(text: 'Línea de Tiempo'),
            Tab(text: 'Mantenimientos'),
            Tab(text: 'Inventario'),
            Tab(text: 'Estadísticas'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filtros',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDateRange(context),
            tooltip: 'Rango de fechas',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'export') {
                _controller.exportData(context);
              } else if (value == 'print') {
                _controller.printReport(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Text('Exportar datos'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'print',
                child: Row(
                  children: [
                    Icon(Icons.print, size: 20),
                    SizedBox(width: 8),
                    Text('Imprimir reporte'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateRangeIndicator(),
          _buildActiveFiltersChips(),
          _buildVisualizationToggle(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTimelineTab(),
                _buildMaintenanceTab(),
                _buildInventoryTab(),
                _buildStatisticsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeIndicator() {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.darkGray;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () => _selectDateRange(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryYellow.withAlpha(30),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primaryYellow.withAlpha(100)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.date_range, color: AppColors.primaryYellow, size: 20),
              const SizedBox(width: 8),
              Text(
                'Periodo: ${formatter.format(_controller.dateRange.start)} - ${formatter.format(_controller.dateRange.end)}',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFiltersChips() {
    List<Widget> chips = [];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.darkGray;

    if (_controller.selectedFicha != null) {
      chips.add(_buildFilterChip('Ficha: ${_controller.selectedFicha}', () {
        setState(() {
          _controller.selectedFicha = null;
        });
      }, textColor));
    }

    if (_controller.selectedCategoria != null) {
      chips.add(_buildFilterChip('Categoría: ${_controller.selectedCategoria}', () {
        setState(() {
          _controller.selectedCategoria = null;
        });
      }, textColor));
    }

    if (_controller.selectedEmpleado != null) {
      chips.add(_buildFilterChip('Empleado: ${_controller.selectedEmpleado}', () {
        setState(() {
          _controller.selectedEmpleado = null;
        });
      }, textColor));
    }

    if (_controller.selectedTipoActividad != null) {
      chips.add(_buildFilterChip('Actividad: ${_controller.selectedTipoActividad}', () {
        setState(() {
          _controller.selectedTipoActividad = null;
        });
      }, textColor));
    }

    if (_controller.selectedTipoInventario != null) {
      chips.add(_buildFilterChip('Tipo Inv.: ${_controller.selectedTipoInventario}', () {
        setState(() {
          _controller.selectedTipoInventario = null;
        });
      }, textColor));
    }

    if (_controller.selectedCategoriaEquipo != null) {
      chips.add(_buildFilterChip('Cat. Equipo: ${_controller.selectedCategoriaEquipo}', () {
        setState(() {
          _controller.selectedCategoriaEquipo = null;
        });
      }, textColor));
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          ...chips,
          TextButton.icon(
            icon: const Icon(Icons.clear_all, size: 18),
            label: const Text('Limpiar filtros'),
            onPressed: () {
              setState(() {
                _controller.clearAllFilters();
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.mediumGray,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDelete, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(label, style: TextStyle(fontSize: 12, color: textColor)),
        deleteIcon: Icon(Icons.close, size: 16, color: textColor),
        onDeleted: onDelete,
        backgroundColor: AppColors.primaryYellow.withAlpha(30),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildVisualizationToggle() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final selectedTextColor = isDarkMode ? AppColors.darkGray : AppColors.darkGray;
    final unselectedTextColor = isDarkMode ? AppColors.white : AppColors.mediumGray;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SegmentedButton<String>(
        segments: [
          ButtonSegment<String>(
            value: 'Lista',
            icon: const Icon(Icons.list),
            label: Text('Lista', style: TextStyle(
                color: _controller.visualizacionMode == 'Lista' ? selectedTextColor : unselectedTextColor
            )),
          ),
          ButtonSegment<String>(
            value: 'Gráfico',
            icon: const Icon(Icons.bar_chart),
            label: Text('Gráfico', style: TextStyle(
                color: _controller.visualizacionMode == 'Gráfico' ? selectedTextColor : unselectedTextColor
            )),
          ),
          ButtonSegment<String>(
            value: 'Calendario',
            icon: const Icon(Icons.calendar_view_month),
            label: Text('Calendario', style: TextStyle(
                color: _controller.visualizacionMode == 'Calendario' ? selectedTextColor : unselectedTextColor
            )),
          ),
        ],
        selected: {_controller.visualizacionMode},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() {
            _controller.visualizacionMode = newSelection.first;
          });
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return AppColors.primaryYellow;
              }
              return Colors.transparent;
            },
          ),
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return selectedTextColor;
              }
              return unselectedTextColor;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineTab() {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        final timelineEvents = _controller.getTimelineEvents(dataService);

        if (timelineEvents.isEmpty) {
          return const Center(
            child: Text('No hay eventos que coincidan con los filtros seleccionados'),
          );
        }

        if (_controller.visualizacionMode == 'Lista') {
          return _controller.buildTimelineList(context, timelineEvents);
        } else if (_controller.visualizacionMode == 'Calendario') {
          return _controller.buildTimelineCalendar(context, timelineEvents);
        } else {
          return _controller.buildTimelineChart(context, timelineEvents);
        }
      },
    );
  }

  Widget _buildMaintenanceTab() {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        final mantenimientosFiltrados = _controller.getFilteredMaintenances(dataService);

        if (mantenimientosFiltrados.isEmpty) {
          return const Center(
            child: Text('No hay mantenimientos que coincidan con los filtros seleccionados'),
          );
        }

        if (_controller.visualizacionMode == 'Lista') {
          return _controller.buildMaintenanceList(context, mantenimientosFiltrados, dataService);
        } else if (_controller.visualizacionMode == 'Calendario') {
          return _controller.buildMaintenanceCalendar(context, mantenimientosFiltrados, dataService);
        } else {
          return _controller.buildMaintenanceChart(context, mantenimientosFiltrados, dataService);
        }
      },
    );
  }

  Widget _buildInventoryTab() {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        final movimientos = _controller.getInventoryMovements(dataService);

        if (movimientos.isEmpty) {
          return const Center(
            child: Text('No hay movimientos de inventario que coincidan con los filtros seleccionados'),
          );
        }

        if (_controller.visualizacionMode == 'Lista') {
          return _controller.buildInventoryList(context, movimientos);
        } else if (_controller.visualizacionMode == 'Calendario') {
          return _controller.buildInventoryCalendar(context, movimientos);
        } else {
          return _controller.buildInventoryChart(context, movimientos);
        }
      },
    );
  }

  Widget _buildStatisticsTab() {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        return _controller.buildStatisticsView(context, dataService);
      },
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.darkGray;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _controller.dateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryYellow,
              onPrimary: AppColors.darkGray,
              surface: isDarkMode ? AppColors.darkGray : AppColors.white,
              onSurface: textColor,
            ),
            dialogBackgroundColor: isDarkMode ? AppColors.darkGray : AppColors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _controller.dateRange) {
      setState(() {
        _controller.dateRange = picked;
      });
    }
  }

  void _showFilterDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.white : AppColors.darkGray;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Consumer<DataService>(
            builder: (context, dataService, child) {
              // Obtener listas para filtros
              final equipos = dataService.equipos.where((e) => e.activo).toList();
              final categorias = ['Todos', ...Equipo.getCategorias()];
              final empleados = dataService.empleados.where((e) => e.activo).toList();
              final tiposActividad = ['Todos', 'Mantenimiento', 'Actualización', 'Inventario'];
              final tiposInventario = ['Todos', ...Inventario.getTipos()];
              final categoriasEquipo = ['Todos', ...Equipo.getCategorias()];

              return AlertDialog(
                title: Text('Filtros Avanzados', style: TextStyle(color: textColor)),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filtros Generales',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String?>(
                        value: _controller.selectedFicha,
                        decoration: const InputDecoration(
                          labelText: 'Equipo',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Todos'),
                          ),
                          ...equipos.map((equipo) {
                            return DropdownMenuItem<String?>(
                              value: equipo.ficha,
                              child: Text('${equipo.ficha} - ${equipo.nombre}'),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _controller.selectedFicha = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String?>(
                        value: _controller.selectedCategoria,
                        decoration: const InputDecoration(
                          labelText: 'Categoría de Equipo',
                          border: OutlineInputBorder(),
                        ),
                        items: categorias.map((categoria) {
                          return DropdownMenuItem<String?>(
                            value: categoria == 'Todos' ? null : categoria,
                            child: Text(categoria),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _controller.selectedCategoria = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String?>(
                        value: _controller.selectedEmpleado,
                        decoration: const InputDecoration(
                          labelText: 'Empleado',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Todos'),
                          ),
                          ...empleados.map((empleado) {
                            return DropdownMenuItem<String?>(
                              value: empleado.nombreCompleto,
                              child: Text(empleado.nombreCompleto),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _controller.selectedEmpleado = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String?>(
                        value: _controller.selectedTipoActividad,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Actividad',
                          border: OutlineInputBorder(),
                        ),
                        items: tiposActividad.map((tipo) {
                          return DropdownMenuItem<String?>(
                            value: tipo == 'Todos' ? null : tipo,
                            child: Text(tipo),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _controller.selectedTipoActividad = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Filtros de Inventario',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String?>(
                        value: _controller.selectedTipoInventario,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Inventario',
                          border: OutlineInputBorder(),
                        ),
                        items: tiposInventario.map((tipo) {
                          return DropdownMenuItem<String?>(
                            value: tipo == 'Todos' ? null : tipo,
                            child: Text(tipo),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _controller.selectedTipoInventario = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String?>(
                        value: _controller.selectedCategoriaEquipo,
                        decoration: const InputDecoration(
                          labelText: 'Categoría de Equipo (Inventario)',
                          border: OutlineInputBorder(),
                        ),
                        items: categoriasEquipo.map((categoria) {
                          return DropdownMenuItem<String?>(
                            value: categoria == 'Todos' ? null : categoria,
                            child: Text(categoria),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _controller.selectedCategoriaEquipo = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      // Limpiar todos los filtros
                      this.setState(() {
                        _controller.clearAllFilters();
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Limpiar Filtros'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      this.setState(() {
                        // Los filtros ya se actualizaron en el StatefulBuilder
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: AppColors.darkGray,
                    ),
                    child: const Text('Aplicar'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
