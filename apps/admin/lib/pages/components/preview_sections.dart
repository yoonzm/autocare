import 'dart:async';

import 'package:autocare_ui_kit/autocare_ui_kit.dart';
import 'package:flutter/material.dart';

import 'preview_common.dart';

class PreviewSection {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> Function(BuildContext context) build;
  const PreviewSection(this.id, this.title, this.subtitle, this.icon, this.build);
}

/// 设计稿「组件库」各画板对应的预览分区。
final List<PreviewSection> previewSections = [
  PreviewSection('overview', '总览与分层', '5 层 · 26 个组件', Icons.layers_outlined, _overview),
  PreviewSection('tokens', '令牌', '颜色 · 字号 · 圆角 · 阴影', Icons.palette_outlined, _tokens),
  PreviewSection('buttons', '按钮', 'AppButton · AppIconButton', Icons.smart_button_outlined, _buttons),
  PreviewSection('choice', '选择类', '标签 · 分段 · 开关 · 加减', Icons.toggle_on_outlined, _choice),
  PreviewSection('input', '输入类', '行内输入 · 金额 · 搜索', Icons.edit_note_outlined, _input),
  PreviewSection('display', '展示类', '卡片 · 列表行 · 标签 · 头像', Icons.view_agenda_outlined, _display),
  PreviewSection('feedback', '提示与状态', '横幅 · 空 / 加载 / 错误', Icons.notifications_none_rounded, _feedback),
  PreviewSection('containers', '页面容器', '头部 · 底栏 · 弹层 · 导航', Icons.web_asset_outlined, _containers),
  PreviewSection('upload', '图片上传', '网格 · 单格槽位', Icons.add_photo_alternate_outlined, _upload),
  PreviewSection('composite', '业务组件拆分', '由基础组件拼出业务块', Icons.account_tree_outlined, _composite),
  PreviewSection('rules', '封装与定制约定', '三层 · 逻辑归属 · 可定制项', Icons.rule_folder_outlined, _rules),
];

PreviewSection? previewSectionById(String id) {
  for (final s in previewSections) {
    if (s.id == id) return s;
  }
  return null;
}

