import 'package:flutter/cupertino.dart';
import 'package:fontper/db/db_provider.dart';
import 'package:fontper/models/pieza_tarea.dart';
import 'package:sqflite/sqflite.dart';

class PiezaTareaProvider with ChangeNotifier {
  List<PiezaTarea> _asignaciones = [];
  List<PiezaTarea> get asignaciones => _asignaciones;

  Future<void> loadData() async {
    final db = await DBProvider.database;
    final res = await db.query('piezastarea');
    _asignaciones = res.map((e) => PiezaTarea.fromMap(e)).toList();
    notifyListeners();
  }

  List<PiezaTarea> getByTareaId(int tareaId) {
    return _asignaciones.where((e) => e.tareaId == tareaId).toList();
  }

  List<PiezaTarea>getByPiezaId(int piezaId) {
    return _asignaciones.where((e) => e.piezaId == piezaId).toList();
  }

  PiezaTarea? getByTareaYPieza(int tareaId, int piezaId) {
    for (final a in _asignaciones) {
      if ( a.tareaId == tareaId && a.piezaId == piezaId) return a;
    }
    return null;
  }

  Future<void> actualizarCantidad(int id, int nuevaCantidad) async {
    final db = await DBProvider.database;
    await db.update(
      'piezastarea',
      {'cantidad': nuevaCantidad},
      where: 'id = ?',
      whereArgs: [id],
    );
    final index = _asignaciones.indexWhere((e) => e.id == id);
    if (index != -1) {
      _asignaciones[index] = _asignaciones[index].copyWith(cantidad: nuevaCantidad);
      notifyListeners();
    }
  }

  Future<void> insertar(PiezaTarea piezaTarea) async {
    final db = await DBProvider.database;
    final id = await db.insert('piezastarea', piezaTarea.toMap());
    _asignaciones.add(piezaTarea.copyWith(id: id));
    notifyListeners();
  }



}