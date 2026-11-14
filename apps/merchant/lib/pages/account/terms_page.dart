import 'package:flutter/material.dart';

import 'legal_web_page.dart';

/// 用户协议：正文由后端 H5 提供。
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) => const LegalWebPage(doc: LegalDoc.terms);
}
