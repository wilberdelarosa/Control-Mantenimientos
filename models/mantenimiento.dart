// Add this enum at the top of the file
enum MantenimientoStatus { Vencido, Proximo, AlDia, NoCalculado }

class MantenimientoProgramado {
  int? id;
  String ficha; // Referencia a Equipo
  String nombreEquipo; // Autocompletado
  String tipoMantenimiento; // Por horas o km
  double horasKmActuales;
  DateTime fechaUltimaActualizacion;
  double frecuencia; // Ej: 250 horas, 5000 km
  DateTime? fechaUltimoMantenimiento;
  double? horasKmUltimoMantenimiento; // Valor del horómetro en el último mantenimiento
  double? proximoMantenimiento; // Calculado
  double? horasKmRestante; // Calculado
  bool activo;

  MantenimientoProgramado({
    this.id,
    required this.ficha,
    required this.nombreEquipo,
    required this.tipoMantenimiento,
    required this.horasKmActuales,
    required this.fechaUltimaActualizacion,
    required this.frecuencia,
    this.fechaUltimoMantenimiento,
    this.horasKmUltimoMantenimiento,
    this.proximoMantenimiento,
    this.horasKmRestante,
    this.activo = true,
  }) {
    calcularProximoMantenimiento();
  }

  MantenimientoStatus get status {
    if (horasKmRestante == null) {
      return MantenimientoStatus.NoCalculado;
    }
    if (horasKmRestante! <= 0) {
      return MantenimientoStatus.Vencido;
    }
    if (tipoMantenimiento == 'Horas' && horasKmRestante! <= 50) {
      return MantenimientoStatus.Proximo;
    }
    if (tipoMantenimiento == 'Kilómetros' && horasKmRestante! <= 500) {
      return MantenimientoStatus.Proximo;
    }
    return MantenimientoStatus.AlDia;
  }

  bool get actualizadoRecientemente {
    return DateTime.now().difference(fechaUltimaActualizacion).inDays <= 7;
  }

  void calcularProximoMantenimiento() {
    if (frecuencia <= 0) {
      proximoMantenimiento = null;
      horasKmRestante = null;
      return;
    }

    if (horasKmUltimoMantenimiento != null) {
      // Si hay mantenimiento previo, el próximo será después de la frecuencia desde el último
      proximoMantenimiento = horasKmUltimoMantenimiento! + frecuencia;
    } else {
      // Si no hay mantenimiento previo, el próximo es el siguiente múltiplo de la frecuencia
      proximoMantenimiento = ((horasKmActuales / frecuencia).floor() + 1) * frecuencia;
    }
    horasKmRestante = proximoMantenimiento! - horasKmActuales;
  }

  // Actualizar solo las horas/km actuales (para actualizaciones semanales)
  void actualizarHorasKmActuales(double nuevasHorasKm, DateTime fecha) {
    horasKmActuales = nuevasHorasKm;
    fechaUltimaActualizacion = fecha;
    calcularProximoMantenimiento();
  }

  // Registrar un mantenimiento completo
  void registrarMantenimiento(DateTime fecha, double horasKmAlMomento) {
    fechaUltimoMantenimiento = fecha;
    horasKmUltimoMantenimiento = horasKmAlMomento;
    horasKmActuales = horasKmAlMomento; // Actualizar también las horas actuales
    fechaUltimaActualizacion = fecha;
    calcularProximoMantenimiento();
  }

