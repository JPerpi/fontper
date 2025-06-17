class TipoPieza {
  final int id;
  final String nombre;

  TipoPieza({
    required this.id,
    required this.nombre,
  });

  factory TipoPieza.fromMap(Map<String, dynamic> map) {
    return TipoPieza(
      id: map['id'],
      nombre: map['nombre'],
    );
  }
}
