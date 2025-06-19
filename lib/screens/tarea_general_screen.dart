import 'package:flutter/material.dart';
import 'package:fontper/providers/tarea_provider.dart';
import 'package:provider/provider.dart';

import '../models/tarea.dart';

class TareaGeneralScreen extends StatelessWidget {
  const TareaGeneralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tareaProvider = Provider.of<TareaProvider>(context);
    final tareas = tareaProvider.tareas;

    return Scaffold(
      appBar: AppBar(
        title: Text('FontPer'),
      ),
      body: ListView.builder(
        itemCount: tareas.length,
        itemBuilder: (context, index) {
          final tarea = tareas[index];

          return GestureDetector(
            onLongPress: () {
              _mostrarDialogoEliminar(context, tarea);
            },
            child: Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(
                  tarea.nombreCliente ?? 'Sin nombre',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tarea.direccion ?? 'Sin dirección'),
                    Text(tarea.telefono ?? 'Sin teléfono'),
                    FutureBuilder<int>(
                      future: tareaProvider.getTotalPiezas(tarea.id!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text('Piezas: ...');
                        }
                        final total = snapshot.data ?? 0;
                        return Text('Piezas: $total');
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/detalleTarea', arguments: tarea);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/nuevaTarea').then((_) {
            Provider.of<TareaProvider>(context, listen: false).loadData();
          });        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _mostrarDialogoEliminar(BuildContext context, Tarea tarea) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('¿Eliminar tarea?'),
        content: Text('Se eliminarán también las piezas asociadas a esta tarea.'),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar'),
            onPressed: () async {
              final tareaProvider = Provider.of<TareaProvider>(context, listen: false);
              await tareaProvider.eliminarTareaConPiezas(tarea.id!);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

}
