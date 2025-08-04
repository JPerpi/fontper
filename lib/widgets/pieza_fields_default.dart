// lib/widgets/generic_pieza_fields.dart

import 'package:flutter/material.dart';

/// Campos genéricos para piezas (medida nominal, conexión, control, uso, instalación).
class PiezaFieldsDefault extends StatelessWidget {
  final void Function(String?) onSavedMedidaNominal;
  final void Function(String?) onSavedConexion;
  final void Function(String?) onSavedTipoControl;
  final void Function(String?) onSavedUso;
  final void Function(String?) onSavedInstalacion;

  const PiezaFieldsDefault({
    Key? key,
    required this.onSavedMedidaNominal,
    required this.onSavedConexion,
    required this.onSavedTipoControl,
    required this.onSavedUso,
    required this.onSavedInstalacion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Medida nominal',
            helperText: '1 1/2", 3/4"…',
          ),
          onSaved: onSavedMedidaNominal,
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Conexión',
            helperText: 'roscado, brida...',
          ),
          onSaved: onSavedConexion,
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Tipo de control',
            helperText: 'Bola, compuerta, diafragma...',
          ),
          onSaved: onSavedTipoControl,
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Uso',
            helperText: 'Agua caliente, fría...',
          ),
          onSaved: onSavedUso,
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Instalación',
            helperText: 'Pared, suelo...',
          ),
          onSaved: onSavedInstalacion,
        ),
      ],
    );
  }
}
