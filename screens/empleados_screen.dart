import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/empleado.dart';
import '../utils/app_theme.dart';

class EmpleadosScreen extends StatefulWidget {
  const EmpleadosScreen({Key? key}) : super(key: key);

  @override
  _EmpleadosScreenState createState() => _EmpleadosScreenState();
}

class _EmpleadosScreenState extends State<EmpleadosScreen> {
  String _searchQuery = '';
  String _selectedCategoria = 'Todos';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Empleados'),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: _buildEmpleadosList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEmpleadoForm(context),
        child: const Icon(Icons.add),
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
              hintText: 'Buscar por nombre o apellido...',
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
                ...Empleado.getCategorias().map((categoria) => _buildFilterChip(categoria)),
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
        backgroundColor: AppColors.lightGray.withOpacity(0.2),
        selectedColor: AppColors.primaryYellow,
      ),
    );
  }
  
  Widget _buildEmpleadosList() {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        // Filtrar empleados
        var empleadosFiltrados = dataService.empleados.where((empleado) => empleado.activo).toList();
        
        // Aplicar filtro de categoría
        if (_selectedCategoria != 'Todos') {
          empleadosFiltrados = empleadosFiltrados.where((empleado) => empleado.categoria == _selectedCategoria).toList();
        }
        
        // Aplicar búsqueda
        if (_searchQuery.isNotEmpty) {
          empleadosFiltrados = empleadosFiltrados.where((empleado) => 
            empleado.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            empleado.apellido.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
        }
        
        if (empleadosFiltrados.isEmpty) {
          return const Center(
            child: Text('No se encontraron empleados'),
          );
        }
        
        return ListView.builder(
          itemCount: empleadosFiltrados.length,
          itemBuilder: (context, index) {
            final empleado = empleadosFiltrados[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryYellow,
                  child: Text(
                    empleado.nombre.substring(0, 1) + empleado.apellido.substring(0, 1),
                    style: TextStyle(color: AppColors.darkGray),
                  ),
                ),
                title: Text(empleado.nombreCompleto),
                subtitle: Text('Categoría: ${empleado.categoria} | Cargo: ${empleado.cargo}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEmpleadoForm(context, empleado),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteConfirmation(context, empleado),
                    ),
                  ],
                ),
                onTap: () => _showEmpleadoDetails(context, empleado),
              ),
            );
          },
        );
      },
    );
  }
  
  void _showEmpleadoForm(BuildContext context, [Empleado? empleado]) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController nombreController = TextEditingController(text: empleado?.nombre ?? '');
    final TextEditingController apellidoController = TextEditingController(text: empleado?.apellido ?? '');
    final TextEditingController cargoController = TextEditingController(text: empleado?.cargo ?? '');
    
    String selectedCategoria = empleado?.categoria ?? Empleado.getCategorias().first;
    DateTime fechaNacimiento = empleado?.fechaNacimiento ?? DateTime(1990, 1, 1);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(empleado == null ? 'Agregar Empleado' : 'Editar Empleado'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: apellidoController,
                  decoration: const InputDecoration(
                    labelText: 'Apellido',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el apellido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategoria,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                  ),
                  items: Empleado.getCategorias().map((categoria) {
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
                TextFormField(
                  controller: cargoController,
                  decoration: const InputDecoration(
                    labelText: 'Cargo',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el cargo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Fecha de Nacimiento'),
                  subtitle: Text(
                    '${fechaNacimiento.day}/${fechaNacimiento.month}/${fechaNacimiento.year}',
                  ),
                  

                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final fecha = await showDatePicker(
                        context: context,
                        initialDate: fechaNacimiento,
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (fecha != null) {
                        fechaNacimiento = fecha;
                        setState(() {});
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
              if (formKey.currentState!.validate()) {
                final dataService = Provider.of<DataService>(context, listen: false);
                
                final newEmpleado = Empleado(
                  id: empleado?.id,
                  nombre: nombreController.text,
                  apellido: apellidoController.text,
                  categoria: selectedCategoria,
                  cargo: cargoController.text,
                  fechaNacimiento: fechaNacimiento,
                  activo: true,
                );
                
                if (empleado == null) {
                  dataService.agregarEmpleado(newEmpleado);
                } else {
                  dataService.actualizarEmpleado(newEmpleado);
                }
                
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(empleado == null ? 'Empleado agregado' : 'Empleado actualizado'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: Text(empleado == null ? 'Agregar' : 'Actualizar'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, Empleado empleado) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Empleado'),
        content: Text('¿Está seguro que desea eliminar a ${empleado.nombreCompleto}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final dataService = Provider.of<DataService>(context, listen: false);
              dataService.eliminarEmpleado(empleado.id!);
              
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Empleado eliminado'),
                  backgroundColor: AppColors.success,
                ),
              );
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
  
  void _showEmpleadoDetails(BuildContext context, Empleado empleado) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(empleado.nombreCompleto),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('Categoría', empleado.categoria),
            _buildDetailItem('Cargo', empleado.cargo),
            _buildDetailItem(
              'Fecha de Nacimiento',
              '${empleado.fechaNacimiento.day}/${empleado.fechaNacimiento.month}/${empleado.fechaNacimiento.year}',
            ),
            _buildDetailItem(
              'Edad',
              '${DateTime.now().year - empleado.fechaNacimiento.year} años',
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
              _showEmpleadoForm(context, empleado);
            },
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailItem(String label, String value) {
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
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
