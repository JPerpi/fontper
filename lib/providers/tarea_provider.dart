import 'package:flutter/cupertino.dart';
import 'package:fontper/db/db_provider.dart';
import 'package:fontper/models/tarea.dart';

class TareaProvider with ChangeNotifier {
  List<Tarea> _tareas = [];
  List<Tarea> get tareas => _tareas;
  
  Future<void> loadData() async {
    final db = await DBProvider.database;
    final res = await db.query('tareas');
    _tareas = res.map((e) => Tarea.fromMap(e)).toList();
    notifyListeners();
  }
  
  Tarea? getById(int id) {
    return _tareas.firstWhere((t) => t.id == id, orElse: ()=> Tarea(id: id));
  }
}