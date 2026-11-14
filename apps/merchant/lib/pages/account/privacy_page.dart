import 'package:flutter/material.dart';

import 'legal_web_page.dart';

/// 隐私政策：正文由后端 H5 提供。
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const LegalWebPage(doc: LegalDoc.privacy);
}
