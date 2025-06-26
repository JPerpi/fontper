import 'package:flutter/material.dart';
import '../db/db_provider.dart';
import '../models/material_fontaneria.dart';

class MaterialProvider with ChangeNotifier {
  Future<List<MaterialFontaneria>> getMaterialesOrdenadosPorUso() async {
    final db = await DBProvider.database;

    final res = await db.rawQuery('''
      SELECT m.*, COUNT(p.id) as uso_total
      FROM material m
      LEFT JOIN pieza p ON p.material_id = m.id
      GROUP BY m.id
      ORDER BY uso_total DESC, m.nombre ASC
    ''');

    return res.map((e) => MaterialFontaneria.fromMap(e)).toList();
  }

  Future<List<MaterialFontaneria>> getTodosLosMateriales() async {
    final db = await DBProvider.database;
    final res = await db.query('material');
    return res.map((e) => MaterialFontaneria.fromMap(e)).toList();
  }

}
