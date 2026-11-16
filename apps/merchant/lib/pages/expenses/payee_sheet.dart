import 'dart:async';

import 'package:autocare_ui_kit/autocare_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 收款方候选项：来自历史开支里的“最近使用”。
class PayeeOption {
  final String name;
  final String category;
  final double amount;
  final String occurredOn;
  const PayeeOption({
    required this.name,
    required this.category,
    required this.amount,
    required this.occurredOn,
  });

  factory PayeeOption.fromJson(Map<String, dynamic> json) => PayeeOption(
    name: '${json['name']}',
    category: '${json['category']}',
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    occurredOn: '${json['occurred_on']}',
  );

  /// 「水电 · 上次 ¥1,180 · 10.05」
  String get subtitle {
    final whole = amount == amount.roundToDouble();
    final text = whole ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2);
    final grouped = text.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    final parts = occurredOn.split('-');
    final date = parts.length == 3 ? '${parts[1]}.${parts[2]}' : occurredOn;
    return '$category · 上次 ¥$grouped · $date';
  }
}

const payeeMaxLength = 20;

String _key(String s) => s.replaceAll(RegExp(r'\s+'), '').toLowerCase();

/// 选择收款方。返回选中的名称；点「清除」返回空字符串；直接关闭返回 null。
/// [load] 按关键字查询最近使用的收款方（空关键字返回最近的若干条）。
Future<String?> showPayeeSheet(
  BuildContext context, {
  required Future<List<PayeeOption>> Function(String query) load,
  required String current,
}) {
  final t = AppTokens.of(context);
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: t.surface,
    barrierColor: t.overlay,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheet),
      ),
    ),
    builder: (_) => PayeeSheet(load: load, current: current),
  );
}

class PayeeSheet extends StatefulWidget {
  final Future<List<PayeeOption>> Function(String query) load;
  final String current;
  const PayeeSheet({super.key, required this.load, required this.current});

  @override
  State<PayeeSheet> createState() => _PayeeSheetState();
}

enum _Phase { loading, ready, failed }

class _PayeeSheetState extends State<PayeeSheet> {
  final _input = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  var _phase = _Phase.loading;
  var _items = const <PayeeOption>[];
  // 用于丢弃迟到的响应：只接受最后一次发出的查询。
  var _seq = 0;
  // 首次无历史（空关键字返回为空）时，不显示“最近使用”标题。
  var _hasHistory = true;

  @override
  void initState() {
    super.initState();
    _query('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  String get _text => _input.text.trim();

  Future<void> _query(String q) async {
    final seq = ++_seq;
    setState(() => _phase = _Phase.loading);
    try {
      final items = await widget.load(q);
      if (!mounted || seq != _seq) return;
      setState(() {
        _items = items;
        _phase = _Phase.ready;
        if (q.isEmpty) _hasHistory = items.isNotEmpty;
      });
    } catch (_) {
      if (!mounted || seq != _seq) return;
      setState(() => _phase = _Phase.failed);
    }
  }

  void _onChanged(String _) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () => _query(_text));
  }

  bool get _canCreate {
    final name = _text;
    if (name.isEmpty || name.length > payeeMaxLength) return false;
    return !_items.any((i) => _key(i.name) == _key(name));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final inset = MediaQuery.of(context).viewInsets.bottom;
    final searching = _text.isNotEmpty;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      padding: EdgeInsets.only(bottom: inset),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: t.line,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Text('选择收款方', style: t.title)),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.pop(context, ''),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        '清除',
                        style: t.small.copyWith(color: t.inkSub),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 46,
                padding: const EdgeInsets.only(left: 14, right: 8),
                decoration: BoxDecoration(
                  color: t.inset,
                  borderRadius: BorderRadius.circular(23),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 18, color: t.inkSub),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _input,
                        focusNode: _focus,
                        onChanged: _onChanged,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          if (_canCreate) Navigator.pop(context, _text);
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(payeeMaxLength),
                        ],
                        style: t.body,
                        decoration: InputDecoration(
                          hintText: '搜索或输入收款方名称',
                          hintStyle: t.body.copyWith(color: t.inkFaint),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (searching)
                      GestureDetector(
                        onTap: () {
                          _input.clear();
                          _onChanged('');
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: t.line,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Flexible(child: _body(t, searching)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(AppTokens t, bool searching) {
    final rows = <Widget>[];
    if (_canCreate) {
      rows.add(_createRow(t));
      rows.add(const SizedBox(height: 8));
    }
    switch (_phase) {
      case _Phase.loading:
        if (_items.isEmpty) {
          rows.add(
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
          break;
        }
        rows.addAll(_list(t));
      case _Phase.failed:
        rows.add(
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _query(_text),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text(
                  '加载失败，点击重试',
                  style: t.small.copyWith(color: t.inkSub),
                ),
              ),
            ),
          ),
        );
      case _Phase.ready:
        if (_items.isNotEmpty) {
          rows.addAll(_list(t));
        } else if (searching) {
          rows.add(_hint(t, '没有找到匹配的收款方。名称最多 $payeeMaxLength 个字。'));
        } else {
          rows.add(_hint(t, '输入名称即可新增收款方'));
        }
    }
    if (!searching && _hasHistory && _phase != _Phase.failed) {
      rows.add(const SizedBox(height: 12));
      rows.add(_dashedAdd(t));
    }
    return ListView(shrinkWrap: true, children: rows);
  }

  List<Widget> _list(AppTokens t) {
    final selected = _key(widget.current);
    final out = <Widget>[];
    if (_text.isEmpty && _hasHistory) {
      out.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text('最近使用', style: t.small.copyWith(color: t.inkSub)),
        ),
      );
    }
    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      final isSelected = selected.isNotEmpty && _key(item.name) == selected;
      if (i > 0) {
        out.add(
          Container(
            height: 1,
            margin: const EdgeInsets.only(left: 52),
            color: t.line,
          ),
        );
      }
      out.add(
        InkWell(
          onTap: () => Navigator.pop(context, item.name),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: t.primarySoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      item.name.characters.first,
                      style: t.body.copyWith(
                        color: t.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.body.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                        Text(
                          item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.small.copyWith(color: t.inkSub),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: t.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return out;
  }

  Widget _createRow(AppTokens t) => InkWell(
    onTap: () => Navigator.pop(context, _text),
    borderRadius: BorderRadius.circular(18),
    child: Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: t.primarySoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.primary, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: t.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.add, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '新增收款方「$_text」',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.body.copyWith(
                    color: t.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text('保存开支后加入常用收款方', style: t.small.copyWith(color: t.inkSub)),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _dashedAdd(AppTokens t) => InkWell(
    onTap: _focus.requestFocus,
    borderRadius: BorderRadius.circular(18),
    child: Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.line, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.add, size: 20, color: t.primaryText),
          const SizedBox(width: 10),
          Text(
            '新增收款方',
            style: t.body.copyWith(
              color: t.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _hint(AppTokens t, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(text, style: t.small.copyWith(color: t.inkSub)),
  );
}
