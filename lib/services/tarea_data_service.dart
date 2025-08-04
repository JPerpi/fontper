import 'package:fontper/db/db_provider.dart';
import 'package:fontper/models/tarea.dart';
import 'package:fontper/models/pieza.dart';
import 'package:fontper/models/pieza_tarea.dart';

/// Contiene las listas cargadas para la pantalla general de tareas.
class TareaData {
  final List<Tarea> tareas;
  final Map<int, List<PiezasTarea>> piezasPorTarea;
  final Map<int, Pieza> piezasMap;

  TareaData({
    required this.tareas,
    required this.piezasPorTarea,
    required this.piezasMap,
  });
}

/// Servicio que encapsula la lógica original de _cargarDatos()
class TareaDataService {
  /// Obtiene todas las tareas, el mapa de piezas por tarea y el mapa de piezas.
  static Future<TareaData> fetchTareaData() async {
    final db = await DBProvider.database;

    // 1) Cargo todas las tareas
    final tareaMaps = await db.query('tareas');
    final tareas = tareaMaps.map((m) => Tarea.fromMap(m)).toList();

    // 2) Cargo todas las piezas y construyo el mapa id→Pieza
    final piezaMaps = await db.query('pieza');
    final piezas = piezaMaps.map((m) => Pieza.fromMap(m)).toList();
    final piezasMap = { for (var p in piezas) p.id!: p };

    // 3) Para cada tarea, cargo sus piezasTarea
    final piezasPorTarea = <int, List<PiezasTarea>>{};
    for (final tarea in tareas) {
      final ptMaps = await db.query(
        'piezasTarea',
        where: 'tareaId = ?',
        whereArgs: [tarea.id],
      );
      piezasPorTarea[tarea.id!] =
          ptMaps.map((m) => PiezasTarea.fromMap(m)).toList();
    }

    return TareaData(
      tareas: tareas,
      piezasPorTarea: piezasPorTarea,
      piezasMap: piezasMap,
    );
  }
}