import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/theme_state.dart';
import 'pages/login_page.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AdminApp());
}

class AdminApp extends StatefulWidget {
  const AdminApp({super.key});
  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    appThemeMode.addListener(_onMode);
  }

  @override
  void dispose() {
    appThemeMode.removeListener(_onMode);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onMode() => setState(() {});

  @override
  void didChangePlatformBrightness() {
    if (appThemeMode.value == ThemeMode.system) setState(() {});
  }

  bool get _isDark => switch (appThemeMode.value) {
    ThemeMode.dark => true,
    ThemeMode.light => false,
    ThemeMode.system =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark,
  };

  /// 页面直接读取全局 [C]，主题变化后需整树重建。
  void _rebuildAll() {
    void visit(Element e) {
      e.markNeedsBuild();
      e.visitChildren(visit);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.rootElement?.visitChildren(visit);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = _isDark;
    if (C.dark != dark) {
      C.dark = dark;
      _rebuildAll();
    }
    SystemChrome.setSystemUIOverlayStyle(
      dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
    return MaterialApp(
      title: '汽美管家 · 运营后台',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: appThemeMode.value,
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const LoginPage(),
    );
  }
}