// ───────────────────────── 总览 ─────────────────────────
List<Widget> _overview(BuildContext context) {
  final t = AppTokens.of(context);
  Widget layer(int n, String name, String desc, Color color) => AppCard(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s14, vertical: AppSpacing.s10),
    child: Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Text('$n', style: t.small.copyWith(color: t.onPrimary, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: AppSpacing.s10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: t.base.copyWith(fontWeight: FontWeight.w600)),
              Text(desc, style: t.caption),
            ],
          ),
        ),
      ],
    ),
  );
  const names = [
    ('AppButton', '按钮'), ('AppIconButton', '圆形图标按钮'), ('AppChoiceChip', '选择标签'),
    ('AppSegmented', '分段控件'), ('AppSwitch', '开关'), ('AppStepper', '数量加减'),
    ('AppCheck / AppRadio', '多选 / 单选'), ('AppAddToggle', '加入 / 已选'), ('AppFormRow 等', '输入框'),
    ('AppSelectField', '选择行'), ('AppSearchBar', '搜索框'), ('AppCard', '卡片'),
    ('AppSectionTitle', '分组标题'), ('AppListRow', '列表行'), ('AppStatusTag', '状态标签'),
    ('AppBadge', '红点数字'), ('AppAvatar', '头像'), ('AppImageUploader', '图片上传'),
    ('AppHeroCard', '深色概览卡'), ('AppBanner', '提示横幅'), ('AppPageHeader', '页面头部'),
    ('AppBottomBar', '底部操作栏'), ('showAppBottomSheet', '底部弹层'), ('showAppDialog', '对话框'),
    ('AppBottomNav', '底部导航'), ('EmptyView 等', '空 / 加载 / 错误'),
  ];
  return [
    Demo(
      title: '组件分层',
      tag: '5 层',
      notes: const [
        '第 1~4 层放在组件库包 autocare_ui_kit，全项目共用；第 5 层放各业务模块自己的 widgets，不跨模块引用。',
        '上层可以引用下层，下层不能反向引用。',
        '组件不含业务逻辑、不请求数据：数据和回调都从参数传入。',
        '颜色只从 AppTokens 取，深色模式才能自动生效。',
      ],
      children: [
        layer(1, 'Tokens 令牌', '颜色、字号、圆角、阴影、间距。组件只引用令牌，不写色值', t.ink),
        layer(2, 'Atoms 基础元素', '按钮、标签、开关、输入框、状态标签、头像。不依赖别的组件', t.primary),
        layer(3, 'Molecules 组合组件', '卡片、列表行、搜索框、横幅、分段控件。由基础元素组成', t.success),
        layer(4, 'Containers 页面容器', '头部、底部栏、弹层、对话框、底部导航。负责布局和出场', t.warn.fg),
        layer(5, 'Features 业务组件', '商品行、会员行、结算明细。组合以上组件，带业务字段', t.inkFaint),
      ],
    ),
    Demo(
      title: '组件一览（共 26 个）',
      tag: '26 个',
      notes: const [
        '空 / 加载 / 错误等状态组件在「前端加载与反馈规范」里定义，由 async_kit 实现，组件库只引用。',
      ],
      children: [
        Wrap(
          spacing: AppSpacing.s6,
          runSpacing: AppSpacing.s6,
          children: [
            for (final (name, label) in names)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s10, vertical: AppSpacing.s6),
                decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(10)),
                child: Text.rich(
                  TextSpan(
                    text: name,
                    style: t.caption.copyWith(color: t.ink, fontWeight: FontWeight.w600),
                    children: [TextSpan(text: '  $label', style: TextStyle(color: t.inkMute, fontWeight: FontWeight.w400))],
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
    const Demo(
      title: '包结构',
      tag: 'packages/ui_kit',
      notes: [
        '命名统一用 App 前缀，文件名小写下划线；每个组件一个文件，配 widget test 与本页的预览。',
        '业务组件需要被第二个模块用到时，再上提到 molecules。',
      ],
      code: 'packages/ui_kit/lib/\n'
          '  autocare_ui_kit.dart        // 公共入口\n'
          '  src/\n'
          '    tokens/      app_tokens.dart\n'
          '    atoms/       app_button  app_icon_button  app_choice_chip\n'
          '                 app_switch  app_check  app_stepper\n'
          '                 app_status_tag  app_badge  app_avatar\n'
          '    molecules/   app_card  app_list_row  app_form  app_search_bar\n'
          '                 app_segmented  app_banner  app_hero_card\n'
          '                 app_image_uploader  app_input_format\n'
          '    containers/  app_page_header  app_bottom_bar\n'
          '                 app_bottom_sheet  app_dialog  app_bottom_nav\n'
          '    states/      // 引用 async_kit 的空 / 加载 / 错误 / Toast',
      children: [Text('目录结构见下方代码块。')],
    ),
  ];
}

// ───────────────────────── 令牌 ─────────────────────────
List<Widget> _tokens(BuildContext context) {
  final t = AppTokens.of(context);
  Widget swatch(String name, String hex, Color color) => SizedBox(
    width: 148,
    child: Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: t.fillStrong),
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: t.caption.copyWith(color: t.ink, fontWeight: FontWeight.w600)),
              Text(hex, style: t.caption.copyWith(fontSize: 11, fontFamily: 'monospace')),
            ],
          ),
        ),
      ],
    ),
  );
  String hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  Widget sw(String n, Color c) => swatch(n, hex(c), c);
  Widget pair(String name, StatusColors c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s10, vertical: AppSpacing.s6),
    decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(AppRadius.tag)),
    child: Text(name, style: t.micro.copyWith(color: c.fg)),
  );
  Widget type(String name, TextStyle style, String sample) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.s6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(width: 64, child: Text(name, style: t.caption.copyWith(fontFamily: 'monospace'))),
        Expanded(child: Text(sample, style: style, maxLines: 1, overflow: TextOverflow.ellipsis)),
        Text('${style.fontSize!.round()}/${(style.fontSize! * style.height!).round()} · ${style.fontWeight!.value}', style: t.caption),
      ],
    ),
  );
  return [
    Demo(
      title: '颜色',
      tag: 'AppTokens',
      notes: const ['主色只有一个蓝；黑色 #18181B 是文字色，不再作为选中色或按钮色。', '黑金卡的黑色是卡种内容色，不属于令牌。'],
      children: [
        Wrap(spacing: AppSpacing.s10, runSpacing: AppSpacing.s10, children: [
          sw('primary', t.primary), sw('primarySoft', t.primarySoft), sw('primaryText', t.primaryText),
          sw('ink', t.ink), sw('inkSub', t.inkSub), sw('inkMute', t.inkMute), sw('inkFaint', t.inkFaint),
          sw('bg', t.bg), sw('surface', t.surface), sw('fill', t.fill), sw('fillStrong', t.fillStrong),
          sw('line', t.line), sw('switchOff', t.switchOff), sw('success', t.success), sw('requiredStar', t.requiredStar),
        ]),
      ],
    ),
    Demo(
      title: '状态色',
      tag: 'StatusColors',
      notes: const ['状态色一律是「浅底 + 深字」成对出现。', '红色实心只用于红点数字和必填星。'],
      children: [
        Wrap(spacing: AppSpacing.s8, runSpacing: AppSpacing.s8, children: [
          pair('ok 成功', t.ok), pair('wait 进行中', t.wait), pair('warn 提醒', t.warn),
          pair('danger 失败', t.danger), pair('off 草稿', t.off),
        ]),
        Row(children: [
          swatch('gold', hex(t.gold), t.gold),
          swatch('badge', hex(t.badge), t.badge),
        ]),
      ],
    ),
    Demo(
      title: '字号',
      tag: 'AppTokens.text',
      notes: const ['字体：Inter + 苹果方体 / 思源黑体（中文）。', '金额、数量使用等宽数字（tabularFigures）。'],
      children: [
        type('display', t.display, '¥3,840'),
        type('title', t.title, '开单收银'),
        type('page', t.page, '页面标题'),
        type('body', t.body, '列表标题、输入文字'),
        type('base', t.base, '行标题、标签文字'),
        type('small', t.small, '选择标签、辅助说明'),
        type('caption', t.caption, '副标题、提示'),
        type('micro', t.micro, '状态标签'),
      ],
    ),
    Demo(
      title: '圆角、间距与阴影',
      tag: 'AppRadius / AppSpacing',
      notes: const [
        '间距刻度：4 · 6 · 8 · 10 · 12 · 14 · 16 · 20 · 24（只用这些值）。',
        '页面左右边距 20；卡片内边距 16；卡片之间 16；最小点击区域 44 × 44。',
        '按钮、标签是胶囊：圆角 = 高度 / 2。深色模式阴影改为 1px 细描边。',
      ],
      children: [
        Wrap(spacing: AppSpacing.s10, runSpacing: AppSpacing.s10, children: [
          for (final (name, r) in const [
            ('tag 9', AppRadius.tag), ('tile 12', AppRadius.tile), ('field 14', AppRadius.field),
            ('inset 16', AppRadius.inset), ('block 20', AppRadius.block), ('card 24', AppRadius.card),
            ('hero 28', AppRadius.hero), ('sheet 32', AppRadius.sheet),
          ])
            Column(children: [
              Container(
                width: 64,
                height: 44,
                decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(r), boxShadow: t.cardShadow),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(name, style: t.caption.copyWith(fontSize: 11)),
            ]),
        ]),
      ],
    ),
  ];
}

