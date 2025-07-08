class ImagenTarea {
  final int? id;
  final int tareaId;
  final String ruta;

  ImagenTarea({this.id, required this.tareaId, required this.ruta});

  factory ImagenTarea.fromMap(Map<String, dynamic> map) => ImagenTarea(
    id:       map['id'] as int?,
    tareaId:  map['tareaId'] as int,
    ruta:     map['ruta']  as String,
  );

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'tareaId': tareaId,
      'ruta':    ruta,
    };
  }
}