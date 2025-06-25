class Pieza {
  int? id;
  String nombre;
  int? materialId;
  String? conexion;
  String? medidaNominal;
  String? tipoControl;
  String? uso;
  String? instalacion;
  String? dimensiones;
  String? tipoTermo;
  String? capacidad;
  String? alimentacion;
  String? potencia;
  String? caudal;
  int? tipoId;
  int usoTotal;
  int esPersonalizado;

  Pieza({
    this.id,
    required this.nombre,
    this.materialId,
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
    this.tipoId,
    this.usoTotal = 0,
    this.esPersonalizado = 0,
  });

  factory Pieza.fromMap(Map<String, dynamic> json) => Pieza(
    id: json['id'],
    nombre: json['nombre'],
    materialId: json['material_id'],
    conexion: json['conexion'],
    medidaNominal: json['medida_nominal'],
    tipoControl: json['tipo_control'],
    uso: json['uso'],
    instalacion: json['instalacion'],
    dimensiones: json['dimensiones'],
    tipoTermo: json['tipo_termo'],
    capacidad: json['capacidad'],
    alimentacion: json['alimentacion'],
    potencia: json['potencia'],
    caudal: json['caudal'],
    tipoId: json['tipo_id'],
    usoTotal: json['uso_total'] ?? 0,
    esPersonalizado: json['es_personalizado'] ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'material_id': materialId,
    'conexion': conexion,
    'medida_nominal': medidaNominal,
    'tipo_control': tipoControl,
    'uso': uso,
    'instalacion': instalacion,
    'dimensiones': dimensiones,
    'tipo_termo': tipoTermo,
    'capacidad': capacidad,
    'alimentacion': alimentacion,
    'potencia': potencia,
    'caudal': caudal,
    'tipo_id': tipoId,
    'uso_total': usoTotal,
    'es_personalizado': esPersonalizado,
  };
}
