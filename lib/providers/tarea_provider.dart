import 'package:flutter/cupertino.dart';
import 'package:fontper/db/db_provider.dart';
import 'package:fontper/models/tarea.dart';
import 'package:sqflite/sqflite.dart';

import '../models/pieza.dart';

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


  Future<int> getTotalPiezas (int tareaId) async {
    final db = await DBProvider.database;
    final result =  await db.rawQuery(
      'SELECT SUM(cantidad) as total FROM piezastarea WHERE tarea_id = ?',
      [tareaId],
    );
    final total = result.first['total'];
    return total != null ? int.parse(total.toString()) : 0;
  }

  Future<void> crearTareaConPiezas(Tarea tarea, Map<Pieza, int> piezasConCantidad) async {
    print('→ [crearTareaConPiezas] Método iniciado');

    try {
      final db = await DBProvider.database;
      print('→ [crearTareaConPiezas] BBDD obtenida');

      final tareaId = await db.insert('tareas', tarea.toMap());
      print('→ [crearTareaConPiezas] Tarea insertada con ID: $tareaId');

      for (final entry in piezasConCantidad.entries) {
        final pieza = entry.key;
        final cantidad = entry.value;

        await db.insert('piezasTarea', {
          'tarea_id': tareaId,
          'pieza_id': pieza.id,
          'cantidad': cantidad,
        });
        print('→ Pieza insertada: ${pieza.nombre} x$cantidad');
      }

      print('→ [crearTareaConPiezas] Finalizado correctamente');
    } catch (e, stack) {
      print('❌ Error al guardar tarea: $e');
      print(stack);
    }
  }


  Future<void> crearTareaSinPiezas(Tarea tarea) async {
    final db = await DBProvider.database;
    await db.insert('tareas', tarea.toMap());
  }

  Future<void> eliminarTareaConPiezas(int tareaId) async {
    final db = await DBProvider.database;
    await db.delete('piezasTarea', where: 'tareaId = ?', whereArgs: [tareaId]);
    await db.delete('tareas', where: 'id = ?', whereArgs: [tareaId]);
    _tareas.removeWhere((t) => t.id == tareaId);
    notifyListeners();
  }

}