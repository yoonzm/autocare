import '../../kit/buttons.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../resources/merchant_svgs.dart';

import 'package:image_picker/image_picker.dart';

import '../../backend/feedback_draft.dart';
import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../kit/text_input.dart';
import '../../widgets/feedback_recovery_scope.dart';
import '../../routes.dart' show openRoute;

class FeedbackPage extends StatefulWidget {
  final Future<XFile?> Function()? pickImage;
  const FeedbackPage({super.key, this.pickImage});
  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _api = merchantApi;
  final _description = TextEditingController(),
      _contact = TextEditingController();
  final _type = SelCtrl({0}, false);
  late FeedbackDraft _draft;
  FeedbackRecovery? _recovery;
  String? _owner;
  bool _initialized = false, _busy = false;
  late final _submitKey = 'feedback-submit-${identityHashCode(this)}';
  late final _imageKeys = List.generate(
    3,
    (i) => 'feedback-image-${identityHashCode(this)}-$i',
  );
  @override
  void initState() {
    super.initState();
    _owner = _api.accountId;
    authExpired.addListener(_saveForLogin);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _recovery = FeedbackRecoveryScope.maybeOf(context);
    _draft = _recovery?.take(_owner) ?? FeedbackDraft();
    _description.text = _draft.text;
    _contact.text = _draft.contact;
    _type.selected
      ..clear()
      ..add(_draft.type);
    _description.addListener(_descriptionChanged);
    _contact.addListener(_contactChanged);
  }

  void _descriptionChanged() => setState(() => _draft.text = _description.text);
  void _contactChanged() => setState(() => _draft.contact = _contact.text);
  void _selectType(int index) {
    _type.tap(index);
    setState(() => _draft.type = index);
  }

  void _saveForLogin() {
    if (_initialized) _recovery?.save(_owner, _draft);
  }

  @override
  void dispose() {
    authExpired.removeListener(_saveForLogin);
    _description.dispose();
    _contact.dispose();
    _type.dispose();
    super.dispose();
  }

