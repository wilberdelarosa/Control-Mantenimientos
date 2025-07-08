import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../models/equipo.dart';
import '../models/inventario.dart';
import '../utils/app_theme.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({Key? key}) : super(key: key);

  @override
  _CategoriasScreenState createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Categorías de Equipos'),
            Tab(text: 'Tipos de Inventario'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEquiposCategorias(),
          _buildInventarioTipos(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showCategoriaEquipoDialog(context);
          } else {
            _showTipoInventarioDialog(context);
          }
        },
        child: const Icon(Icons.add),
        backgroundColor: AppColors.primaryYellow,
        foregroundColor: AppColors.darkGray,
      ),
    );
  }

  Widget _buildEquiposCategorias() {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        final categorias = Equipo.getCategorias();

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: categorias.length,
          itemBuilder: (context, index) {
            final categoria = categorias[index];
            final equiposCount = dataService.equipos
                .where((e) => e.activo && e.categoria == categoria)
                .length;

            return Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                title: Text(categoria),
                subtitle: Text('$equiposCount equipos'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showCategoriaEquipoDialog(context, categoria),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: equiposCount > 0
                          ? null
                          : () => _showDeleteConfirmation(context, categoria, isEquipo: true),
                      tooltip: equiposCount > 0
                          ? 'No se puede eliminar: hay equipos en esta categoría'
                          : 'Eliminar categoría',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInventarioTipos() {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        final tipos = Inventario.getTipos();

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: tipos.length,
          itemBuilder: (context, index) {
            final tipo = tipos[index];
            final inventarioCount = dataService.inventarios
                .where((i) => i.activo && i.tipo == tipo)
                .length;

            return Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                title: Text(tipo),
                subtitle: Text('$inventarioCount productos'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showTipoInventarioDialog(context, tipo),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: inventarioCount > 0
                          ? null
                          : () => _showDeleteConfirmation(context, tipo, isEquipo: false),
                      tooltip: inventarioCount > 0
                          ? 'No se puede eliminar: hay productos de este tipo'
                          : 'Eliminar tipo',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCategoriaEquipoDialog(BuildContext context, [String? categoriaExistente]) {
    final TextEditingController controller = TextEditingController(text: categoriaExistente);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(categoriaExistente == null ? 'Nueva Categoría de Equipo' : 'Editar Categoría'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre de la categoría',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                // Aquí se implementaría la lógica para guardar la categoría
                // Por ahora solo mostramos un mensaje
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(categoriaExistente == null
                        ? 'Categoría ${controller.text} creada'
                        : 'Categoría actualizada a ${controller.text}'),
                    backgroundColor: AppColors.success,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: Text(categoriaExistente == null ? 'Crear' : 'Actualizar'),
          ),
        ],
      ),
    );
  }

  void _showTipoInventarioDialog(BuildContext context, [String? tipoExistente]) {
    final TextEditingController controller = TextEditingController(text: tipoExistente);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tipoExistente == null ? 'Nuevo Tipo de Inventario' : 'Editar Tipo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre del tipo',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                // Aquí se implementaría la lógica para guardar el tipo
                // Por ahora solo mostramos un mensaje
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tipoExistente == null
                        ? 'Tipo ${controller.text} creado'
                        : 'Tipo actualizado a ${controller.text}'),
                    backgroundColor: AppColors.success,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: Text(tipoExistente == null ? 'Crear' : 'Actualizar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String nombre, {required bool isEquipo}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar ${isEquipo ? 'Categoría' : 'Tipo'}'),
        content: Text('¿Está seguro que desea eliminar ${isEquipo ? 'la categoría' : 'el tipo'} "$nombre"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Aquí se implementaría la lógica para eliminar
              // Por ahora solo mostramos un mensaje
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${isEquipo ? 'Categoría' : 'Tipo'} "$nombre" eliminado'),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pop(context);
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
