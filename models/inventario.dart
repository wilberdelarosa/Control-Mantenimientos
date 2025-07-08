class Inventario {
  int? id;
  String nombre;
  String tipo; // Filtro, Aceite, Grasa, etc.
  String categoriaEquipo; // Categoría de equipo al que pertenece
  int cantidad;
  List<MovimientoInventario> movimientos;
  bool activo;
  // Nuevos campos
  String? codigoIdentificacion;
  String? empresaSuplidora;
  List<String> marcasCompatibles;
  List<String> modelosCompatibles;

  Inventario({
    this.id,
    required this.nombre,
    required this.tipo,
    required this.categoriaEquipo,
    required this.cantidad,
    List<MovimientoInventario>? movimientos,
    this.activo = true,
    this.codigoIdentificacion,
    this.empresaSuplidora,
    List<String>? marcasCompatibles,
    List<String>? modelosCompatibles,
  }) :
        this.movimientos = movimientos ?? [],
        this.marcasCompatibles = marcasCompatibles ?? [],
        this.modelosCompatibles = modelosCompatibles ?? [];

  factory Inventario.fromJson(Map<String, dynamic> json) {
    return Inventario(
      id: json['id'],
      nombre: json['nombre'],
      tipo: json['tipo'],
      categoriaEquipo: json['categoriaEquipo'],
      cantidad: json['cantidad'],
      movimientos: (json['movimientos'] as List?)
          ?.map((m) => MovimientoInventario.fromJson(m))
          .toList() ?? [],
      activo: json['activo'] ?? true,
      codigoIdentificacion: json['codigoIdentificacion'],
      empresaSuplidora: json['empresaSuplidora'],
      marcasCompatibles: (json['marcasCompatibles'] as List?)?.cast<String>() ?? [],
      modelosCompatibles: (json['modelosCompatibles'] as List?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo': tipo,
      'categoriaEquipo': categoriaEquipo,
      'cantidad': cantidad,
      'movimientos': movimientos.map((m) => m.toJson()).toList(),
      'activo': activo,
      'codigoIdentificacion': codigoIdentificacion,
      'empresaSuplidora': empresaSuplidora,
      'marcasCompatibles': marcasCompatibles,
      'modelosCompatibles': modelosCompatibles,
    };
  }

  // Verificar si el inventario es compatible con un equipo específico
  bool esCompatibleConEquipo(String marca, String modelo) {
    // Si no hay marcas o modelos especificados, es compatible con todos
    if (marcasCompatibles.isEmpty && modelosCompatibles.isEmpty) {
      return true;
    }

    // Verificar si la marca y modelo están en las listas de compatibilidad
    bool marcaCompatible = marcasCompatibles.isEmpty || marcasCompatibles.contains(marca);
    bool modeloCompatible = modelosCompatibles.isEmpty || modelosCompatibles.contains(modelo);

    return marcaCompatible && modeloCompatible;
  }

  static List<String> getTipos() {
    return [
      'Filtro de aceite',
      'Filtro de aire',
      'Filtro de aire complemento',
      'Filtro de cabina',
      'Filtro de gasoil',
      'Trampa de agua',
      'Aceite',
      'Grasa',
      'Repuesto',
      'Otro',
    ];
  }
}

class MovimientoInventario {
  DateTime fecha;
  String tipo; // Ingreso, Egreso
  int cantidad;
  String responsable;
  String motivo;

  MovimientoInventario({
    required this.fecha,
    required this.tipo,
    required this.cantidad,
    required this.responsable,
    required this.motivo,
  });

  factory MovimientoInventario.fromJson(Map<String, dynamic> json) {
    return MovimientoInventario(
      fecha: DateTime.parse(json['fecha']),
      tipo: json['tipo'],
      cantidad: json['cantidad'],
      responsable: json['responsable'],
      motivo: json['motivo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fecha': fecha.toIso8601String(),
      'tipo': tipo,
      'cantidad': cantidad,
      'responsable': responsable,
      'motivo': motivo,
    };
  }
}