// ───────────────────────── 按钮 ─────────────────────────
List<Widget> _buttons(BuildContext context) => [
  Demo(
    title: '按钮',
    tag: 'AppButton',
    notes: const [
      'kind：primary / secondary / danger / text（surface 是白底带阴影的筛选按钮，补充约定）。黑色不是按钮色。',
      'size：large 50（底栏）· medium 44（页内）· small 32（卡片内）。',
      '点击后立即进入 loading：文字前加转圈、整体透明度 .72、不可再点，失败后恢复。',
      '禁用时用 fillStrong 底 + inkFaint 字，不只降透明度。左右并排：次要 : 主要 = 1 : 2。',
    ],
    code: "AppButton(\n  label: '确认收款',\n  kind: AppButtonKind.primary,   // secondary | danger | text\n  size: AppButtonSize.large,     // medium | small\n  loading: state.submitting,\n  onPressed: state.canSubmit ? submit : null,  // null = 禁用\n)",
    children: [
      const GroupLabel('主要 / 次要 / 危险 / 文字'),
      Wrap(spacing: AppSpacing.s10, runSpacing: AppSpacing.s10, children: [
        StateLabel('primary', AppButton(label: '保存', onPressed: () {})),
        StateLabel('surface', AppButton(label: '筛选', kind: AppButtonKind.surface, onPressed: () {})),
        StateLabel('secondary · 底栏', AppButton(label: '取消', kind: AppButtonKind.secondary, onPressed: () {})),
        StateLabel('danger', AppButton(label: '作废此单', kind: AppButtonKind.danger, onPressed: () {})),
        StateLabel('text', AppButton(label: '更换', kind: AppButtonKind.text, onPressed: () {})),
      ]),
      const GroupLabel('状态'),
      Wrap(spacing: AppSpacing.s10, runSpacing: AppSpacing.s10, children: [
        StateLabel('默认', AppButton(label: '确认收款', onPressed: () {})),
        const StateLabel('加载中', AppButton(label: '提交中', loading: true, onPressed: _noop)),
        const StateLabel('禁用', AppButton(label: '确认收款')),
      ]),
      const GroupLabel('尺寸'),
      Wrap(spacing: AppSpacing.s10, runSpacing: AppSpacing.s10, crossAxisAlignment: WrapCrossAlignment.end, children: [
        StateLabel('large · 高 50 · 底栏', AppButton(label: '确认入库', size: AppButtonSize.large, onPressed: () {})),
        StateLabel('medium · 高 44 · 页内', AppButton(label: '保存', onPressed: () {})),
        StateLabel('small · 高 32 · 卡片内', AppButton(label: '去补货', kind: AppButtonKind.secondary, size: AppButtonSize.small, onPressed: () {})),
      ]),
    ],
  ),
  Demo(
    title: '圆形图标按钮 / 胶囊图标按钮',
    tag: 'AppIconButton',
    notes: const [
      '页面头部的返回、关闭、右上角入口用它：白底 + 卡片阴影，44 × 44；「添加」这类入口用 kind: primary（主色实心）。',
      '带文字的入口（如「挂单 4」）是胶囊形，高度同样 44。右上角入口不放保存、提交这类主要操作，主要操作放在底栏。',
    ],
    code: "AppIconButton(icon: Icons.chevron_left_rounded, semanticLabel: '返回', onPressed: pop)\nAppIconButton.pill(label: '挂单', badge: 4, onPressed: openHold)",
    children: [
      Wrap(spacing: AppSpacing.s12, crossAxisAlignment: WrapCrossAlignment.center, children: [
        AppIconButton(icon: Icons.chevron_left_rounded, semanticLabel: '返回', onPressed: () {}),
        AppIconButton.pill(label: '挂单', badge: 4, onPressed: () {}),
        AppIconButton(icon: Icons.search_rounded, semanticLabel: '搜索', size: AppIconButtonSize.small, onPressed: () {}),
        AppIconButton(icon: Icons.add_rounded, semanticLabel: '添加', kind: AppIconButtonKind.primary, onPressed: () {}),
      ]),
    ],
  ),
];

void _noop() {}

// ───────────────────────── 选择类 ─────────────────────────
List<Widget> _choice(BuildContext context) => [
  Demo(
    title: '选择标签',
    tag: 'AppChoiceChip / AppChoiceGroup',
    notes: const [
      '选中 = 浅蓝底 + 1.5px 内描边蓝 + 蓝字，三者同时出现；未选中也预留同样空间，切换时不抖动。',
      '选中状态只来自一个受控变量 selected；同组最多一个。筛选、分类、客户来源、技师、支付方式都用这一个组件。',
    ],
    code: "AppChoiceGroup<int>(\n  items: [ChoiceItem(value: 1, label: '洗车'), ...],\n  selected: state.category,\n  onChanged: vm.setCategory,\n  kind: ChipKind.pill,   // tile | avatar | option\n)",
    children: [
      const GroupLabel('胶囊 pill · 高 34'),
      _Stateful<String>('洗车', (v, set) => AppChoiceGroup<String>(
        items: const [
          ChoiceItem(value: '洗车', label: '洗车'),
          ChoiceItem(value: '镀晶镀膜', label: '镀晶镀膜'),
          ChoiceItem(value: '改色膜', label: '改色膜'),
          ChoiceItem(value: '不可选', label: '不可选', enabled: false),
        ],
        selected: v,
        onChanged: set,
      )),
      const GroupLabel('方块 tile · 高 38'),
      _Stateful<String>('17:30', (v, set) => AppChoiceGroup<String>(
        kind: ChipKind.tile,
        items: const [
          ChoiceItem(value: '17:00', label: '17:00'),
          ChoiceItem(value: '17:30', label: '17:30'),
          ChoiceItem(value: '18:00', label: '18:00'),
          ChoiceItem(value: '14:00', label: '14:00', enabled: false),
        ],
        selected: v,
        onChanged: set,
      )),
      const GroupLabel('带头像 avatar · 高 36'),
      _Stateful<String>('李国强', (v, set) => AppChoiceGroup<String>(
        kind: ChipKind.avatar,
        items: const [
          ChoiceItem(value: '李国强', label: '李国强 · 镀晶', avatarName: '李'),
          ChoiceItem(value: '刘洋', label: '刘洋', avatarName: '刘'),
        ],
        selected: v,
        onChanged: set,
      )),
      const GroupLabel('方块选项 option · 支付方式'),
      _Stateful<String>('余额', (v, set) => AppChoiceGroup<String>(
        kind: ChipKind.option,
        items: const [
          ChoiceItem(value: '余额', label: '会员余额', subtitle: '可用 ¥3,680'),
          ChoiceItem(value: '扫码', label: '微信 / 支付宝', subtitle: '扫码收款'),
        ],
        selected: v,
        onChanged: set,
      )),
    ],
  ),
  Demo(
    title: '开关与选择框',
    tag: 'AppSwitch / AppCheck / AppRadio',
    notes: const [
      '开关 46 × 28，开 = 主色，关 = switchOff，滑块白色。单选、多选都是 22 圆；选中 = 主色实心 + 白色内容。',
      '列表里的「加入」按钮（AppAddToggle）28 圆，选中显示对勾。点击区域外扩到 44 × 44。',
    ],
    code: "AppSwitch(value: v, onChanged: set)\nAppCheck(value: v, onChanged: set)\nAppRadio<T>(value: a, group: g, onChanged: set)",
    children: [
      Wrap(spacing: AppSpacing.s16, runSpacing: AppSpacing.s8, crossAxisAlignment: WrapCrossAlignment.center, children: [
        _Stateful<bool>(true, (v, set) => AppSwitch(value: v, onChanged: set, semanticLabel: '开关')),
        _Stateful<bool>(false, (v, set) => AppSwitch(value: v, onChanged: set, semanticLabel: '开关')),
        const AppSwitch(value: true),
        _Stateful<bool>(true, (v, set) => AppCheck(value: v, onChanged: set, semanticLabel: '多选')),
        _Stateful<bool>(false, (v, set) => AppCheck(value: v, onChanged: set, semanticLabel: '多选')),
        _Stateful<String>('a', (v, set) => Row(mainAxisSize: MainAxisSize.min, children: [
          AppRadio<String>(value: 'a', group: v, onChanged: set, semanticLabel: '单选 a'),
          AppRadio<String>(value: 'b', group: v, onChanged: set, semanticLabel: '单选 b'),
        ])),
        _Stateful<bool>(false, (v, set) => AppAddToggle(selected: v, onChanged: set, semanticLabel: '加入')),
        _Stateful<bool>(true, (v, set) => AppAddToggle(selected: v, onChanged: set, semanticLabel: '已选')),
      ]),
    ],
  ),
  Demo(
    title: '分段控件',
    tag: 'AppSegmented',
    notes: const ['用于「切换整页内容」，选中是白色滑块；不用黑色，也不和选择标签混用。2~4 项，超过 4 项改用选择标签或下拉。'],
    code: "AppSegmented<int>(items: [...], selected: tab, onChanged: setTab)",
    children: [
      _Stateful<int>(0, (v, set) => AppSegmented<int>(
        items: const [
          SegmentItem(value: 0, label: '入库单'),
          SegmentItem(value: 1, label: '出库单'),
          SegmentItem(value: 2, label: '盘点单', badge: 2),
        ],
        selected: v,
        onChanged: set,
      )),
    ],
  ),
  Demo(
    title: '数量加减',
    tag: 'AppStepper',
    notes: const [
      '32 圆的减、加按钮，中间是数字（15/22 · 600，等宽数字）。标准样式两个按钮都是灰底；行内样式（选择服务弹层）白减蓝加。',
      '到下限减号置灰、到上限加号置灰；按住加减按钮连续增减；数字区可点开键盘直接输入（小数商品见 allowDecimal）。',
    ],
    code: "AppStepper(value: qty, min: 1, max: 99, onChanged: setQty)",
    children: [
      Wrap(spacing: AppSpacing.s20, runSpacing: AppSpacing.s10, crossAxisAlignment: WrapCrossAlignment.center, children: [
        StateLabel('标准', _Stateful<num>(2, (v, set) => AppStepper(value: v, min: 1, max: 99, onChanged: set))),
        StateLabel('到下限 · 减号置灰', _Stateful<num>(1, (v, set) => AppStepper(value: v, min: 1, max: 99, onChanged: set))),
        StateLabel('行内', _Stateful<num>(1, (v, set) => AppStepper(value: v, min: 0, max: 9, style: AppStepperStyle.inline, onChanged: set))),
        StateLabel('小数 · 步长 0.5', _Stateful<num>(1.5, (v, set) => AppStepper(value: v, min: 0, step: .5, allowDecimal: true, onChanged: set))),
      ]),
    ],
  ),
];

