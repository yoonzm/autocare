import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../backend/feedback_draft.dart';
import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';
import '../kit/kit.dart';
import '../routes.dart';

FeedbackDraft? _pending;
String? _owner;

class FeedbackForm extends StatefulWidget {
  final WidgetBuilder builder;
  const FeedbackForm({super.key, required this.builder});
  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  late final FeedbackDraft draft;
  late final TextEditingController text, contact;
  bool busy = false;
  bool expired = false;
  void authChanged() => expired = true;
  void update(VoidCallback action) => setState(action);
  @override
  void initState() {
    super.initState();
    authExpired.addListener(authChanged);
    final owner = merchantApi.hasSession
        ? merchantApi.client.auth.currentUser?.id
        : null;
    if (owner != _owner || _pending?.submitted == true) {
      _pending = null;
    }
    _owner = owner;
    draft = _pending ??= FeedbackDraft();
    text = TextEditingController(text: draft.text)
      ..addListener(() {
        draft.text = text.text;
        setState(() {});
      });
    contact = TextEditingController(text: draft.contact)
      ..addListener(() {
        draft.contact = contact.text;
        setState(() {});
      });
  }

  @override
  void dispose() {
    authExpired.removeListener(authChanged);
    if (!expired && identical(_pending, draft)) _pending = null;
    text.dispose();
    contact.dispose();
    super.dispose();
  }

  Future<void> pick(int index) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await runBusy('feedback-image-$index', () async {
        final file = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 90,
        );
        if (file == null || !mounted) return;
        if (await file.length() > 5242880) {
          throw const AppError('请选择 5MB 以内的 JPEG 或 PNG 图片');
        }
        final bytes = await file.readAsBytes();
        if (!mounted) return;
        draft.images[index] = FeedbackImage(bytes);
      });
    } catch (e) {
      if (mounted) AppToast.error(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> submit() async {
    if (busy || draft.submitted) return;
    if (draft.problem != null) {
      AppToast.show(context, draft.problem!);
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => busy = true);
    var success = false;
    final slow = Timer(const Duration(seconds: 10), () {
      if (mounted && busy && !draft.submitted) {
        AppToast.show(context, '网络较慢，请稍候');
      }
    });
    try {
      await runBusy('Feedback>AboutApp', () async {
        await draft.submit(merchantApi.invoke);
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
      if (mounted) setState(() => busy = false);
    }
    if (success && mounted) {
      _pending = null;
      await WidgetsBinding.instance.endOfFrame;
      if (mounted) {
        openRoute(context, 'AboutApp');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!merchantApi.hasSession) {
      return Scaffold(
        body: ErrorView(
          error: const AppError('请先登录后提交反馈', type: AppErrorType.auth),
          onNext: () => openRoute(context, 'Login'),
        ),
      );
    }
    return ConfirmDiscard(
      dirty: !draft.submitted && draft.dirty,
      busy: busy,
      child: AbsorbPointer(
        absorbing: busy || draft.submitted,
        child: _FeedbackScope(
          state: this,
          child: Builder(builder: widget.builder),
        ),
      ),
    );
  }
}

class _FeedbackScope extends InheritedWidget {
  final _FeedbackFormState state;
  const _FeedbackScope({required this.state, required super.child});
  @override
  bool updateShouldNotify(_FeedbackScope oldWidget) => true;
}

_FeedbackFormState _form(BuildContext context) =>
    context.dependOnInheritedWidgetOfExactType<_FeedbackScope>()!.state;

Widget feedbackInput(BuildContext context, HInput input) {
  final f = _form(context);
  return TextField(
    controller: input.maxLines == 4 ? f.text : f.contact,
    onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    style: input.style,
    maxLines: input.maxLines,
    minLines: 1,
    decoration: InputDecoration(
      isCollapsed: true,
      border: InputBorder.none,
      hintText: input.hint,
      hintStyle: input.style.copyWith(
        color: dk(context, const Color(0xFF71717A), const Color(0xFF9A9AA3)),
      ),
    ),
  );
}

Widget feedbackTypes(
  BuildContext context,
  Widget Function(BuildContext, List<SelCtrl>) builder,
) {
  final f = _form(context);
  return HSelHolder(
    groups: [
      ({f.draft.type}, false),
    ],
    onSelect: {0: (i) => f.update(() => f.draft.type = i)},
    builder: builder,
  );
}

void feedbackSubmit(BuildContext context) => unawaited(_form(context).submit());
Widget feedbackSubmitLabel(BuildContext context, Text label) => hBusy(
  'Feedback>AboutApp',
  Text(
    _form(context).draft.submitted ? '已提交' : label.data!,
    style: label.style,
  ),
  label: '提交中…',
  style: label.style,
);

Widget feedbackImage(BuildContext context, HImageSlot slot) {
  final f = _form(context), index = int.parse(slot.imgKey.split('_').last) - 4;
  final image = f.draft.images[index];
  return GestureDetector(
    onTap: () => unawaited(f.pick(index)),
    behavior: HitTestBehavior.opaque,
    child: hBusy(
      'feedback-image-$index',
      Stack(
        children: [
          slot.child,
          if (image != null)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(slot.radius),
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
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => f.update(() => f.draft.images[index] = null),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: CircleAvatar(
                      radius: 11,
                      backgroundColor: Color(0x99000000),
                      child: Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      icon: true,
    ),
  );
}
