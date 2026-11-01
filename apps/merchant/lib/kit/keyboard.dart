import 'package:flutter/material.dart';

/// 收起软键盘。
void dismissKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

/// 点击输入框之外的区域时收起键盘（用于所有 TextField 的 onTapOutside）。
void onTapOutsideDismiss(PointerDownEvent _) => dismissKeyboard();
