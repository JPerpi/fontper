import 'package:flutter/cupertino.dart';
import '../db/db_provider.dart';
import '../models/pieza.dart';

class PiezaProvider with ChangeNotifier {
  List<Pieza> _piezas = [];


  Future<List<Pieza>> getTodasLasPiezas() async {
    if (_piezas.isNotEmpty) return _piezas; // ya cargadas
    final db = await DBProvider.database;
    final res = await db.query('pieza');
    _piezas = res.map((e) => Pieza.fromMap(e)).toList();
    return _piezas;
  }

  Pieza? getPiezaPorId(int id) {
    try {
      return _piezas.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Pieza>> getPiezasPorMaterial(int materialId) async {
    final db = await DBProvider.database;
    final res = await db.query('pieza', where: 'material_id = ?', whereArgs: [materialId]);
    return res.map((e) => Pieza.fromMap(e)).toList();
  }

  Future<void> insertarPiezaPersonalizada(Pieza pieza) async {
    final db = await DBProvider.database;
    await db.insert('pieza', pieza.toMap());
  }

}