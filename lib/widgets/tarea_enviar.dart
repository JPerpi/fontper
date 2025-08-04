import 'package:flutter/material.dart';
import '../models/tarea.dart';
import '../models/pieza_tarea.dart';
import '../models/pieza.dart';
import '../widgets/glass_card.dart';

/// Widget para mostrar una tarea en modo “enviar”:
/// - Permite expandir para ver piezas con casillas.
/// - Checkbox para seleccionar toda la tarea.
/// - Badges de sello y cantidad.
class TareaItemEnviar extends StatelessWidget {
  final Tarea tarea;
  final List<PiezasTarea> piezas;
  final Map<int, Pieza> piezasMap;
  final Set<int> seleccionadas; // piezas seleccionadas en esta tarea
  final bool tareaEnteraSeleccionada;
  final ValueChanged<bool> onSeleccionarTareaEntera;
  final void Function(int piezaId, bool seleccionado) onSeleccionarPieza;

  const TareaItemEnviar({
    Key? key,
    required this.tarea,
    required this.piezas,
    required this.piezasMap,
    required this.seleccionadas,
    required this.tareaEnteraSeleccionada,
    required this.onSeleccionarTareaEntera,
    required this.onSeleccionarPieza,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Badge “completada”
    final sello = tarea.finalizada == 1
        ? Positioned(
      top: -12,
      right: -12,
      child: Transform.rotate(
        angle: -0.35,
        child: Image.asset(
          'assets/selloCompletada.png',
          width: 88,
          height: 88,
        ),
      ),
    )
        : const SizedBox.shrink();

    // Badge de número de piezas restantes
    final totalRestante = piezas.fold<int>(
      0,
          (sum, pt) => sum + (pt.cantidad - pt.cantidadEnviada),
    );
    final badgePiezas = tarea.finalizada != 1
        ? Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Piezas: $totalRestante',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    )
        : const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GlassCard(
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tarea.nombreCliente ?? 'Sin nombre'),
                        Text(tarea.direccion ?? '',
                            style: const TextStyle(fontSize: 12)),
                        Text(tarea.telefono ?? '',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: tareaEnteraSeleccionada,
                    onChanged: (bool? v) => onSeleccionarTareaEntera(v ?? false),
                  ),
                ],
              ),
              children: piezas.map((pt) {
                final pieza = piezasMap[pt.piezaId];
                final nombre = pieza?.nombre ?? 'Pieza';
                final unidades = pt.cantidad - pt.cantidadEnviada;
                final estaSeleccionada = seleccionadas.contains(pt.piezaId);
                return CheckboxListTile(
                  title: Text('$nombre ($unidades ud.)'),
                  value: estaSeleccionada,
                  onChanged: (v) => onSeleccionarPieza(pt.piezaId, v ?? false),
                );
              }).toList(),
            ),
          ),
          sello,
          badgePiezas,
        ],
      ),
    );
  }
}