/// 预览里的受控状态小助手：组件本身不保存状态，由这里持有。
class _Stateful<T> extends StatefulWidget {
  final T initial;
  final Widget Function(T value, ValueChanged<T> set) builder;
  const _Stateful(this.initial, this.builder);

  @override
  State<_Stateful<T>> createState() => _StatefulState<T>();
}

class _StatefulState<T> extends State<_Stateful<T>> {
  late T value = widget.initial;

  @override
  Widget build(BuildContext context) =>
      widget.builder(value, (v) => setState(() => value = v));
}

// ───────────────────────── 输入类 ─────────────────────────
List<Widget> _input(BuildContext context) => [
  Demo(
    title: '行内输入（表单默认）',
    tag: 'AppFormCard / AppFormRow',
    notes: const [
      '标签在左（宽 64 或 72），输入在右对齐，行高至少 54；必填在标签后加红星；单位放在输入右侧。',
      '错误：标签变红，行下方右对齐 12px 红字。手机号分段、金额千分位等格式化是组件内置逻辑；没值时必须有占位文字。',
    ],
    code: "AppFormCard(children: [\n  AppFormRow(label: '手机号', hint: '请输入手机号', required: true,\n    format: AppInputFormat.phone, controller: tel),\n  AppFormRow(label: '安全库存', hint: '数量', suffix: '卷',\n    errorText: vm.stockError),\n])",
    children: [
      const AppFormCard(children: [
        AppFormRow(label: '手机号', hint: '请输入手机号', required: true, format: AppInputFormat.phone),
        AppFormRow(label: '姓名', hint: '请输入客户姓名', required: true),
        AppFormRow(label: '车牌号', hint: '选填'),
        AppFormRow(label: '安全库存', hint: '数量', required: true, suffix: '卷', format: AppInputFormat.integer),
        AppFormRow(label: '成本价', hint: '0.00', suffix: '元', errorText: '成本价不能小于 0', format: AppInputFormat.amount),
      ]),
    ],
  ),
  Demo(
    title: '小数字输入 / 选择行 / 金额输入 / 多行输入',
    tag: 'AppNumberBox · AppSelectField · AppAmountField · AppTextArea',
    notes: const [
      '小数字输入：48 × 36 灰色框，居中，圆角 10；选择行：灰底块圆角 14，没选显示灰色占位。',
      '金额输入：灰底块圆角 16，数字 26/32 · 600，一个页面最多一两个；多行输入：标签在上，最小高 64。',
    ],
    children: [
      const AppCard(padding: EdgeInsets.zero, child: AppNumberBox(label: '提成比例', hint: '0', suffix: '%', caption: '约 ¥126 / 单')),
      _Stateful<String?>(null, (v, set) => AppSelectField(
        label: '推荐人',
        placeholder: '请选择',
        value: v,
        onTap: () => set(v == null ? '王建国 · 黑金' : null),
      )),
      const AppAmountField(label: '门店价', hint: '0.00'),
      const AppTextArea(label: '备注', hint: '如：车主偏好、车辆旧伤位置'),
    ],
  ),
  Demo(
    title: '输入框（标签在上）',
    tag: 'AppTextField',
    notes: const [
      '13/18 · 500 的标签，下方灰底块（圆角 14，最小高 48）；必填标签后加红星；错误时灰底块加红描边，下方显示 12px 红字。',
      '密码框内置显示 / 隐藏按钮；hint 必填，没有值时一定有占位文字。成排的设置类表单用 AppFormRow。',
    ],
    code: "AppTextField(label: '密码', required: true, hint: '请输入密码',\n  obscure: true, errorText: vm.passwordError, onSubmitted: login)",
    children: [
      const AppCard(
        child: Column(children: [
          AppTextField(label: '用户名', required: true, hint: '请输入用户名'),
          SizedBox(height: AppSpacing.s14),
          AppTextField(label: '密码', required: true, hint: '请输入密码', obscure: true, errorText: '用户名或密码错误'),
        ]),
      ),
    ],
  ),
  Demo(
    title: '搜索框',
    tag: 'AppSearchBar',
    notes: const ['白底胶囊，高 44，带卡片阴影；输入后 300ms 防抖再请求，清空按钮在输入后出现；搜索结果为空显示「空数据状态」。'],
    code: "AppSearchBar(hint: '搜索商品名称 / SKU', onChanged: vm.search,\n  trailing: AppIconButton(icon: scan, semanticLabel: '扫码'))",
    children: [
      _Stateful<String>('', (v, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AppSearchBar(
          hint: '搜索商品名称 / SKU',
          onChanged: set,
          trailing: AppIconButton(icon: Icons.qr_code_scanner_rounded, semanticLabel: '扫码', onPressed: () {}),
        ),
        const SizedBox(height: AppSpacing.s8),
        Builder(builder: (context) => Text(v.isEmpty ? '防抖后的搜索词：（空）' : '防抖后的搜索词：$v', style: AppTokens.of(context).caption)),
      ])),
    ],
  ),
];

