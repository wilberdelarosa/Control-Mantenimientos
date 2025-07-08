class Equipo {
  int? id;
  String ficha;
  String nombre;
  String marca;
  String modelo;
  String numeroSerie;
  String placa;
  String categoria;
  bool activo;
  String? motivoInactividad;

  Equipo({
    this.id,
    required this.ficha,
    required this.nombre,
    required this.marca,
    required this.modelo,
    required this.numeroSerie,
    required this.placa,
    required this.categoria,
    this.activo = true,
    this.motivoInactividad,
  });

  factory Equipo.fromJson(Map<String, dynamic> json) {
    return Equipo(
      id: json['id'],
      ficha: json['ficha'],
      nombre: json['nombre'],
      marca: json['marca'],
      modelo: json['modelo'],
      numeroSerie: json['numeroSerie'],
      placa: json['placa'],
      categoria: json['categoria'],
      activo: json['activo'] ?? true,
      motivoInactividad: json['motivoInactividad'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ficha': ficha,
      'nombre': nombre,
      'marca': marca,
      'modelo': modelo,
      'numeroSerie': numeroSerie,
      'placa': placa,
      'categoria': categoria,
      'activo': activo,
      'motivoInactividad': motivoInactividad,
    };
  }

  static List<String> getCategorias() {
    return [
      'Minicargadores',
      'Retropalas',
      'Miniretro',
      'Rodillos',
      'Excavadora',
      'Telehandler',
      'Camiones',
      'Vehículo transporte',
      'Vehículo personal',
    ];
  }
}
