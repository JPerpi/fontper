class Tarea {
  final int? id;
  final String? nombreCliente;
  final String? direccion;
  final String? telefono;

  Tarea({
    this.id,
    this.nombreCliente,
    this.direccion,
    this.telefono,
  });

  factory Tarea.fromMap(Map<String, dynamic> map) {
    return Tarea(
      id: map['id'],
      nombreCliente: map['nombre_cliente'],
      direccion: map['direccion'],
      telefono: map['telefono'],
    );
  }
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'nombre_cliente': nombreCliente,
      'direccion': direccion,
      'telefono': telefono,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }
}
