import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../theme.dart' show C, softShadow;

class VisitHistory extends StatelessWidget {
  final List<Map<String, dynamic>> rows;
  const VisitHistory({super.key, required this.rows});
  @override
  Widget build(BuildContext context) {
    final ink = dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA));
    final muted = dk(context, const Color(0xFF71717A), const Color(0xFF9A9AA3));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            '历史回访',
            style: hts(
              13,
              dk(context, const Color(0xFF52525B), const Color(0xFFA8A8B3)),
              w: FontWeight.w500,
              lh: 18,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(24),
            boxShadow: C.dark ? null : softShadow,
            border: C.dark ? Border.all(color: const Color(0xFF26262B)) : null,
          ),
          child: rows.isEmpty
              ? Text('还没有回访记录', style: hts(13, muted, lh: 18))
              : Column(
                  children: [
                    for (var i = 0; i < rows.length && i < 5; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                [
                                  '${rows[i]['method']}',
                                  if ('${rows[i]['result']}'.isNotEmpty)
                                    '${rows[i]['result']}',
                                ].join(' · '),
                                style: hts(14, ink, w: FontWeight.w500, lh: 20),
                              ),
                              const Spacer(),
                              Text(
                                _md(rows[i]['created_at']),
                                style: hts(12, muted, lh: 17),
                              ),
                            ],
                          ),
                          if ('${rows[i]['content']}'.isNotEmpty)
                            Text(
                              '${rows[i]['content']}',
                              style: hts(13, muted, lh: 18),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

String _md(Object? at) {
  final t = DateTime.tryParse('$at')?.toLocal();
  if (t == null) return '';
  return '${t.month.toString().padLeft(2, '0')}.${t.day.toString().padLeft(2, '0')}';
}
