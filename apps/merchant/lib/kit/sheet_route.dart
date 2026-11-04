import 'package:flutter/cupertino.dart' show CupertinoSheetRoute;
import 'package:flutter/material.dart';

/// 左上角是 ✕ 的表单 / 流程页统一的出场方式：iOS 整页 sheet。
///
/// - 从底部滑入，顶部露出上一页；上一页不缩放（显式给出 `topGap` 后 Flutter 不再缩放下层页面）。
/// - 手势下拉可以关闭；页面里的滚动区域用 sheet 提供的控制器，滚到顶后继续下拉也会关闭。
/// - 页面有未保存修改（`ConfirmDiscard` 拦截返回）时，下拉不会直接关闭，要点 ✕ 走放弃确认。
/// - 结果页（支付 / 开卡成功等）不使用它：设计稿要求禁止下拉返回。
///
/// 页面入口一律通过这里创建，不在各处自己 new `CupertinoSheetRoute`。
Route<T> appSheetRoute<T>({RouteSettings? settings, required Widget page}) =>
    CupertinoSheetRoute<T>(
      settings: settings,
      topGap: 0.08,
      scrollableBuilder: (_, controller) =>
          PrimaryScrollController(controller: controller, child: page),
    );
