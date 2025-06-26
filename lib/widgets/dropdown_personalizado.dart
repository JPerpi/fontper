import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatefulWidget {
  final String label;
  final List<T> items;
  final T? value;
  final String Function(T) labelBuilder;
  final void Function(T) onChanged;
  final String? Function(T?)? validator;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    this.value,
    this.validator,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  final _fieldKey = GlobalKey<FormFieldState>();

  void _abrirMenu() async {
    final selected = await showDialog<T>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFD3D2D4).withOpacity(0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.all(8),
          content: SizedBox(
            width: double.maxFinite,
            height: 300, // altura máxima del menú
            child: ListView.builder(
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return InkWell(
                  onTap: () => Navigator.pop(context, item),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // un poco más de separación vertical
                    child: Text(
                      widget.labelBuilder(item),
                      style: const TextStyle(fontSize: 16), // un tamaño de letra ligeramente mayor
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (selected != null) {
      widget.onChanged(selected);
      _fieldKey.currentState?.didChange(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      key: _fieldKey,
      validator: widget.validator,
      builder: (state) {
        return GestureDetector(
          onTap: _abrirMenu,
          child: InputDecorator(
            decoration: InputDecoration(labelText: widget.label),
            isEmpty: widget.value == null,
            child: Text(
              widget.value != null ? widget.labelBuilder(widget.value as T) : '',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    );
  }
}
