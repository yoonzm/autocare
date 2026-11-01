import 'package:flutter/foundation.dart';

/// 订阅状态：首页提醒条、到期页等界面是同一套界面在不同状态下的呈现。
enum SubState { normal, trialEnding, expiring, expired }

const subStateLabels = {
  SubState.normal: '正常使用',
  SubState.trialEnding: '试用将到期（剩 3 天）',
  SubState.expiring: '套餐将到期（剩 7 天）',
  SubState.expired: '套餐已到期',
};

final ValueNotifier<SubState> subState = ValueNotifier<SubState>(
  SubState.normal,
);
