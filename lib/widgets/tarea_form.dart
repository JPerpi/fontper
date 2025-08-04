import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Formulario para crear/editar una tarea.
class TareaForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final void Function(String?) onSavedNombre;
  final void Function(String?) onSavedDireccion;
  final void Function(String?) onSavedTelefono;
  final void Function(String?) onSavedNotas;
  final VoidCallback onAddPiezas;

  const TareaForm({
    Key? key,
    required this.formKey,
    required this.onSavedNombre,
    required this.onSavedDireccion,
    required this.onSavedTelefono,
    required this.onSavedNotas,
    required this.onAddPiezas,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Nombre del cliente'),
            onSaved: onSavedNombre,
            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Dirección'),
            onSaved: onSavedDireccion,
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Teléfono'),
            onSaved: onSavedTelefono,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 8),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Notas'),
            maxLines: null,
            onSaved: onSavedNotas,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                'Piezas seleccionadas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: onAddPiezas,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
