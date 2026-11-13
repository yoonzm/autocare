import 'package:autocare_ui_kit/autocare_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

const _svg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M4 12h16" stroke="currentColor"/></svg>';
const _darkSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12 4v16" stroke="currentColor"/></svg>';

void main() {
  testWidgets('SVG buttons select theme source and apply state tint', (
    t,
  ) async {
    for (final brightness in Brightness.values) {
      final tokens = AppTokens.forBrightness(brightness);
      await pump(
        t,
        Row(
          children: [
            AppButton(
              label: '保存',
              svg: _svg,
              darkSvg: _darkSvg,
              onPressed: () {},
            ),
            const AppIconButton(
              svg: _svg,
              darkSvg: _darkSvg,
              semanticLabel: '禁用',
            ),
            AppIconButton.pill(label: '挂单', svg: _svg, onPressed: () {}),
          ],
        ),
        brightness: brightness,
      );
      await t.pumpAndSettle();
      final pictures = t
          .widgetList<SvgPicture>(find.byType(SvgPicture))
          .toList();
      final selected = brightness == Brightness.dark ? _darkSvg : _svg;
      expect(
        (pictures[0].bytesLoader as SvgStringLoader).provideSvg(null),
        selected,
      );
      expect(
        (pictures[1].bytesLoader as SvgStringLoader).provideSvg(null),
        selected,
      );
      expect(
        (pictures[2].bytesLoader as SvgStringLoader).provideSvg(null),
        _svg,
      );
      expect(
        pictures[0].colorFilter,
        ColorFilter.mode(tokens.onPrimary, BlendMode.srcIn),
      );
      expect(
        pictures[1].colorFilter,
        ColorFilter.mode(tokens.inkFaint, BlendMode.srcIn),
      );
      expect(
        pictures[2].colorFilter,
        ColorFilter.mode(tokens.ink, BlendMode.srcIn),
      );
      expect(t.getSize(find.byType(SvgPicture).at(1)), const Size(20, 20));
    }
  });

  testWidgets(
    'SVG and IconData are mutually exclusive; dark source needs light source',
    (t) async {
      expect(
        () => AppButton(label: '保存', icon: Icons.add, svg: _svg),
        throwsAssertionError,
      );
      expect(
        () => AppButton(label: '保存', darkSvg: _darkSvg),
        throwsAssertionError,
      );
      expect(() => AppIconButton(semanticLabel: '添加'), throwsAssertionError);
      expect(
        () => AppIconButton(icon: Icons.add, svg: _svg, semanticLabel: '添加'),
        throwsAssertionError,
      );
      expect(
        () => AppIconButton.pill(label: '挂单', darkSvg: _darkSvg),
        throwsAssertionError,
      );
    },
  );

  testWidgets('IconData still renders; AppButton loading replaces SVG', (
    t,
  ) async {
    await pump(t, AppButton(label: '保存', icon: Icons.add, onPressed: () {}));
    expect(find.byIcon(Icons.add), findsOneWidget);
    await pump(
      t,
      AppButton(label: '保存', svg: _svg, loading: true, onPressed: () {}),
    );
    expect(find.byType(SvgPicture), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets(
    'icon loading preserves size, hides content, blocks taps and recovers',
    (t) async {
      for (final brightness in Brightness.values) {
        for (final variant in ['regular', 'small', 'primary', 'pill']) {
          var calls = 0;
          AppIconButton button(bool loading) => variant == 'pill'
              ? AppIconButton.pill(
                  label: '全部挂单',
                  badge: 12,
                  svg: _svg,
                  loading: loading,
                  onPressed: () => calls++,
                )
              : AppIconButton(
                  icon: Icons.add,
                  semanticLabel: '添加',
                  size: variant == 'small'
                      ? AppIconButtonSize.small
                      : AppIconButtonSize.regular,
                  kind: variant == 'primary'
                      ? AppIconButtonKind.primary
                      : AppIconButtonKind.surface,
                  loading: loading,
                  onPressed: () => calls++,
                );
          await pump(t, button(false), brightness: brightness);
          final before = t.getSize(find.byType(AppIconButton));
          await pump(t, button(true), brightness: brightness);
          expect(t.getSize(find.byType(AppIconButton)), before);
          expect(t.widget<Opacity>(find.byType(Opacity).first).opacity, 0);
          expect(find.byType(AppSpinner), findsOneWidget);
          final tokens = AppTokens.forBrightness(brightness);
          expect(
            t.widget<AppSpinner>(find.byType(AppSpinner)).color,
            variant == 'primary' ? tokens.onPrimary : tokens.primary,
          );
          expect(t.getSize(find.byType(AppSpinner)), const Size(20, 20));
          final label = variant == 'pill' ? '全部挂单' : '添加';
          expect(find.bySemanticsLabel('$label，处理中'), findsOneWidget);
          await t.tap(find.byType(AppIconButton));
          expect(calls, 0);
          await pump(t, button(false), brightness: brightness);
          expect(find.byType(AppSpinner), findsNothing);
          await t.tap(find.byType(AppIconButton));
          expect(calls, 1);
          expect(t.takeException(), isNull);
        }
      }
    },
  );
}
