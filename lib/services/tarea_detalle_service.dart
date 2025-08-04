// lib/services/tarea_detalle_data_service.dart

import 'package:fontper/db/db_provider.dart';
import 'package:fontper/models/imagenes_tarea.dart';
import 'package:fontper/models/pieza.dart';
import 'package:fontper/models/pieza_tarea.dart';
import 'package:fontper/providers/imagenes_tarea_provider.dart';

/// Valor de retorno que agrupa todas las colecciones
/// que necesita la pantalla de detalle.
class TareaDetalleService {
  final List<PiezasTarea> piezas;
  final Map<int, Pieza> piezasMap;
  final List<ImagenTarea> imagenes;

  TareaDetalleService({
    required this.piezas,
    required this.piezasMap,
    required this.imagenes,
  });
}

/// Servicio que encapsula la lógica de obtención de piezas e imágenes.
class TareaDetalleDataService {
  /// Carga piezas, mapa de piezas y las imágenes de la tarea.
  static Future<TareaDetalleService> fetchDetalle(int tareaId) async {
    final db = await DBProvider.database;

    // 1) Cargo las piezasTarea
    final ptMaps = await db.query(
      'piezasTarea',
      where: 'tareaId = ?',
      whereArgs: [tareaId],
    );
    final piezas = ptMaps.map((m) => PiezasTarea.fromMap(m)).toList();

    // 2) Cargo las piezas para construir el mapa id→Pieza
    final piezaIds = piezas.map((pt) => pt.piezaId).toSet();
    Map<int, Pieza> piezasMap = {};
    if (piezaIds.isNotEmpty) {
      final placeholders = List.filled(piezaIds.length, '?').join(', ');
      final pMaps = await db.query(
        'pieza',
        where: 'id IN ($placeholders)',
        whereArgs: piezaIds.toList(),
      );
      piezasMap = { for (var m in pMaps) m['id'] as int : Pieza.fromMap(m) };
    }

    // 3) Cargo las imágenes asociadas
    final imagenProv = ImagenTareaProvider();
    final imagenes = await imagenProv.getImagenesPorTarea(tareaId);

    return TareaDetalleService(
      piezas: piezas,
      piezasMap: piezasMap,
      imagenes: imagenes,
    );
  }
}
