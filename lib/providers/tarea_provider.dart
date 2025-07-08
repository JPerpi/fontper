import 'package:flutter/material.dart';
import '../db/db_provider.dart';
import '../models/pieza_tarea.dart';
import '../models/tarea.dart';
import '../services/notifications_services.dart';


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

  Future<void> crearTareaConPiezas(
      Tarea tarea, List<PiezasTarea> piezas) async {
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

  Future<void> eliminarTareasAntiguas() async {
    final db = await DBProvider.database;
    // Primero eliminamos las piezas asociadas
    await db.delete(
      'piezasTarea',
      where:
          "tareaId IN (SELECT id FROM tareas WHERE finalizada = 1 AND fecha_creacion <= datetime('now', '-3 months'))",
    );

    // Después eliminamos las tareas completadas
    await db.delete(
      'tareas',
      where:
          "finalizada = 1 AND fecha_creacion <= datetime('now', '-4 months')",
    );
  }

  Future<void> actualizarTarea({
    required int id,
    required String? nombre,
    required String? direccion,
    required String? telefono,
  }) async {
    final db = await DBProvider.database;
    await db.update(
      'tareas',
      {
        'nombre_cliente': nombre,
        'direccion': direccion,
        'telefono': telefono,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    notifyListeners();
  }

  Future<void> programarCita(Tarea tarea, DateTime cita) async {
    final db = await DBProvider.database;

    // ✔️ 2.1 Actualiza scheduledAt en la BBDD
    tarea.scheduledAt = cita.millisecondsSinceEpoch;
    await db.update(
      'tareas',
      tarea.toMap(),
      where: 'id = ?',
      whereArgs: [tarea.id],
    );

    // ✔️ 2.2 Cancela notificaciones anteriores (si las hubiera)
    await NotificationsService.cancelCita(tarea.id!);

    // ✔️ 2.3 Programa los 4 recordatorios
    await NotificationsService.scheduleCita(
      tarea.id!,
      tarea.nombreCliente!,
      cita,
    );

    // ✔️ 2.4 Refresca la UI
    notifyListeners();
  }

  Future<void> borrarCita(Tarea tarea) async {
    final db = await DBProvider.database;

    // ✔️ 3.1 Pone scheduledAt a null en la BBDD
    tarea.scheduledAt = null;
    await db.update(
      'tareas',
      tarea.toMap(),
      where: 'id = ?',
      whereArgs: [tarea.id],
    );

    // ✔️ 3.2 Cancela todas las notificaciones asociadas
    await NotificationsService.cancelCita(tarea.id!);

    // ✔️ 3.3 Refresca la UI
    notifyListeners();
  }
}
