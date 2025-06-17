class Tarea {
  final int id;
  final String? nombreCliente;
  final String? direccion;
  final String? telefono;

  Tarea({
    required this.id,
    this.nombreCliente,
    this.direccion,
    this.telefono,
});

  factory Tarea.fromMap(Map<String, dynamic>map) {
    return Tarea(
      id: map['id'],
      nombreCliente: map['nombre_cliente'],
      direccion: map['direccion'],
      telefono: map['telefono'],
    );
  }
}