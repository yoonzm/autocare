import 'package:flutter/services.dart';

/// 输入格式：手机号分段（3-4-4）、金额千分位与两位小数、纯数字、小数。格式化是组件的内置逻辑。
enum AppInputFormat { none, phone, amount, integer, decimal }

extension AppInputFormatX on AppInputFormat {
  List<TextInputFormatter> get formatters => switch (this) {
    AppInputFormat.none => const [],
    AppInputFormat.phone => [PhoneFormatter()],
    AppInputFormat.amount => [AmountFormatter()],
    AppInputFormat.integer => [FilteringTextInputFormatter.digitsOnly],
    AppInputFormat.decimal => [DecimalFormatter()],
  };

  TextInputType? get keyboard => switch (this) {
    AppInputFormat.none => null,
    AppInputFormat.phone => TextInputType.phone,
    AppInputFormat.amount ||
    AppInputFormat.decimal => const TextInputType.numberWithOptions(decimal: true),
    AppInputFormat.integer => TextInputType.number,
  };
}

TextEditingValue _reformat(
  TextEditingValue value,
  String Function(String raw) format,
  bool Function(String c) isDigitPart,
) {
  // 光标位置按「光标左侧有效字符个数」保持不变。
  final cursor = value.selection.baseOffset.clamp(0, value.text.length);
  var before = 0;
  for (final c in value.text.substring(0, cursor).split('')) {
    if (isDigitPart(c)) before++;
  }
  final raw = value.text.split('').where(isDigitPart).join();
  final text = format(raw);
  var seen = 0;
  var offset = text.length;
  if (before == 0) {
    offset = 0;
  } else {
    for (var i = 0; i < text.length; i++) {
      if (isDigitPart(text[i])) seen++;
      if (seen == before) {
        offset = i + 1;
        break;
      }
    }
  }
  return TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: offset),
  );
}

/// `13916885530` → `139 1688 5530`。
class PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => _reformat(newValue, (raw) {
    final d = raw.length > 11 ? raw.substring(0, 11) : raw;
    final b = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (i == 3 || i == 7) b.write(' ');
      b.write(d[i]);
    }
    return b.toString();
  }, (c) => RegExp(r'\d').hasMatch(c));

  /// 取出纯数字。
  static String digits(String text) => text.replaceAll(RegExp(r'\D'), '');
}

/// `1580.5` → `1,580.5`：整数部分千分位，最多两位小数。
class AmountFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => _reformat(newValue, (raw) {
    // raw 里只有数字和小数点（小数点保留在 isDigitPart 里）。
    final firstDot = raw.indexOf('.');
    var whole = firstDot < 0 ? raw : raw.substring(0, firstDot);
    var fraction = firstDot < 0
        ? null
        : raw.substring(firstDot + 1).replaceAll('.', '');
    if (fraction != null && fraction.length > 2) {
      fraction = fraction.substring(0, 2);
    }
    whole = whole.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final b = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) b.write(',');
      b.write(whole[i]);
    }
    if (whole.isEmpty && fraction != null) b.write('0');
    return fraction == null ? b.toString() : '$b.$fraction';
  }, (c) => RegExp(r'[\d.]').hasMatch(c));

  /// `1,580.50` → `1580.50`。
  static String plain(String text) => text.replaceAll(',', '');
}

/// 小数：数字和一个小数点，最多两位小数，不加千分位。
class DecimalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');
    final firstDot = raw.indexOf('.');
    var text = raw;
    if (firstDot >= 0) {
      final fraction = raw.substring(firstDot + 1).replaceAll('.', '');
      text = '${raw.substring(0, firstDot)}.${fraction.length > 2 ? fraction.substring(0, 2) : fraction}';
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
