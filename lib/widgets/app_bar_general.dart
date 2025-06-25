import 'package:flutter/material.dart';
import '../screens/tarea_general_screen.dart';

class AppBarGeneral extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  final BuildContext context;

  const AppBarGeneral({
    super.key,
    required this.titulo,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 4.0),
        child: Image.asset(
          'assets/logoFontPer.png',
          width: 90,
          height: 90,
        ),
      ),
      title: Text(titulo),
      actions: [
        if (ModalRoute.of(context)?.settings.name == '/' || titulo == 'Tareas')
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const TareaGeneralScreen(modoEnviar: true),
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
