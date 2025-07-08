class Tarea {
  final int? id;
  late final String? nombreCliente;
  late final String? direccion;
  late final String? telefono;
  final int? finalizada;
  int? scheduledAt;
  final String? notas;

  Tarea({
    this.id,
    this.nombreCliente,
    this.direccion,
    this.telefono,
    this.finalizada = 0,
    this.scheduledAt,
    this.notas,
  });

  factory Tarea.fromMap(Map<String, dynamic> map) => Tarea(
        id: map['id'],
        nombreCliente: map['nombre_cliente'],
        direccion: map['direccion'],
        telefono: map['telefono'],
        finalizada: map['finalizada'] ?? 0,
        scheduledAt: map['scheduledAt'] as int?,
        notas: map['notas'],
      );

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'id': id,
      'nombre_cliente': nombreCliente,
      'direccion': direccion,
      'telefono': telefono,
      'finalizada': finalizada,
      'notas': notas,
    };
    if (scheduledAt != null) {
      m['scheduledAt'] = scheduledAt; // la guardamos solo si no es null
    }
    return m;
  }
}
