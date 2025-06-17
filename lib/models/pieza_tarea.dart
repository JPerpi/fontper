class PiezaTarea {
  final int id;
  final int tareaId;
  final int piezaId;
  final int cantidad;

  PiezaTarea({
    required this.id,
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
}