// ───────────────────────── 展示类 ─────────────────────────
List<Widget> _display(BuildContext context) => [
  Demo(
    title: '卡片 + 分组标题',
    tag: 'AppCard / AppSectionTitle',
    notes: const ['白底、圆角 24、内边距 16、卡片阴影；卡片之间 16；页面背景上的卡片不加描边。分组标题 13/18 · 500，灰字，左缩进 4。'],
    code: "AppSectionTitle('基础设置')\nAppCard(child: ...)",
    children: [
      const AppSectionTitle('基础设置'),
      const AppCard(child: Text('店铺名称  汽美旗舰店')),
    ],
  ),
  Demo(
    title: '状态标签、红点',
    tag: 'AppStatusTag / AppBadge',
    notes: const ['状态标签：高 18、圆角 9、11/600、浅底 + 深字，5 种：ok / wait / bad / off / warn；补充 violet（店长等角色）、dark（老板，黑底金字）、gold / okOnDark（只用在深色概览卡上）。', '红点数字：最小宽 18、圆角 9，只用于待处理数量。车牌、黑金卡种这类内容标签不使用状态色。'],
    code: "AppStatusTag('已入库', tone: Tone.ok)\nAppBadge(count: 4)",
    children: [
      const Wrap(spacing: AppSpacing.s8, runSpacing: AppSpacing.s8, crossAxisAlignment: WrapCrossAlignment.center, children: [
        AppStatusTag('已入库', tone: Tone.ok),
        AppStatusTag('进行中', tone: Tone.wait),
        AppStatusTag('已作废', tone: Tone.bad),
        AppStatusTag('草稿', tone: Tone.off),
        AppStatusTag('临期', tone: Tone.warn),
        AppStatusTag('低库存', tone: Tone.bad),
        AppStatusTag('店长', tone: Tone.violet),
        AppStatusTag('老板', tone: Tone.dark),
        AppBadge(count: 4),
        AppBadge(count: 128),
      ]),
    ],
  ),
  Demo(
    title: '深色概览卡',
    tag: 'AppHeroCard',
    notes: const ['深底白字、圆角 28，右上角有同心圆装饰；每页最多一张；深色模式下改为 surface 色加描边。', '需要放头像、状态等任意内容时用 AppHeroCard.custom，默认是品牌渐变加金色光晕（后台概览、账号详情顶部）。'],
    code: "AppHeroCard(title: '库存概览', value: '¥86,420', footnote: '...')",
    children: [
      const AppHeroCard(title: '库存概览', value: '¥86,420', footnote: '248 种商品 · 7 项低库存'),
      const AppHeroCard.custom(
        child: Row(children: [
          AppAvatar(name: '刘', size: 48),
          SizedBox(width: AppSpacing.s12),
          Expanded(child: _HeroDemoText()),
          AppStatusTag('正常', tone: Tone.gold),
        ]),
      ),
    ],
  ),
  Demo(
    title: '列表行',
    tag: 'AppListRow / AppListGroup',
    notes: const ['最小高 54；左侧可选 32 圆角图标底；右侧可放文字、箭头、开关。分割线 1px，左缩进，最后一行不画。', '整行可点时才显示箭头；点击反馈为整行叠 4% 黑色。'],
    code: "AppListRow(\n  title: '工位管理', subtitle: '共 6 个工位',\n  leading: AppIconTile(icon: ..., tone: Tone.wait),\n  onTap: openBays,\n)",
    children: [
      AppListGroup(rows: [
        AppListRow(title: '营业时间', value: '每天 09:00 – 21:00', leading: const AppIconTile(icon: Icons.schedule_rounded, tone: Tone.warn), onTap: () {}),
        AppListRow(title: '工位管理', subtitle: '共 6 个工位', leading: const AppIconTile(icon: Icons.grid_view_rounded), onTap: () {}),
        AppListRow(
          title: '消息通知',
          subtitle: '已开启',
          leading: const AppIconTile(icon: Icons.notifications_none_rounded, tone: Tone.bad),
          trailing: _Stateful<bool>(true, (v, set) => AppSwitch(value: v, onChanged: set, semanticLabel: '消息通知')),
        ),
      ]),
    ],
  ),
  Demo(
    title: '头像',
    tag: 'AppAvatar',
    notes: const ['默认 44 圆；字取姓；会员按卡种配色（黑金 = 黑底金字）；没有名字时用灰色人像图标；小头像 28 用于选择标签内部。'],
    code: "AppAvatar(name: '王建国', tier: AppAvatarTier.blackGold, size: 44)",
    children: [
      const Wrap(spacing: AppSpacing.s12, crossAxisAlignment: WrapCrossAlignment.center, children: [
        AppAvatar(name: '王'),
        AppAvatar(name: '刘', tier: AppAvatarTier.blackGold),
        AppAvatar(name: '李', tier: AppAvatarTier.gold),
        AppAvatar(name: '陈', tier: AppAvatarTier.silver),
        AppAvatar(name: '赵', tier: AppAvatarTier.normal),
        AppAvatar(name: ''),
        AppAvatar(name: '周', size: 28),
      ]),
    ],
  ),
];

class _HeroDemoText extends StatelessWidget {
  const _HeroDemoText();

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('139 1122 3344', style: t.title.copyWith(color: t.heroInk)),
        Text('自定义内容 · 渐变样式', style: t.caption.copyWith(color: t.heroInkSub)),
      ],
    );
  }
}

