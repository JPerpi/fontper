class PiezaTarea {
  final int? id;
  final int? tareaId;
  final int? piezaId;
  final int cantidad;

  PiezaTarea({
    this.id,
    required this.tareaId,
    required this.piezaId,
    required this.cantidad,
});

  factory PiezaTarea.fromMap(Map<String, dynamic> map) {
    return PiezaTarea(
      id: map['id'],
      tareaId: map['tarea_id'],
      piezaId: map['pieza_id'],
      cantidad: map['cantidad'],
    );
  }
  PiezaTarea copyWith({
    int? id,
    int? tareaId,
    int? piezaId,
    int? cantidad,
  }) {
    return PiezaTarea(
      id: id ?? this.id,
      tareaId: tareaId ?? this.tareaId,
      piezaId: piezaId ?? this.piezaId,
      cantidad: cantidad ?? this.cantidad,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'tarea_id': tareaId,
      'pieza_id': piezaId,
      'cantidad': cantidad,
    };
    if (id != null) map['id'] = id;
    return map;
  }


}