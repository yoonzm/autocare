import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';

import 'mock/theme_state.dart';
import 'pages/login_page.dart';
import 'routes.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QimeiApp());
}

class QimeiApp extends StatefulWidget {
  const QimeiApp({super.key});

  @override
  State<QimeiApp> createState() => _QimeiAppState();
}

class _QimeiAppState extends State<QimeiApp> with WidgetsBindingObserver {
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

  /// 手写页面直接读取全局 [C]，主题变化后需整树重建。
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
      title: '汽美管家',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: appThemeMode.value,
      navigatorObservers: [navTracker],
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
