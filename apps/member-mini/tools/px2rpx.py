#!/usr/bin/env python3
"""把以设计稿像素书写的 `*.px.wxss` / `*.px.wxml` 转成 rpx 的 `*.wxss` / `*.wxml`。

设计稿画板宽 390px，小程序 rpx 以 750 为基准：1 设计 px = 750 / 390 rpx。
- 样式源文件（`.px.wxss`）按设计稿数值书写，便于和设计稿逐项核对；生成的 `.wxss` 提交入库，开发者工具可直接打开。
- `1px`、`0.5px` 这类发丝线保持 px。
- WXML 里只转换 `style="..."` 属性；`{{n}}px` 这类运行时计算出来的真实 px 不动。
- `--check` 只检查生成文件是否最新（CI 使用）。
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
FACTOR = 750 / 390
HEADER = '/* 由 tools/px2rpx.py 从 {src} 生成，请改源文件，不要直接编辑本文件。 */\n'


def convert(css: str) -> str:
    def px(match: re.Match) -> str:
        value = float(match.group(1))
        if match.group(1) in ('0', '0.0'):
            return '0'
        if abs(value) in (0.5, 1.0) and match.group(0).endswith('px'):
            return match.group(0)
        rpx = round(value * FACTOR, 2)
        text = ('%.2f' % rpx).rstrip('0').rstrip('.')
        return text + 'rpx'
    # 注释原样保留，不转换其中的数字
    pieces = re.split(r'(/\*.*?\*/)', css, flags=re.S)
    return ''.join(
        piece if piece.startswith('/*') else re.sub(r'(?<![\w.#-])(-?\d*\.?\d+)px\b', px, piece)
        for piece in pieces
    )


def targets():
    return sorted(list(ROOT.rglob('*.px.wxss')) + list(ROOT.rglob('*.px.wxml')))


def output_for(src: pathlib.Path) -> pathlib.Path:
    return src.with_name(src.name.replace('.px.', '.'))


def render(src: pathlib.Path) -> str:
    text = src.read_text(encoding='utf-8')
    if src.name.endswith('.wxml'):
        body = re.sub(r'style="([^"]*)"', lambda m: 'style="' + convert(m.group(1)) + '"', text)
        return '<!-- ' + HEADER.format(src=src.name).strip()[3:-3].strip() + ' -->\n' + body
    return HEADER.format(src=src.name) + convert(text)


def main(argv):
    check = '--check' in argv
    stale = []
    for src in targets():
        out = output_for(src)
        text = render(src)
        if check:
            if not out.exists() or out.read_text(encoding='utf-8') != text:
                stale.append(str(out.relative_to(ROOT)))
        else:
            out.write_text(text, encoding='utf-8')
    if stale:
        print('过期的生成文件，请运行 python3 tools/px2rpx.py：\n  ' + '\n  '.join(stale))
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
