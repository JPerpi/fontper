class TipoPieza {
  final int? id;
  final String nombre;

  TipoPieza({
    this.id,
    required this.nombre,
  });

  factory TipoPieza.fromMap(Map<String, dynamic> map) => TipoPieza(
        id: map['id'],
        nombre: map['nombre'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
      };
}
