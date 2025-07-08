import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/data_service.dart';
import '../../../models/equipo.dart';
import '../../../models/inventario.dart';
import '../../../utils/app_theme.dart';
import '../historial_avanzado_controller.dart';

class FilterDialog extends StatefulWidget {
  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HistorialAvanzadoController>(context, listen: false);
    
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        // Obtener listas para filtros
        final equipos = dataService.equipos.where((e) => e.activo).toList();
        final categorias = ['Todos', ...Equipo.getCategorias()];
        final empleados = dataService.empleados.where((e) => e.activo).toList();
        final tiposActividad = ['Todos', 'Mantenimiento', 'Actualización', 'Inventario'];
        final tiposInventario = ['Todos', ...Inventario.getTipos()];
        final categoriasEquipo = ['Todos', ...Equipo.getCategorias()];
        
        // Obtener marcas y modelos únicos
        final Set<String> todasLasMarcas = {'Todos'};
        final Set<String> todosLosModelos = {'Todos'};

        for (var equipo in equipos) {
          todasLasMarcas.add(equipo.marca);
          todosLosModelos.add(equipo.modelo);
        }

        return AlertDialog(
          title: const Text('Filtros Avanzados'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filtros Generales',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  value: controller.selectedFicha,
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
                      controller.setSelectedFicha(value);
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  value: controller.selectedCategoria,
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
                      controller.setSelectedCategoria(value);
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  value: controller.selectedMarca,
                  decoration: const InputDecoration(
                    labelText: 'Marca',
                    border: OutlineInputBorder(),
                  ),
                  items: todasLasMarcas.map((marca) {
                    return DropdownMenuItem<String?>(
                      value: marca == 'Todos' ? null : marca,
                      child: Text(marca),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      controller.setSelectedMarca(value);
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  value: controller.selectedModelo,
                  decoration: const InputDecoration(
                    labelText: 'Modelo',
                    border: OutlineInputBorder(),
                  ),
                  items: todosLosModelos.map((modelo) {
                    return DropdownMenuItem<String?>(
                      value: modelo == 'Todos' ? null : modelo,
                      child: Text(modelo),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      controller.setSelectedModelo(value);
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  value: controller.selectedEmpleado,
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
                      controller.setSelectedEmpleado(value);
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  value: controller.selectedTipoActividad,
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
                      controller.setSelectedTipoActividad(value);
                    });
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Filtros de Inventario',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  value: controller.selectedTipoInventario,
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
                      controller.setSelectedTipoInventario(value);
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  value: controller.selectedCategoriaEquipo,
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
                      controller.setSelectedCategoriaEquipo(value);
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
                controller.clearFilters();
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
                // Los filtros ya se actualizaron en el state
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
  }
}
