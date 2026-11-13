import 'package:flutter/material.dart';

import 'kit.dart' show SelCtrl;

class MultipleSelection extends StatefulWidget {
  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;
  final Widget Function(BuildContext context, SelCtrl selection) builder;
  const MultipleSelection({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.builder,
  });
  @override
  State<MultipleSelection> createState() => _MultipleSelectionState();
}

class _MultipleSelectionState extends State<MultipleSelection> {
  late final selection = SelCtrl({...widget.selected}, true)
    ..addListener(_changed);
  bool syncing = false;
  void _changed() {
    if (!syncing) widget.onChanged({...selection.selected});
  }

  @override
  void didUpdateWidget(MultipleSelection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (selection.selected.length != widget.selected.length ||
        !selection.selected.containsAll(widget.selected)) {
      syncing = true;
      selection.selected
        ..clear()
        ..addAll(widget.selected);
      selection.refresh();
      syncing = false;
    }
  }

  @override
  void dispose() {
    selection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, selection);
}