// ───────────────────────── 提示与状态 ─────────────────────────
List<Widget> _feedback(BuildContext context) {
  final t = AppTokens.of(context);
  Widget row(String name, String desc) => Container(
    margin: const EdgeInsets.only(bottom: AppSpacing.s8),
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s14, vertical: AppSpacing.s10),
    decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(AppRadius.field)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 130, child: Text(name, style: t.caption.copyWith(color: t.wait.fg, fontFamily: 'monospace'))),
        Expanded(child: Text(desc, style: t.small.copyWith(fontWeight: FontWeight.w400))),
      ],
    ),
  );
  return [
    Demo(
      title: '提示横幅',
      tag: 'AppBanner',
      notes: const ['圆角 14、内边距 10 × 14、13/18 · 500；左侧一个 16 图标；info / warn / err 三种，浅底 + 深字。', '出现在页面内容顶部或表单上方，不盖住内容，也不自动消失。'],
      code: "AppBanner.warn('7 项低于安全库存', onTap: openLow)",
      children: [
        AppBanner.warn('7 项低于安全库存，另有 2 项将在 30 天内过期', onTap: () {}),
        const AppBanner.err('库存不足，无法出库。请先减少数量或先入库。'),
        const AppBanner.info('同一时间只能有一张进行中的盘点单。'),
      ],
    ),
    Demo(
      title: '其他状态组件对照',
      tag: 'EmptyView 等',
      notes: const ['这些组件的尺寸、文案、时序都已在「前端加载与反馈规范」里写明，由 async_kit 实现。页面里只允许用这几个组件表达加载 / 空 / 错误。'],
      children: [
        row('EmptyView', '空数据（AppEmptyState）'),
        row('AppSkeleton', '首次加载，骨架屏'),
        row('AppToast', '轻提示、刷新失败'),
        row('ErrorView', '整页加载失败、重试（AppErrorView）'),
        row('LoadingButton', '按钮提交状态'),
        const SizedBox(height: AppSpacing.s4),
        const AppSkeleton(width: 160, height: 18),
        const SizedBox(height: AppSpacing.s8),
        const AppSkeleton(height: 44, radius: 22),
      ],
    ),
  ];
}

// ───────────────────────── 页面容器 ─────────────────────────
List<Widget> _containers(BuildContext context) => [
  Demo(
    title: '页面头部',
    tag: 'AppPageHeader',
    notes: const ['左侧返回或关闭（圆形图标按钮 44），标题居中 17/24 · 600，右侧最多一个入口。弹层式页面用关闭 ×，进入下一级用返回 ‹。', '有底部操作栏时，右上角不再放保存、提交。'],
    code: "AppPageHeader(title: '新增商品', leading: HeaderLeading.close, trailing: ...)",
    children: [
      AppPageHeader(title: '新增商品', leading: HeaderLeading.close, onLeading: () {}),
      AppPageHeader(title: '全部商品', onLeading: () {}, trailing: AppIconButton(icon: Icons.search_rounded, semanticLabel: '搜索', onPressed: () {})),
    ],
  ),
  Demo(
    title: '底部操作栏',
    tag: 'AppBottomBar',
    notes: const ['固定在底部，左右内边距 20，顶部 1px 分割线，底部安全区另加。一个主要按钮；有次要按钮时，次要 : 主要 = 1 : 2。', '结算类页面左侧显示金额，不超过两行；内容区底部要留出栏高度。'],
    code: "AppBottomBar(summary: AppAmountSummary(...), secondary: AppButton(...), primary: AppButton(...))",
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.inset),
        child: Column(children: [
          AppBottomBar(
            secondary: AppButton(label: '取消', kind: AppButtonKind.secondary, onPressed: () {}),
            primary: AppButton(label: '确认入库', onPressed: () {}),
          ),
          AppBottomBar(
            summary: const AppAmountSummary(caption: '应收 · 已优惠 ¥226', amount: '¥1,422.00'),
            secondary: AppButton(label: '挂单', kind: AppButtonKind.secondary, onPressed: () {}),
            primary: AppButton(label: '确认收款', onPressed: () {}),
          ),
        ]),
      ),
    ],
  ),
  Demo(
    title: '底部弹层 / 对话框',
    tag: 'showAppBottomSheet / showAppDialog',
    notes: const [
      '弹层：遮罩 50% 黑，顶部圆角 32，小横条 40 × 5，标题 20/28 · 600，内容可滚动，按钮在底部固定；点遮罩或下滑关闭，有未保存内容时先二次确认。',
      '对话框：只用于「确认」类打断，宽 280、圆角 28；按钮并排，取消在左，危险操作的确认按钮用危险色。',
    ],
    code: "showAppBottomSheet(context, title: '选择供应商', builder: ..., actions: [...])\nshowAppDialog(context, title: '确认停用？', message: '...', danger: true)",
    children: [
      Wrap(spacing: AppSpacing.s10, runSpacing: AppSpacing.s10, children: [
        Builder(builder: (context) => AppButton(
          label: '打开弹层',
          kind: AppButtonKind.surface,
          onPressed: () => showAppBottomSheet<void>(
            context,
            title: '选择供应商',
            hasUnsavedChanges: () => true,
            builder: (_) => const Column(children: [
              AppListGroup(rows: [
                AppListRow(title: '蓝盾膜业', subtitle: '贴膜'),
                AppListRow(title: '驰光贸易', subtitle: '养护用品'),
              ]),
            ]),
            actions: [
              AppButton(label: '取消', kind: AppButtonKind.secondary, onPressed: () => Navigator.pop(context)),
              AppButton(label: '确定', onPressed: () => Navigator.pop(context)),
            ],
          ),
        )),
        Builder(builder: (context) => AppButton(
          label: '打开对话框',
          kind: AppButtonKind.surface,
          onPressed: () => showAppDialog(context, title: '确认停用此商品？', message: '停用后不能再入库出库，历史记录保留。', confirmLabel: '停用', cancelLabel: '再想想', danger: true),
        )),
      ]),
    ],
  ),
  Demo(
    title: '底部导航',
    tag: 'AppBottomNav',
    notes: const ['5 个位置，中间是凸起的扫码浮动按钮，高 84（含安全区另加）。当前项：主色图标和文字 + 下方 4px 圆点；其他项 inkMute。只在一级页面出现。'],
    code: "AppBottomNav(items: [...], current: tab, onScan: openScan, onTap: switchTab)",
    children: [
      const SizedBox(height: AppSpacing.s16),
      _Stateful<int>(2, (v, set) => ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.inset),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(padding: EdgeInsets.zero),
          child: AppBottomNav(
            current: v,
            onTap: set,
            onScan: () {},
            items: const [
              AppNavItem(label: '首页', icon: Icons.home_outlined),
              AppNavItem(label: '会员', icon: Icons.people_outline_rounded),
              AppNavItem(label: '库存', icon: Icons.inventory_2_outlined),
              AppNavItem(label: '统计', icon: Icons.bar_chart_rounded),
            ],
          ),
        ),
      )),
    ],
  ),
];

