// lib/widgets/boton_enviar_bar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pieza_tarea.dart';
import '../models/tarea.dart';
import '../providers/pieza_tarea_provider.dart';
import '../screens/tarea_general_screen.dart';
import '../utils/whatsapp_helper.dart';

/// Barra inferior que muestra los botones “Cancelar” y “Compartir”
/// en el modo envío de TareaGeneralScreen.
class BotonEnviarBar extends StatelessWidget {
  final String mensajeFinal;
  final List<Tarea> tareasFiltradas;
  final Map<int, List<PiezasTarea>> piezasPorTareaFiltrado;
  final Map<int, Set<int>> piezasSeleccionadasPorTarea;

  const BotonEnviarBar({
    Key? key,
    required this.mensajeFinal,
    required this.tareasFiltradas,
    required this.piezasPorTareaFiltrado,
    required this.piezasSeleccionadasPorTarea,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              label: const Text('Cancelar'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) =>
                    const TareaGeneralScreen(modoEnviar: false),
                    transitionDuration: const Duration(milliseconds: 300),
                    transitionsBuilder: (_, animation, __, child) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(0.0, 0.1),
                        end: Offset.zero,
                      ).animate(animation);
                      return SlideTransition(
                        position: offsetAnimation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              label: const Text('Compartir'),
              onPressed: () {
                // 1) Obtengo el provider sin escuchar para no redibujar aquí
                final prov = Provider.of<PiezasTareaProvider>(
                  context,
                  listen: false,
                );

                // 2) Construyo la lista de PiezasTarea seleccionadas
                final piezasSeleccionadas = <PiezasTarea>[];
                for (final tarea in tareasFiltradas) {
                  final listaPT = piezasPorTareaFiltrado[tarea.id] ?? [];
                  final seleccionadas = piezasSeleccionadasPorTarea[tarea.id] ?? {};
                  piezasSeleccionadas.addAll(
                    listaPT.where((pt) => seleccionadas.contains(pt.piezaId)),
                  );
                }

                // 3) Registro los IDs pendientes en el provider
                prov.registrarPendientes(piezasSeleccionadas);

                // 4) Disparo el helper para compartir por WhatsApp
                compartirPorWhatsApp(context, mensajeFinal);
              },
            ),
          ),
        ],
      ),
    );
  }
}
