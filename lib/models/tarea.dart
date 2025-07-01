class Tarea {
  final int? id;
  late final String? nombreCliente;
  late final String? direccion;
  late final String? telefono;
  final int? finalizada;

  Tarea({
    this.id,
    this.nombreCliente,
    this.direccion,
    this.telefono,
    this.finalizada = 0,
  });

  factory Tarea.fromMap(Map<String, dynamic> map) => Tarea(
        id: map['id'],
        nombreCliente: map['nombre_cliente'],
        direccion: map['direccion'],
        telefono: map['telefono'],
        finalizada: map['finalizada'] ?? 0,

  );

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre_cliente': nombreCliente,
        'direccion': direccion,
        'telefono': telefono,
        'finalizada': finalizada,

  };
}
