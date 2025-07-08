import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/inventario.dart';
import '../models/equipo.dart';
import '../utils/app_theme.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({Key? key}) : super(key: key);

  @override
  _InventarioScreenState createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  String _searchQuery = '';
  String _selectedTipo = 'Todos';
  String _selectedCategoria = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Inventario'),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: _buildInventarioList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showInventarioForm(context),
        child: const Icon(Icons.add),
        backgroundColor: AppColors.primaryYellow,
        foregroundColor: AppColors.darkGray,
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
              hintText: 'Buscar por nombre o código...',
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
                const Text('Tipo: '),
                const SizedBox(width: 8),
                _buildFilterChip('Todos', isType: true),
                ...Inventario.getTipos().map((tipo) => _buildFilterChip(tipo, isType: true)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('Categoría: '),
                const SizedBox(width: 8),
                _buildFilterChip('Todos', isType: false),
                ...Equipo.getCategorias().map((categoria) => _buildFilterChip(categoria, isType: false)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, {required bool isType}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(value),
        selected: isType
            ? _selectedTipo == value
            : _selectedCategoria == value,
        onSelected: (selected) {
          setState(() {
            if (isType) {
              _selectedTipo = selected ? value : 'Todos';
            } else {
              _selectedCategoria = selected ? value : 'Todos';
            }
          });
        },
        backgroundColor: AppColors.lightGray.withAlpha(51),
        selectedColor: AppColors.primaryYellow,
      ),
    );
  }

  Widget _buildInventarioList() {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        // Filtrar inventario
        var inventarioFiltrado = dataService.inventarios.where((inventario) => inventario.activo).toList();

        // Aplicar filtro de tipo
        if (_selectedTipo != 'Todos') {
          inventarioFiltrado = inventarioFiltrado.where((inventario) => inventario.tipo == _selectedTipo).toList();
        }

        // Aplicar filtro de categoría
        if (_selectedCategoria != 'Todos') {
          inventarioFiltrado = inventarioFiltrado.where((inventario) => inventario.categoriaEquipo == _selectedCategoria).toList();
        }

        // Aplicar búsqueda
        if (_searchQuery.isNotEmpty) {
          inventarioFiltrado = inventarioFiltrado.where((inventario) =>
          inventario.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (inventario.codigoIdentificacion?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
          ).toList();
        }

        if (inventarioFiltrado.isEmpty) {
          return const Center(
            child: Text('No se encontraron productos en el inventario'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: inventarioFiltrado.length,
          itemBuilder: (context, index) {
            final inventario = inventarioFiltrado[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getColorByStock(inventario.cantidad),
                  child: Text(
                    inventario.cantidad.toString(),
                    style: TextStyle(color: AppColors.darkGray),
                  ),
                ),
                title: Text(
                  inventario.nombre,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipo: ${inventario.tipo} | Categoría: ${inventario.categoriaEquipo}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (inventario.codigoIdentificacion != null)
                      Text(
                        'Código: ${inventario.codigoIdentificacion}',
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => _showMovimientoForm(context, inventario, 'Ingreso'),
                      tooltip: 'Ingreso',
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => _showMovimientoForm(context, inventario, 'Egreso'),
                      tooltip: 'Egreso',
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showInventarioForm(context, inventario),
                      tooltip: 'Editar',
                    ),
                  ],
                ),
                onTap: () => _showInventarioDetails(context, inventario),
                isThreeLine: inventario.codigoIdentificacion != null,
              ),
            );
          },
        );
      },
    );
  }

  Color _getColorByStock(int cantidad) {
    if (cantidad <= 1) {
      return AppColors.error;
    } else if (cantidad <= 3) {
      return AppColors.warning;
    } else {
      return AppColors.success;
    }
  }

  void _showInventarioForm(BuildContext context, [Inventario? inventario]) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController nombreController = TextEditingController(text: inventario?.nombre ?? '');
    final TextEditingController codigoController = TextEditingController(text: inventario?.codigoIdentificacion ?? '');
    final TextEditingController empresaController = TextEditingController(text: inventario?.empresaSuplidora ?? '');

    String selectedTipo = inventario?.tipo ?? Inventario.getTipos().first;
    String selectedCategoria = inventario?.categoriaEquipo ?? Equipo.getCategorias().first;
    int cantidad = inventario?.cantidad ?? 0;

    // Para la selección de equipos compatibles
    List<String> marcasSeleccionadas = List.from(inventario?.marcasCompatibles ?? []);
    List<String> modelosSeleccionados = List.from(inventario?.modelosCompatibles ?? []);

    // Obtener todas las marcas y modelos disponibles
    final dataService = Provider.of<DataService>(context, listen: false);
    final equipos = dataService.equipos.where((e) => e.activo).toList();

    // Extraer marcas y modelos únicos
    final Set<String> todasLasMarcas = equipos.map((e) => e.marca).toSet();
    final Set<String> todosLosModelos = equipos.map((e) => e.modelo).toSet();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(inventario == null ? 'Agregar Producto' : 'Editar Producto'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Producto',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el nombre del producto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: codigoController,
                      decoration: const InputDecoration(
                        labelText: 'Código de Identificación (opcional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: empresaController,
                      decoration: const InputDecoration(
                        labelText: 'Empresa Suplidora (opcional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedTipo,
                      decoration: const InputDecoration(
                        labelText: 'Tipo',
                        border: OutlineInputBorder(),
                      ),
                      items: Inventario.getTipos().map((tipo) {
                        return DropdownMenuItem<String>(
                          value: tipo,
                          child: Text(tipo),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedTipo = value!;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategoria,
                      decoration: const InputDecoration(
                        labelText: 'Categoría de Equipo',
                        border: OutlineInputBorder(),
                      ),
                      items: Equipo.getCategorias().map((categoria) {
                        return DropdownMenuItem<String>(
                          value: categoria,
                          child: Text(categoria),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedCategoria = value!;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Cantidad Inicial: '),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            if (cantidad > 0) {
                              setState(() {
                                cantidad--;
                              });
                            }
                          },
                        ),
                        Text(
                          cantidad.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            setState(() {
                              cantidad++;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Compatibilidad con Equipos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Marcas Compatibles:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: todasLasMarcas.map((marca) {
                        final isSelected = marcasSeleccionadas.contains(marca);
                        return FilterChip(
                          label: Text(marca),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                marcasSeleccionadas.add(marca);
                              } else {
                                marcasSeleccionadas.remove(marca);
                              }
                            });
                          },
                          backgroundColor: AppColors.lightGray.withAlpha(51),
                          selectedColor: AppColors.primaryYellow,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Modelos Compatibles:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: todosLosModelos.map((modelo) {
                        final isSelected = modelosSeleccionados.contains(modelo);
                        return FilterChip(
                          label: Text(modelo),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                modelosSeleccionados.add(modelo);
                              } else {
                                modelosSeleccionados.remove(modelo);
                              }
                            });
                          },
                          backgroundColor: AppColors.lightGray.withAlpha(51),
                          selectedColor: AppColors.primaryYellow,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nota: Si no selecciona ninguna marca o modelo, el producto será compatible con todos los equipos.',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.mediumGray,
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
                  if (formKey.currentState!.validate()) {
                    final dataService = Provider.of<DataService>(context, listen: false);

                    final newInventario = Inventario(
                      id: inventario?.id,
                      nombre: nombreController.text,
                      tipo: selectedTipo,
                      categoriaEquipo: selectedCategoria,
                      cantidad: cantidad,
                      movimientos: inventario?.movimientos ?? [],
                      activo: true,
                      codigoIdentificacion: codigoController.text.isEmpty ? null : codigoController.text,
                      empresaSuplidora: empresaController.text.isEmpty ? null : empresaController.text,
                      marcasCompatibles: marcasSeleccionadas,
                      modelosCompatibles: modelosSeleccionados,
                    );

                    if (inventario == null) {
                      // Si es nuevo, agregar un movimiento inicial
                      if (cantidad > 0) {
                        newInventario.movimientos.add(
                          MovimientoInventario(
                            fecha: DateTime.now(),
                            tipo: 'Ingreso',
                            cantidad: cantidad,
                            responsable: 'Admin',
                            motivo: 'Registro inicial',
                          ),
                        );
                      }

                      dataService.agregarInventario(newInventario);
                    } else {
                      // Si es edición, solo actualizar los datos
                      dataService.actualizarInventario(newInventario);
                    }

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(inventario == null ? 'Producto agregado' : 'Producto actualizado'),
                        backgroundColor: AppColors.success,
                      ),
                    );

                    // Actualizar la UI
                    this.setState(() {});
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: AppColors.darkGray,
                ),
                child: Text(inventario == null ? 'Agregar' : 'Actualizar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showMovimientoForm(BuildContext context, Inventario inventario, String tipoMovimiento) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController cantidadController = TextEditingController(text: '1');
    final TextEditingController responsableController = TextEditingController();
    final TextEditingController motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$tipoMovimiento de ${inventario.nombre}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: cantidadController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la cantidad';
                  }
                  final cantidad = int.tryParse(value);
                  if (cantidad == null || cantidad <= 0) {
                    return 'La cantidad debe ser un número mayor a 0';
                  }
                  if (tipoMovimiento == 'Egreso' && cantidad > inventario.cantidad) {
                    return 'No hay suficiente stock disponible';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: responsableController,
                decoration: const InputDecoration(
                  labelText: 'Responsable',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el responsable';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: motivoController,
                decoration: InputDecoration(
                  labelText: 'Motivo',
                  hintText: tipoMovimiento == 'Ingreso' ? 'Compra, devolución, etc.' : 'Mantenimiento, préstamo, etc.',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el motivo';
                  }
                  return null;
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
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final dataService = Provider.of<DataService>(context, listen: false);

                final movimiento = MovimientoInventario(
                  fecha: DateTime.now(),
                  tipo: tipoMovimiento,
                  cantidad: int.parse(cantidadController.text),
                  responsable: responsableController.text,
                  motivo: motivoController.text,
                );

                dataService.registrarMovimientoInventario(inventario.id!, movimiento);

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$tipoMovimiento registrado correctamente'),
                    backgroundColor: AppColors.success,
                  ),
                );

                // Actualizar la UI
                setState(() {});
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: tipoMovimiento == 'Ingreso' ? AppColors.success : AppColors.error,
            ),
            child: Text('Registrar $tipoMovimiento'),
          ),
        ],
      ),
    );
  }

  // Agregar esta función para eliminar un filtro completamente
  void _confirmarEliminarFiltroCompletamente(BuildContext context, Inventario inventario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Filtro Permanentemente'),
        content: Text(
            '¿Está seguro que desea eliminar permanentemente el filtro "${inventario.nombre}"? '
                'Esta acción no se puede deshacer y eliminará todos los datos asociados a este filtro.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final dataService = Provider.of<DataService>(context, listen: false);
              dataService.eliminarFiltroCompletamente(inventario.id!);

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filtro eliminado permanentemente'),
                  backgroundColor: AppColors.success,
                ),
              );

              // Actualizar la UI
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Eliminar Permanentemente'),
          ),
        ],
      ),
    );
  }

  // Modificar la función _showInventarioDetails para incluir la opción de eliminar permanentemente
  void _showInventarioDetails(BuildContext context, Inventario inventario) {
    final dataService = Provider.of<DataService>(context, listen: false);
    final equiposCompatibles = dataService.equipos
        .where((equipo) =>
        inventario.esCompatibleConEquipo(equipo.marca, equipo.modelo))
        .toList();

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
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
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
                    inventario.nombre,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (inventario.codigoIdentificacion != null)
                    Text(
                      'Código: ${inventario.codigoIdentificacion}',
                      style: TextStyle(
                        color: AppColors.mediumGray,
                      ),
                    ),
                  if (inventario.empresaSuplidora != null)
                    Text(
                      'Proveedor: ${inventario.empresaSuplidora}',
                      style: TextStyle(
                        color: AppColors.mediumGray,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildDetailChip('Tipo: ${inventario.tipo}', AppColors.primaryYellow),
                      const SizedBox(width: 8),
                      _buildDetailChip('Categoría: ${inventario.categoriaEquipo}', AppColors.secondaryYellow),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStockIndicator(inventario.cantidad),
                      const Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Ingreso'),
                        onPressed: () {
                          Navigator.pop(context);
                          _showMovimientoForm(context, inventario, 'Ingreso');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.remove_circle_outline),
                        label: const Text('Egreso'),
                        onPressed: () {
                          Navigator.pop(context);
                          _showMovimientoForm(context, inventario, 'Egreso');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sección de compatibilidad
                  const Text(
                    'Compatibilidad con Equipos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),

                  inventario.marcasCompatibles.isEmpty && inventario.modelosCompatibles.isEmpty
                      ? const Text('Compatible con todos los equipos')
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (inventario.marcasCompatibles.isNotEmpty) ...[
                        const Text('Marcas compatibles:'),
                        Wrap(
                          spacing: 8,
                          children: inventario.marcasCompatibles.map((marca) {
                            return Chip(
                              label: Text(marca),
                              backgroundColor: AppColors.primaryYellow.withAlpha(30),
                            );
                          }).toList(),
                        ),
                      ],
                      if (inventario.modelosCompatibles.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text('Modelos compatibles:'),
                        Wrap(
                          spacing: 8,
                          children: inventario.modelosCompatibles.map((modelo) {
                            return Chip(
                              label: Text(modelo),
                              backgroundColor: AppColors.secondaryYellow.withAlpha(30),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 8),
                      const Text('Equipos compatibles:'),
                      const SizedBox(height: 4),
                      equiposCompatibles.isEmpty
                          ? const Text('No hay equipos compatibles registrados')
                          : Column(
                        children: equiposCompatibles.map((equipo) {
                          return ListTile(
                            title: Text(equipo.nombre),
                            subtitle: Text('${equipo.marca} ${equipo.modelo}'),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.lightGray,
                              child: Text(
                                equipo.ficha.substring(equipo.ficha.length - 2),
                              ),
                            ),
                            dense: true,
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  const Divider(height: 32),
                  Text(
                    'Historial de Movimientos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  inventario.movimientos.isEmpty
                      ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No hay movimientos registrados'),
                    ),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: inventario.movimientos.length,
                    itemBuilder: (context, index) {
                      final movimiento = inventario.movimientos[inventario.movimientos.length - 1 - index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: movimiento.tipo == 'Ingreso'
                              ? AppColors.success
                              : AppColors.error,
                          child: Icon(
                            movimiento.tipo == 'Ingreso'
                                ? Icons.add
                                : Icons.remove,
                            color: Colors.white,
                          ),
                        ),
                        title: Text('${movimiento.tipo}: ${movimiento.cantidad}'),
                        subtitle: Text(
                          'Responsable: ${movimiento.responsable}\nMotivo: ${movimiento.motivo}',
                        ),
                        trailing: Text(
                          _formatDate(movimiento.fecha),
                          style: TextStyle(
                            color: AppColors.mediumGray,
                          ),
                        ),
                      );
                    },
                  ),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Eliminar Permanentemente'),
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmarEliminarFiltroCompletamente(context, inventario);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailChip(String text, Color color) {
    return Chip(
      label: Text(text),
      backgroundColor: color.withAlpha(30),
      labelStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStockIndicator(int cantidad) {
    final Color color = _getColorByStock(cantidad);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2_outlined, color: color),
          const SizedBox(width: 8),
          Text(
            'Stock: $cantidad',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
