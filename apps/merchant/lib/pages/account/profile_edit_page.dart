import '../../kit/buttons.dart';

import 'dart:convert';

import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../backend/store_profile.dart';
import '../../backend/profile_flow.dart';
import '../../kit/async_kit.dart';
import '../../kit/text_input.dart';
import '../../routes.dart' show openRoute;

import '../../kit/kit.dart';
import '../../resources/merchant_svgs.dart';

class ProfileEditPage extends StatefulWidget {
  final Future<XFile?> Function(BuildContext)? pickAvatar;
  const ProfileEditPage({super.key, this.pickAvatar});
  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _name = TextEditingController(text: storeProfile.profileName);
  final _email = TextEditingController(text: storeProfile.profileEmail);
  XFile? _avatar;
  XFile? _uploadedAvatar;
  late final _api = merchantApi;
  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final path = await (widget.pickAvatar ?? pickSingleImage)(context);
    if (path != null && mounted) setState(() => _avatar = path);
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    if (name.isEmpty) throw const AppError('请填写姓名');
    final avatar = _avatar;
    if (avatar != null && !identical(avatar, _uploadedAvatar)) {
      final bytes = await avatar.readAsBytes();
      if (!mounted) return;
      await _api.uploadAvatar(base64Encode(bytes));
      if (!mounted) return;
      _uploadedAvatar = avatar;
    }
    await _api.updateProfile(name: name, email: email);
    if (!mounted) return;
    final store = await _api.getStore();
    if (!mounted) return;
    storeProfile.apply(store);
    ProfileFlow.changed.value++;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AsyncAction(
      onTap: _save,
      builder: (actionKey, onSave) => AsyncActionScope(
        actionKey: actionKey,
        child: ListenableBuilder(
          listenable: storeProfile,
          builder: (context, _) => HPage(
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
                              '编辑资料',
                              style: hts(
                                17,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w600,
                                lh: 24,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          ActionButton(
                            actionKey: actionKey,
                            label: '保存',
                            kind: AppButtonKind.primary,
                            size: AppButtonSize.medium,
                            expanded: false,
                            onPressed: onSave,
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.center,
                        gap: 8,
                      ),
                      hcol(
                        [
                          ImageSlot(
                            localPath: _avatar?.path ?? '',
                            remoteUrl: storeProfile.avatarUrl,
                            onPick: _pickAvatar,
                            onClear: () => setState(() => _avatar = null),
                            clipBehavior: Clip.none,
                            badge: _avatarBadge(context),
                            radius: 44,
                            child: hbox(
                              w: 88,
                              h: 88,
                              bg: Color(0xFF0485F7),
                              radius: BorderRadius.circular(44),
                              child: hstack(
                                hrow(
                                  [
                                    Flexible(
                                      flex: 32,
                                      child: Text(
                                        storeProfile.profileInitial,
                                        style: hts(
                                          32,
                                          Color(0xFFFFFFFF),
                                          w: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.center,
                                  cross: CrossAxisAlignment.center,
                                  gap: 0,
                                ),
                                [
                                  Positioned(
                                    right: -2,
                                    bottom: -2,
                                    width: 30,
                                    height: 30,
                                    child: hbox(
                                      w: 30,
                                      h: 30,
                                      bg: dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFF34343A),
                                      ),
                                      radius: BorderRadius.circular(15),
                                      shadow: dk(
                                        context,
                                        [
                                          BoxShadow(
                                            color: Color(0xFFF4F4F5),
                                            offset: Offset(0, 0),
                                            blurRadius: 0,
                                            spreadRadius: 3,
                                          ),
                                        ],
                                        [
                                          BoxShadow(
                                            color: Color(0xFF09090B),
                                            offset: Offset(0, 0),
                                            blurRadius: 0,
                                            spreadRadius: 3,
                                          ),
                                        ],
                                      ),
                                      child: hrow(
                                        [hsvg(Svgs.s322, w: 15, h: 15)],
                                        main: MainAxisAlignment.center,
                                        cross: CrossAxisAlignment.center,
                                        gap: 0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AppButton(
                            label: '更换头像',
                            kind: AppButtonKind.text,
                            size: AppButtonSize.medium,
                            expanded: false,
                            onPressed: _pickAvatar,
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.center,
                        gap: 10,
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
                                Text.rich(
                                  TextSpan(
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
                                    children: [
                                      TextSpan(
                                        text: '姓名 ',
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
                                      TextSpan(
                                        text: '*',
                                        style: hts(
                                          13,
                                          dk(
                                            context,
                                            Color(0xFFA43433),
                                            Color(0xFFFF7B7E),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 18,
                                        ),
                                      ),
                                    ],
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
                                          style: hts(
                                            15,
                                            dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFFFAFAFA),
                                            ),
                                            lh: 22,
                                          ),
                                          hint: '您的姓名',
                                          controller: _name,
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
                            hcol(
                              [
                                Text.rich(
                                  TextSpan(
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
                                    children: [
                                      TextSpan(
                                        text: '手机号 ',
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
                                      TextSpan(
                                        text: '*',
                                        style: hts(
                                          13,
                                          dk(
                                            context,
                                            Color(0xFFA43433),
                                            Color(0xFFFF7B7E),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 18,
                                        ),
                                      ),
                                    ],
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
                                        flex: 1,
                                        child: Text(
                                          storeProfile.profileMaskedPhone,
                                          style: hts(
                                            15,
                                            dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFFFAFAFA),
                                            ),
                                          ),
                                        ),
                                      ),
                                      AppButton(
                                        label: '更换',
                                        kind: AppButtonKind.text,
                                        size: AppButtonSize.medium,
                                        expanded: false,
                                        onPressed: () =>
                                            openRoute(context, 'ChangePhone'),
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
                            hcol(
                              [
                                Text(
                                  '邮箱',
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
                                          style: hts(
                                            15,
                                            dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFFFAFAFA),
                                            ),
                                            lh: 22,
                                          ),
                                          hint: '用于接收账单和发票',
                                          controller: _email,
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
                        pad: EdgeInsets.fromLTRB(0, 4, 0, 4),
                        child: hcol(
                          [
                            hbox(
                              minH: 54,
                              pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '角色',
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF52525B),
                                          Color(0xFFA8A8B3),
                                        ),
                                        lh: 20,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    storeProfile.profileRoleText,
                                    style: hts(
                                      15,
                                      dk(
                                        context,
                                        Color(0xFF71717A),
                                        Color(0xFF9A9AA3),
                                      ),
                                      lh: 22,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 12,
                              ),
                            ),
                            hbox(
                              h: 1,
                              bg: dk(
                                context,
                                Color(0xFFEFEFF1),
                                Color(0xFF2A2A2E),
                              ),
                              margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                            ),
                            hbox(
                              minH: 56,
                              pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '所属门店',
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF52525B),
                                          Color(0xFFA8A8B3),
                                        ),
                                        lh: 20,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    storeProfile.name,
                                    style: hts(
                                      15,
                                      dk(
                                        context,
                                        Color(0xFF71717A),
                                        Color(0xFF9A9AA3),
                                      ),
                                      lh: 22,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 12,
                              ),
                            ),
                            hbox(
                              h: 1,
                              bg: dk(
                                context,
                                Color(0xFFEFEFF1),
                                Color(0xFF2A2A2E),
                              ),
                              margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                            ),
                            hbox(
                              minH: 54,
                              pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '入职时间',
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF52525B),
                                          Color(0xFFA8A8B3),
                                        ),
                                        lh: 20,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    storeProfile.profileJoinedText,
                                    style: hts(
                                      15,
                                      dk(
                                        context,
                                        Color(0xFF71717A),
                                        Color(0xFF9A9AA3),
                                      ),
                                      lh: 22,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 12,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 0,
                        ),
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
            overlays: [],
          ),
        ),
      ),
    );
  }
}

Widget _avatarBadge(BuildContext context) => Positioned(
  right: -2,
  bottom: -2,
  width: 30,
  height: 30,
  child: Container(
    decoration: BoxDecoration(
      color: dk(context, const Color(0xFF18181B), const Color(0xFF34343A)),
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: dk(context, const Color(0xFFF4F4F5), const Color(0xFF09090B)),
          spreadRadius: 3,
        ),
      ],
    ),
    child: Center(child: hsvg(Svgs.s322, w: 15, h: 15)),
  ),
);
