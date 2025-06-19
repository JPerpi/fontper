import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tarea.dart';
import '../models/pieza.dart';
import '../providers/tarea_provider.dart';
import 'selector_piezas_screen.dart'; // ← importante

class TareaScreen extends StatefulWidget {
  const TareaScreen({super.key});

  @override
  _TareaScreenState createState() => _TareaScreenState();
}

class _TareaScreenState extends State<TareaScreen> {
  final _formKey = GlobalKey<FormState>();
  String _nombre = '';
  String _direccion = '';
  String _telefono = '';
  Map<Pieza, int> _piezasSeleccionadas = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nueva Tarea')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campos del formulario
                TextFormField(
                  decoration: InputDecoration(labelText: 'Nombre del cliente'),
                  onChanged: (value) => _nombre = value,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Campo requerido' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Dirección'),
                  onChanged: (value) => _direccion = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => _telefono = value,
                ),

                SizedBox(height: 20),

                // Botón para abrir la pantalla de selección
                ElevatedButton.icon(
                  onPressed: () async {
                    final resultado = await Navigator.push<Map<Pieza, int>>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SelectorPiezasScreen(
                          piezasIniciales: _piezasSeleccionadas,
                        ),
                      ),
                    );

                    if (resultado != null) {
                      setState(() {
                        _piezasSeleccionadas = resultado;
                      });
                    }
                  },
                  icon: Icon(Icons.add),
                  label: Text('Añadir o modificar piezas'),
                ),

                SizedBox(height: 16),

                // Resumen de piezas seleccionadas
                if (_piezasSeleccionadas.isNotEmpty) ...[
                  Text(
                    'Piezas añadidas:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ..._piezasSeleccionadas.entries.map((entry) {
                    final pieza = entry.key;
                    final cantidad = entry.value;

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(pieza.nombre),
                        subtitle: Text('Cantidad: $cantidad'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  if (cantidad > 1) {
                                    _piezasSeleccionadas[pieza] = cantidad - 1;
                                  } else {
                                    _piezasSeleccionadas.remove(pieza);
                                  }
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  _piezasSeleccionadas[pieza] = cantidad + 1;
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _piezasSeleccionadas.remove(pieza);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],

                Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).padding.bottom,
                    top: 12,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        print('→ BOTÓN PRESIONADO');

                        if (_formKey.currentState!.validate()) {
                          print('→ FORM VALIDADO');

                          final nuevaTarea = Tarea(
                            nombreCliente: _nombre,
                            direccion: _direccion,
                            telefono: _telefono,
                          );
                          print('→ TAREA CREADA: ${nuevaTarea.toMap()}');

                          final tareaProvider = Provider.of<TareaProvider>(
                              context,
                              listen: false);
                          if (_piezasSeleccionadas.isEmpty) {
                            print('→ SIN PIEZAS → crearTareaSinPiezas');
                            await tareaProvider.crearTareaSinPiezas(nuevaTarea);
                          } else {
                            print('→ CON PIEZAS → crearTareaConPiezas');
                             await tareaProvider.crearTareaConPiezas(
                                nuevaTarea, _piezasSeleccionadas);
                          }

                          Navigator.pop(context);
                        } else {
                          print('→ FORM NO VÁLIDO');
                        }
                      },
                      child: Text('Guardar tarea'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
