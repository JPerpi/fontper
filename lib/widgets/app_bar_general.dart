import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tema_provider.dart';
import '../screens/tarea_general_screen.dart';

class AppBarGeneral extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;

  const AppBarGeneral({
    super.key,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.black;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 4.0),
        child: Image.asset(
          'assets/logoFontPer.png',
          width: 90,
          height: 90,
        ),
      ),
      title: Text(
        titulo),
      actions: [
        if (ModalRoute.of(context)?.settings.name == '/' || titulo == 'Tareas')
          IconButton(
            icon: Icon(Icons.share, color: iconColor),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const TareaGeneralScreen(modoEnviar: true),
                ),
              );
            },
          ),
        Consumer<ThemeProvider>(
          builder: (_, themeProv, __) {
            final isDarkMode = themeProv.mode == ThemeMode.dark;
            return IconButton(
              icon: Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: iconColor,
              ),
              tooltip: isDarkMode ? 'Tema claro' : 'Tema oscuro',
              onPressed: () => themeProv.toggleTheme(!isDarkMode),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
