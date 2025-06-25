import '../models/pieza.dart';
import '../models/pieza_tarea.dart';

String generarResumenDePiezasSeleccionadas({
  required Map<int, List<PiezasTarea>> piezasPorTarea,
  required Map<int, Set<int>> piezasSeleccionadasPorTarea,
  required Map<int, Pieza> piezasMap,
}) {
  final Map<int, int> cantidadPorPieza = {};

  for (final entry in piezasSeleccionadasPorTarea.entries) {
    final tareaId = entry.key;
    final ids = entry.value;
    final piezas = piezasPorTarea[tareaId] ?? [];

    for (final pt in piezas) {
      if (ids.contains(pt.piezaId)) {
        cantidadPorPieza.update(pt.piezaId, (val) => val + pt.cantidad, ifAbsent: () => pt.cantidad);
      }
    }
  }

  if (cantidadPorPieza.isEmpty) return 'No se ha seleccionado ninguna pieza.';

  return 'Materiales necesarios:\n${cantidadPorPieza.entries.map((e) {
        final pieza = piezasMap[e.key];
        final nombre = pieza?.nombre ?? 'Pieza';
        final cantidad = e.value;
        return '- $nombre: x$cantidad';
      }).join('\n')}';

}
