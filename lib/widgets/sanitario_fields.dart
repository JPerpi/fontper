import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campos específicos para piezas de tipo sanitario:
/// alto, ancho y profundo.
class SanitarioFields extends StatelessWidget {
  final void Function(String?) onSavedAlto;
  final void Function(String?) onSavedAncho;
  final void Function(String?) onSavedProfundo;

  const SanitarioFields({
    Key? key,
    required this.onSavedAlto,
    required this.onSavedAncho,
    required this.onSavedProfundo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Alto (cm) *',
            helperText: 'Altura máxima de la pieza',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) =>
          v == null || v.isEmpty ? 'Obligatorio' : null,
          onSaved: onSavedAlto,
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Ancho (cm) *',
            helperText: 'Anchura máxima de la pieza',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) =>
          v == null || v.isEmpty ? 'Obligatorio' : null,
          onSaved: onSavedAncho,
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Profundo (cm) *',
            helperText: 'Profundidad total de la pieza',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) =>
          v == null || v.isEmpty ? 'Obligatorio' : null,
          onSaved: onSavedProfundo,
        ),
      ],
    );
  }
}
