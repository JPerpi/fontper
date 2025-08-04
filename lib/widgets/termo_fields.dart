import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campos específicos para piezas de tipo termo/calentador.
class TermoFields extends StatelessWidget {
  final void Function(String?) onSavedTipoTermo;
  final void Function(String?) onSavedCapacidad;
  final void Function(String?) onSavedAlimentacion;
  final void Function(String?) onSavedPotencia;
  final void Function(String?) onSavedCaudal;

  const TermoFields({
    Key? key,
    required this.onSavedTipoTermo,
    required this.onSavedCapacidad,
    required this.onSavedAlimentacion,
    required this.onSavedPotencia,
    required this.onSavedCaudal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Tipo de termo',
            helperText: 'Eléctrico, gas, horizontal…',
          ),
          onSaved: onSavedTipoTermo,
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Capacidad (L)',
            helperText: 'Volumen de agua caliente que almacena',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onSaved: onSavedCapacidad,
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Alimentación',
            helperText: 'Electricidad, gas, diesel...',
          ),
          onSaved: onSavedAlimentacion,
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Potencia (W)',
            helperText: 'Potencia en vatios',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onSaved: onSavedPotencia,
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Caudal (L/min)',
            helperText: 'Caudal máximo en litros por minuto',
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d{1,2})?$')),
          ],
          onSaved: onSavedCaudal,
        ),
      ],
    );
  }
}
