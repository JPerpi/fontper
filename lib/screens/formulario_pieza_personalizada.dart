import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fontper/widgets/app_bar_general.dart';
import 'package:fontper/widgets/pieza_personalizada_form.dart';

import '../providers/catalogo_provider.dart';
import '../providers/pieza_provider.dart';

class FormularioPiezaPersonalizada extends StatelessWidget {
  const FormularioPiezaPersonalizada({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogoProvider>();

    // 1) Mientras se cargan tipos/materiales:
    if (catalog.loading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2) Ya cargó: mostramos el formulario
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AppBarGeneral(titulo: 'Nueva pieza'),
        body: PiezaPersonalizadaForm(
          tipos: catalog.tipos,
          materiales: catalog.materiales,
          onSubmit: (pieza) async {
            // guarda la pieza y notificamos
            await context
                .read<PiezaProvider>()
                .insertarPiezaPersonalizada(pieza);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pieza guardada correctamente')),
            );
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
