import 'package:flutter/material.dart';

import '../../kit/kit.dart';

class ClearCacheSheet extends StatelessWidget {
  const ClearCacheSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return hbox(
      bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
      radius: BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
        bottomRight: Radius.circular(0),
        bottomLeft: Radius.circular(0),
      ),
      pad: EdgeInsets.fromLTRB(20, 10, 20, bottomInset(context)),
      child: hcol(
        [
          Align(
            alignment: Alignment.topCenter,
            child: hbox(
              w: 40,
              h: 5,
              bg: dk(context, Color(0xFFD4D4D8), Color(0xFF3F3F46)),
              radius: BorderRadius.circular(3),
            ),
          ),
          Text(
            '清除缓存',
            style: hts(
              20,
              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
              w: FontWeight.w600,
              lh: 28,
            ),
          ),
          Text(
            '清除后将重新下载图片等内容，不会删除会员、订单等业务数据。',
            style: hts(
              13,
              dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
              lh: 18,
            ),
          ),
          hbox(
            bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
            radius: BorderRadius.circular(18),
            pad: EdgeInsets.fromLTRB(14, 4, 14, 4),
            child: hcol(
              [
                hbox(
                  minH: 44,
                  child: hrow(
                    [
                      Expanded(
                        flex: 1,
                        child: Text(
                          '图片缓存',
                          style: hts(
                            14,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          ),
                        ),
                      ),
                      Text(
                        '96 MB',
                        style: hts(
                          14,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w500,
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 0,
                  ),
                ),
                hbox(
                  h: 1,
                  bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                ),
                hbox(
                  minH: 44,
                  child: hrow(
                    [
                      Expanded(
                        flex: 1,
                        child: Text(
                          '离线数据',
                          style: hts(
                            14,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          ),
                        ),
                      ),
                      Text(
                        '24 MB',
                        style: hts(
                          14,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w500,
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 0,
                  ),
                ),
                hbox(
                  h: 1,
                  bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                ),
                hbox(
                  minH: 44,
                  child: hrow(
                    [
                      Expanded(
                        flex: 1,
                        child: Text(
                          '其他临时文件',
                          style: hts(
                            14,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          ),
                        ),
                      ),
                      Text(
                        '8 MB',
                        style: hts(
                          14,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w500,
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 0,
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 0,
            ),
          ),
          hrow(
            [
              Expanded(
                flex: 10,
                child: hTap(
                  context,
                  hbox(
                    h: 50,
                    bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                    radius: BorderRadius.circular(25),
                    child: Align(
                      alignment: Alignment(0, 0),
                      widthFactor: 1,
                      child: Text(
                        '取消',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w500,
                          lh: 22,
                        ),
                      ),
                    ),
                  ),
                  to: 'AboutApp',
                ),
              ),
              Expanded(
                flex: 16,
                child: hTap(
                  context,
                  hbox(
                    h: 50,
                    bg: dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                    radius: BorderRadius.circular(25),
                    child: Align(
                      alignment: Alignment(0, 0),
                      widthFactor: 1,
                      child: Text(
                        '清除 128 MB',
                        style: hts(
                          15,
                          dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                    ),
                  ),
                  to: 'AboutApp',
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
        gap: 14,
      ),
    );
  }
}