// ───────────────────────── 图片上传 ─────────────────────────
List<Widget> _upload(BuildContext context) => [
  Demo(
    title: '多张图片（凭证、商品图）',
    tag: 'AppImageUploader.grid',
    notes: const [
      '方块 72 × 72，圆角 16，间距 10；「添加」格永远排在最后，传满后消失；标题右侧写 已选 / 上限，上传中和失败的也计入。',
      '已上传：右上角删除角标；上传中：遮罩 + 百分比 + 3px 进度条，点遮罩可取消；失败：浅红底 + 「重试」，只重试这一张，不自动重试。',
      '这里点「添加」会模拟一次上传（第 3 张会失败，点它重试），仅用于预览组件状态，不会真的选择或上传图片。',
    ],
    code: "AppImageUploader.grid(\n  title: '凭证', max: 6, items: vm.proofs,\n  onPick: vm.addProof, onRemove: vm.removeProof, onRetry: vm.retryProof,\n)",
    children: [const _UploadGridDemo()],
  ),
  Demo(
    title: '单张证件、门店照',
    tag: 'AppImageUploader.slot',
    notes: const ['高 110，圆角 16，一行两个各占一半；部位名写在格内。未上传：虚线边框 + 相机图标；已上传：右上角绿色对勾；上传中：百分比 + 底部进度条；失败：浅红底 + 重试。', '已上传的格子再点一下，就是重新选择并替换，不先弹删除确认。'],
    code: "AppImageUploader.slot(\n  label: '人像面', item: vm.idFront,\n  onPick: vm.pickIdFront, onRetry: vm.retryIdFront,\n)",
    children: [
      Row(children: [
        Expanded(child: AppImageUploader.slot(label: '人像面', item: const AppUploadItem(id: 'a', state: AppUploadState.uploaded), onPick: () {})),
        const SizedBox(width: AppSpacing.s10),
        Expanded(child: AppImageUploader.slot(label: '国徽面', onPick: () {})),
      ]),
      Row(children: [
        Expanded(child: AppImageUploader.slot(label: '门头照', item: const AppUploadItem(id: 'b', state: AppUploadState.uploading, progress: .62))),
        const SizedBox(width: AppSpacing.s10),
        Expanded(child: AppImageUploader.slot(label: '店内照', item: const AppUploadItem(id: 'c', state: AppUploadState.failed), onRetry: (_) {})),
      ]),
    ],
  ),
  Demo(
    title: '通用规则',
    tag: 'AppImageRules',
    notes: const [
      '来源：拍照、相册，不支持文件管理器。格式 JPG、PNG，HEIC 先转 JPG。长边压到 2048px 以内，单张不超过 5 MB，超过提示「图片超过 5 MB」。',
      '网格默认最多 6 张；槽位固定 1 张；单张超时 60 秒；失败只重试失败的那张；上传中返回前二次确认；还有图片在传时点保存弹 Toast「还有图片没传完」。',
      '压缩、转码、权限和上传请求属于适配层，不在组件里：组件只显示传入的状态。',
    ],
    children: [
      Builder(builder: (context) => Text(
        '长边 ≤ ${AppImageRules.maxEdge}px · 单张 ≤ ${AppImageRules.maxBytes ~/ 1048576} MB · 网格默认 ${AppImageRules.defaultMax} 张 · 超时 ${AppImageRules.timeout.inSeconds} 秒 · ${AppImageRules.formats.join(" / ").toUpperCase()}',
        style: AppTokens.of(context).small,
      )),
    ],
  ),
];

/// 模拟上传的网格预览：点「添加」生成一张「上传中」的图，几秒后变成已上传（第 3 张失败）。
class _UploadGridDemo extends StatefulWidget {
  const _UploadGridDemo();

  @override
  State<_UploadGridDemo> createState() => _UploadGridDemoState();
}

class _UploadGridDemoState extends State<_UploadGridDemo> {
  final items = <AppUploadItem>[
    const AppUploadItem(id: '1', state: AppUploadState.uploaded),
  ];
  var counter = 1;
  final timers = <Timer>[];

  @override
  void dispose() {
    for (final t in timers) {
      t.cancel();
    }
    super.dispose();
  }

  void _replace(String id, AppUploadItem next) {
    final i = items.indexWhere((e) => e.id == id);
    if (i >= 0 && mounted) setState(() => items[i] = next);
  }

  void _simulate(String id, {required bool fail}) {
    _replace(id, AppUploadItem(id: id, state: AppUploadState.uploading, progress: .1));
    var progress = .1;
    late Timer timer;
    timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      progress += .3;
      if (progress >= 1) {
        timer.cancel();
        _replace(id, AppUploadItem(id: id, state: fail ? AppUploadState.failed : AppUploadState.uploaded));
      } else {
        _replace(id, AppUploadItem(id: id, state: AppUploadState.uploading, progress: progress));
      }
    });
    timers.add(timer);
  }

  void _add() {
    counter++;
    final id = '$counter';
    setState(() => items.add(AppUploadItem(id: id, state: AppUploadState.uploading)));
    _simulate(id, fail: counter == 3);
  }

  @override
  Widget build(BuildContext context) => AppImageUploader.grid(
    title: '凭证',
    max: 4,
    items: items,
    onPick: _add,
    onRemove: (i) => setState(() => items.removeWhere((e) => e.id == i.id)),
    onRetry: (i) => _simulate(i.id, fail: false),
    onCancel: (i) => setState(() => items.removeWhere((e) => e.id == i.id)),
  );
}

