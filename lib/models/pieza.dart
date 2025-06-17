class Pieza {
  final int id;
  final String nombre;
  final String? material;
  final String? conexion;
  final String? medidaNominal;
  final String? tipoControl;
  final String? uso;
  final String? instalacion;
  final String? dimensiones;
  final String? tipoTermo;
  final String? capacidad;
  final String? alimentacion;
  final String? potencia;
  final String? caudal;
  final int tipoId;

  Pieza({
    required this.id,
    required this.nombre,
    this.material,
    this.conexion,
    this.medidaNominal,
    this.tipoControl,
    this.uso,
    this.instalacion,
    this.dimensiones,
    this.tipoTermo,
    this.capacidad,
    this.alimentacion,
    this.potencia,
    this.caudal,
    required this.tipoId,
  });

  factory Pieza.fromMap(Map<String, dynamic> map) {
    return Pieza(
      id: map['id'],
      nombre: map['nombre'],
      material: map['material'],
      conexion: map['conexion'],
      medidaNominal: map['medida_nominal'],
      tipoControl: map['tipo_control'],
      uso: map['uso'],
      instalacion: map['instalacion'],
      dimensiones: map['dimensiones'],
      tipoTermo: map['tipo_termo'],
      capacidad: map['capacidad'],
      alimentacion: map['alimentacion'],
      potencia: map['potencia'],
      caudal: map['caudal'],
      tipoId: map['tipo_id'],
    );
  }
}
