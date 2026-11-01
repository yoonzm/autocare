# Merchant app

汽美管家商户端 Flutter 原型，从 LanScope 仓库的 `claude/sleepy-clarke-4ehenr` 分支（提交 `e696c67`）迁入。目前使用 mock 数据，尚未接入 Supabase。

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

应用标识：iOS 与 Android 均为 `com.yoonzm.autocare.merchant`。iOS 发布需为该标识重新创建 Apple App、Provisioning Profile 和 Actions Secrets，不得沿用 LanScope 的描述文件。
