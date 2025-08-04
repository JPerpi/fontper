// lib/widgets/selected_pieces_list.dart

import 'package:flutter/material.dart';
import 'package:fontper/widgets/glass_card.dart';
import 'package:fontper/models/pieza_tarea.dart';
import 'package:fontper/providers/pieza_provider.dart';

/// Muestra una lista de piezas seleccionadas con swipe-to-delete.
class ListaPiezasSeleccionadas extends StatelessWidget {
  final Map<int, PiezasTarea> piezas; // key=piezaId, value=PiezasTarea
  final PiezaProvider piezaProvider;
  final void Function(int piezaId, int delta) onChangeCantidad;
  final void Function(int piezaId) onRemove;

  const ListaPiezasSeleccionadas({
    Key? key,
    required this.piezas,
    required this.piezaProvider,
    required this.onChangeCantidad,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (piezas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Center(child: Text('No hay piezas añadidas')),
      );
    }

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: piezas.values.map((pt) {
        final pieza = piezaProvider.getPiezaPorId(pt.piezaId);
        return Dismissible(
          key: ValueKey(pt.piezaId),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.redAccent,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (_) => showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Confirmar'),
              content: const Text('¿Eliminar esta pieza?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Sí'),
                ),
              ],
            ),
          ),
          onDismissed: (_) => onRemove(pt.piezaId),
          child: GlassCard(
            child: ListTile(
              title: Text(pieza?.nombre ?? 'Pieza'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => onChangeCantidad(pt.piezaId, -1),
                  ),
                  Text('${pt.cantidad}', style: const TextStyle(fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => onChangeCantidad(pt.piezaId, 1),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
