class MaterialFontaneria {
  final int? id;
  final String nombre;
  final int prioridad;

  MaterialFontaneria({
    this.id,
    required this.nombre,
    required this.prioridad,
  });

  factory MaterialFontaneria.fromMap(Map<String, dynamic> map) =>
      MaterialFontaneria(
        id: map['id'],
        nombre: map['nombre'],
        prioridad: map['prioridad'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'prioridad': prioridad,
      };
}
