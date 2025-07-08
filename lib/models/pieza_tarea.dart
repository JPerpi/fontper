class PiezasTarea {
  final int? id;
  final int cantidad;
  final int tareaId;
  final int piezaId;
  final int cantidadEnviada;

  PiezasTarea({
    this.id,
    required this.cantidad,
    required this.tareaId,
    required this.piezaId,
    this.cantidadEnviada = 0,
  });

  factory PiezasTarea.fromMap(Map<String, dynamic> map) => PiezasTarea(
        id: map['id'],
        cantidad: map['cantidad'],
        tareaId: map['tareaId'],
        piezaId: map['piezaId'],
        cantidadEnviada: map['cantidadEnviada'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'cantidad': cantidad,
        'tareaId': tareaId,
        'piezaId': piezaId,
        'cantidadEnviada': cantidadEnviada,
      };
  PiezasTarea copyWith({
    int? id,
    int? cantidad,
    int? tareaId,
    int? piezaId,
    int? cantidadEnviada,
  }) {
    return PiezasTarea(
      id: id ?? this.id,
      cantidad: cantidad ?? this.cantidad,
      tareaId: tareaId ?? this.tareaId,
      piezaId: piezaId ?? this.piezaId,
      cantidadEnviada: cantidadEnviada ?? this.cantidadEnviada,
    );
  }
}
