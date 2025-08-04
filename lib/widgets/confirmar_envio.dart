import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pieza_tarea_provider.dart';

Future<bool?> showConfirmarEnvioDialog(BuildContext context) {
  final prov = Provider.of<PiezasTareaProvider>(context, listen: false);
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('¿Se envió correctamente?'),
      content: const Text('¿Marcar estas piezas como enviadas?'),
      actions: [
        TextButton(
          onPressed: () {
            prov.cancelarPendiente();
            Navigator.pop(context, false);
          },
          child: const Text('No'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Sí'),
        ),
      ],
    ),
  );
}