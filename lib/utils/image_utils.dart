import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  static Future<File?> pickAndSaveImage(int tareaId, {ImageSource source = ImageSource.camera}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked == null) return null;

    final appDir = await getApplicationDocumentsDirectory();
    final filename = 'tarea_${tareaId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final destPath = '${appDir.path}/$filename';
    return File(picked.path).copy(destPath);
  }


  static Future<void> deleteFileIfExists(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}