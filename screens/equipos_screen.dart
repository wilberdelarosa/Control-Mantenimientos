import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/equipo.dart';
import '../utils/app_theme.dart';
import '../widgets/equipment_card.dart';

class EquiposScreen extends StatefulWidget {
  const EquiposScreen({Key? key}) : super(key: key);

  @override
  _EquiposScreenState createState() => _EquiposScreenState();
}

class _EquiposScreenState extends State<EquiposScreen> {
  String _searchQuery = '';
  String _selectedCategoria = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Equipos'),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: _buildEquiposList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEquipoForm(context),
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
      child: FilterChip(
        label: Text(categoria),
        selected: _selectedCategoria == categoria,
        onSelected: (selected) {
          setState(() {
            _selectedCategoria = selected ? categoria : 'Todos';
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
          padding: const EdgeInsets.all(16.0),
          itemCount: equiposFiltrados.length,
          itemBuilder: (context, index) {
            final equipo = equiposFiltrados[index];
            return EquipmentCard(
              equipment: equipo,
              onEdit: () => _showEquipoForm(context, equipo),
              onDelete: () => _showDeleteConfirmation(context, equipo),
            );
          },
        );
      },
    );
  }

  void _showEquipoForm(BuildContext context, [Equipo? equipo]) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController fichaController = TextEditingController(text: equipo?.ficha ?? 'AC-0');
    final TextEditingController nombreController = TextEditingController(text: equipo?.nombre ?? '');
    final TextEditingController marcaController = TextEditingController(text: equipo?.marca ?? '');
    final TextEditingController modeloController = TextEditingController(text: equipo?.modelo ?? '');
    final TextEditingController numeroSerieController = TextEditingController(text: equipo?.numeroSerie ?? '');
    final TextEditingController placaController = TextEditingController(text: equipo?.placa ?? '');

    String selectedCategoria = equipo?.categoria ?? Equipo.getCategorias().first;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(equipo == null ? 'Agregar Equipo' : 'Editar Equipo'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Campo de ficha con formato AC-0XXX
                TextFormField(
                  controller: fichaController,
                  decoration: const InputDecoration(
                    labelText: 'Ficha',
                    hintText: 'AC-0XXX',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese la ficha';
                    }
                    // Validar que solo contenga números después de AC-0
                    if (!RegExp(r'^AC-0\d+$').hasMatch(value)) {
                      return 'Formato inválido. Debe ser AC-0 seguido de números';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    // Asegurar que siempre tenga el prefijo AC-0
                    if (!value.startsWith('AC-0')) {
                      fichaController.text = 'AC-0${value.replaceAll('AC-0', '')}';
                      fichaController.selection = TextSelection.fromPosition(
                        TextPosition(offset: fichaController.text.length),
                      );
                    }
                  },
                  enabled: equipo == null, // Solo permitir editar la ficha si es un nuevo equipo
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Equipo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el nombre del equipo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategoria,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor seleccione una categoría';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: marcaController,
                  decoration: const InputDecoration(
                    labelText: 'Marca',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese la marca';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: modeloController,
                  decoration: const InputDecoration(
                    labelText: 'Modelo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el modelo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: numeroSerieController,
                  decoration: const InputDecoration(
                    labelText: 'Número de Serie',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el número de serie';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: placaController,
                  decoration: const InputDecoration(
                    labelText: 'Placa',
                    border: OutlineInputBorder(),
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

                final newEquipo = Equipo(
                  id: equipo?.id,
                  ficha: fichaController.text,
                  nombre: nombreController.text,
                  marca: marcaController.text,
                  modelo: modeloController.text,
                  numeroSerie: numeroSerieController.text,
                  placa: placaController.text,
                  categoria: selectedCategoria,
                  activo: true,
                );

                if (equipo == null) {
                  dataService.agregarEquipo(newEquipo);
                } else {
                  dataService.actualizarEquipo(newEquipo);
                }

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(equipo == null ? 'Equipo agregado' : 'Equipo actualizado'),
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
            child: Text(equipo == null ? 'Agregar' : 'Actualizar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Equipo equipo) {
    final TextEditingController motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Equipo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Está seguro que desea eliminar el equipo ${equipo.nombre}?'),
            const SizedBox(height: 16),
            const Text('Por favor, indique el motivo:'),
            const SizedBox(height: 8),
            TextField(
              controller: motivoController,
              decoration: const InputDecoration(
                hintText: 'Vendido, dañado, etc.',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (motivoController.text.isNotEmpty) {
                final dataService = Provider.of<DataService>(context, listen: false);
                dataService.eliminarEquipo(equipo.id!, motivoController.text);

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Equipo eliminado'),
                    backgroundColor: AppColors.success,
                  ),
                );

                // Actualizar la UI
                setState(() {});
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor, indique el motivo'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
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
}
