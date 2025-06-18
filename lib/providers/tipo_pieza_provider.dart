import 'package:flutter/cupertino.dart';
import 'package:fontper/db/db_provider.dart';
import 'package:fontper/models/tipo_pieza.dart';

class TipoPiezaProvider with ChangeNotifier {
  List<TipoPieza> _tipos = [];

  List<TipoPieza> get tipos => _tipos;

  Future<void> loadData() async {
    final db = await DBProvider.database;
    final res = await db.query('tipoPiezas');

    _tipos =  res.map((e) => TipoPieza.fromMap(e)).toList();
    notifyListeners();
  }
}