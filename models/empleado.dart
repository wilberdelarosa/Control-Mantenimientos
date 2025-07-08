class Empleado {
  int? id;
  String nombre;
  String apellido;
  String categoria; // Operador, Chófer, Supervisor, etc.
  String cargo;
  DateTime fechaNacimiento;
  bool activo;

  Empleado({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.categoria,
    required this.cargo,
    required this.fechaNacimiento,
    this.activo = true,
  });

  factory Empleado.fromJson(Map<String, dynamic> json) {
    return Empleado(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      categoria: json['categoria'],
      cargo: json['cargo'],
      fechaNacimiento: DateTime.parse(json['fechaNacimiento']),
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'categoria': categoria,
      'cargo': cargo,
      'fechaNacimiento': fechaNacimiento.toIso8601String(),
      'activo': activo,
    };
  }

  String get nombreCompleto => '$nombre $apellido';

  static List<String> getCategorias() {
    return [
      'Operador',
      'Chófer',
      'Supervisor',
      'Ayudante',
      'Oficina',
      'Gerente',
      'Otro',
    ];
  }
}
