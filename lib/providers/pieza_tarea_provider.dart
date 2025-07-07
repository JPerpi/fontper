import 'package:flutter/material.dart';
import '../db/db_provider.dart';
import '../models/pieza.dart';
import '../models/pieza_tarea.dart';

class PiezasTareaProvider with ChangeNotifier {
  List<int> _pendingIds = [];
  bool get hasPending => _pendingIds.isNotEmpty;

  Future<List<PiezasTarea>> getPiezasPorTarea(int tareaId) async {
    final db = await DBProvider.database;
    final res = await db.query(
      'piezasTarea',
      where: 'tareaId = ?',
      whereArgs: [tareaId],
    );
    return res.map((e) => PiezasTarea.fromMap(e)).toList();
  }

  Future<void> insertarPiezaTarea(PiezasTarea piezaTarea) async {
    final db = await DBProvider.database;
    await db.insert('piezasTarea', piezaTarea.toMap());
  }

  Future<void> actualizarCantidadPieza(int tareaId, int piezaId, int nuevaCantidad) async {
    final db = await DBProvider.database;

    await db.update(
      'piezasTarea',
      {'cantidad': nuevaCantidad},
      where: 'tareaId = ? AND piezaId = ?',
      whereArgs: [tareaId, piezaId],
    );
  }

  Future<void> eliminarPiezaDeTarea(int tareaId, int piezaId) async {
    final db = await DBProvider.database;
    await db.delete(
      'piezasTarea',
      where: 'tareaId = ? AND piezaId = ?',
      whereArgs: [tareaId, piezaId],
    );
  }

  Future<void> insertarNuevaPiezaTarea(int tareaId, int piezaId, int cantidad) async {
    final db = await DBProvider.database;
    await db.insert('piezasTarea', {
      'piezaId': piezaId,
      'tareaId': tareaId,
      'cantidad': cantidad,
    });
  }

  Future<Map<int, Pieza>> getPiezasMapPorTarea(int tareaId) async {
    final db = await DBProvider.database;

    // Primero obtenemos todas las piezasTarea asociadas a la tarea
    final piezasTarea = await db.query(
      'piezasTarea',
      where: 'tareaId = ?',
      whereArgs: [tareaId],
    );

    final piezaIds = piezasTarea.map((pt) => pt['piezaId'] as int).toSet();

    if (piezaIds.isEmpty) return {};

    // Luego consultamos las piezas reales en la tabla pieza
    final piezasQuery = await db.query(
      'pieza',
      where: 'id IN (${List.filled(piezaIds.length, '?').join(', ')})',
      whereArgs: piezaIds.toList(),
    );

    return {
      for (var p in piezasQuery) p['id'] as int: Pieza.fromMap(p),
    };
  }

  void registrarPendientes(List<PiezasTarea> piezas) {
    // Asegúrate de que cada pieza tenga un ID no-null
    _pendingIds = piezas.map((p) => p.id!).toList();
  }

  Future<void> confirmarMarcado() async {
    if (_pendingIds.isEmpty) return;
    final db = await DBProvider.database;
    final batch = db.batch();
    for (var id in _pendingIds) {
      // SET cantidadEnviada = cantidad (campo existente en la tabla)
      batch.execute(
        'UPDATE piezasTarea SET cantidadEnviada = cantidad WHERE id = ?',
        [id],
      );
    }
    await batch.commit(noResult: true);
    _pendingIds.clear();
    notifyListeners();
  }

  void cancelarPendiente() {
    _pendingIds.clear();
    notifyListeners();
  }

}
