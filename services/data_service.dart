import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/equipo.dart';
import '../models/inventario.dart';
import '../models/mantenimiento.dart';
import '../models/empleado.dart';

class DataService {
  // Singleton pattern
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  late SharedPreferences _prefs;

  // Listas de datos
  List<Equipo> equipos = [];
  List<Inventario> inventarios = [];
  List<MantenimientoProgramado> mantenimientosProgramados = [];
  List<MantenimientoRealizado> mantenimientosRealizados = [];
  List<ActualizacionHorasKm> actualizacionesHorasKm = [];
  List<Empleado> empleados = [];

  // Claves para SharedPreferences
  static const String _equiposKey = 'equipos';
  static const String _inventariosKey = 'inventarios';
  static const String _mantenimientosProgramadosKey = 'mantenimientosProgramados';
  static const String _mantenimientosRealizadosKey = 'mantenimientosRealizados';
  static const String _actualizacionesHorasKmKey = 'actualizacionesHorasKm';
  static const String _empleadosKey = 'empleados';

  // Inicializar el servicio
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _cargarDatos();

    // Si no hay datos, cargar datos de ejemplo
    if (equipos.isEmpty) {
      await _cargarDatosEjemplo();
    }
  }

  // Cargar datos desde SharedPreferences
  Future<void> _cargarDatos() async {
    final equiposJson = _prefs.getString(_equiposKey);
    if (equiposJson != null) {
      final List<dynamic> decodedEquipos = jsonDecode(equiposJson);
      equipos = decodedEquipos.map((e) => Equipo.fromJson(e)).toList();
    }

    final inventariosJson = _prefs.getString(_inventariosKey);
    if (inventariosJson != null) {
      final List<dynamic> decodedInventarios = jsonDecode(inventariosJson);
      inventarios = decodedInventarios.map((e) => Inventario.fromJson(e)).toList();
    }

    final mantenimientosProgramadosJson = _prefs.getString(_mantenimientosProgramadosKey);
    if (mantenimientosProgramadosJson != null) {
      final List<dynamic> decodedMantenimientosProgramados = jsonDecode(mantenimientosProgramadosJson);
      mantenimientosProgramados = decodedMantenimientosProgramados.map((e) => MantenimientoProgramado.fromJson(e)).toList();
    }

    final mantenimientosRealizadosJson = _prefs.getString(_mantenimientosRealizadosKey);
    if (mantenimientosRealizadosJson != null) {
      final List<dynamic> decodedMantenimientosRealizados = jsonDecode(mantenimientosRealizadosJson);
      mantenimientosRealizados = decodedMantenimientosRealizados.map((e) => MantenimientoRealizado.fromJson(e)).toList();
    }

    final actualizacionesHorasKmJson = _prefs.getString(_actualizacionesHorasKmKey);
    if (actualizacionesHorasKmJson != null) {
      final List<dynamic> decodedActualizaciones = jsonDecode(actualizacionesHorasKmJson);
      actualizacionesHorasKm = decodedActualizaciones.map((e) => ActualizacionHorasKm.fromJson(e)).toList();
    }

    final empleadosJson = _prefs.getString(_empleadosKey);
    if (empleadosJson != null) {
      final List<dynamic> decodedEmpleados = jsonDecode(empleadosJson);
      empleados = decodedEmpleados.map((e) => Empleado.fromJson(e)).toList();
    }
  }

  // Guardar datos en SharedPreferences
  Future<void> guardarDatos() async {
    await _prefs.setString(_equiposKey, jsonEncode(equipos.map((e) => e.toJson()).toList()));
    await _prefs.setString(_inventariosKey, jsonEncode(inventarios.map((e) => e.toJson()).toList()));
    await _prefs.setString(_mantenimientosProgramadosKey, jsonEncode(mantenimientosProgramados.map((e) => e.toJson()).toList()));
    await _prefs.setString(_mantenimientosRealizadosKey, jsonEncode(mantenimientosRealizados.map((e) => e.toJson()).toList()));
    await _prefs.setString(_actualizacionesHorasKmKey, jsonEncode(actualizacionesHorasKm.map((e) => e.toJson()).toList()));
    await _prefs.setString(_empleadosKey, jsonEncode(empleados.map((e) => e.toJson()).toList()));
  }

  // Cargar datos de ejemplo
  Future<void> _cargarDatosEjemplo() async {
    // Agregar algunos equipos de ejemplo
    equipos = [
      Equipo(
        id: 1,
        ficha: 'AC-001',
        nombre: 'HILUX 2021',
        marca: 'TOYOTA',
        modelo: '2021',
        numeroSerie: '123456789',
        placa: 'ABC-123',
        categoria: 'Vehículo transporte',
      ),
      Equipo(
        id: 2,
        ficha: 'AC-002',
        nombre: 'EXCAVADORA CAT 320',
        marca: 'CATERPILLAR',
        modelo: '320',
        numeroSerie: '987654321',
        placa: 'XYZ-789',
        categoria: 'Excavadora',
      ),
    ];

    /* Agregar algunos inventarios de ejemplo
    inventarios = [
      Inventario(
        id: 1,
        nombre: 'Filtro de aceite para TOYOTA',
        tipo: 'Filtro de aceite',
        categoriaEquipo: 'Vehículo transporte',
        cantidad: 5,
        movimientos: [
          MovimientoInventario(
            fecha: DateTime.now().subtract(Duration(days: 30)),
            tipo: 'Ingreso',
            cantidad: 10,
            responsable: 'Admin',
            motivo: 'Compra inicial',
          ),
          MovimientoInventario(
            fecha: DateTime.now().subtract(Duration(days: 15)),
            tipo: 'Egreso',
            cantidad: 5,
            responsable: 'Mecánico',
            motivo: 'Mantenimiento',
          ),
        ],
      ),
      Inventario(
        id: 2,
        nombre: 'Filtro de aire para CAT',
        tipo: 'Filtro de aire',
        categoriaEquipo: 'Excavadora',
        cantidad: 3,
        movimientos: [
          MovimientoInventario(
            fecha: DateTime.now().subtract(Duration(days: 20)),
            tipo: 'Ingreso',
            cantidad: 5,
            responsable: 'Admin',
            motivo: 'Compra inicial',
          ),
          MovimientoInventario(
            fecha: DateTime.now().subtract(Duration(days: 10)),
            tipo: 'Egreso',
            cantidad: 2,
            responsable: 'Mecánico',
            motivo: 'Mantenimiento',
          ),
        ],
      ),
    ];

    // Agregar algunos empleados de ejemplo
    empleados = [
      Empleado(
        id: 1,
        nombre: 'Juan',
        apellido: 'Pérez',
        categoria: 'Operador',
        cargo: 'Operador de Excavadora',
        fechaNacimiento: DateTime(1985, 5, 15),
      ),
      Empleado(
        id: 2,
        nombre: 'María',
        apellido: 'González',
        categoria: 'Supervisor',
        cargo: 'Supervisor de Mantenimiento',
        fechaNacimiento: DateTime(1980, 10, 20),
      ),
    ];

    // Fechas para ejemplos
    final fechaHoy = DateTime.now();
    final fechaUltimaActualizacion = DateTime(fechaHoy.year, fechaHoy.month, fechaHoy.day - (fechaHoy.weekday - 1)); // Último lunes
    final fechaUltimoMantenimiento = fechaUltimaActualizacion.subtract(Duration(days: 30));

    // Agregar algunas actualizaciones de horas/km
    actualizacionesHorasKm = [
      ActualizacionHorasKm(
        id: 1,
        ficha: 'AC-001',
        fecha: fechaUltimaActualizacion.subtract(Duration(days: 7)), // Lunes anterior
        horasKm: 4800,
        incremento: 100,
      ),
      ActualizacionHorasKm(
        id: 2,
        ficha: 'AC-001',
        fecha: fechaUltimaActualizacion,
        horasKm: 5000,
        incremento: 200,
      ),
      ActualizacionHorasKm(
        id: 3,
        ficha: 'AC-002',
        fecha: fechaUltimaActualizacion.subtract(Duration(days: 7)),
        horasKm: 180,
        incremento: 10,
      ),
      ActualizacionHorasKm(
        id: 4,
        ficha: 'AC-002',
        fecha: fechaUltimaActualizacion,
        horasKm: 200,
        incremento: 20,
      ),
    ];

    // Agregar algunos mantenimientos programados de ejemplo
    mantenimientosProgramados = [
      MantenimientoProgramado(
        id: 1,
        ficha: 'AC-001',
        nombreEquipo: 'HILUX 2021',
        tipoMantenimiento: 'Kilómetros',
        horasKmActuales: 5000,
        fechaUltimaActualizacion: fechaUltimaActualizacion,
        frecuencia: 5000,
        fechaUltimoMantenimiento: fechaUltimoMantenimiento,
        horasKmUltimoMantenimiento: 0,
      ),
      MantenimientoProgramado(
        id: 2,
        ficha: 'AC-002',
        nombreEquipo: 'EXCAVADORA CAT 320',
        tipoMantenimiento: 'Horas',
        horasKmActuales: 200,
        fechaUltimaActualizacion: fechaUltimaActualizacion,
        frecuencia: 250,
        fechaUltimoMantenimiento: fechaUltimoMantenimiento,
        horasKmUltimoMantenimiento: 0,
      ),
    ];

    // Agregar algunos mantenimientos realizados de ejemplo
    mantenimientosRealizados = [
      MantenimientoRealizado(
        id: 1,
        ficha: 'AC-001',
        fechaMantenimiento: fechaUltimoMantenimiento,
        horasKmAlMomento: 0,
        idEmpleado: 2,
        filtrosUtilizados: [
          FiltroUtilizado(
            idInventario: 1,
            nombre: 'Filtro de aceite para TOYOTA',
            cantidad: 1,
          ),
        ],
        observaciones: 'Mantenimiento preventivo inicial',
        incrementoDesdeUltimo: 0,
      ),
    ];
*/
    await guardarDatos();
  }

  // Métodos para obtener datos
  Future<List<Equipo>> obtenerEquipos() async {
    return equipos;
  }

  Future<List<Empleado>> obtenerEmpleados() async {
    return empleados;
  }

  Future<List<Inventario>> obtenerInventarios() async {
    return inventarios;
  }

  Future<List<MantenimientoProgramado>> obtenerMantenimientosProgramados() async {
    return mantenimientosProgramados;
  }

  Future<List<MantenimientoRealizado>> obtenerMantenimientosRealizados() async {
    return mantenimientosRealizados;
  }

  Future<List<ActualizacionHorasKm>> obtenerActualizacionesHorasKm() async {
    return actualizacionesHorasKm;
  }

  // Métodos para guardar datos
  Future<void> guardarEquipo(Equipo equipo) async {
    final index = equipos.indexWhere((e) => e.id == equipo.id);
    if (index != -1) {
      equipos[index] = equipo;
    } else {
      equipos.add(equipo);
    }
    await guardarDatos();
  }

  Future<void> guardarEmpleado(Empleado empleado) async {
    final index = empleados.indexWhere((e) => e.id == empleado.id);
    if (index != -1) {
      empleados[index] = empleado;
    } else {
      empleados.add(empleado);
    }
    await guardarDatos();
  }

  Future<void> guardarInventario(Inventario inventario) async {
    final index = inventarios.indexWhere((e) => e.id == inventario.id);
    if (index != -1) {
      inventarios[index] = inventario;
    } else {
      inventarios.add(inventario);
    }
    await guardarDatos();
  }

  Future<void> guardarMantenimientoProgramado(MantenimientoProgramado mantenimiento) async {
    final index = mantenimientosProgramados.indexWhere((e) => e.id == mantenimiento.id);
    if (index != -1) {
      mantenimientosProgramados[index] = mantenimiento;
    } else {
      mantenimientosProgramados.add(mantenimiento);
    }
    await guardarDatos();
  }

  Future<void> guardarMantenimientoRealizado(MantenimientoRealizado mantenimiento) async {
    final index = mantenimientosRealizados.indexWhere((e) => e.id == mantenimiento.id);
    if (index != -1) {
      mantenimientosRealizados[index] = mantenimiento;
    } else {
      mantenimientosRealizados.add(mantenimiento);
    }
    await guardarDatos();
  }

  Future<void> guardarActualizacionHorasKm(ActualizacionHorasKm actualizacion) async {
    final index = actualizacionesHorasKm.indexWhere((e) => e.id == actualizacion.id);
    if (index != -1) {
      actualizacionesHorasKm[index] = actualizacion;
    } else {
      actualizacionesHorasKm.add(actualizacion);
    }
    await guardarDatos();
  }

  // CRUD para Equipos
  Future<void> agregarEquipo(Equipo equipo) async {
    if (equipo.id == null) {
      equipo.id = equipos.isEmpty ? 1 : (equipos.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
    }
    equipos.add(equipo); // Agregar al final
    await guardarDatos();
  }

  Future<void> actualizarEquipo(Equipo equipo) async {
    final index = equipos.indexWhere((e) => e.id == equipo.id);
    if (index != -1) {
      equipos[index] = equipo;
      await guardarDatos();
    }
  }

  Future<void> eliminarEquipo(int id, String motivo) async {
    final index = equipos.indexWhere((e) => e.id == id);
    if (index != -1) {
      equipos[index].activo = false;
      equipos[index].motivoInactividad = motivo;
      await guardarDatos();
    }
  }

  Equipo? obtenerEquipoPorFicha(String ficha) {
    try {
      return equipos.firstWhere((e) => e.ficha == ficha && e.activo);
    } catch (e) {
      return null;
    }
  }

  List<Equipo> obtenerEquiposPorCategoria(String categoria) {
    return equipos.where((e) => e.categoria == categoria && e.activo).toList();
  }

  List<Equipo> obtenerEquiposOrdenados() {
    final equiposActivos = equipos.where((e) => e.activo == true).toList();
    equiposActivos.sort((a, b) {
      // Extraer el número de la ficha (formato AC-0XXX)
      final numA = int.tryParse(a.ficha.replaceAll('AC-0', '')) ?? 0;
      final numB = int.tryParse(b.ficha.replaceAll('AC-0', '')) ?? 0;
      return numA.compareTo(numB);
    });
    return equiposActivos;
  }

  // CRUD para Inventario
  Future<void> agregarInventario(Inventario inventario) async {
    if (inventario.id == null) {
      inventario.id = inventarios.isEmpty ? 1 : (inventarios.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
    }
    inventarios.insert(0, inventario); // Agregar al principio
    await guardarDatos();
  }

  Future<void> actualizarInventario(Inventario inventario) async {
    final index = inventarios.indexWhere((e) => e.id == inventario.id);
    if (index != -1) {
      inventarios[index] = inventario;
      await guardarDatos();
    }
  }

  Future<void> eliminarInventario(int id) async {
    final index = inventarios.indexWhere((e) => e.id == id);
    if (index != -1) {
      inventarios[index].activo = false;
      await guardarDatos();
    }
  }

  // Eliminar un filtro completamente (no solo marcarlo como inactivo)
  Future<void> eliminarFiltroCompletamente(int id) async {
    final index = inventarios.indexWhere((e) => e.id == id);
    if (index != -1) {
      inventarios.removeAt(index);
      await guardarDatos();
    }
  }

  // Eliminar todos los filtros
  Future<void> eliminarTodosFiltros() async {
    // Filtrar los inventarios que son filtros
    final filtros = inventarios.where((i) =>
        i.tipo.toLowerCase().contains('filtro')).toList();

    // Eliminar cada filtro
    for (var filtro in filtros) {
      if (filtro.id != null) {
        await eliminarFiltroCompletamente(filtro.id!);
      }
    }
  }

  // Eliminar historial de filtros (mantener los filtros pero eliminar sus movimientos)
  Future<void> eliminarHistorialFiltros() async {
    for (var inventario in inventarios) {
      if (inventario.tipo.toLowerCase().contains('filtro')) {
        inventario.movimientos.clear();
      }
    }
    await guardarDatos();
  }

  Future<void> registrarMovimientoInventario(int idInventario, MovimientoInventario movimiento) async {
    final index = inventarios.indexWhere((e) => e.id == idInventario);
    if (index != -1) {
      // Agregar al principio de la lista de movimientos
      inventarios[index].movimientos.insert(0, movimiento);

      // Actualizar cantidad
      if (movimiento.tipo == 'Ingreso') {
        inventarios[index].cantidad += movimiento.cantidad;
      } else if (movimiento.tipo == 'Egreso') {
        inventarios[index].cantidad -= movimiento.cantidad;
      }

      await guardarDatos();
    }
  }

  List<Inventario> obtenerInventariosPorCategoria(String categoriaEquipo) {
    return inventarios.where((e) => e.categoriaEquipo == categoriaEquipo && e.activo).toList();
  }

  // CRUD para Mantenimientos Programados
  Future<void> agregarMantenimientoProgramado(MantenimientoProgramado mantenimiento) async {
    if (mantenimiento.id == null) {
      mantenimiento.id = mantenimientosProgramados.isEmpty ? 1 : (mantenimientosProgramados.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
    }
    mantenimientosProgramados.add(mantenimiento);
    await guardarDatos();
  }

  Future<void> actualizarMantenimientoProgramado(MantenimientoProgramado mantenimiento) async {
    final index = mantenimientosProgramados.indexWhere((e) => e.id == mantenimiento.id);
    if (index != -1) {
      mantenimientosProgramados[index] = mantenimiento;
      await guardarDatos();
    }
  }

  Future<void> eliminarMantenimientoProgramado(int id) async {
    final index = mantenimientosProgramados.indexWhere((e) => e.id == id);
    if (index != -1) {
      mantenimientosProgramados[index].activo = false;
      await guardarDatos();
    }
  }

  MantenimientoProgramado? obtenerMantenimientoProgramadoPorFicha(String ficha) {
    try {
      return mantenimientosProgramados.firstWhere((e) => e.ficha == ficha && e.activo);
    } catch (e) {
      return null;
    }
  }

  List<MantenimientoProgramado> obtenerMantenimientosProgramadosOrdenados() {
    final mantenimientosActivos = mantenimientosProgramados.where((m) => m.activo == true).toList();
    mantenimientosActivos.sort((a, b) {
      // Extraer el número de la ficha (formato AC-0XXX)
      final numA = int.tryParse(a.ficha.replaceAll('AC-0', '')) ?? 0;
      final numB = int.tryParse(b.ficha.replaceAll('AC-0', '')) ?? 0;
      return numA.compareTo(numB);
    });
    return mantenimientosActivos;
  }

  // Actualización semanal de horas/km (para los lunes)
  Future<void> actualizarHorasKmSemanal(String ficha, double nuevasHorasKm, DateTime fecha) async {
    // Buscar el mantenimiento programado
    final mantenimiento = obtenerMantenimientoProgramadoPorFicha(ficha);
    if (mantenimiento != null) {
      // Calcular incremento desde la última actualización
      final incremento = nuevasHorasKm - mantenimiento.horasKmActuales;

      // Actualizar el mantenimiento programado
      mantenimiento.actualizarHorasKmActuales(nuevasHorasKm, fecha);
      await actualizarMantenimientoProgramado(mantenimiento);

      // Registrar la actualización en el historial
      final nuevaActualizacion = ActualizacionHorasKm(
        ficha: ficha,
        fecha: fecha,
        horasKm: nuevasHorasKm,
        incremento: incremento,
      );

      // Asignar ID a la nueva actualización
      nuevaActualizacion.id = actualizacionesHorasKm.isEmpty
          ? 1
          : (actualizacionesHorasKm.map((a) => a.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);

      actualizacionesHorasKm.insert(0, nuevaActualizacion); // Agregar al principio
      await guardarDatos();
    }
  }

  // Obtener historial de actualizaciones de horas/km para un equipo
  List<ActualizacionHorasKm> obtenerHistorialActualizacionesPorFicha(String ficha) {
    return actualizacionesHorasKm
        .where((a) => a.ficha == ficha)
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha)); // Ordenar por fecha descendente
  }

  // CRUD para Mantenimientos Realizados
  Future<void> agregarMantenimientoRealizado(MantenimientoRealizado mantenimiento) async {
    if (mantenimiento.id == null) {
      mantenimiento.id = mantenimientosRealizados.isEmpty
          ? 1
          : (mantenimientosRealizados.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
    }

    // Calcular incremento desde el último mantenimiento
    final ultimoMantenimiento = obtenerUltimoMantenimientoRealizadoPorFicha(mantenimiento.ficha);
    if (ultimoMantenimiento != null) {
      mantenimiento.incrementoDesdeUltimo = mantenimiento.horasKmAlMomento - ultimoMantenimiento.horasKmAlMomento;
    } else {
      mantenimiento.incrementoDesdeUltimo = mantenimiento.horasKmAlMomento;
    }

    mantenimientosRealizados.insert(0, mantenimiento); // Agregar al principio

    // Actualizar el mantenimiento programado correspondiente
    final mantenimientoProgramado = obtenerMantenimientoProgramadoPorFicha(mantenimiento.ficha);
    if (mantenimientoProgramado != null) {
      mantenimientoProgramado.registrarMantenimiento(mantenimiento.fechaMantenimiento, mantenimiento.horasKmAlMomento);
      await actualizarMantenimientoProgramado(mantenimientoProgramado);
    }

    // Descontar los filtros utilizados del inventario
    for (var filtro in mantenimiento.filtrosUtilizados) {
      await registrarMovimientoInventario(
        filtro.idInventario,
        MovimientoInventario(
          fecha: mantenimiento.fechaMantenimiento,
          tipo: 'Egreso',
          cantidad: filtro.cantidad,
          responsable: 'Mantenimiento',
          motivo: 'Mantenimiento de ${mantenimiento.ficha}',
        ),
      );
    }

    await guardarDatos();
  }

  MantenimientoRealizado? obtenerUltimoMantenimientoRealizadoPorFicha(String ficha) {
    final mantenimientos = obtenerMantenimientosRealizadosPorFicha(ficha);
    if (mantenimientos.isNotEmpty) {
      return mantenimientos.first; // Ya está ordenado por fecha descendente
    }
    return null;
  }

  List<MantenimientoRealizado> obtenerMantenimientosRealizadosPorFicha(String ficha) {
    return mantenimientosRealizados
        .where((e) => e.ficha == ficha)
        .toList()
      ..sort((a, b) => b.fechaMantenimiento.compareTo(a.fechaMantenimiento)); // Ordenar por fecha descendente
  }

  // CRUD para Empleados
  Future<void> agregarEmpleado(Empleado empleado) async {
    if (empleado.id == null) {
      empleado.id = empleados.isEmpty ? 1 : (empleados.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
    }
    empleados.insert(0, empleado); // Agregar al principio
    await guardarDatos();
  }

  Future<void> actualizarEmpleado(Empleado empleado) async {
    final index = empleados.indexWhere((e) => e.id == empleado.id);
    if (index != -1) {
      empleados[index] = empleado;
      await guardarDatos();
    }
  }

  Future<void> eliminarEmpleado(int id) async {
    final index = empleados.indexWhere((e) => e.id == id);
    if (index != -1) {
      empleados[index].activo = false;
      await guardarDatos();
    }
  }

  Empleado? obtenerEmpleadoPorId(int id) {
    try {
      return empleados.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Empleado> obtenerEmpleadosPorCategoria(String categoria) {
    return empleados.where((e) => e.categoria == categoria && e.activo).toList();
  }

  // Métodos para reportes y estadísticas

  // Obtener equipos que necesitan mantenimiento pronto
  List<MantenimientoProgramado> obtenerEquiposCercanosAMantenimiento() {
    return mantenimientosProgramados
        .where((m) => m.activo && m.horasKmRestante != null && m.horasKmRestante! > 0)
        .where((m) => m.tipoMantenimiento == 'Horas'
        ? m.horasKmRestante! <= 50
        : m.horasKmRestante! <= 500)
        .toList();
  }

  // Obtener equipos con mantenimiento vencido
  List<MantenimientoProgramado> obtenerEquiposConMantenimientoVencido() {
    return mantenimientosProgramados
        .where((m) => m.activo && m.horasKmRestante != null && m.horasKmRestante! <= 0)
        .toList();
  }

  // Obtener promedio de horas/km entre mantenimientos para un equipo
  double? obtenerPromedioIncrementoEntreMantenimientos(String ficha) {
    final mantenimientos = obtenerMantenimientosRealizadosPorFicha(ficha);
    if (mantenimientos.length < 2) return null;

    double sumaIncrementos = 0;
    int contador = 0;

    for (var i = 0; i < mantenimientos.length - 1; i++) {
      if (mantenimientos[i].incrementoDesdeUltimo != null) {
        sumaIncrementos += mantenimientos[i].incrementoDesdeUltimo!;
        contador++;
      }
    }

    return contador > 0 ? sumaIncrementos / contador : null;
  }

  // Obtener promedio de incremento semanal para un equipo
  double? obtenerPromedioIncrementoSemanal(String ficha) {
    final actualizaciones = obtenerHistorialActualizacionesPorFicha(ficha);
    if (actualizaciones.length < 2) return null;

    double sumaIncrementos = 0;
    int contador = 0;

    for (var actualizacion in actualizaciones) {
      if (actualizacion.incremento != null) {
        sumaIncrementos += actualizacion.incremento!;
        contador++;
      }
    }

    return contador > 0 ? sumaIncrementos / contador : null;
  }

  // Formatear fecha
  String formatearFecha(DateTime fecha) {
    return DateFormat('dd/MM/yyyy').format(fecha);
  }

  // Exportar todos los datos a JSON
  Future<Map<String, dynamic>> exportarTodosLosDatos() async {
    final datos = {
      'equipos': equipos.map((e) => e.toJson()).toList(),
      'inventarios': inventarios.map((e) => e.toJson()).toList(),
      'mantenimientosProgramados': mantenimientosProgramados.map((e) => e.toJson()).toList(),
      'mantenimientosRealizados': mantenimientosRealizados.map((e) => e.toJson()).toList(),
      'actualizacionesHorasKm': actualizacionesHorasKm.map((e) => e.toJson()).toList(),
      'empleados': empleados.map((e) => e.toJson()).toList(),
    };

    return datos;
  }

  // Importar datos desde JSON
  Future<void> importarDatosDesdeJSON(Map<String, dynamic> datos) async {
    try {
      // Importar equipos
      if (datos.containsKey('equipos')) {
        final List<dynamic> equiposData = datos['equipos'];
        equipos = equiposData.map((e) => Equipo.fromJson(e)).toList();
      }

      // Importar inventarios
      if (datos.containsKey('inventarios')) {
        final List<dynamic> inventariosData = datos['inventarios'];
        inventarios = inventariosData.map((e) => Inventario.fromJson(e)).toList();
      }

      // Importar mantenimientos programados
      if (datos.containsKey('mantenimientosProgramados')) {
        final List<dynamic> mantenimientosData = datos['mantenimientosProgramados'];
        mantenimientosProgramados = mantenimientosData.map((e) => MantenimientoProgramado.fromJson(e)).toList();
      }

      // Importar mantenimientos realizados
      if (datos.containsKey('mantenimientosRealizados')) {
        final List<dynamic> mantenimientosData = datos['mantenimientosRealizados'];
        mantenimientosRealizados = mantenimientosData.map((e) => MantenimientoRealizado.fromJson(e)).toList();
      }

      // Importar actualizaciones de horas/km
      if (datos.containsKey('actualizacionesHorasKm')) {
        final List<dynamic> actualizacionesData = datos['actualizacionesHorasKm'];
        actualizacionesHorasKm = actualizacionesData.map((e) => ActualizacionHorasKm.fromJson(e)).toList();
      }

      // Importar empleados
      if (datos.containsKey('empleados')) {
        final List<dynamic> empleadosData = datos['empleados'];
        empleados = empleadosData.map((e) => Empleado.fromJson(e)).toList();
      }

      // Guardar los datos importados
      await guardarDatos();
    } catch (e) {
      print('Error al importar datos: $e');
      throw e;
    }
  }

  // Eliminar datos específicos (mantenimientos realizados y actualizaciones)
  Future<void> eliminarDatosHistoricos() async {
    // Mantener los mantenimientos programados pero actualizar sus valores
    for (var mantenimiento in mantenimientosProgramados) {
      mantenimiento.fechaUltimoMantenimiento = null;
      mantenimiento.horasKmUltimoMantenimiento = null;
      mantenimiento.calcularProximoMantenimiento();
    }

    // Limpiar mantenimientos realizados y actualizaciones
    mantenimientosRealizados.clear();
    actualizacionesHorasKm.clear();

    // Guardar los cambios
    await guardarDatos();
  }
}
