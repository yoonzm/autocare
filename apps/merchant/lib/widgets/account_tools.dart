import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../backend/app_cache.dart';
import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';
import '../kit/kit.dart' show hBusy, hConfirm;
import '../routes.dart';
import '../theme.dart';

Widget accountAction(
  BuildContext context,
  String key,
  Widget child,
  Future<void> Function() action, {
  String? confirmation,
  String confirmLabel = '确认',
}) => BusyOverlay(
  actionKey: key,
  child: GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () async {
      if (isBusy(key)) return;
      if (confirmation != null) {
        final confirmed = await hConfirm(
          context,
          confirmation,
          ok: confirmLabel,
        );
        if (!confirmed || !context.mounted) return;
      }
      if (!isBusy(key)) {
        unawaited(
          runBusy(key, () async {
            try {
              await action();
            } catch (e) {
              if (context.mounted) AppToast.error(context, e);
            }
          }),
        );
      }
    },
    child: hBusy(key, child),
  ),
);

class AccountDevices extends StatefulWidget {
  final Widget Function(BuildContext, Map<String, dynamic>, Widget) row;
  const AccountDevices({super.key, required this.row});
  @override
  State<AccountDevices> createState() => _AccountDevicesState();
}

class _AccountDevicesState extends State<AccountDevices> {
  final _key = GlobalKey<AsyncViewState<List<Map<String, dynamic>>>>();
  @override
  Widget build(BuildContext context) => AsyncView<List<Map<String, dynamic>>>(
    key: _key,
    load: merchantApi.accountDevices,
    isEmpty: (d) => d.isEmpty,
    shrinkWrap: true,
    inlineError: true,
    pullToRefresh: false,
    skeletonScrollable: false,
    skeletonPadding: EdgeInsets.zero,
    waiting: const SizedBox(height: 60),
    skeleton: const Padding(
      padding: EdgeInsets.all(16),
      child: AppSkeleton(height: 28),
    ),
    empty: (_) =>
        const Padding(padding: EdgeInsets.all(16), child: Text('暂无登录设备')),
    onNext: () => openRoute(context, 'Login'),
    builder: (context, devices) => Column(
      children: [
        for (var i = 0; i < devices.length; i++) ...[
          if (i > 0) Divider(height: 1, indent: 16, color: C.stroke),
          widget.row(
            context,
            devices[i],
            devices[i]['current'] == true
                ? Text(
                    '当前设备',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: C.greenInk,
                    ),
                  )
                : accountAction(
                    context,
                    'device:${devices[i]['id']}',
                    Text(
                      '移除',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: C.redInk,
                      ),
                    ),
                    () async {
                      await merchantApi.revokeDevice('${devices[i]['id']}');
                      _key.currentState?.reload();
                    },
                    confirmation: '移除后，该设备需要重新登录才能使用。',
                    confirmLabel: '移除',
                  ),
          ),
        ],
      ],
    ),
  );
}

String accountDeviceName(Map<String, dynamic> d) =>
    '${d['name']}${d['current'] == true ? ' · 本机' : ''}';
String accountDeviceTime(Map<String, dynamic> d) {
  final time = DateTime.tryParse('${d['active_at']}')
      ?.toUtc()
      .add(const Duration(hours: 8));
  if (time == null) return '活跃时间未知';
  String two(int n) => n.toString().padLeft(2, '0');
  return '${time.year}.${two(time.month)}.${two(time.day)} ${two(time.hour)}:${two(time.minute)} 活跃';
}