// ───────────────────────── 业务组件拆分 ─────────────────────────
List<Widget> _composite(BuildContext context) {
  final t = AppTokens.of(context);
  Widget kv(String k, String v, {Color? color, bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Expanded(child: Text(k, style: t.small.copyWith(color: t.inkSub, fontWeight: FontWeight.w400))),
      Text(v, style: t.small.copyWith(color: color ?? t.ink, fontWeight: bold ? FontWeight.w600 : FontWeight.w500, fontFeatures: AppTokens.tabular)),
    ]),
  );
  return [
    Demo(
      title: '商品行（库存、选择商品弹层）',
      tag: 'ProductRow',
      notes: const ['由 AppListRow 组成：leading 图标块 + 标题行（名称 + AppStatusTag）+ 副标题 + trailing 数量；选择商品弹层里 leading 换成 AppCheck。', '业务组件只组合基础组件，不重写样式；需要新样式时先问能不能给基础组件加一个参数。这里只是拆分示例，业务页面仍使用各自模块的实现。'],
      children: [
        AppListGroup(rows: [
          AppListRow(
            title: '隐形车衣 TPU 1.52m',
            subtitle: '贴膜 · A-02 · 参考成本 ¥1,280',
            leading: const AppIconTile(icon: Icons.inventory_2_outlined),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              const AppStatusTag('低库存', tone: Tone.bad),
              const SizedBox(width: AppSpacing.s8),
              Text('3 卷', style: t.body.copyWith(color: t.danger.fg, fontWeight: FontWeight.w600, fontFeatures: AppTokens.tabular)),
            ]),
          ),
          AppListRow(
            title: '改色膜 哑光黑',
            subtitle: '贴膜 · A-03 · 参考成本 ¥640',
            leading: const AppIconTile(icon: Icons.inventory_2_outlined),
            trailing: Text('5 卷', style: t.body.copyWith(fontWeight: FontWeight.w600, fontFeatures: AppTokens.tabular)),
          ),
        ]),
      ],
    ),
    Demo(
      title: '结算明细',
      tag: 'SettleSummary',
      notes: const ['由 AppCard + 若干键值行 + 分割线组成；金额全部用等宽数字。优惠项用成功色，抵扣项用 − 号。'],
      children: [
        AppCard(
          child: Column(children: [
            kv('项目合计', '¥1,648.00'),
            kv('次卡抵扣 · 精致洗车 1 次', '-¥68.00', color: t.ok.fg),
            kv('黑金会员 9 折', '-¥158.00', color: t.ok.fg),
            Container(height: 1, margin: const EdgeInsets.symmetric(vertical: 6), color: t.line),
            kv('应收', '¥1,422.00', bold: true),
          ]),
        ),
      ],
    ),
  ];
}

// ───────────────────────── 封装与定制约定 ─────────────────────────
List<Widget> _rules(BuildContext context) {
  final t = AppTokens.of(context);
  Widget table(List<List<String>> rows, List<double> widths) => Column(
    children: [
      for (var i = 0; i < rows.length; i++)
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: t.line))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var j = 0; j < rows[i].length; j++)
                Expanded(
                  flex: (widths[j] * 10).round(),
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.s8),
                    child: Text(
                      rows[i][j],
                      style: t.caption.copyWith(
                        color: i == 0 ? t.inkMute : t.ink,
                        fontWeight: i == 0 || j == 0 ? FontWeight.w600 : FontWeight.w400,
                        height: 18 / 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
    ],
  );
  return [
    Demo(
      title: '一个组件包含什么',
      tag: '三层',
      notes: const [
        '页面里禁止写 Color(0x…)、TextStyle(fontSize: …) 去改组件外观。',
        '组件内部状态尽量由外部传入（受控）：选中、开关、数值这类业务相关的值不放在组件里自己保存。',
      ],
      children: [
        table(const [
          ['层', '内容'],
          ['1 默认样式', '按组件库数值实现，颜色字号圆角来自 AppTokens，浅色和深色自动切换'],
          ['2 内置逻辑', '状态切换、防重复点击、范围限制、格式化、无障碍等通用行为，写在组件里'],
          ['3 受限的定制', '只通过参数开放：尺寸档、语义类型、文案、图标、插槽；没有「任意颜色」这类自由样式参数'],
        ], const [2, 6]),
      ],
    ),
    Demo(
      title: '逻辑放在组件里，还是页面里',
      tag: '判断标准',
      notes: const ['判断标准：这段逻辑换一个页面还一样吗？一样 → 放组件；跟具体业务有关 → 放页面或 ViewModel。', '例：数字输入限制范围属于组件；「库存不足不能出库」属于页面。'],
      children: [
        table(const [
          ['逻辑归属', '组件自己负责', '页面 / ViewModel 负责'],
          ['状态外观', '默认、按下、聚焦、禁用、加载、选中', '决定什么时候禁用、什么时候加载'],
          ['交互行为', '防重复点击、热区 44、长按连续增减、搜索防抖 300ms、范围钳制', '点击后做什么（提交、跳转）'],
          ['输入格式', '手机号分段、金额千分位、小数位数、键盘类型', '校验规则、错误文案'],
          ['无障碍', '语义标签、选中状态朗读', '提供 semanticLabel 文案'],
          ['数据', '不持有业务数据，只显示传入的值', '拉取、保存、缓存策略'],
        ], const [1.4, 3.4, 3]),
      ],
    ),
    Demo(
      title: '参数怎么设计',
      tag: '代码约定',
      notes: const ['用枚举表达语义（kind、size、tone），不用 Color、double。', '需要新的外观，说明缺的是一种「语义」：在组件里加一个枚举值，颜色放进 AppTokens，更新组件库；业务专属样式放到业务模块的组件里。'],
      code: "// 好：只开放有限的、有语义的参数\nclass AppButton extends StatefulWidget {\n  final String label;\n  final AppButtonKind kind;\n  final AppButtonSize size;\n  final bool loading;\n  final VoidCallback? onPressed; // null = 禁用\n  // 没有 color / radius / height / textStyle 参数\n}\n// 差：把样式整个放开\nAppButton(label: '保存', color: Colors.black)  // ✗",
      children: [
        table(const [
          ['可以自定义（参数）', '不可以自定义'],
          ['size · kind / tone · label · icon · leading / trailing 插槽 · expanded · enabled / loading · semanticLabel', '任意颜色 · 任意字号字重 · 任意圆角 · 阴影 · 改点击反馈 · 关掉无障碍语义 · 绕过防重复点击'],
        ], const [1, 1]),
      ],
    ),
    Demo(
      title: '各组件的内置逻辑与可定制项',
      tag: '对照表',
      notes: const ['开发每做一个组件，先对照这张表，参数不要超出「可自定义」一列。'],
      children: [
        table(const [
          ['组件', '内置逻辑', '可自定义'],
          ['AppButton', '防重复点击 · 加载态 · 按下反馈', 'kind size loading icon expanded'],
          ['AppChoiceGroup', '单选互斥 · 内描边不抖动 · 禁用项跳过', 'kind items selected'],
          ['AppSwitch', '点按 · 触觉反馈', 'value onChanged'],
          ['AppStepper', '上下限 · 长按连续 · 小数位', 'min max step allowDecimal style'],
          ['AppFormRow', '键盘类型 · 格式化 · 错误显示位置', 'label required suffix errorText'],
          ['AppSearchBar', '防抖 300ms · 清空按钮', 'hint onChanged trailing'],
          ['AppListRow', '整行点击反馈 · 分割线处理', 'title subtitle leading trailing onTap'],
          ['AppBottomSheet', '遮罩 · 下滑关闭 · 未保存确认', 'title builder actions'],
          ['AppBottomBar', '安全区 · 键盘弹起时的位置', 'summary secondary primary'],
        ], const [1.4, 3, 2.4]),
      ],
    ),
  ];
}
