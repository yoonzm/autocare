import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../backend/merchant_api.dart'
    show supabaseUrl, supabasePublishableKey;
import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../resources/merchant_svgs.dart';

/// 用户协议 / 隐私政策由后端以 H5 提供（`merchant-v1/legal/<页面>`），改文案只需更新后端，不必发新版 App。
enum LegalDoc { terms, privacy }

Uri legalUrl(LegalDoc doc) => Uri.parse(
  '$supabaseUrl/functions/v1/merchant-v1/legal/${doc == LegalDoc.terms ? 'terms' : 'privacy'}',
);

/// 网页视图的构造入口；测试里替换成不依赖原生 WebView 的占位。
typedef LegalWebViewBuilder = Widget Function(
  Uri url,
  Map<String, String> headers,
  VoidCallback onLoaded,
  ValueChanged<AppError> onError,
);

LegalWebViewBuilder legalWebViewBuilder = _nativeWebView;

/// 默认的原生构造函数，测试结束后用它还原。
const LegalWebViewBuilder legalNativeWebViewBuilder = _nativeWebView;

Widget _nativeWebView(
  Uri url,
  Map<String, String> headers,
  VoidCallback onLoaded,
  ValueChanged<AppError> onError,
) => _NativeLegalWebView(
  url: url,
  headers: headers,
  onLoaded: onLoaded,
  onError: onError,
);

class _NativeLegalWebView extends StatefulWidget {
  final Uri url;
  final Map<String, String> headers;
  final VoidCallback onLoaded;
  final ValueChanged<AppError> onError;
  const _NativeLegalWebView({
    required this.url,
    required this.headers,
    required this.onLoaded,
    required this.onError,
  });

  @override
  State<_NativeLegalWebView> createState() => _NativeLegalWebViewState();
}

class _NativeLegalWebViewState extends State<_NativeLegalWebView> {
  late final WebViewController _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.disabled)
    ..setNavigationDelegate(
      NavigationDelegate(
        // 只允许加载这一页；页面里的任何跳转都拦下。
        onNavigationRequest: (request) => request.url == widget.url.toString()
            ? NavigationDecision.navigate
            : NavigationDecision.prevent,
        onPageFinished: (_) => widget.onLoaded(),
        onHttpError: (error) => widget.onError(
          AppError(
            '协议页面暂时无法打开',
            type: (error.response?.statusCode ?? 500) >= 500
                ? AppErrorType.server
                : AppErrorType.notFound,
          ),
        ),
        onWebResourceError: (error) {
          if (error.isForMainFrame ?? true) {
            widget.onError(const AppError.network());
          }
        },
      ),
    )
    ..loadRequest(widget.url, headers: widget.headers);

  @override
  Widget build(BuildContext context) => WebViewWidget(controller: _controller);
}

class LegalWebPage extends StatefulWidget {
  final LegalDoc doc;
  const LegalWebPage({super.key, required this.doc});

  @override
  State<LegalWebPage> createState() => _LegalWebPageState();
}

class _LegalWebPageState extends State<LegalWebPage> {
  int _attempt = 0;
  bool _loaded = false;
  AppError? _error;

  String get _title => widget.doc == LegalDoc.terms ? '用户协议' : '隐私政策';

  void _retry() => setState(() {
    _attempt++;
    _loaded = false;
    _error = null;
  });

  @override
  Widget build(BuildContext context) {
    final card = dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B));
    return Scaffold(
      backgroundColor: dk(
        context,
        const Color(0xFFF4F4F5),
        const Color(0xFF09090B),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, topInset(context), 20, 20),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: card,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: hsvg(dk(context, Svgs.s0, Svgs.s1), w: 20, h: 20),
                  ),
                ),
                Expanded(
                  child: Text(
                    _title,
                    textAlign: TextAlign.center,
                    style: hts(
                      17,
                      dk(
                        context,
                        const Color(0xFF18181B),
                        const Color(0xFFFAFAFA),
                      ),
                      w: FontWeight.w600,
                      lh: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 44),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: ColoredBox(
                  color: card,
                  child: _error != null
                      ? ErrorView(error: _error!, onRetry: _retry)
                      : Stack(
                          children: [
                            KeyedSubtree(
                              key: ValueKey('legal-$_attempt'),
                              child: legalWebViewBuilder(
                                legalUrl(widget.doc),
                                {'apikey': supabasePublishableKey},
                                () {
                                  if (mounted && !_loaded && _error == null) {
                                    setState(() => _loaded = true);
                                  }
                                },
                                (e) {
                                  if (mounted) setState(() => _error = e);
                                },
                              ),
                            ),
                            if (!_loaded)
                              const Center(child: CircularProgressIndicator()),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
