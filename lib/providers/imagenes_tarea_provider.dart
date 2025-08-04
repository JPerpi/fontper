import 'package:flutter/foundation.dart';
import 'package:fontper/utils/image_utils.dart';
import 'package:image_picker/image_picker.dart';
import '../db/db_provider.dart';
import '../models/imagenes_tarea.dart';

class ImagenTareaProvider with ChangeNotifier {

  Future<List<ImagenTarea>> getImagenesPorTarea(int tareaId) async {
    final db = await DBProvider.database;
    final maps = await db.query(
      'imagenesTarea',
      where: 'tareaId = ?',
      whereArgs: [tareaId],
    );
    return maps.map((m) => ImagenTarea.fromMap(m)).toList();
  }

  Future<void> agregarImagen(int tareaId, {ImageSource source = ImageSource.camera}) async {
    final file = await ImageUtils.pickAndSaveImage(tareaId, source: source);
    if (file == null) return;

    final nueva = ImagenTarea(tareaId: tareaId, ruta: file.path);
    final db = await DBProvider.database;
    await db.insert('imagenesTarea', nueva.toMap());
    notifyListeners();
  }


  Future<void> eliminarImagen(int idImagen) async {
    final db = await DBProvider.database;
    final maps = await db.query(
      'imagenesTarea',
      columns: ['ruta'],
      where: 'id = ?',
      whereArgs: [idImagen],
    );
    if (maps.isEmpty) return;

    final ruta = maps.first['ruta'] as String;
    await db.delete('imagenesTarea', where: 'id = ?', whereArgs: [idImagen]);
    await ImageUtils.deleteFileIfExists(ruta);
    notifyListeners();
  }
}
