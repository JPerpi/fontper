import 'package:flutter/cupertino.dart';
import 'package:fontper/db/db_provider.dart';
import 'package:fontper/models/pieza_tarea.dart';
import 'package:sqflite/sqflite.dart';

class PiezaTAreaProvider with ChangeNotifier {
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
}