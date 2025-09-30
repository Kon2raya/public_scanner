import 'package:aai_scanner_epson/core/config/theme/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';

class GlobalSearchField<T> extends StatefulWidget {
  final TextEditingController controller;
  final String Function(T) displayText;
  final void Function(T) onSelected;
  final Future<List<T>> Function(String) asyncSuggestions;
  final String label;
  final IconData prefixIcon;
  final VoidCallback onClear;
  final bool enabled;
  final bool readOnly;
  final T? initialItem;
  final String? Function(String?)? validator;

  const GlobalSearchField({
    super.key,
    required this.controller,
    required this.displayText,
    required this.onSelected,
    required this.asyncSuggestions,
    required this.label,
    required this.prefixIcon,
    required this.onClear,
    this.enabled = true,
    this.readOnly = false,
    this.initialItem,
    this.validator,
  });

  @override
  State<GlobalSearchField<T>> createState() => _GlobalSearchFieldState<T>();
}

class _GlobalSearchFieldState<T> extends State<GlobalSearchField<T>> {
  FocusNode? _focusNode;
  List<SearchFieldListItem<T>> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode?.addListener(_handleFocus);
  }

  void _handleFocus() {
    if (!mounted) return;
    if (_focusNode?.hasFocus ?? false) {
      Future.microtask(() async {
        if (!mounted) return;
        final results = await widget.asyncSuggestions('');
        if (!mounted) return;
        setState(() {
          _suggestions = results
              .map(
                (item) => SearchFieldListItem<T>(
                  widget.displayText(item),
                  item: item,
                ),
              )
              .toList();
        });
      });
    }
  }

  Future<void> injectScannedText(String scannedText) async {
    if (!mounted) return;
    widget.controller.text = scannedText;
    final results = await widget.asyncSuggestions(scannedText);
    if (!mounted) return;

    T? match;
    try {
      match = results.firstWhere(
        (item) => widget.displayText(item) == scannedText,
      );
    } catch (_) {
      match = results.isNotEmpty ? results.first : null;
    }

    if (match != null) {
      widget.onSelected(match);
    }
  }

  @override
  // void dispose() {
  //   // ✅ Close keyboard and unfocus automatically when disposing
  //   if (_focusNode?.hasFocus ?? false) {
  //     _focusNode?.unfocus();
  //   }
  //   _focusNode?.removeListener(_handleFocus);
  //   // _focusNode?.dispose();
  //   _focusNode = null;
  //   super.dispose();
  // }
  @override
  Widget build(BuildContext context) {
    return SearchField<T>(
      controller: widget.controller,
      focusNode: _focusNode, // ✅ safe usage
      suggestionState: Suggestion.expand,
      suggestions: _suggestions,
      suggestionItemDecoration: BoxDecoration(
        color: Colors.white, // 👈 background color for the dropdown
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      searchInputDecoration: SearchInputDecoration(
        filled: true, // ✅ Enable background fill
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.all(4.0),
        labelText: widget.label,
        hintText: 'Select ${widget.label}',
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryRed, width: 2.0),
        ),
        prefixIcon: Icon(widget.prefixIcon),
        suffixIcon:
            widget.controller.text.isNotEmpty || widget.initialItem != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  widget.onClear();
                  widget.controller.clear();
                },
              )
            : null,
      ),
      onSuggestionTap: (item) {
        final selected = item.item;
        if (selected != null) {
          widget.onSelected(selected);
        }
      },
      onSearchTextChanged: (query) async {
        final results = await widget.asyncSuggestions(query);
        return results
            .map(
              (item) =>
                  SearchFieldListItem<T>(widget.displayText(item), item: item),
            )
            .toList();
      },
      itemHeight: 50,
      maxSuggestionsInViewPort: 6,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      validator: widget.validator,
    );
  }
}
