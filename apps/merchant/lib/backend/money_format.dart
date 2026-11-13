String money(num v, {int digits = 0}) {
  final neg = v < 0;
  final fixed = v.abs().toStringAsFixed(digits);
  final parts = fixed.split('.');
  final buf = StringBuffer();
  final s = parts[0];
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return '${neg ? '-' : ''}$buf${parts.length > 1 ? '.${parts[1]}' : ''}';
}