  Future<void> _pickImage(int index) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await runBusy(_imageKeys[index], () async {
        final file =
            await (widget.pickImage?.call() ??
                ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 90,
                ));
        if (file == null || !mounted) return;
        if (await file.length() > 5242880) {
          throw const AppError('请选择 5MB 以内的 JPEG 或 PNG 图片');
        }
        final bytes = await file.readAsBytes();
        if (!mounted) return;
        _draft.images[index] = FeedbackImage(bytes);
      });
    } catch (e) {
      if (mounted) AppToast.error(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    if (_busy || _draft.submitted) return;
    if (_draft.problem != null) {
      AppToast.show(context, _draft.problem!);
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _busy = true);
    var success = false;
    final slow = Timer(const Duration(seconds: 10), () {
      if (mounted && _busy && !_draft.submitted) {
        AppToast.show(context, '网络较慢，请稍候');
      }
    });
    try {
      await runBusy(_submitKey, () async {
        await _draft.submit(_api.invoke);
      });
      success = true;
      if (mounted) {
        setState(() {});
        AppToast.show(context, '反馈已提交', kind: ToastKind.success);
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    } catch (e) {
      if (mounted) AppToast.error(context, e);
    } finally {
      slow.cancel();
      if (mounted) setState(() => _busy = false);
    }
    if (success && mounted) {
      await WidgetsBinding.instance.endOfFrame;
      if (mounted) openRoute(context, 'AboutApp');
    }
  }

  Widget _image(int index, {required double radius, required Widget child}) {
    final image = _draft.images[index];
    return GestureDetector(
      key: ValueKey('feedback-image-$index'),
      onTap: () => unawaited(_pickImage(index)),
      behavior: HitTestBehavior.opaque,
      child: hBusy(
        _imageKeys[index],
        Stack(
          children: [
            child,
            if (image != null)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: Image.memory(
                    image.bytes,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Center(child: Icon(Icons.broken_image_outlined)),
                  ),
                ),
              ),
            if (image != null)
              Positioned(
                top: 0,
                right: 0,
                child: AppIconButton(
                  icon: Icons.close,
                  semanticLabel: '移除图片',
                  onPressed: () => setState(() => _draft.images[index] = null),
                ),
              ),
          ],
        ),
        icon: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_api.hasSession) {
      return Scaffold(
        body: ErrorView(
          error: const AppError('请先登录后提交反馈', type: AppErrorType.auth),
          onNext: () => openRoute(context, 'Login'),
        ),
      );
    }
    return ConfirmDiscard(
      dirty: !_draft.submitted && _draft.dirty,
      busy: _busy,
      child: AbsorbPointer(
        absorbing: _busy || _draft.submitted,
        child: HPage(
          bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
          height: 844,
          fixedHeight: false,
          flow: hcol(
            [
              hbox(
                pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 120),
                child: hcol(
                  [
                    hrow(
                      [
                        AppIconButton(
                          svg: dk(context, Svgs.s0, Svgs.s1),
                          semanticLabel: "返回",
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '意见反馈',
                            style: hts(
                              17,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w600,
                              lh: 24,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        hbox(w: 44),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 8,
                    ),
                    hbox(
                      bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                      radius: BorderRadius.circular(24),
                      shadow: dk(
                        context,
                        [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.06),
                            offset: Offset(0, 0),
                            blurRadius: 1,
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.06),
                            offset: Offset(0, 1),
                            blurRadius: 2,
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.04),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                        [
                          BoxShadow(
                            color: Color(0xFF26262B),
                            offset: Offset(0, 0),
                            blurRadius: 0,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: hcol(
                        [
                          hcol(
                            [
                              Text(
                                '反馈类型',
                                style: hts(
                                  14,
                                  dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  w: FontWeight.w600,
                                  lh: 20,
                                ),
                              ),
                              Builder(
                                builder: (context) => hwrap(
                                  [
                                    HSel(
                                      ctrl: _type,
                                      index: 0,
                                      onTap: () => _selectType(0),
                                      on: hbox(
                                        h: 34,
                                        bg: dk(
                                          context,
                                          Color(0xFFE1F0FE),
                                          Color.fromRGBO(4, 133, 247, 0.18),
                                        ),
                                        radius: BorderRadius.circular(17),
                                        border: Border.all(
                                          color: Color(0xFF0485F7),
                                          width: 1.5,
                                        ),
                                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                        child: Align(
                                          alignment: Alignment.center,
                                          widthFactor: 1,
                                          child: Text(
                                            '功能建议',
                                            style: hts(
                                              13,
                                              dk(
                                                context,
                                                Color(0xFF1E63AE),
                                                Color(0xFF6AB4FA),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      off: hbox(
                                        h: 34,
                                        bg: dk(
                                          context,
                                          Color(0xFFF4F4F5),
                                          Color(0xFF27272A),
                                        ),
                                        radius: BorderRadius.circular(17),
                                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                        child: Align(
                                          alignment: Alignment.center,
                                          widthFactor: 1,
                                          child: Text(
                                            '功能建议',
                                            style: hts(
                                              13,
                                              dk(
                                                context,
                                                Color(0xFF3F3F46),
                                                Color(0xFFD4D4D8),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    HSel(
                                      ctrl: _type,
                                      index: 1,
                                      onTap: () => _selectType(1),
                                      on: hbox(
                                        h: 34,
                                        bg: dk(
                                          context,
                                          Color(0xFFE1F0FE),
                                          Color.fromRGBO(4, 133, 247, 0.18),
                                        ),
                                        radius: BorderRadius.circular(17),
                                        border: Border.all(
                                          color: Color(0xFF0485F7),
                                          width: 1.5,
                                        ),
                                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                        child: Align(
                                          alignment: Alignment.center,
                                          widthFactor: 1,
                                          child: Text(
                                            '问题报告',
                                            style: hts(
                                              13,
                                              dk(
                                                context,
                                                Color(0xFF1E63AE),
                                                Color(0xFF6AB4FA),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      off: hbox(
                                        h: 34,
                                        bg: dk(
                                          context,
                                          Color(0xFFF4F4F5),
                                          Color(0xFF27272A),
                                        ),
                                        radius: BorderRadius.circular(17),
                                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                        child: Align(
                                          alignment: Alignment.center,
                                          widthFactor: 1,
                                          child: Text(
                                            '问题报告',
                                            style: hts(
                                              13,
                                              dk(
                                                context,
                                                Color(0xFF3F3F46),
                                                Color(0xFFD4D4D8),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    HSel(
                                      ctrl: _type,
                                      index: 2,
                                      onTap: () => _selectType(2),
                                      on: hbox(
                                        h: 34,
                                        bg: dk(
                                          context,
                                          Color(0xFFE1F0FE),
                                          Color.fromRGBO(4, 133, 247, 0.18),
                                        ),
                                        radius: BorderRadius.circular(17),
                                        border: Border.all(
                                          color: Color(0xFF0485F7),
                                          width: 1.5,
                                        ),
                                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                        child: Align(
                                          alignment: Alignment.center,
                                          widthFactor: 1,
                                          child: Text(
                                            '账号与付费',
                                            style: hts(
                                              13,
                                              dk(
                                                context,
                                                Color(0xFF1E63AE),
                                                Color(0xFF6AB4FA),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      off: hbox(
                                        h: 34,
                                        bg: dk(
                                          context,
                                          Color(0xFFF4F4F5),
                                          Color(0xFF27272A),
                                        ),
                                        radius: BorderRadius.circular(17),
                                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                        child: Align(
                                          alignment: Alignment.center,
                                          widthFactor: 1,
                                          child: Text(
                                            '账号与付费',
                                            style: hts(
                                              13,
                                              dk(
                                                context,
                                                Color(0xFF3F3F46),
                                                Color(0xFFD4D4D8),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    HSel(
                                      ctrl: _type,
                                      index: 3,
                                      onTap: () => _selectType(3),
                                      on: hbox(
                                        h: 34,
                                        bg: dk(
                                          context,
                                          Color(0xFFE1F0FE),
                                          Color.fromRGBO(4, 133, 247, 0.18),
                                        ),
                                        radius: BorderRadius.circular(17),
                                        border: Border.all(
                                          color: Color(0xFF0485F7),
                                          width: 1.5,
                                        ),
                                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                        child: Align(
                                          alignment: Alignment.center,
                                          widthFactor: 1,
                                          child: Text(
                                            '其他',
                                            style: hts(
                                              13,
                                              dk(
                                                context,
                                                Color(0xFF1E63AE),
                                                Color(0xFF6AB4FA),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      off: hbox(
                                        h: 34,
                                        bg: dk(
                                          context,
                                          Color(0xFFF4F4F5),
                                          Color(0xFF27272A),
                                        ),
                                        radius: BorderRadius.circular(17),
                                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                        child: Align(
                                          alignment: Alignment.center,
                                          widthFactor: 1,
                                          child: Text(
                                            '其他',
                                            style: hts(
                                              13,
                                              dk(
                                                context,
                                                Color(0xFF3F3F46),
                                                Color(0xFFD4D4D8),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  gap: 8,
                                  rowGap: 8,
                                  cross: WrapCrossAlignment.start,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 8,
                          ),
                          hcol(
                            [
                              Text(
                                '详细描述',
                                style: hts(
                                  14,
                                  dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  w: FontWeight.w600,
                                  lh: 20,
                                ),
                              ),
                              hbox(
                                minH: 130,
                                bg: dk(
                                  context,
                                  Color(0xFFF4F4F5),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(14),
                                pad: EdgeInsets.fromLTRB(12, 10, 12, 10),
                                child: AppTextInput(
                                  controller: _description,
                                  style: hts(
                                    14,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    lh: 22,
                                  ),
                                  maxLines: 4,
                                  hint: '请描述您遇到的问题或建议，越具体越好',
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 8,
                          ),
                          hcol(
                            [
                              Text.rich(
                                TextSpan(
                                  style: hts(
                                    14,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    w: FontWeight.w600,
                                    lh: 20,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '截图 ',
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        w: FontWeight.w600,
                                        lh: 20,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '· 选填，最多 3 张',
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF71717A),
                                          Color(0xFF9A9AA3),
                                        ),
                                        lh: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              hrow(
                                [
                                  UnconstrainedBox(
                                    alignment: Alignment.topLeft,
                                    constrainedAxis: Axis.horizontal,
                                    child: _image(
                                      0,
                                      radius: 16,
                                      child: hbox(
                                        w: 76,
                                        h: 76,
                                        bg: Color(0xFFFAFAFA),
                                        radius: BorderRadius.circular(16),
                                        dashed: true,
                                        dashColor: dk(
                                          context,
                                          Color(0xFFD4D4D8),
                                          Color(0xFF3F3F46),
                                        ),
                                        dashWidth: 2,
                                        child: hrow(
                                          [
                                            hsvg(
                                              dk(context, Svgs.s154, Svgs.s155),
                                              w: 22,
                                              h: 22,
                                            ),
                                          ],
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  UnconstrainedBox(
                                    alignment: Alignment.topLeft,
                                    constrainedAxis: Axis.horizontal,
                                    child: _image(
                                      1,
                                      radius: 16,
                                      child: hbox(
                                        w: 76,
                                        h: 76,
                                        bg: Color(0xFFFAFAFA),
                                        radius: BorderRadius.circular(16),
                                        dashed: true,
                                        dashColor: dk(
                                          context,
                                          Color(0xFFD4D4D8),
                                          Color(0xFF3F3F46),
                                        ),
                                        dashWidth: 2,
                                        child: hrow(
                                          [
                                            hsvg(
                                              dk(context, Svgs.s154, Svgs.s155),
                                              w: 22,
                                              h: 22,
                                            ),
                                          ],
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  UnconstrainedBox(
                                    alignment: Alignment.topLeft,
                                    constrainedAxis: Axis.horizontal,
                                    child: _image(
                                      2,
                                      radius: 16,
                                      child: hbox(
                                        w: 76,
                                        h: 76,
                                        bg: Color(0xFFFAFAFA),
                                        radius: BorderRadius.circular(16),
                                        dashed: true,
                                        dashColor: dk(
                                          context,
                                          Color(0xFFD4D4D8),
                                          Color(0xFF3F3F46),
                                        ),
                                        dashWidth: 2,
                                        child: hrow(
                                          [
                                            hsvg(
                                              dk(context, Svgs.s154, Svgs.s155),
                                              w: 22,
                                              h: 22,
                                            ),
                                          ],
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 10,
                                intrinsic: true,
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 8,
                          ),
                          hcol(
                            [
                              Text(
                                '联系方式',
                                style: hts(
                                  13,
                                  dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  w: FontWeight.w500,
                                  lh: 18,
                                ),
                              ),
                              hbox(
                                minH: 48,
                                bg: dk(
                                  context,
                                  Color(0xFFF4F4F5),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(14),
                                pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                child: hrow(
                                  [
                                    Expanded(
                                      child: AppTextInput(
                                        controller: _contact,
                                        style: hts(
                                          15,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          lh: 22,
                                        ),
                                        hint: '手机号或邮箱（选填）',
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 10,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 6,
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 16,
                      ),
                    ),
                    Text(
                      '反馈提交后将由平台处理，暂不支持查看进度和回复',
                      style: hts(
                        12,
                        dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 16,
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 0,
          ),
          overlays: [
            HBottomDock(
              child: hbox(
                bg: dk(
                  context,
                  Color.fromRGBO(255, 255, 255, 0.94),
                  Color.fromRGBO(9, 9, 11, 0.92),
                ),
                shadow: dk(
                  context,
                  [
                    BoxShadow(
                      color: Color(0xFFE4E4E7),
                      offset: Offset(0, -1),
                      blurRadius: 0,
                      spreadRadius: 0,
                    ),
                  ],
                  [
                    BoxShadow(
                      color: Color(0xFF3A3A40),
                      offset: Offset(0, -1),
                      blurRadius: 0,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                pad: EdgeInsets.fromLTRB(20, 12, 20, bottomInset(context)),
                child: hrow(
                  [
                    Expanded(
                      flex: 1,
                      child: ActionButton(
                        actionKey: _submitKey,
                        label: _draft.submitted ? '已提交' : '提交反馈',
                        kind: AppButtonKind.primary,
                        size: AppButtonSize.large,
                        expanded: true,
                        onPressed: () => unawaited(_submit()),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
