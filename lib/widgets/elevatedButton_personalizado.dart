import 'package:flutter/material.dart';

class BotonAnimadoFlotante extends StatefulWidget {
  final VoidCallback onPressed;
  const BotonAnimadoFlotante({super.key, required this.onPressed});

  @override
  State<BotonAnimadoFlotante> createState() => _BotonAnimadoFlotanteState();
}

class _BotonAnimadoFlotanteState extends State<BotonAnimadoFlotante>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleAnimation = _controller.drive(Tween(begin: 1.0, end: 0.95));
  }

  void _onTap() async {
    await _controller.reverse();
    await _controller.forward();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FloatingActionButton.extended(
        onPressed: _onTap,
        backgroundColor: const Color(0xFFCF4648),
        icon: const Icon(Icons.add),
        label: const Text(
          'Añadir tarea',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
