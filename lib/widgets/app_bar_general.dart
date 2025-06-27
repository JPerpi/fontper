import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tema_provider.dart';
import '../screens/tarea_general_screen.dart';

class AppBarGeneral extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  final List<Widget>? actions; // ✅ nuevo parámetro opcional

  const AppBarGeneral({
    super.key,
    required this.titulo,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final themeProv = Provider.of<ThemeProvider>(context);
    final isDark = themeProv.mode == ThemeMode.dark;
    final iconColor = isDark ? Colors.white : Colors.black;
    final isTareasScreen =
        ModalRoute.of(context)?.settings.name == '/' || titulo == 'Tareas';

    return ClipRRect(
        child: AppBar(
          elevation: 0,
          leading: ModalRoute.of(context)?.canPop == true
              ? IconButton(
            icon: const Icon(Icons.arrow_back),
            color: iconColor,
            onPressed: () => Navigator.of(context).pop(),
          )
              : Padding(
            padding: const EdgeInsets.all(6),
            child: SizedBox(
              width: 50,
              height: 50,
              child: Image.asset('assets/logoFontPer.png'),
            ),
          ),
          title: Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          actions: [
            if (isTareasScreen)
              IconButton(
                icon: Icon(Icons.share, color: iconColor),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const TareaGeneralScreen(modoEnviar: true),
                      transitionsBuilder: (_, animation, __, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 250),
                    ),
                  );
                },
              ),
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: iconColor,
              ),
              tooltip: isDark ? 'Tema claro' : 'Tema oscuro',
              onPressed: () => themeProv.toggleTheme(!isDark),
            ),
            if (actions != null) ...actions!, // ✅ insertar acciones personalizadas
          ],
        ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
