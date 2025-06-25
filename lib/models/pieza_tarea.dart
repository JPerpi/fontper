class PiezasTarea {
  final int? id;
  final int cantidad;
  final int tareaId;
  final int piezaId;

  PiezasTarea({
    this.id,
    required this.cantidad,
    required this.tareaId,
    required this.piezaId,
  });

  factory PiezasTarea.fromMap(Map<String, dynamic> map) => PiezasTarea(
        id: map['id'],
        cantidad: map['cantidad'],
        tareaId: map['tareaId'],
        piezaId: map['piezaId'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'cantidad': cantidad,
        'tareaId': tareaId,
        'piezaId': piezaId,
      };
  PiezasTarea copyWith({
    int? id,
    int? cantidad,
    int? tareaId,
    int? piezaId,
  }) {
    return PiezasTarea(
      id: id ?? this.id,
      cantidad: cantidad ?? this.cantidad,
      tareaId: tareaId ?? this.tareaId,
      piezaId: piezaId ?? this.piezaId,
    );
  }
}
