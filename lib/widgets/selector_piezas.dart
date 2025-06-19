import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fontper/models/tipo_pieza.dart';
import 'package:fontper/providers/pieza_provider.dart';
import 'package:fontper/providers/tipo_pieza_provider.dart';
import 'package:provider/provider.dart';

import '../models/pieza.dart';

class SelectorPiezas extends StatefulWidget {
  final Map<Pieza, int> piezasSeleccionadas;
  final Function(Map<Pieza, int>) onPiezasActualizadas;


  SelectorPiezas({
    Key? key,
    required this.piezasSeleccionadas,
    required this.onPiezasActualizadas,
  }) : super(key: key);
  @override
  _SelectorPiezasState createState() => _SelectorPiezasState();
}

class _SelectorPiezasState extends State<SelectorPiezas> {
  List<TipoPieza> tiposDisponibles = [];
  int? tipoSeleccionadoId;
  List<Pieza> piezasFiltradas = [];

  @override
  void initState() {
    super.initState();
    cargarTipos();
  }
  void cargarTipos() async {
    final tipoProvider = Provider.of<TipoPiezaProvider>(context, listen: false);
    final tipos = await tipoProvider.getAllTipos();

    print('Tipos cargados: \$tipos');

    setState(() {
      tiposDisponibles = tipos;
    });
  }

  void cargarPiezasTipo(int tipoId) async {
    final piezaProvider = Provider.of<PiezaProvider>(context, listen: false);
    final piezas = await piezaProvider.getByTipo(tipoId);

    setState(() {
      tipoSeleccionadoId = tipoId;
      piezasFiltradas = piezas;
    });
  }
  void incrementarCantidad(Pieza pieza) {
    final actual = Map<Pieza, int>.from(widget.piezasSeleccionadas);
    actual[pieza] = (actual[pieza] ?? 0) + 1;
    widget.onPiezasActualizadas(actual);
  }

  void decrementarCantidad(Pieza pieza) {
    final actual = Map<Pieza, int>.from(widget.piezasSeleccionadas);
    if ((actual[pieza] ?? 0) > 1) {
      actual[pieza] = actual[pieza]! - 1;
    } else {
      actual.remove(pieza);
    }
    widget.onPiezasActualizadas(actual);
  }

  int cantidadDe(Pieza pieza) {
    return widget.piezasSeleccionadas[pieza] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<int>(
          hint: Text('Selecciona tipo de pieza'),
          value: tipoSeleccionadoId,
          isExpanded: true,
          items: tiposDisponibles.map((tipo) {
            return DropdownMenuItem<int>(
              value: tipo.id,
              child: Text(tipo.nombre),
            );
          }).toList(),
          onChanged: (nuevoId) {
            if (nuevoId != null) {
              setState(() {
                tipoSeleccionadoId = nuevoId;
              });
              cargarPiezasTipo(nuevoId);
            }
          },
        ),
        SizedBox(height: 12),
        Expanded(
          child: piezasFiltradas.isEmpty
              ? Center(child: Text('Selecciona un tipo para ver las piezas'))
              : ListView.builder(
            itemCount: piezasFiltradas.length,
            itemBuilder: (_, i) {
              final pieza = piezasFiltradas[i];
              final cantidad = cantidadDe(pieza);
              return Card(
                margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 2,
                child: ListTile(
                  title: Text(
                    pieza.nombre,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () => decrementarCantidad(pieza),
                      ),
                      Text('$cantidad'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => incrementarCantidad(pieza),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}