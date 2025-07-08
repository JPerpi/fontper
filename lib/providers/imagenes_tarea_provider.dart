import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../db/db_provider.dart';
import '../models/imagenes_tarea.dart';

class ImagenTareaProvider with ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  Future<List<ImagenTarea>> getImagenesPorTarea(int tareaId) async {
    final db = await DBProvider.database;
    final maps = await db.query(
      'imagenesTarea',
      where: 'tareaId = ?',
      whereArgs: [tareaId],
    );
    return maps.map((m) => ImagenTarea.fromMap(m)).toList();
  }

  Future<void> agregarImagen(int tareaId) async {
    // 1) Elegir o capturar imagen
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;

    // 2) Copiarla a carpeta de la app
    final appDir = await getApplicationDocumentsDirectory();
    final filename = 'tarea_${tareaId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final destPath = '${appDir.path}/$filename';
    final file = await File(picked.path).copy(destPath);

    // 3) Guardar ruta en la BBDD
    final nueva = ImagenTarea(tareaId: tareaId, ruta: file.path);
    final db = await DBProvider.database;
    final id = await db.insert('imagenesTarea', nueva.toMap());
    notifyListeners();
  }

  Future<void> eliminarImagen(int idImagen) async {
    final db = await DBProvider.database;
    // 1) Borrar registro de la BBDD
    final maps = await db.query(
      'imagenesTarea',
      columns: ['ruta'],
      where: 'id = ?',
      whereArgs: [idImagen],
    );
    if (maps.isEmpty) return;
    final ruta = maps.first['ruta'] as String;
    await db.delete('imagenesTarea', where: 'id = ?', whereArgs: [idImagen]);

    // 2) Borrar el fichero
    final file = File(ruta);
    if (await file.exists()) await file.delete();

    notifyListeners();
  }
}
