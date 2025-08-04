import 'package:flutter/material.dart';
import '../models/tarea.dart';
import '../models/pieza_tarea.dart';
import '../models/pieza.dart';
import '../widgets/glass_card.dart';

/// Widget para mostrar una tarea en modo lectura (no envío),
/// con swipe-to-delete manejado externamente.
class TareaItemNormal extends StatelessWidget {
  final Tarea tarea;
  final List<PiezasTarea> piezas;
  final Map<int, Pieza> piezasMap;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const TareaItemNormal({
    Key? key,
    required this.tarea,
    required this.piezas,
    required this.piezasMap,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Suma total de unidades
    final total = piezas.fold<int>(0, (sum, pt) => sum + pt.cantidad);

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

    // Badge con número de piezas
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
          'Piezas: $total',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    )
        : const SizedBox.shrink();

    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tarea.nombreCliente ?? 'Sin nombre'),
                    Text(tarea.direccion ?? '',
                        style: const TextStyle(fontSize: 12)),
                    Text(tarea.telefono ?? '',
                        style: const TextStyle(fontSize: 12)),
                    if (tarea.scheduledAt != null) ...[
                      const SizedBox(height: 8),
                      Builder(builder: (context) {
                        final dt = DateTime.fromMillisecondsSinceEpoch(
                            tarea.scheduledAt!);
                        final loc = MaterialLocalizations.of(context);
                        final fecha = loc.formatShortDate(dt);
                        final hora = loc.formatTimeOfDay(
                          TimeOfDay.fromDateTime(dt),
                          alwaysUse24HourFormat: false,
                        );
                        return Chip(
                          avatar:
                          const Icon(Icons.event, size: 16, color: Colors.white),
                          label: Text(
                            '$fecha  •  $hora',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        sello,
        badgePiezas,
      ],
    );
  }
}
