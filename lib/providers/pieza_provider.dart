import 'package:flutter/cupertino.dart';
import 'package:fontper/db/db_provider.dart';
import 'package:fontper/models/pieza.dart';

class PiezaProvider with ChangeNotifier {
  List<Pieza> _piezas = [];

  List<Pieza> get piezas => _piezas;

  Future<void> loadData() async {
    final db = await DBProvider.database;
    final res = await db.query('pieza');
    _piezas = res.map((e) => Pieza.fromMap(e)).toList();
    notifyListeners();
  }

  List<Pieza> getByTipo(int tipoId) {
    return _piezas.where((p) => p.tipoId == tipoId).toList();
  }

  Pieza? getById(int id) {
    for (final pieza in _piezas) {
      if (pieza.id == id) return pieza;
    }
    return null;
  }
}