  factory MantenimientoProgramado.fromJson(Map<String, dynamic> json) {
    return MantenimientoProgramado(
      id: json['id'],
      ficha: json['ficha'],
      nombreEquipo: json['nombreEquipo'],
      tipoMantenimiento: json['tipoMantenimiento'],
      horasKmActuales: json['horasKmActuales'].toDouble(),
      fechaUltimaActualizacion: DateTime.parse(json['fechaUltimaActualizacion']),
      frecuencia: json['frecuencia'].toDouble(),
      fechaUltimoMantenimiento: json['fechaUltimoMantenimiento'] != null
          ? DateTime.parse(json['fechaUltimoMantenimiento'])
          : null,
      horasKmUltimoMantenimiento: json['horasKmUltimoMantenimiento']?.toDouble(),
      proximoMantenimiento: json['proximoMantenimiento']?.toDouble(),
      horasKmRestante: json['horasKmRestante']?.toDouble(),
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ficha': ficha,
      'nombreEquipo': nombreEquipo,
      'tipoMantenimiento': tipoMantenimiento,
      'horasKmActuales': horasKmActuales,
      'fechaUltimaActualizacion': fechaUltimaActualizacion.toIso8601String(),
      'frecuencia': frecuencia,
      'fechaUltimoMantenimiento': fechaUltimoMantenimiento?.toIso8601String(),
      'horasKmUltimoMantenimiento': horasKmUltimoMantenimiento,
      'proximoMantenimiento': proximoMantenimiento,
      'horasKmRestante': horasKmRestante,
      'activo': activo,
    };
  }

  static List<String> getTiposMantenimiento() {
    return ['Horas', 'Kilómetros'];
  }
}

class MantenimientoRealizado {
  int? id;
  String ficha; // Referencia a Equipo
  DateTime fechaMantenimiento;
  double horasKmAlMomento;
  int idEmpleado; // Quien lo hizo o supervisó
  List<FiltroUtilizado> filtrosUtilizados;
  String observaciones;
  double? incrementoDesdeUltimo; // Horas/km desde el último mantenimiento

  MantenimientoRealizado({
    this.id,
    required this.ficha,
    required this.fechaMantenimiento,
    required this.horasKmAlMomento,
    required this.idEmpleado,
    required this.filtrosUtilizados,
    required this.observaciones,
    this.incrementoDesdeUltimo,
  });

  factory MantenimientoRealizado.fromJson(Map<String, dynamic> json) {
    return MantenimientoRealizado(
      id: json['id'],
      ficha: json['ficha'],
      fechaMantenimiento: DateTime.parse(json['fechaMantenimiento']),
      horasKmAlMomento: json['horasKmAlMomento'].toDouble(),
      idEmpleado: json['idEmpleado'],
      filtrosUtilizados: (json['filtrosUtilizados'] as List)
          .map((f) => FiltroUtilizado.fromJson(f))
          .toList(),
      observaciones: json['observaciones'],
      incrementoDesdeUltimo: json['incrementoDesdeUltimo']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ficha': ficha,
      'fechaMantenimiento': fechaMantenimiento.toIso8601String(),
      'horasKmAlMomento': horasKmAlMomento,
      'idEmpleado': idEmpleado,
      'filtrosUtilizados': filtrosUtilizados.map((f) => f.toJson()).toList(),
      'observaciones': observaciones,
      'incrementoDesdeUltimo': incrementoDesdeUltimo,
    };
  }
}

class ActualizacionHorasKm {
  int? id;
  String ficha;
  DateTime fecha;
  double horasKm;
  double? incremento; // Incremento desde la última actualización

  ActualizacionHorasKm({
    this.id,
    required this.ficha,
    required this.fecha,
    required this.horasKm,
    this.incremento,
  });

  factory ActualizacionHorasKm.fromJson(Map<String, dynamic> json) {
    return ActualizacionHorasKm(
      id: json['id'],
      ficha: json['ficha'],
      fecha: DateTime.parse(json['fecha']),
      horasKm: json['horasKm'].toDouble(),
      incremento: json['incremento']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ficha': ficha,
      'fecha': fecha.toIso8601String(),
      'horasKm': horasKm,
      'incremento': incremento,
    };
  }
}

class FiltroUtilizado {
  int idInventario;
  String nombre;
  int cantidad;

  FiltroUtilizado({
    required this.idInventario,
    required this.nombre,
    required this.cantidad,
  });

  factory FiltroUtilizado.fromJson(Map<String, dynamic> json) {
    return FiltroUtilizado(
      idInventario: json['idInventario'],
      nombre: json['nombre'],
      cantidad: json['cantidad'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idInventario': idInventario,
      'nombre': nombre,
      'cantidad': cantidad,
    };
  }
}
