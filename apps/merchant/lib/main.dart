import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'backend/access_flow.dart';
import 'backend/feedback_draft.dart';
import 'widgets/feedback_recovery_scope.dart';
import 'backend/merchant_api.dart';
import 'backend/store_profile.dart';
import 'kit/async_kit.dart';
import 'preferences/theme_preferences.dart';
import 'pages/account/access_boot.dart';
import 'pages/account/access_pages.dart';
import 'pages/account/login_page.dart';
import 'routes.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );
  // 上次选的外观（跟随系统 / 浅色 / 深色）保存在本机，启动时读回，之后每次切换都保存
  await Access.restore();
  await loadThemeMode();
  persistThemeMode();
  runApp(const QimeiApp());
}

class QimeiApp extends StatefulWidget {
  const QimeiApp({super.key});

  @override
  State<QimeiApp> createState() => _QimeiAppState();
}

class _QimeiAppState extends State<QimeiApp> with WidgetsBindingObserver {
  final _navKey = GlobalKey<NavigatorState>();
  final _msgKey = GlobalKey<ScaffoldMessengerState>();
  bool _expiring = false;
  final _feedbackRecovery = FeedbackRecovery();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    appThemeMode.addListener(_onMode);
    authExpired.addListener(_onAuthExpired);
    accessIssue.addListener(_onAccessIssue);
  }

  /// 令牌刷新失败：清掉本地登录态，回到登录页并说明原因。
  /// TODO: 登录后回到失效前的页面（需要记录来源页并在登录成功后恢复）。
  Future<void> _onAuthExpired() async {
    if (_expiring) return;
    _expiring = true;
    try {
      storeProfile.clear();
      try {
        await merchantApi.client.auth.signOut(scope: SignOutScope.local);
      } catch (_) {
        // 本地清理失败不影响回到登录页
      }
      _navKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
      final messenger = _msgKey.currentState;
      if (messenger != null) {
        AppToast.showOn(messenger, '登录已过期，请重新登录', kind: ToastKind.error);
      }
    } finally {
      _expiring = false;
    }
  }

  /// 服务端返回的身份 / 套餐状态：套餐到期、需先确认加入、身份被停用。
  Future<void> _onAccessIssue() async {
    final issue = accessIssue.value;
    if (issue == null) return;
    accessIssue.value = null;
    final nav = _navKey.currentState;
    if (nav == null) return;
    void go(Widget page) => nav.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => page),
      (_) => false,
    );
    if (issue == 'staff_disabled') {
      Access.clear();
      storeProfile.clear();
      try {
        await merchantApi.client.auth.signOut(scope: SignOutScope.local);
      } catch (_) {
        // 本地清理失败不影响回到登录页
      }
      go(const LoginPage());
      final messenger = _msgKey.currentState;
      if (messenger != null) {
        AppToast.showOn(messenger, '该门店已停用你的账号', kind: ToastKind.error);
      }
    } else if (issue == 'join_required') {
      go(const StAuthLivePage());
    }
  }

  @override
  void dispose() {
    _feedbackRecovery.clear();
    accessIssue.removeListener(_onAccessIssue);
    authExpired.removeListener(_onAuthExpired);
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
    return FeedbackRecoveryScope(
      recovery: _feedbackRecovery,
      child: MaterialApp(
        title: '汽美管家',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: appThemeMode.value,
        navigatorKey: _navKey,
        scaffoldMessengerKey: _msgKey,
        navigatorObservers: [navTracker],
        builder: (context, child) =>
            ToastHost(child: child ?? const SizedBox()),
        locale: const Locale('zh', 'CN'),
        supportedLocales: const [Locale('zh', 'CN')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: bootPage(),
      ),
    );
  }
}
