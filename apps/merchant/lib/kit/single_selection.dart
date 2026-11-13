import 'package:flutter/material.dart';

import 'kit.dart' show SelCtrl;

/// 单选控件的实例控制器。调用者显式提供当前值和回调。
class SingleSelection extends StatefulWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final Widget Function(BuildContext context, SelCtrl selection) builder;
  const SingleSelection({
    super.key,
    required this.index,
    required this.onChanged,
    required this.builder,
  });

  @override
  State<SingleSelection> createState() => _SingleSelectionState();
}

class _SingleSelectionState extends State<SingleSelection> {
  late final selection = SelCtrl({widget.index}, false)
    ..onSelect = (i) => widget.onChanged(i);

  @override
  void didUpdateWidget(SingleSelection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (selection.selected.length != 1 ||
        !selection.selected.contains(widget.index)) {
      selection.selected
        ..clear()
        ..add(widget.index);
      selection.refresh();
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
