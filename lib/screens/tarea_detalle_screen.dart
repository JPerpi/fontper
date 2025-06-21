import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../models/tarea.dart';
import '../models/pieza_tarea.dart';
import '../models/pieza.dart';
import '../providers/pieza_tarea_provider.dart';
import '../providers/pieza_provider.dart';
import '../screens/selector_piezas_screen.dart';

class TareaDetalleScreen extends StatefulWidget {
  @override
  State<TareaDetalleScreen> createState() => _TareaDetalleScreenState();
}

class _TareaDetalleScreenState extends State<TareaDetalleScreen> {
  late Tarea tarea;
  bool _cargando = true;
  bool _tareaInicializada = false;

  List<PiezaTarea> asignaciones = [];
  Map<int, String> nombresPiezas = {}; // piezaTarea.id -> nombre
  List<int> seleccionadas = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_tareaInicializada) {
      tarea = ModalRoute.of(context)!.settings.arguments as Tarea;
      _tareaInicializada = true;
      _cargarAsignaciones();
    }
  }

  Future<void> _cargarAsignaciones() async {
    final piezaTareaProvider = Provider.of<PiezaTareaProvider>(context, listen: false);
    final piezaProvider = Provider.of<PiezaProvider>(context, listen: false);

    final relaciones = piezaTareaProvider.getByTareaId(tarea.id!);
    final nombres = <int, String>{};

    for (final pt in relaciones) {
      if (pt.piezaId != null) {
        final pieza = await piezaProvider.getById(pt.piezaId!);
        if (pieza != null) {
          nombres[pt.id!] = pieza.nombre;
        }
      }
    }

    setState(() {
      asignaciones = relaciones;
      nombresPiezas = nombres;
      _cargando = false;
    });
  }

  String _generarMensaje() {
    final buffer = StringBuffer();
    final lista = seleccionadas.isEmpty
        ? []
        : asignaciones.where((pt) => seleccionadas.contains(pt.id)).toList();

    buffer.writeln('Material necesario para ${tarea.nombreCliente}:');

        for (final pt in lista) {
      final nombre = nombresPiezas[pt.id] ?? 'Pieza desconocida';
      buffer.writeln('- $nombre x${pt.cantidad}');
    }
    return buffer.toString();
  }

  Widget _vistaPreviaMensaje() {
    final mensaje = _generarMensaje();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(
        mensaje,
        style: TextStyle(fontSize: 14),
      ),
    );
  }

  void _abrirModalEnviar() {
    bool seleccionarTodas = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text('Enviar por WhatsApp'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Vista previa del mensaje:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                _vistaPreviaMensaje(),
                SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        CheckboxListTile(
                          title: Text('Seleccionar todas'),
                          value: seleccionarTodas,
                          onChanged: (value) {
                            setState(() {
                              seleccionarTodas = value!;
                              seleccionadas = value
                                  ? asignaciones.map((pt) => pt.id!).toList()
                                  : [];
                            });
                          },
                        ),
                        ...asignaciones.map((pt) {
                          final seleccionada = seleccionadas.contains(pt.id);
                          final nombre = nombresPiezas[pt.id] ?? 'Pieza';
                          return CheckboxListTile(
                            title: Text(nombre),
                            subtitle: Text('Cantidad: ${pt.cantidad ?? "-"}'),
                            value: seleccionada,
                            onChanged: (valor) {
                              setState(() {
                                if (valor == true) {
                                  seleccionadas.add(pt.id!);
                                } else {
                                  seleccionadas.remove(pt.id!);
                                }
                              });
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              ElevatedButton.icon(
                icon: FaIcon(FontAwesomeIcons.whatsapp),
                label: Text('Enviar'),
                onPressed: seleccionadas.isEmpty ? null : () async {
                  final mensaje = _generarMensaje();
                  if (mensaje.trim().isEmpty) return;
                  await Share.share(mensaje);
                  Navigator.pop(context);
                },
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final piezaTareaProvider = Provider.of<PiezaTareaProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(tarea.nombreCliente ?? 'Tarea'),
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.whatsapp),
            tooltip: 'Enviar por WhatsApp',
            onPressed: _abrirModalEnviar,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add),
        label: Text('Añadir piezas'),
        onPressed: () async {
          final resultado = await Navigator.push<Map<Pieza, int>>(
            context,
            MaterialPageRoute(
              builder: (_) => SelectorPiezasScreen(
                piezasIniciales: {},
              ),
            ),
          );

          if (resultado != null && resultado.isNotEmpty) {
            final nuevas = resultado.entries.map((e) => PiezaTarea(
              tareaId: tarea.id!,
              piezaId: e.key.id!,
              cantidad: e.value,
            )).toList();

            for (final pieza in nuevas) {
              await piezaTareaProvider.insertar(pieza);
            }

            await _cargarAsignaciones();
          }
        },
      ),
      body: _cargando
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          ListTile(
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dirección: ${tarea.direccion ?? ''}'),
                Text('Teléfono: ${tarea.telefono ?? ''}'),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: asignaciones.isEmpty
                ? Center(child: Text('No hay piezas asociadas'))
                : ListView.builder(
              itemCount: asignaciones.length,
              itemBuilder: (context, index) {
                final pt = asignaciones[index];
                final nombre = nombresPiezas[pt.id] ?? 'Sin nombre';

                return ListTile(
                  title: Text(nombre),
                  subtitle: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () async {
                          final nuevaCantidad = (pt.cantidad ?? 1) > 1
                              ? pt.cantidad! - 1
                              : 1;
                          await piezaTareaProvider.actualizarCantidad(pt.id!, nuevaCantidad);
                          await _cargarAsignaciones();
                        },
                      ),
                      Text('${pt.cantidad ?? 1}'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () async {
                          final nuevaCantidad = (pt.cantidad ?? 1) + 1;
                          await piezaTareaProvider.actualizarCantidad(pt.id!, nuevaCantidad);
                          await _cargarAsignaciones();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
