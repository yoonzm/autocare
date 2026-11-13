import '../../kit/buttons.dart';

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../backend/store_form_request.dart';
import '../../backend/store_profile.dart';
import '../../kit/async_kit.dart';
import '../../kit/text_input.dart';
import '../../routes.dart' show openRoute;
import '../../backend/store_context.dart';
import '../../backend/merchant_api.dart';

import '../../resources/merchant_svgs.dart';

class StoreEditPage extends StatefulWidget {
  const StoreEditPage({super.key});
  @override
  State<StoreEditPage> createState() => _StoreEditPageState();
}

class _StoreEditPageState extends State<StoreEditPage> {
  final _name = TextEditingController(text: storeProfile.name);
  final _phone = TextEditingController(text: storeProfile.phone);
  final _address = TextEditingController(text: storeProfile.address);
  final _request = StoreFormRequest.update(storeId: StoreContext.id);
  late final _api = merchantApi;
  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await _request.save(
      name: _name.text,
      phone: _phone.text,
      address: _address.text,
    );
    if (!mounted) return;
    final store = await _api.getStore();
    if (!mounted) return;
    storeProfile.apply(store);
    if (mounted) _leave();
  }

  void _leave() {
    final nav = Navigator.of(context);
    nav.pop();
  }

  void _pickImage() {
    // TODO: 门店图片尚无存储与上传闭环，预期 store_media_upload 接口；不保存本地假图片。
    AppToast.show(context, '门店图片上传暂未接通');
  }

  void _locate() {
    // TODO: 地图定位尚无真实渠道，预期地图选址适配；地址由用户手动填写。
    AppToast.show(context, '地图定位暂未接通，请手动填写地址');
  }

  @override
  Widget build(BuildContext context) {
    return AsyncAction(
      onTap: _save,
      builder: (actionKey, onSave) => AsyncActionScope(
        actionKey: actionKey,
        child: HPage(
          bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
          height: 602,
          fixedHeight: false,
          flow: hcol(
            [
              hbox(
                pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 32),
                child: hcol(
                  [
                    hrow(
                      [
                        AppIconButton(
                          svg: dk(context, Svgs.s71, Svgs.s72),
                          semanticLabel: "返回",
                          onPressed: _leave,
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '编辑门店信息',
                            style: hts(
                              17,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
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
                          hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '门店照片',
                                  style: hts(
                                    15,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    w: FontWeight.w600,
                                    lh: 22,
                                  ),
                                ),
                              ),
                              Text(
                                '第一张为封面 · 最多 9 张',
                                style: hts(
                                  12,
                                  dk(
                                    context,
                                    Color(0xFF71717A),
                                    Color(0xFF9A9AA3),
                                  ),
                                  lh: 16,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.baseline,
                            gap: 0,
                          ),
                          hcol([
                            hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: ImageSlot(
                                    localPath: '',
                                    onPick: _pickImage,
                                    onClear: () {},
                                    radius: 14,
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: hbox(
                                        bg: dk(
                                          context,
                                          Color(0xFFE4E4E7),
                                          Color(0xFF3A3A40),
                                        ),
                                        radius: BorderRadius.circular(14),
                                        child: hstack(
                                          hrow(
                                            [
                                              hsvg(
                                                dk(
                                                  context,
                                                  Svgs.s366,
                                                  Svgs.s367,
                                                ),
                                                w: 20,
                                                h: 20,
                                              ),
                                            ],
                                            main: MainAxisAlignment.center,
                                            cross: CrossAxisAlignment.center,
                                            gap: 0,
                                          ),
                                          [
                                            Positioned(
                                              left: 6,
                                              bottom: 6,
                                              child: hbox(
                                                bg: dk(
                                                  context,
                                                  Color(0xFF18181B),
                                                  Color(0xFF1F1F23),
                                                ),
                                                radius: BorderRadius.circular(
                                                  8,
                                                ),
                                                pad: EdgeInsets.fromLTRB(
                                                  6,
                                                  0,
                                                  6,
                                                  0,
                                                ),
                                                child: Text(
                                                  '封面',
                                                  style: hts(
                                                    10,
                                                    Color(0xFFFFFFFF),
                                                    w: FontWeight.w600,
                                                    lh: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: ImageSlot(
                                    localPath: '',
                                    onPick: _pickImage,
                                    onClear: () {},
                                    radius: 14,
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: hbox(
                                        bg: dk(
                                          context,
                                          Color(0xFFE4E4E7),
                                          Color(0xFF3A3A40),
                                        ),
                                        radius: BorderRadius.circular(14),
                                        child: hrow(
                                          [
                                            hsvg(
                                              dk(context, Svgs.s366, Svgs.s367),
                                              w: 20,
                                              h: 20,
                                            ),
                                          ],
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: ImageSlot(
                                    localPath: '',
                                    onPick: _pickImage,
                                    onClear: () {},
                                    radius: 14,
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: hbox(
                                        bg: dk(
                                          context,
                                          Color(0xFFE4E4E7),
                                          Color(0xFF3A3A40),
                                        ),
                                        radius: BorderRadius.circular(14),
                                        child: hrow(
                                          [
                                            hsvg(
                                              dk(context, Svgs.s366, Svgs.s367),
                                              w: 20,
                                              h: 20,
                                            ),
                                          ],
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: ImageSlot(
                                    localPath: '',
                                    onPick: _pickImage,
                                    onClear: () {},
                                    radius: 14,
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: hbox(
                                        bg: dk(
                                          context,
                                          Color(0xFFF4F4F5),
                                          Color(0xFF27272A),
                                        ),
                                        radius: BorderRadius.circular(14),
                                        border: dk(
                                          context,
                                          Border.all(
                                            color: Color(0xFFD4D4D8),
                                            width: 1.5,
                                          ),
                                          Border.all(
                                            color: Color(0xFF3F3F46),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: hrow(
                                          [
                                            hsvg(
                                              dk(context, Svgs.s368, Svgs.s369),
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
                                ),
                              ],
                              cross: CrossAxisAlignment.stretch,
                              gap: 8,
                              intrinsic: true,
                              min: false,
                            ),
                          ], gap: 8),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 12,
                      ),
                    ),
                    hcol(
                      [
                        hbox(
                          pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                          child: Text(
                            '基本信息',
                            style: hts(
                              13,
                              dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
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
                                    hbox(
                                      w: 72,
                                      child: Text(
                                        '门店名称',
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
                                    Expanded(
                                      child: AppTextInput(
                                        controller: _name,
                                        style: hts(
                                          15,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          lh: 22,
                                        ),
                                        hint: '请输入门店名称',
                                        align: TextAlign.right,
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
                                    hbox(
                                      w: 72,
                                      child: Text(
                                        '联系电话',
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
                                    Expanded(
                                      child: AppTextInput(
                                        controller: _phone,
                                        style: hts(
                                          15,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          lh: 22,
                                        ),
                                        hint: '请输入联系电话',
                                        keyboard: TextInputType.phone,
                                        align: TextAlign.right,
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
                                    hbox(
                                      w: 72,
                                      child: Text(
                                        '门店地址',
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
                                    Expanded(
                                      child: hbox(
                                        minW: 0,
                                        child: AppTextInput(
                                          controller: _address,
                                          style: hts(
                                            15,
                                            dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFFFAFAFA),
                                            ),
                                            lh: 22,
                                          ),
                                          hint: '请输入门店地址',

                                          align: TextAlign.right,
                                        ),
                                      ),
                                    ),
                                    AppIconButton(
                                      svg: dk(context, Svgs.s370, Svgs.s371),
                                      semanticLabel: '定位',
                                      onPressed: _locate,
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
                      gap: 8,
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => openRoute(context, 'BusinessHours'),
                      child: hbox(
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
                        pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: hrow(
                          [
                            hbox(
                              w: 40,
                              h: 40,
                              bg: dk(
                                context,
                                Color(0xFFE1F0FE),
                                Color.fromRGBO(4, 133, 247, 0.18),
                              ),
                              radius: BorderRadius.circular(12),
                              child: hrow(
                                [
                                  hsvg(
                                    dk(context, Svgs.s458, Svgs.s459),
                                    w: 20,
                                    h: 20,
                                  ),
                                ],
                                main: MainAxisAlignment.center,
                                cross: CrossAxisAlignment.center,
                                gap: 0,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '营业时间与工位',
                                    style: hts(
                                      15,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w500,
                                      lh: 22,
                                    ),
                                  ),
                                  hLiveText(
                                    (p) => p.hoursLine,
                                    hts(
                                      12,
                                      dk(
                                        context,
                                        Color(0xFF71717A),
                                        Color(0xFF9A9AA3),
                                      ),
                                      lh: 16,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 2,
                              ),
                            ),
                            hsvg(dk(context, Svgs.s3, Svgs.s4), w: 16, h: 16),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.center,
                          gap: 12,
                        ),
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
    );
  }
}
