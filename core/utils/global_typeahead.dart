import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class GlobalTypeAheadField<T> extends StatelessWidget {
  final TextEditingController controller;
  final Future<List<T>> Function(String) suggestionsCallback;
  final Widget Function(BuildContext, T) itemBuilder;
  final void Function(T) onSelected;
  final String Function(T) displayText;
  final String label;
  final IconData prefixIcon;
  final dynamic selectedItem;
  final VoidCallback onClear;

  const GlobalTypeAheadField({
    required this.controller,
    required this.suggestionsCallback,
    required this.itemBuilder,
    required this.onSelected,
    required this.displayText,
    required this.label,
    required this.prefixIcon,
    required this.selectedItem,
    required this.onClear,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<T>(
      controller: controller,
      debounceDuration: const Duration(milliseconds: 300),
      hideOnEmpty: true,
      hideOnLoading: true,
      suggestionsCallback: suggestionsCallback,
      builder: (context, controller, focusNode) {
        return SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            onChanged: (_) => (context as Element).markNeedsBuild(),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(4.0),
              labelText: label,
              hintText: 'Select $label',
              border: const OutlineInputBorder(),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2.0),
              ),
              prefixIcon: Icon(prefixIcon),
              suffixIcon: controller.text.isNotEmpty || selectedItem != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        onClear();
                        controller.clear();
                        focusNode.requestFocus();
                      },
                    )
                  : null,
            ),
            style: const TextStyle(fontSize: 16.0, color: Colors.black),
          ),
        );
      },
      itemBuilder: itemBuilder,
      onSelected: onSelected,
    );
  }
}
