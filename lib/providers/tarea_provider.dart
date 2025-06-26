import 'package:flutter/material.dart';
import '../db/db_provider.dart';
import '../models/pieza_tarea.dart';
import '../models/tarea.dart';

class TareaProvider with ChangeNotifier {
  Future<List<Tarea>> getTodasLasTareas() async {
    final db = await DBProvider.database;
    final res = await db.query('tareas');
    return res.map((e) => Tarea.fromMap(e)).toList();
  }

  Future<void> eliminarTareaConPiezas(int tareaId) async {
    final db = await DBProvider.database;
    await db.delete('piezasTarea', where: 'tareaId = ?', whereArgs: [tareaId]);
    await db.delete('tareas', where: 'id = ?', whereArgs: [tareaId]);
  }

  Future<int> insertarTarea(Tarea tarea) async {
    final db = await DBProvider.database;
    return await db.insert('tareas', tarea.toMap());
  }

  Future<void> crearTareaConPiezas(Tarea tarea,
      List<PiezasTarea> piezas) async {
    final db = await DBProvider.database;

    final tareaId = await insertarTarea(tarea);

    for (final pt in piezas) {
      await db.insert('piezasTarea', {
        'tareaId': tareaId,
        'piezaId': pt.piezaId,
        'cantidad': pt.cantidad,
      });
    }
  }

  Future<void> marcarComoFinalizada(int tareaId, bool finalizada) async {
    final db = await DBProvider.database;
    await db.update(
      'tareas',
      {'finalizada': finalizada ? 1 : 0},
      where: 'id = ?',
      whereArgs: [tareaId],
    );
  }

}
