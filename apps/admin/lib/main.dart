import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/admin_api.dart';
import 'data/store.dart';
import 'ui.dart';
import 'pages/shell_page.dart';

import 'data/theme_state.dart';
import 'pages/login_page.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: backendUrl, publishableKey: backendKey);
  runApp(const AdminApp());
}

class AdminApp extends StatefulWidget {
  const AdminApp({super.key});
  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> with WidgetsBindingObserver {
  final navigatorKey = GlobalKey<NavigatorState>();
  bool reauthenticating = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    appThemeMode.addListener(_onMode);
    authExpired.addListener(_expired);
    store.addListener(_storeChanged);
  }

  @override
  void dispose() {
    appThemeMode.removeListener(_onMode);
    authExpired.removeListener(_expired);
    store.removeListener(_storeChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onMode() => setState(() {});
  void _storeChanged() {
    final error = store.refreshError;
    if (error == null || navigatorKey.currentContext == null) return;
    store.refreshError = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || navigatorKey.currentContext == null) return;
      AppToast.show(
        navigatorKey.currentContext!,
        '操作已保存，刷新失败：${error.message}',
        kind: ToastKind.error,
        actionLabel: '重试',
        onAction: () async {
          try {
            await store.refresh();
          } catch (e) {
            if (navigatorKey.currentContext != null) {
              AppToast.error(navigatorKey.currentContext!, e);
            }
          }
        },
      );
    });
  }

  Future<void> _expired() async {
    if (reauthenticating || navigatorKey.currentState == null) return;
    reauthenticating = true;
    final previousUser = store.me?.id;
    try {
      await navigatorKey.currentState!.push<bool>(
        MaterialPageRoute(
          builder: (_) => LoginPage(resuming: true, previousUser: previousUser),
        ),
      );
    } finally {
      reauthenticating = false;
    }
  }

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
      navigatorKey: navigatorKey,
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
      builder: (_, child) => ToastHost(child: child!),
      home: const SessionGate(),
    );
  }
}

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});
  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  @override
  Widget build(BuildContext context) => AsyncView<bool>(
    load: store.restore,
    isEmpty: (_) => false,
    skeleton: const SizedBox.shrink(),
    empty: (_) => const LoginPage(),
    builder: (_, signedIn) => signedIn
        ? store.me!.mustChange
              ? ChangePasswordPage(
                  username: store.me!.username,
                  restoring: true,
                )
              : const ShellPage()
        : const LoginPage(),
  );
}