class AccountCancellationChecks extends StatelessWidget {
  final Widget Function(BuildContext, Map<String, dynamic>) builder;
  const AccountCancellationChecks({super.key, required this.builder});
  @override
  Widget build(BuildContext context) => AsyncView<Map<String, dynamic>>(
    load: merchantApi.cancellationCheck,
    isEmpty: (_) => false,
    shrinkWrap: true,
    inlineError: true,
    pullToRefresh: false,
    skeletonScrollable: false,
    skeletonPadding: EdgeInsets.zero,
    waiting: const SizedBox(height: 174),
    skeleton: Column(
      children: [
        for (var i = 0; i < 3; i++)
          const Padding(
            padding: EdgeInsets.all(16),
            child: AppSkeleton(height: 26),
          ),
      ],
    ),
    empty: (_) => const SizedBox.shrink(),
    onNext: () => openRoute(context, 'Login'),
    builder: builder,
  );
}

String cancellationWork(Map<String, dynamic> check) =>
    check['can_cancel'] == true
    ? '当前无未处理挂单或预约'
    : '当前 ${check['holds']} 笔挂单、${check['appointments']} 笔预约未处理';

class AccountCachePanel extends StatelessWidget {
  final Widget Function(BuildContext, CacheUsage) builder;
  const AccountCachePanel({super.key, required this.builder});
  @override
  Widget build(BuildContext context) => AsyncView<CacheUsage>(
    load: AppCache.usage,
    isEmpty: (_) => false,
    shrinkWrap: true,
    inlineError: true,
    pullToRefresh: false,
    skeletonScrollable: false,
    skeletonPadding: EdgeInsets.zero,
    waiting: const SizedBox(height: 300),
    skeleton: const SizedBox(
      height: 300,
      child: Center(child: AppSkeleton(height: 132)),
    ),
    empty: (_) => const SizedBox.shrink(),
    builder: builder,
  );
}

Widget accountCacheClear(BuildContext context, Widget button) =>
    accountAction(context, 'cache:clear', button, () async {
      await AppCache.clear();
      if (!context.mounted) return;
      Navigator.of(context).pop();
      AppToast.show(context, '缓存已清除', kind: ToastKind.success);
    });
Widget accountSupportCall(BuildContext context, Widget row) =>
    accountAction(context, 'account:support', row, () async {
      final phone = await merchantApi.supportPhone();
      if (phone.isEmpty) throw const AppError('客服热线暂未配置');
      if (!await launchUrl(
        Uri(scheme: 'tel', path: phone),
        mode: LaunchMode.externalApplication,
      )) {
        throw const AppError('无法打开拨号，请在支持电话的设备上重试');
      }
    });

class AccountCacheText extends StatelessWidget {
  final TextStyle? style;
  const AccountCacheText({super.key, this.style});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
    valueListenable: AppCache.changed,
    builder: (context, _, child) => AsyncView<CacheUsage>(
      key: ValueKey(AppCache.changed.value),
      load: AppCache.usage,
      isEmpty: (_) => false,
      shrinkWrap: true,
      inlineError: true,
      pullToRefresh: false,
      skeletonScrollable: false,
      skeletonPadding: EdgeInsets.zero,
      waiting: const SizedBox(width: 38, height: 16),
      skeleton: const AppSkeleton(width: 38, height: 16),
      empty: (_) => const SizedBox.shrink(),
      builder: (_, usage) => Text(CacheUsage.format(usage.total), style: style),
    ),
  );
}

class AccountVersionText extends StatelessWidget {
  final TextStyle? style;
  final bool detailed;
  const AccountVersionText({super.key, this.style, this.detailed = false});
  @override
  Widget build(BuildContext context) => AsyncView<PackageInfo>(
    load: PackageInfo.fromPlatform,
    isEmpty: (_) => false,
    shrinkWrap: true,
    inlineError: true,
    pullToRefresh: false,
    skeletonScrollable: false,
    skeletonPadding: EdgeInsets.zero,
    waiting: const SizedBox(width: 50, height: 16),
    skeleton: const AppSkeleton(width: 50, height: 16),
    empty: (_) => const SizedBox.shrink(),
    builder: (_, info) => Text(
      detailed
          ? '版本 ${info.version} (${info.buildNumber})'
          : 'v${info.version}',
      style: style,
    ),
  );
}
