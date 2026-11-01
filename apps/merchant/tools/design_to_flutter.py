#!/usr/bin/env python3
"""把设计稿（*.dc.html，内联样式的 flex/grid 布局）转换为 Flutter 页面代码。

用法：
  python3 tools/design_to_flutter.py <设计稿 project 目录> <输出目录 lib/pages/gen> [页面名 ...]

输出：
  <名称>_page.dart   每个页面一个 StatelessWidget（类名 <名称>Page）
  svgs.dart          去重后的 SVG 字符串常量
  gen_routes.dart    页面名 -> 构建函数
"""
import html
import re
import sys
import os
import collections
from html.parser import HTMLParser

# 已手写实现、不需要生成的页面
HANDWRITTEN = {
    'Main', 'Members', 'MemberDetail', 'Inventory', 'Stats', 'Login',
    'Settings', 'Order', 'Appointments', 'AppointmentAdd', 'Services',
    'ThemeSheet',
    'FindScanPlate', 'FindScanCode', 'ScanLicense', 'ScanPlate',  # 相机扫描页：手写  # 外观选择：手写，直接作用于全局主题
}
# 由后端门店资料驱动的文字：(页面, 设计稿里的示例文字) -> 取值表达式。
# 表达式里的 p 是 StoreProfile；门店资料尚未加载时（离线 / 测试）仍显示设计稿示例文字。
LIVE_TEXT = {
    ('RegDone', '驰光汽车美容 · 已为您创建店长账号'): "'${p.name} · 已为您创建店长账号'",
    ('RegDone', '专业版 · 试用'): 'p.planText',
    ('RegDone', '2026.11.14'): 'p.trialEndText',
    ('RegDone', '手机号 139 **** 8812'): "'手机号 ${p.maskedPhone}'",
    ('Security', '139 **** 8812'): 'p.maskedPhone',
    ('ChangePhone', '验证码将发送至 139 **** 8812'): "'验证码将发送至 ${p.maskedPhone}'",
    ('StoreInfo', '驰光汽车美容 · 徐汇店'): 'p.name',
    ('StoreInfo', '上海市徐汇区[详细地址]'): 'p.addressText',
    ('StoreInfo', '021-[门店电话]'): 'p.localPhone',
}

SKIP = {'AppIcon', 'DarkTokens', 'PageTransitions'}
# 设计稿里的深色版本只是参考，深色效果由同一套页面自动适配
SKIP_SUFFIX = ('Dark',)


# ───────────────────────── 深色模式 ─────────────────────────
# 设计稿 DarkTokens 的颜色对照；其余页面按这些规则自动适配。
BG_DARK = {
    '#FFFFFF': '#18181B', '#EEEEF0': '#27272A', '#E9E9EB': '#1F1F23', '#EFEFF1': '#2A2A2E',
    '#E4E4E7': '#3A3A40', '#D4D4D8': '#3F3F46', '#F1F1F3': '#27272A', '#E8E8EA': '#26262B',
    '#E1F0FE': 'rgba(4,133,247,.18)', '#DDF6E7': 'rgba(23,201,100,.16)',
    '#FDEFD6': 'rgba(245,165,36,.16)', '#FFE1E2': 'rgba(255,56,60,.18)',
    '#F3F9FF': 'rgba(4,133,247,.10)', '#FDF8EC': 'rgba(245,165,36,.10)',
}
FG_DARK = {
    '#18181B': '#FAFAFA', '#27272A': '#D4D4D8', '#3F3F46': '#D4D4D8', '#52525B': '#A8A8B3',
    '#71717A': '#9A9AA3', '#A1A1AA': '#80808A', '#1E63AE': '#6AB4FA', '#2B7745': '#5FD48C',
    '#855F2E': '#F0C46A', '#A43433': '#FF7B7E', '#1F5E37': '#5FD48C', '#6B4A1F': '#F0C46A',
    '#8A2A29': '#FF7B7E',
    '#CFEFDB': '#1F5A3A', '#E6F6EC': '#163D29',
}
LINE_DARK = {'#E4E4E7': '#3A3A40', '#D4D4D8': '#3F3F46', '#EFEFF1': '#2A2A2E', '#E8E8EA': '#26262B'}


def _px(v):
    m = re.fullmatch(r'(-?[\d.]+)(px)?', (v or '').strip())
    return float(m.group(1)) if m else None


def dark_of(n):
    """返回该节点在深色模式下需要覆盖的样式（只含与浅色不同的属性）。"""
    st, out, tag = n.style, {}, n.tag
    is_root = n.attrs.get('_root') == '1'
    bg = (st.get('background') or '').upper()
    col = (st.get('color') or '').upper()
    inv = False  # 背景反白（深色按钮 -> 白底），此时白字改深色
    if bg:
        if bg == '#F4F4F5':
            out['background'] = '#09090B' if is_root else '#27272A'
        elif bg in BG_DARK:
            out['background'] = BG_DARK[bg]
        elif bg.startswith('RGBA(255,255,255') or bg.startswith('RGBA(255, 255, 255'):
            out['background'] = 'rgba(9,9,11,.92)'
        elif bg == '#18181B':
            w, h, r = _px(st.get('width')), _px(st.get('height')), _px((st.get('border-radius') or '').split()[0] if st.get('border-radius') else '')
            if col == '#F5D78E':
                out['background'] = '#34343A'
            elif w and h and w == h and w >= 48:
                out['background'] = '#FAFAFA'; inv = True
            elif tag == 'button' and col in ('#FAFAFA', '#FFFFFF') and not (w and h and w == h):
                # 选中的按钮 / 胶囊：深色模式下反白，才能与未选中项区分开
                out['background'] = '#FAFAFA'; inv = True
            elif col == '#FAFAFA':
                out['background'] = '#1F1F23'
                if r and r >= 24 and not (h and h <= 64):
                    out['border'] = '1px solid #2E2E33'
            elif h and h <= 36:
                out['background'] = '#34343A'
            elif h and h >= 40 and (tag in ('a', 'button') or (r and r >= h / 2 - 2)):
                out['background'] = '#FAFAFA'; inv = True
            elif w and h and w == h and w <= 44:
                out['background'] = '#34343A'
            else:
                out['background'] = '#1F1F23'
    if col:
        if col in ('#FFFFFF', '#FAFAFA') and inv:
            out['color'] = '#18181B'
        elif col in FG_DARK:
            out['color'] = FG_DARK[col]
    elif inv:
        out['color'] = '#18181B'
    sh = st.get('box-shadow')
    if sh and sh != 'none':
        has_bg = bool(bg) and bg != 'TRANSPARENT'
        if 'inset' not in sh and re.search(r'rgba\(0,\s*0,\s*0,\s*\.0[468]\)', sh) and ('2px 4px' in sh or '1px 2px' in sh or '8px 24px' in sh):
            out['box-shadow'] = '0 0 0 1px #26262B' if has_bg else 'none'
        else:
            new = sh
            for k, v in LINE_DARK.items():
                new = re.sub(k, v, new, flags=re.I)
            # 描边环（0 0 0 Npx 白 / 页面底色）用来“镂空”背后的线条或圆点，深色下要换成对应的卡片 / 页面底色
            new = re.sub(r'(0 0 0 \d+px )#FFFFFF', r'\1#18181B', new, flags=re.I)
            new = re.sub(r'(0 0 0 \d+px )#F4F4F5', r'\1#09090B', new, flags=re.I)
            if new != sh:
                out['box-shadow'] = new
    for k in ('border', 'border-top', 'border-bottom', 'border-left', 'border-right'):
        v = st.get(k)
        if v and v != '0':
            new = v
            for a, b in LINE_DARK.items():
                new = re.sub(a, b, new, flags=re.I)
            if new != v:
                out[k] = new
    return out


def dark_color_of(c):
    """文字/图标颜色 (r,g,b,a) 的深色对应色。"""
    if c is None:
        return None
    hexs = '#%02X%02X%02X' % c[:3]
    if hexs in FG_DARK:
        m = FG_DARK[hexs]
        return (int(m[1:3], 16), int(m[3:5], 16), int(m[5:7], 16), c[3])
    return c



# ───────────────────────── 解析 ─────────────────────────


class Node:
    def __init__(self, tag, attrs):
        self.tag = tag
        self.attrs = dict(attrs)
        self.style = parse_style(self.attrs.get('style', ''))
        self.children = []
        self.parent = None
        self.raw = None  # svg 原始标记
        self._dark = None

    @property
    def dark(self):
        if self._dark is None:
            # 二维码底板保持白底黑码（深色模式下也要能被扫描）
            self._dark = {} if self.attrs.get('_keeplight') else dark_of(self)
        return self._dark

    def copy_with_style(self, style):
        n = Node(self.tag, self.attrs.items())
        n.style = style
        n.children = self.children
        n.parent = self.parent
        n.raw = self.raw
        return n


class Parser(HTMLParser):
    VOID = {'input', 'br', 'img', 'link', 'meta', 'hr'}

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.root = Node('root', [])
        self.stack = [self.root]
        self.svgs = []

    def handle_starttag(self, tag, attrs):
        if tag == 'svgph':
            n = Node('svg', [])
            n.raw = self.svgs[int(dict(attrs)['i'])]
            head = re.match(r'<svg\b([^>]*)>', n.raw, flags=re.S).group(1)
            n.attrs = dict(re.findall(r'([\w:-]+)="([^"]*)"', head))
            n.style = parse_style(n.attrs.get('style', ''))
            n.parent = self.stack[-1]
            self.stack[-1].children.append(n)
            self.stack.append(n)
            return
        n = Node(tag, attrs)
        n.parent = self.stack[-1]
        self.stack[-1].children.append(n)
        if tag not in self.VOID:
            self.stack.append(n)

    def handle_startendtag(self, tag, attrs):
        self.handle_starttag(tag, attrs)
        if tag == 'svgph':
            self.stack.pop()
        elif tag not in self.VOID:
            self.stack.pop()

    def handle_endtag(self, tag):
        if tag == 'svgph':
            tag = 'svg'
        for i in range(len(self.stack) - 1, 0, -1):
            if self.stack[i].tag == tag:
                del self.stack[i:]
                return

    def handle_data(self, data):
        if self.stack[-1].tag == 'svg':
            return
        self.stack[-1].children.append(data)


def extract_page(src):
    helm = re.search(r'<helmet>(.*?)</helmet>', src, flags=re.S)
    body = src.split('<x-dc>', 1)[1].split('</x-dc>', 1)[0]
    body = re.sub(r'<helmet>.*?</helmet>', '', body, flags=re.S)
    svgs = []

    def grab(m):
        svgs.append(m.group(0))
        return '<svgph i="%d"></svgph>' % (len(svgs) - 1)

    body = re.sub(r'<svg\b.*?</svg>', grab, body, flags=re.S)
    p = Parser()
    p.svgs = svgs
    p.feed(body)
    roots = [c for c in p.root.children if isinstance(c, Node)]
    return roots[0]


# ───────────────────────── 样式 ─────────────────────────


def parse_style(s):
    d = {}
    for part in s.split(';'):
        if ':' not in part:
            continue
        k, v = part.split(':', 1)
        d[k.strip()] = v.strip()
    # 展开简写
    if 'font' in d:
        m = re.match(r'(?:(\d+|normal|bold)\s+)?([\d.]+)px(?:/([\d.]+(?:px)?))?', d['font'])
        if m:
            if m.group(1):
                d['font-weight'] = {'normal': '400', 'bold': '700'}.get(m.group(1), m.group(1))
            d['font-size'] = m.group(2) + 'px'
            if m.group(3):
                d['line-height'] = m.group(3)
        del d['font']
    if 'inset' in d:
        v = d.pop('inset').split()
        v = (v * 4)[:4] if len(v) == 1 else v
        d.setdefault('top', v[0]); d.setdefault('right', v[1 % len(v)])
        d.setdefault('bottom', v[2 % len(v)]); d.setdefault('left', v[3 % len(v)])
    for name in ('padding', 'margin'):
        if name in d:
            t, r, b, l = box4(d.pop(name))
            for side, val in zip(('top', 'right', 'bottom', 'left'), (t, r, b, l)):
                d.setdefault('%s-%s' % (name, side), val)
    if 'flex' in d:
        f = d.pop('flex')
        if f == 'none':
            d['flex-grow'] = '0'; d['flex-shrink'] = '0'
        elif f == 'auto':
            d['flex-grow'] = '1'
        else:
            parts = f.split()
            d['flex-grow'] = parts[0]
            if len(parts) > 1:
                d['flex-shrink'] = parts[1]
    return d


def box4(v):
    p = v.split()
    if len(p) == 1:
        p = p * 4
    elif len(p) == 2:
        p = [p[0], p[1], p[0], p[1]]
    elif len(p) == 3:
        p = [p[0], p[1], p[2], p[1]]
    return p[:4]


def px(v, default=None):
    if v is None:
        return default
    v = v.strip()
    if v in ('0', 'auto', ''):
        return 0.0 if v == '0' else default
    m = re.fullmatch(r'(-?[\d.]+)(px)?', v)
    return float(m.group(1)) if m else default


def num(f):
    return ('%g' % f)


def parse_color(v, cur=None):
    """返回 (r,g,b,a) 或 None。"""
    if v is None:
        return None
    v = v.strip()
    if v in ('transparent', 'none'):
        return None
    if v in ('currentColor', 'inherit'):
        return cur
    m = re.fullmatch(r'#([0-9a-fA-F]{3,8})', v)
    if m:
        h = m.group(1)
        if len(h) == 3:
            h = ''.join(c * 2 for c in h)
        r, g, b = int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)
        a = int(h[6:8], 16) / 255 if len(h) == 8 else 1.0
        return (r, g, b, a)
    m = re.fullmatch(r'rgba?\(([^)]*)\)', v)
    if m:
        p = [x.strip() for x in m.group(1).replace('/', ',').split(',')]
        a = float(p[3]) if len(p) > 3 else 1.0
        return (int(float(p[0])), int(float(p[1])), int(float(p[2])), a)
    return None


def dcolor(c):
    if c is None:
        return 'Colors.transparent'
    r, g, b, a = c
    if a >= 0.999:
        return 'Color(0xFF%02X%02X%02X)' % (r, g, b)
    return 'Color.fromRGBO(%d, %d, %d, %s)' % (r, g, b, num(round(a, 3)))


def scolor(c):
    r, g, b, a = c
    return '#%02X%02X%02X' % (r, g, b)


def split_top(s, sep=','):
    out, depth, cur = [], 0, ''
    for ch in s:
        if ch == '(':
            depth += 1
        elif ch == ')':
            depth -= 1
        if ch == sep and depth == 0:
            out.append(cur); cur = ''
        else:
            cur += ch
    if cur.strip():
        out.append(cur)
    return [x.strip() for x in out]


def parse_gradient(v, cur):
    m = re.fullmatch(r'linear-gradient\((.*)\)', v, flags=re.S)
    if not m:
        return None
    parts = split_top(m.group(1))
    angle = 180.0
    if re.fullmatch(r'-?[\d.]+deg', parts[0]):
        angle = float(parts[0][:-3]); parts = parts[1:]
    elif parts[0].startswith('to '):
        angle = {'to bottom': 180, 'to top': 0, 'to right': 90, 'to left': 270,
                 'to bottom right': 135, 'to top right': 45}.get(parts[0], 180)
        parts = parts[1:]
    import math
    rad = math.radians(angle)
    dx, dy = math.sin(rad), -math.cos(rad)
    begin = 'Alignment(%s, %s)' % (num(round(-dx, 3)), num(round(-dy, 3)))
    end = 'Alignment(%s, %s)' % (num(round(dx, 3)), num(round(dy, 3)))
    colors, stops = [], []
    for i, p in enumerate(parts):
        m2 = re.match(r'(.*?)(?:\s+([\d.]+)%)?$', p)
        c = parse_color(m2.group(1).strip(), cur)
        colors.append(dcolor(c))
        stops.append(float(m2.group(2)) / 100 if m2.group(2) else i / max(1, len(parts) - 1))
    return 'LinearGradient(begin: %s, end: %s, colors: [%s], stops: [%s])' % (
        begin, end, ', '.join(colors), ', '.join(num(round(s, 3)) for s in stops))


def dstr(s):
    return "'" + s.replace('\\', '\\\\').replace('$', '\\$').replace("'", "\\'").replace('\n', '\\n') + "'"


# ───────────────────────── 生成器 ─────────────────────────

TEXT_PROPS = {
    'color', 'font-size', 'font-weight', 'line-height', 'letter-spacing', 'text-decoration',
    'font-variant-numeric', 'white-space', 'cursor', 'font-family', 'text-align', 'font-style',
    'box-sizing', 'all', 'vertical-align', 'margin-top', 'margin-bottom', 'margin-left', 'margin-right',
    'padding-top', 'padding-bottom', 'padding-left', 'padding-right', 'border', 'outline',
}
INLINE_TAGS = {'span', 'b', 'strong', 'em', 'i', 'a', 'u', 'small', 'br', 'label'}


class Gen:
    def __init__(self, svg_registry):
        self.svgs = svg_registry
        self.sel_counter = 0
        self.refs = {}
        self.global_refs = {}
        self.shared = {}
        self.dyn_filter = {}
        self.page_name = ''
        self.warnings = []
        self.switch_off = None

    # ── 工具 ──
    def svg_const(self, markup):
        if markup not in self.svgs:
            self.svgs[markup] = 's%d' % len(self.svgs)
        return 'Svgs.%s' % self.svgs[markup]

    def disp(self, n):
        d = n.style.get('display')
        if d:
            return d
        if n.tag in ('span', 'a', 'b', 'strong', 'em', 'label', 'button', 'legend'):
            return 'inline'
        return 'block'

    def kids(self, n):
        out = []
        for c in n.children:
            if isinstance(c, str):
                if c.strip():
                    out.append(c)
            else:
                out.append(c)
        return out

    def is_abs(self, n):
        return isinstance(n, Node) and n.style.get('position') == 'absolute'

    def is_inline_plain(self, n):
        if not isinstance(n, Node):
            return False
        if n.tag == 'br':
            return True
        if n.tag not in INLINE_TAGS or self.is_abs(n):
            return False
        if n.attrs.get('role') in ('switch', 'radio', 'tab'):
            return False
        if n.style.get('display') in ('flex', 'inline-flex', 'grid', 'block'):
            return False
        for k in n.style:
            if k not in TEXT_PROPS:
                return False
        return self.text_only(n)

    def text_only(self, n):
        if n.style.get('display') in ('flex', 'inline-flex', 'grid'):
            return all(isinstance(c, str) for c in n.children) and any(c.strip() for c in n.children if isinstance(c, str))
        has = False
        for c in n.children:
            if isinstance(c, str):
                if c.strip():
                    has = True
            elif isinstance(c, Node):
                if c.tag == 'br':
                    has = True
                    continue
                if not self.is_inline_plain(c):
                    return False
                has = True
        return has

    # ── 文本样式继承 ──
    def inherit(self, inh, st, dn=None):
        o = dict(inh)
        if 'color' in st:
            c = parse_color(st['color'], inh.get('color'))
            if c:
                o['color'] = c
        # 深色模式下的文字色：优先用深色覆盖，其次沿用（未映射的颜色深浅一致）
        dsrc = (dn or {}).get('color') or st.get('color')
        if dsrc:
            dc = parse_color(dsrc, inh.get('dcolor') or inh.get('color'))
            if dc:
                o['dcolor'] = dc
        if 'font-size' in st:
            o['size'] = px(st['font-size'], o['size'])
        if 'font-weight' in st:
            w = st['font-weight']
            o['w'] = {'normal': 400, 'bold': 700}.get(w, None) or int(float(w))
        if 'line-height' in st:
            lh = st['line-height']
            if lh == 'normal':
                o['lh'] = None
            elif lh.endswith('px'):
                o['lh'] = float(lh[:-2])
            else:
                o['lh'] = float(lh) * o['size']
        elif 'font-size' in st and o.get('lh') is not None and 'line-height' not in st:
            pass
        if 'letter-spacing' in st:
            ls = st['letter-spacing']
            if ls.endswith('em'):
                o['ls'] = float(ls[:-2]) * o['size']
            else:
                o['ls'] = px(ls, 0)
        if 'font-variant-numeric' in st:
            o['tab'] = 'tabular' in st['font-variant-numeric']
        if 'text-decoration' in st:
            o['deco'] = st['text-decoration']
        if 'text-align' in st:
            o['ta'] = st['text-align']
        if 'white-space' in st:
            o['nowrap'] = st['white-space'] == 'nowrap'
        return o

    def ts(self, inh):
        lc = dcolor(inh['color'])
        dcc = inh.get('dcolor') or inh['color']
        col = lc if dcc == inh['color'] else 'dk(context, %s, %s)' % (lc, dcolor(dcc))
        args = [num(inh['size']), col]
        if inh['w'] != 400:
            args.append('w: FontWeight.w%d' % inh['w'])
        if inh.get('lh'):
            args.append('lh: %s' % num(round(inh['lh'], 2)))
        if inh.get('ls'):
            args.append('ls: %s' % num(round(inh['ls'], 3)))
        if inh.get('tab'):
            args.append('tab: true')
        d = inh.get('deco')
        if d and 'line-through' in d:
            args.append('deco: TextDecoration.lineThrough')
        elif d and 'underline' in d:
            args.append('deco: TextDecoration.underline')
        return 'hts(%s)' % ', '.join(args)

    # ── 文本 ──
    def collect(self, n, inh, out):
        for c in n.children:
            if isinstance(c, str):
                out.append((re.sub(r'\s+', ' ', c), inh))
            elif c.tag == 'br':
                out.append(('\n', inh))
            else:
                self.collect(c, self.inherit(inh, c.style, c.dark), out)

    def emit_text(self, n, inh):
        segs = []
        self.collect(n, inh, segs)
        # 去掉首尾空白
        while segs and segs[0][0].strip() == '' and segs[0][0] != '\n':
            segs.pop(0)
        while segs and segs[-1][0].strip() == '' and segs[-1][0] != '\n':
            segs.pop()
        if segs:
            segs[0] = (segs[0][0].lstrip(' '), segs[0][1])
            segs[-1] = (segs[-1][0].rstrip(' '), segs[-1][1])
        extra = []
        ta = {'center': 'TextAlign.center', 'right': 'TextAlign.right', 'end': 'TextAlign.right'}.get(inh.get('ta'))
        if ta:
            extra.append('textAlign: %s' % ta)
        if inh.get('nowrap'):
            extra.append('softWrap: false')
            if not any('\n' in sg[0] for sg in segs):
                extra.append('maxLines: 1')
        same = all(s[1] == segs[0][1] for s in segs)
        if same:
            text = ''.join(s[0] for s in segs)
            live = LIVE_TEXT.get((self.page_name, text))
            if live:
                return 'hLiveText((p) => p.live ? (%s) : %s, %s%s)' % (
                    live, dstr(text), self.ts(segs[0][1]), ''.join(', ' + e for e in extra))
            return 'Text(%s, style: %s%s)' % (dstr(text), self.ts(segs[0][1]), ''.join(', ' + e for e in extra))
        spans = []
        for t, i in segs:
            spans.append('TextSpan(text: %s, style: %s)' % (dstr(t), self.ts(i)))
        return 'Text.rich(TextSpan(style: %s, children: [%s])%s)' % (
            self.ts(inh), ', '.join(spans), ''.join(', ' + e for e in extra))

    # ── 装饰 ──
    def box_args(self, n, inh, parent, has_children_stack=False):
        """返回 hbox 参数列表（字符串）：浅色与深色不同的参数合并为 dk(context, 浅, 深)。"""
        la, neg = self._box_args(n, inh, parent, n.style, inh.get('color'))
        if not n.dark:
            return la, neg
        dst = dict(n.style)
        dst.update(n.dark)
        da, _ = self._box_args(n, inh, parent, dst, inh.get('dcolor') or inh.get('color'))
        ld = collections.OrderedDict(a.split(': ', 1) for a in la)
        dd = collections.OrderedDict(a.split(': ', 1) for a in da)
        out = []
        for k in list(ld) + [k for k in dd if k not in ld]:
            lv, dv = ld.get(k), dd.get(k)
            if lv == dv:
                out.append('%s: %s' % (k, lv))
            else:
                out.append('%s: dk(context, %s, %s)' % (k, lv if lv is not None else 'null', dv if dv is not None else 'null'))
        return out, neg

    def _box_args(self, n, inh, parent, st, cur):
        a = []
        w = st.get('width'); h = st.get('height')
        wpx = px(w) if w and not w.endswith('%') else None
        hpx = px(h) if h and not h.endswith('%') else None
        if wpx is not None:
            a.append('w: %s' % num(wpx))
        if hpx is not None:
            a.append('h: %s' % num(hpx))
        if 'min-width' in st and px(st['min-width']) is not None:
            a.append('minW: %s' % num(px(st['min-width'])))
        if 'min-height' in st and px(st['min-height']) is not None:
            a.append('minH: %s' % num(px(st['min-height'])))
        if 'max-width' in st and px(st['max-width']) is not None:
            a.append('maxW: %s' % num(px(st['max-width'])))
        # 背景
        bgv = st.get('background') or st.get('background-color')
        if bgv:
            g = parse_gradient(bgv, cur)
            if g:
                a.append('grad: %s' % g)
            else:
                c = parse_color(bgv, cur)
                if c:
                    a.append('bg: %s' % dcolor(c))
        # 圆角
        rv = st.get('border-radius')
        if rv:
            if rv.endswith('%'):
                r = min(wpx or 999, hpx or 999) / 2 if (wpx or hpx) else 999
                a.append('radius: BorderRadius.circular(%s)' % num(r))
            else:
                vals = rv.split()
                if len(vals) == 1:
                    if px(vals[0]):
                        a.append('radius: BorderRadius.circular(%s)' % num(min(px(vals[0]), 999)))
                else:
                    t = box4(rv)
                    pv = [px(x, 0) for x in t]
                    a.append('radius: BorderRadius.only(topLeft: Radius.circular(%s), topRight: Radius.circular(%s), bottomRight: Radius.circular(%s), bottomLeft: Radius.circular(%s))' % tuple(num(x) for x in pv))
        # 阴影 / 内描边
        shadows, ring = [], None
        if 'box-shadow' in st and st['box-shadow'] != 'none':
            for sh in split_top(st['box-shadow']):
                inset = sh.startswith('inset')
                sh2 = sh.replace('inset', '').strip()
                cm = re.search(r'(rgba?\([^)]*\)|#[0-9a-fA-F]{3,8})', sh2)
                color = parse_color(cm.group(1), cur) if cm else None
                nums = [float(x) for x in re.findall(r'(?<![\w#.])-?[\d.]+(?=px|\s|$)', sh2.replace(cm.group(1), '') if cm else sh2)]
                nums += [0.0] * (4 - len(nums))
                x, y, blur, spread = nums[:4]
                if inset:
                    if blur == 0 and x == 0 and y == 0:
                        ring = (color, spread)
                    continue
                shadows.append('BoxShadow(color: %s, offset: Offset(%s, %s), blurRadius: %s, spreadRadius: %s)' % (
                    dcolor(color), num(x), num(y), num(blur), num(spread)))
        if shadows:
            a.append('shadow: [%s]' % ', '.join(reversed(shadows)))
        # 边框
        border_sides = {}
        dashed = None
        for side in ('top', 'right', 'bottom', 'left'):
            v = st.get('border-' + side)
            if v:
                m = re.match(r'([\d.]+)px\s+(solid|dashed|dotted)\s+(.*)', v)
                if m:
                    border_sides[side] = (float(m.group(1)), parse_color(m.group(3), cur))
        bv = st.get('border')
        if bv and bv != '0' and bv != 'none':
            m = re.match(r'([\d.]+)px\s+(solid|dashed|dotted)\s+(.*)', bv)
            if m:
                if m.group(2) == 'solid':
                    for side in ('top', 'right', 'bottom', 'left'):
                        border_sides.setdefault(side, (float(m.group(1)), parse_color(m.group(3), cur)))
                else:
                    dashed = (float(m.group(1)), parse_color(m.group(3), cur))
        # border-top 虚线
        for side in ('top',):
            v = st.get('border-' + side)
            if v and 'dashed' in v and not dashed:
                m = re.match(r'([\d.]+)px\s+\w+\s+(.*)', v)
                dashed = (float(m.group(1)), parse_color(m.group(2), cur))
                border_sides.pop(side, None)
        if border_sides:
            a.append('border: Border(%s)' % ', '.join(
                '%s: BorderSide(color: %s, width: %s)' % (s, dcolor(c), num(wd)) for s, (wd, c) in border_sides.items()))
        elif ring and ring[0] is not None:
            a.append('border: Border.all(color: %s, width: %s)' % (dcolor(ring[0]), num(ring[1])))
        if dashed:
            a.append('dashed: true')
            a.append('dashColor: %s' % dcolor(dashed[1]))
            a.append('dashWidth: %s' % num(dashed[0]))
        # 内边距
        pads = [px(st.get('padding-' + s), 0.0) for s in ('top', 'right', 'bottom', 'left')]
        pad_top_code = num(pads[0])
        pad_bottom_code = num(pads[2])
        if st.get('padding-top') == '56px':
            pad_top_code = 'topInset(context)'
        if (parent == 'root_abs' and st.get('padding-bottom') == '30px') or st.get('padding-bottom') == '30px' and 'position' in st and st.get('position') == 'absolute':
            pad_bottom_code = 'bottomInset(context)'
        if any(pads) or pad_top_code != num(pads[0]) or pad_bottom_code != num(pads[2]):
            a.append('pad: EdgeInsets.fromLTRB(%s, %s, %s, %s)' % (num(pads[3]), pad_top_code, num(pads[1]), pad_bottom_code))
        # 外边距（负值另外处理）
        marg = [px(st.get('margin-' + s), 0.0) if st.get('margin-' + s) != 'auto' else 0.0 for s in ('top', 'right', 'bottom', 'left')]
        neg = {}
        for i, s in enumerate(('top', 'right', 'bottom', 'left')):
            if marg[i] < 0:
                neg[s] = marg[i]
                marg[i] = 0.0
        if any(marg):
            a.append('margin: EdgeInsets.fromLTRB(%s, %s, %s, %s)' % (num(marg[3]), num(marg[0]), num(marg[1]), num(marg[2])))
        if st.get('overflow') == 'hidden':
            a.append('clip: true')
        if 'opacity' in st:
            a.append('opacity: %s' % st['opacity'])
        return a, neg

    def align_code(self, n, direction):
        st = n.style
        if st.get('display') not in ('flex', 'inline-flex'):
            return None
        jc = st.get('justify-content', 'flex-start')
        ai = st.get('align-items')
        f = {'center': 0, 'flex-start': -1, 'start': -1, 'flex-end': 1, 'end': 1}
        if jc not in f and jc != 'flex-start':
            return None
        jv = f.get(jc, -1)
        av = f.get(ai, None) if ai else None
        if av is None:
            av = -1 if ai is None else None
        if av is None:
            return None
        if jv == -1 and av == -1:
            return None
        x, y = (jv, av) if direction == 'row' else (av, jv)
        return 'Alignment(%s, %s)' % (num(x), num(y))

    # ── 最大内容宽度估算（用于模拟 CSS flex-shrink 的按比例收缩）──
    def has_text(self, n):
        if isinstance(n, str):
            return bool(n.strip())
        if n.tag in ('svg', 'input', 'textarea') or self.is_abs(n):
            return False
        return any(self.has_text(c) for c in n.children)

    def est(self, n, inh):
        if isinstance(n, str):
            t = re.sub(r'\s+', ' ', n.strip())
            w = 0.0
            for ch in t:
                o = ord(ch)
                if o > 0x2E80:
                    w += inh['size']
                elif ch == ' ':
                    w += inh['size'] * 0.3
                elif ch.isdigit() or ch.isalpha():
                    w += inh['size'] * 0.58
                else:
                    w += inh['size'] * 0.5
            return w
        if n.tag == 'svg':
            return px(n.attrs.get('width', ''), 0) or 0
        if n.tag in ('input', 'textarea'):
            return 100.0
        st = n.style
        wv = st.get('width')
        if wv and not wv.endswith('%') and px(wv) is not None:
            return px(wv)
        inh2 = self.inherit(inh, st, n.dark)
        kids = [c for c in n.children if not (isinstance(c, Node) and self.is_abs(c))]
        pad = (px(st.get('padding-left'), 0) or 0) + (px(st.get('padding-right'), 0) or 0)
        if self.text_only(n):
            segs = []
            self.collect(n, inh2, segs)
            return sum(self.est(t, i) for t, i in segs) + pad
        disp = self.disp(n)
        parts = [self.est(c, inh2) for c in kids if not isinstance(c, str) or c.strip()]
        if not parts:
            return pad
        if disp in ('flex', 'inline-flex') and st.get('flex-direction') != 'column':
            return sum(parts) + (px(st.get('gap'), 0) or 0) * (len(parts) - 1) + pad
        return max(parts) + pad

    # ── 主入口：元素 ──
    def emit(self, n, inh, parent):
        """parent: 'row' | 'col' | 'block' | 'grid' | 'abs' | 'root'"""
        if isinstance(n, str):
            return 'Text(%s, style: %s)' % (dstr(re.sub(r'\s+', ' ', n).strip()), self.ts(inh))
        if n.tag == 'svg':
            return self.emit_svg(n, inh, parent)
        if n.tag == 'input':
            return self.emit_input(n, inh, parent)
        if n.tag == 'textarea':
            return self.emit_textarea(n, inh)
        if n.attrs.get('role') == 'switch':
            on = n.attrs.get('aria-checked') == 'true'
            return 'HSwitch(initial: %s)' % ('true' if on else 'false')
        if n.attrs.get('aria-label', '').startswith('车牌号') and n.tag == 'div':
            return self.emit_plate(n)
        pick_vars = self.setup_picker(n)
        inh2 = self.inherit(inh, n.style, n.dark)
        st = n.style
        disp = self.disp(n)
        kids = self.kids(n)
        content = None
        direction = 'row'
        is_text = self.text_only(n)
        if is_text and '_code' in n.attrs:
            content = 'hCodeText(%s, %s)' % (n.attrs['_code'], self.ts(inh2))
        elif is_text and '_str' in n.attrs:
            ph = n.attrs.get('_ph')
            content = 'hStr(%s, %s%s)' % (n.attrs['_str'], self.ts(inh2), ', placeholder: %s' % dstr(ph) if ph else '')
        elif is_text and '_count' in n.attrs:
            content = 'hCount(%s, %s%s)' % (n.attrs['_count'], self.ts(inh2), (', %s' % n.attrs['_cfmt']) if '_cfmt' in n.attrs else '')
        elif is_text and '_month' in n.attrs:
            content = 'hMonth(%s, %s)' % (n.attrs['_month'], self.ts(inh2))
        elif is_text and '_pwd' in n.attrs:
            content = 'hPwdLabel(%s, %s)' % (n.attrs['_pwd'], self.ts(inh2))
        elif is_text:
            content = self.emit_text(n, inh2)
        elif not kids:
            content = None
        elif disp == 'grid':
            content = self.emit_grid(n, inh2)
        else:
            inline_mixed = (disp == 'inline' and any(isinstance(k, str) for k in kids)
                            and any(isinstance(k, Node) for k in kids))
            if inline_mixed:
                # 行内混排（文字 + 带底色的小标签）：按一行排列，垂直居中
                n.style.setdefault('align-items', 'center')
                n.style.setdefault('gap', '6px')
                direction = 'row'
                disp = 'inline-flex'
            else:
                direction = 'col' if (disp in ('block', 'inline') or st.get('flex-direction') == 'column') else 'row'
            content = self.emit_flex(n, inh2, direction, disp, parent)
        # 盒子
        args, neg = self.box_args(n, inh2, parent)
        al = self.align_code(n, direction) if is_text else None
        if is_text and al is None and inh2.get('ta') in ('center', 'right') and \
                any(a.startswith(('w:', 'minW:')) for a in args):
            al = 'Alignment.center' if inh2.get('ta') == 'center' else 'Alignment.centerRight'
        if is_text and n.tag == 'button' and not st.get('display') and (st.get('height') or st.get('min-height') or st.get('width')):
            al = 'Alignment.center'
        if al:
            if any(a.startswith('w:') for a in args) or st.get('width') == '100%':
                args.append('align: %s' % al)
            else:
                content = 'Align(alignment: %s, widthFactor: 1, child: %s)' % (al, content)
        wv = st.get('width')
        frac = None
        if wv and wv.endswith('%') and wv != '100%':
            frac = float(wv[:-1]) / 100
        if content is None:
            if args:
                code = 'hbox(%s)' % ', '.join(args)
            else:
                code = 'SizedBox.shrink()'
        elif args:
            code = 'hbox(%s, child: %s)' % (', '.join(args), content)
        else:
            code = content
        if st.get('aspect-ratio'):
            code = 'AspectRatio(aspectRatio: %s, child: %s)' % (st['aspect-ratio'], code)
        if frac is not None and parent != 'row':
            code = 'hfrac(%s, %s)' % (num(frac), code)
        if neg:
            code = 'NegMargin(top: %s, left: %s, child: %s)' % (num(neg.get('top', 0)), num(neg.get('left', 0)), code)
        # 图片选择：拍照 / 相册（“添加”按钮、虚线上传框、照片占位）
        pk = self.image_kind(n)
        if pk:
            self.img_n = getattr(self, 'img_n', 0) + 1
            ikey = dstr('%s_%s' % (self.page_name, pk[1] if len(pk) > 1 and pk[1] else self.img_n))
            rad = n.style.get('border-radius', '16px')
            rv = float(re.match(r'[\d.]+', rad).group(0)) if re.match(r'[\d.]+', rad) else 16
            if rad.endswith('%'):
                rv = 999
            if pk[0] == 'add':
                sz = n.style.get('width', '72px')
                szv = float(re.match(r'[\d.]+', sz).group(0)) if re.match(r'[\d.]+', sz) else 72
                code = 'HImageAdd(imgKey: %s, size: %s, radius: %s, child: %s)' % (ikey, num(szv), num(rv), code)
            else:
                code = 'HImageSlot(imgKey: %s, radius: %s, child: %s)' % (ikey, num(rv), code)
        elif n.tag == 'a' or n.tag == 'button' or ('_tap' in n.attrs and not n.attrs.get('_notap')) \
                or (self.page_name == 'ProfileEdit' and re.sub(r'\s+', ' ', self.tree_text(n)).strip() == '更换头像'):
            code = self.tap(n, code)
        for pv, init, pk in reversed(pick_vars):
            if pk == 'code':
                code = 'HCodeHolder(builder: (context, %s) => %s)' % (pv, code)
            else:
                code = 'HStrHolder(initial: %s, builder: (context, %s) => %s)' % (dstr(init), pv, code)
        return code

    def image_kind(self, n):
        """返回 ('add'|'slot', key) 表示该节点是图片选择入口。"""
        label = n.attrs.get('aria-label', '')
        txt = re.sub(r'\s+', ' ', self.tree_text(n)).strip()
        st = n.style
        if label == '拍照添加凭证':
            return ('add', None)
        if label in ('添加照片', '照片占位', '封面照片占位', '门店照片占位'):
            return ('slot', None)
        if 'dashed' in (st.get('border') or '') and txt.startswith('上传'):
            return ('slot', None)
        if 'dashed' in (st.get('border') or '') and not txt and st.get('width', '').endswith('px') \
                and float(st['width'][:-2]) <= 90:
            return ('slot', None)
        if self.page_name == 'ProfileEdit' and n.tag == 'span' and st.get('width') == '88px' and txt.startswith('陈'):
            return ('slot', 'avatar')
        return None

    def tap(self, n, code):
        txt0 = re.sub(r'\s+', ' ', self.tree_text(n)).strip()
        if self.page_name == 'ProfileEdit' and txt0 == '更换头像':
            return "hTap(context, %s, onTap: () => hPickImage(context, 'ProfileEdit_avatar'))" % code
        if n.attrs.get('_notap'):
            return code
        if '_tap' in n.attrs:
            return 'hTap(context, %s, onTap: %s)' % (code, n.attrs['_tap'])
        href = n.attrs.get('href', '')
        label = n.attrs.get('aria-label', '') or re.sub(r'\s+', ' ', self.tree_text(n)).strip()
        m = re.match(r'([A-Za-z]+)\.dc\.html', href)
        back = any(k in label for k in ('返回', '关闭')) or self.has_back_icon(n)
        if back:
            return 'hTap(context, %s, back: true)' % code
        if m:
            return 'hTap(context, %s, to: %s)' % (code, dstr(m.group(1)))
        if re.search(r'(删除此|停用|解除绑定|退出所有|注销账号)', label):
            return 'hTap(context, %s, onTap: () => hConfirmPop(context, %s))' % (code, dstr(label[:14]))
        if href.startswith('tel:'):
            return 'hTap(context, %s, label: %s)' % (code, dstr('拨打电话'))
        return 'hTap(context, %s, label: %s)' % (code, dstr(label[:14]))

    def has_back_icon(self, n):
        for c in n.children:
            if isinstance(c, Node) and c.tag == 'svg':
                if 'M15 6l-6 6 6 6' in c.raw or 'M6 6l12 12M18 6L6 18' in c.raw:
                    return True
        return False

    # ── svg ──
    def emit_svg(self, n, inh, parent):
        raw0 = n.raw
        cur = inh.get('color') or (0, 0, 0, 1)
        dcur = inh.get('dcolor') or cur
        raw = re.sub(r'currentColor', scolor(cur), raw0)
        # 深色模式：currentColor 取深色文字色，描边里的灰色按文字色表映射（装饰性填充保持不变）
        draw = re.sub(r'(stroke=")(#[0-9A-Fa-f]{6})(")',
                      lambda m: m.group(1) + FG_DARK.get(m.group(2).upper(), m.group(2)) + m.group(3), raw0)
        draw = re.sub(r'currentColor', scolor(dcur), draw)
        if 'id="abg"' in raw:
            # 设计稿里这个图标的子元素被误写入了外层的 width/height/style，这里还原为 1024 画布
            head_end = raw.index('>') + 1
            rest = raw[head_end:]
            rest = re.sub(r'\s*aria-hidden="true"\s*style="display: block;"', '', rest)
            rest = rest.replace('width="88" height="88"', 'width="1024" height="1024"')
            raw = raw[:head_end] + rest
        # 去掉外层 style
        raw = re.sub(r'^(<svg\b[^>]*?)\sstyle="[^"]*"', r'\1', raw, count=1, flags=re.S)
        if 'xmlns=' not in raw[:200]:
            raw = raw.replace('<svg', '<svg xmlns="http://www.w3.org/2000/svg"', 1)
        draw = re.sub(r'^(<svg\b[^>]*?)\sstyle="[^"]*"', r'\1', draw, count=1, flags=re.S)
        if 'xmlns=' not in draw[:200]:
            draw = draw.replace('<svg', '<svg xmlns="http://www.w3.org/2000/svg"', 1)
        w = n.attrs.get('width'); h = n.attrs.get('height')
        w = px(w) if w else None
        h = px(h) if h else None
        args = []
        if w:
            args.append('w: %s' % num(w))
        if h:
            args.append('h: %s' % num(h))
        if 'id="abg"' in draw:
            draw = raw
        if draw != raw:
            src = 'dk(context, %s, %s)' % (self.svg_const(raw), self.svg_const(draw))
        else:
            src = self.svg_const(raw)
        code = 'hsvg(%s%s)' % (src, ''.join(', ' + a for a in args))
        st = n.style
        marg = [px(st.get('margin-' + s), 0.0) for s in ('top', 'right', 'bottom', 'left')]
        if any(marg):
            code = 'Padding(padding: EdgeInsets.fromLTRB(%s, %s, %s, %s), child: %s)' % (
                num(marg[3]), num(marg[0]), num(marg[1]), num(marg[2]), code)
        return code

    # ── 表单 ──
    def placeholder_for(self, n):
        """输入框的 placeholder：优先用设计稿写的；没有就取 label / aria-label 文字，
        拼成“请输入××”；都没有时退回“请输入”。"""
        ph = (n.attrs.get('placeholder') or '').strip()
        if ph:
            return ph
        label = self.labels.get(n.attrs.get('id', '')) or n.attrs.get('aria-label') or ''
        label = re.sub(r'[*＊\s]+', '', label)
        label = re.sub(r'[（(·].*$', '', label)
        return '请输入' + label

    def emit_input(self, n, inh, parent):
        t = n.attrs.get('type', 'text')
        inh2 = self.inherit(inh, n.style, n.dark)
        if t == 'checkbox':
            size = px(n.style.get('width'), 16)
            ac = parse_color(n.style.get('accent-color', ''), None)
            col = ', color: %s' % dcolor(ac) if ac else ''
            code = 'HCheck(initial: %s, size: %s%s)' % ('true' if 'checked' in n.attrs else 'false', num(size), col)
            mg = [px(n.style.get('margin-' + sd), 0.0) or 0.0 for sd in ('top', 'right', 'bottom', 'left')]
            if any(mg):
                code = 'Padding(padding: EdgeInsets.fromLTRB(%s, %s, %s, %s), child: %s)' % (num(mg[3]), num(mg[0]), num(mg[1]), num(mg[2]), code)
            return code
        kb = {'tel': 'TextInputType.phone', 'number': 'TextInputType.number', 'email': 'TextInputType.emailAddress'}.get(t)
        mode = n.attrs.get('inputmode')
        if mode == 'numeric':
            kb = 'TextInputType.number'
        if mode == 'decimal':
            kb = 'TextInputType.numberWithOptions(decimal: true)'
        args = ['style: %s' % self.ts(inh2)]
        # 规范：所有输入框没值时都要有 placeholder（设计稿没写的，用对应标签文字推导）
        args.append('hint: %s' % dstr(self.placeholder_for(n)))
        if n.attrs.get('value'):
            args.append('value: %s' % dstr(n.attrs['value']))
        if kb:
            args.append('keyboard: %s' % kb)
        if t == 'password':
            args.append('obscure: true')
        ta = {'center': 'TextAlign.center', 'right': 'TextAlign.right'}.get(inh2.get('ta'))
        if ta:
            args.append('align: %s' % ta)
        if '_obscure' in n.attrs:
            ctl = n.attrs['_obscure']
            args = [a for a in args if a != 'obscure: true'] + ['obscure: %s.on' % ctl]
            code = 'ListenableBuilder(listenable: %s, builder: (context, _) => HInput(%s))' % (ctl, ', '.join(args))
        else:
            code = 'HInput(%s)' % ', '.join(args)
        box, _ = self.box_args(n, inh2, parent)
        if box:
            if any(a.startswith('h:') for a in box):
                box.append('align: Alignment.centerLeft')
            code = 'hbox(%s, child: %s)' % (', '.join(box), code)
        return code

    def emit_textarea(self, n, inh):
        inh2 = self.inherit(inh, n.style, n.dark)
        args = ['style: %s' % self.ts(inh2), 'maxLines: 4']
        args.append('hint: %s' % dstr(self.placeholder_for(n)))
        txt = ''.join(c for c in n.children if isinstance(c, str)).strip()
        if txt:
            args.append('value: %s' % dstr(txt))
        code = 'HInput(%s)' % ', '.join(args)
        a, _ = self.box_args(n, inh2, 'block')
        a = [x for x in a if not x.startswith('w:')]
        return 'hbox(%s, child: %s)' % (', '.join(a), code) if a else code

    # ── 交互：可选控件 ──
    def selectable(self, c):
        return (isinstance(c, Node) and c.tag == 'button' and 'disabled' not in c.attrs and (
            c.attrs.get('role') in ('radio', 'tab', 'checkbox') or 'aria-pressed' in c.attrs))

    def sel_state(self, c):
        for k in ('aria-checked', 'aria-selected', 'aria-pressed'):
            if k in c.attrs:
                return c.attrs[k] == 'true'
        return False

    def kind(self, c):
        if 'aria-pressed' in c.attrs:
            return 'press'
        return c.attrs.get('role', 'press')

    def prescan(self, n):
        """记录页面内各类可选控件的“选中/未选中”参考节点。"""
        if not isinstance(n, Node):
            return
        if self.selectable(n):
            ref = self.refs.setdefault(self.kind(n), {})
            ref.setdefault('on' if self.sel_state(n) else 'off', n)
        for c in n.children:
            self.prescan(c)

    def tree_text(self, n):
        if isinstance(n, str):
            return n
        return ''.join(self.tree_text(c) for c in n.children)

    def new_ctrl(self, prefix='g'):
        self.sel_counter += 1
        return '%s%d' % (prefix, self.sel_counter)

    def find_groups(self, kids, pg=None):
        """把同级的可选控件分组。每组：on_node/off_node 为样式参考，cands 为成员。"""
        groups, mapping = [], {}
        cands = [c for c in kids if self.selectable(c)]
        if len(cands) >= 2:
            by = collections.OrderedDict()
            for c in cands:
                key = 'multi' if ('aria-pressed' in c.attrs or c.attrs.get('role') == 'checkbox') else 'single'
                by.setdefault(key, []).append(c)
            for key, cs in by.items():
                ons = [c for c in cs if self.sel_state(c)]
                offs = [c for c in cs if not self.sel_state(c)]
                ref = self.refs.get(self.kind(cs[0]), {})
                on_n = ons[0] if ons else ref.get('on')
                off_n = offs[0] if offs else ref.get('off')
                if on_n is None or off_n is None:
                    continue
                gi = len(groups)
                groups.append({'multi': key == 'multi', 'on_node': on_n, 'off_node': off_n, 'cands': cs,
                               'initial': [i for i, c in enumerate(cs) if self.sel_state(c)]})
                for i, c in enumerate(cs):
                    mapping[id(c)] = (gi, i)
        # 非按钮的“样式差异”分组（日期条、标签条、芯片）
        sg = self.style_group(kids)
        if sg:
            gi = len(groups)
            groups.append(sg)
            for i, c in enumerate(sg['cands']):
                mapping[id(c)] = (gi, i)
        return groups, mapping

    VIS = {'background', 'color', 'box-shadow', 'font-weight', 'border', 'opacity'}

    def style_group(self, kids):
        els = [c for c in kids if isinstance(c, Node) and not self.is_abs(c)]
        if len(els) < 3 or any(self.selectable(c) for c in els):
            return None
        if len({c.tag for c in els}) != 1 or els[0].tag in ('svg', 'input', 'br', 'textarea', 'a'):
            return None
        keys = set()
        for c in els:
            keys |= set(c.style)
        diff = [k for k in keys if len({c.style.get(k) for c in els}) > 1]
        if not diff or not set(diff) <= self.VIS or 'background' not in diff:
            return None
        texts = [self.tree_text(c).strip() for c in els]
        if any(len(t) < 2 or len(t) > 14 for t in texts):
            return None
        variants = collections.OrderedDict()
        for c in els:
            variants.setdefault(tuple(sorted((k, c.style.get(k)) for k in diff)), []).append(c)
        if len(variants) != 2:
            return None
        v = sorted(variants.values(), key=len)
        on_nodes, off_nodes = v[0], v[1]
        if len(on_nodes) > len(off_nodes):
            return None
        multi = self.page_name in ('AppointmentAdd', 'RegShop')
        return {'multi': multi, 'on_node': on_nodes[0], 'off_node': off_nodes[0], 'cands': els,
                'initial': [i for i, c in enumerate(els) if c in on_nodes], 'style_only': True, 'on_members': on_nodes}

    def variant(self, c, g, want_on):
        ref = g['on_node'] if want_on else g['off_node']
        other = g['off_node'] if want_on else g['on_node']
        orig = self.sel_state(c) if 'style_only' not in g else (c in g.get('on_members', []))
        if 'style_only' in g:
            orig = c in g['on_members']
        if want_on == orig:
            # 本来就处于该状态：保持设计稿原样
            n = c.copy_with_style(dict(c.style))
            n.attrs['_notap'] = '1'
            return n
        delta = [k for k in set(ref.style) | set(other.style) if ref.style.get(k) != other.style.get(k)]
        # 各成员本来就不同的底色（如各色圆点）不属于“选中态差异”
        members = g.get('cands', [])
        if not g.get('style_only') and len({x.style.get('background') for x in members}) > 1 and 'background' in delta:
            delta.remove('background')
        st = dict(c.style)
        for k in delta:
            if k in ref.style:
                st[k] = ref.style[k]
            else:
                st.pop(k, None)
        n = c.copy_with_style(st)
        # 纯图标控件：选中态常带有额外的子元素（如 √），以参考节点的子元素为准
        if not self.has_text(c) and not g.get('style_only') and self.struct(ref) != self.struct(other):
            n.children = ref.children
        n.attrs['_notap'] = '1'
        return n

    def struct(self, n):
        return [(x.tag, x.raw if x.tag == 'svg' else None) if isinstance(x, Node) else 'T' for x in n.children]

    # 把页面内同一类控件当作独立开关处理（没有同级对照时使用页面参考）
    def toggle_code(self, c, inh, direction):
        ref = self.refs.get(self.kind(c), {})
        if 'on' not in ref or 'off' not in ref:
            return None
        g = {'on_node': ref['on'], 'off_node': ref['off']}
        on = self.emit(self.variant(c, g, True), inh, direction)
        off = self.emit(self.variant(c, g, False), inh, direction)
        return 'HToggle(initial: %s, on: %s, off: %s)' % ('true' if self.sel_state(c) else 'false', on, off)

    # ── 表单选择行 / 车牌 ──
    PICK_RULES = [
        (r'^生日(?!礼)', 'birthday'), (r'品牌车型', 'car'), (r'^(所在)?城市', 'city'), (r'^所属分类', 'category'),
        (r'^标准工时', 'duration'), (r'^供应商', 'supplier'), (r'^收款方', 'payee'),
        (r'^支付(账户|方式)', 'account'), (r'^推荐人', 'referrer'), (r'^工位', 'station'),
        (r'^(领用|默认)?技师', 'tech'), (r'^关联工单', 'workorder'), (r'^积分倍率', 'multiplier'),
        (r'^生日礼', 'gift'), (r'^(开始|结束)日期$', 'datefull'), (r'^运费', 'amount'), (r'^(入库|出库)?日期', 'date'), (r'^从 ', 'budgetFrom'),
    ]

    def leaf_texts(self, n, out=None):
        out = [] if out is None else out
        for c in n.children:
            if isinstance(c, Node) and c.tag not in ('svg', 'input', 'textarea'):
                if self.text_only(c):
                    out.append(c)
                else:
                    self.leaf_texts(c, out)
        return out

    def has_chevron(self, n):
        return any(isinstance(c, Node) and c.tag == 'svg' and ('M9 6l6 6-6 6' in c.raw or 'M6 9l6 6 6-6' in c.raw)
                   for c in n.children) or any(
            isinstance(c, Node) and c.tag in ('span', 'div') and self.has_chevron(c) for c in n.children)

    TIME_RE = r'\d{1,2}:\d{2}'

    def setup_picker(self, n):
        """表单里“标签 + 值 + ›”的选择行：点击弹出选择器，选中值回写到行内。返回 [(控制器变量, 初始值)]。"""
        if '_picked' in n.attrs or n.tag not in ('div', 'button') or n.attrs.get('href') or self.is_abs(n):
            return []
        leaves = self.leaf_texts(n)
        if n.tag == 'button' and self.text_only(n):
            leaves = [n]
        texts = [re.sub(r'\s+', ' ', self.tree_text(l)).strip() for l in leaves]
        # 时间区间：09:00 至 20:00，两个时间各自可选
        if n.tag == 'div' and len(texts) == 3 and texts[1] == '至' and all(re.fullmatch(self.TIME_RE, t) for t in (texts[0], texts[2])):
            out = []
            for leaf, t, lab in ((leaves[0], texts[0], '开始'), (leaves[2], texts[2], '结束')):
                var = self.new_ctrl('s')
                leaf.attrs['_str'] = var
                leaf.attrs['_tap'] = '() => hPick(context, \'time\', %s, %s)' % (dstr(lab), var)
                out.append((var, t, 'str'))
            n.attrs['_picked'] = 'time-range'
            return out
        # 单个时间按钮：开门 09:00 / 打烊 20:00
        if n.tag == 'button' and len(texts) == 2 and re.fullmatch(self.TIME_RE, texts[1]):
            var = self.new_ctrl('s')
            n.attrs['_picked'] = var
            leaves[1].attrs['_str'] = var
            n.attrs['_tap'] = '() => hPick(context, \'time\', %s, %s)' % (dstr(texts[0]), var)
            return [(var, texts[1], 'str')]
        # 获取验证码：点击后 60 秒倒计时
        if n.tag == 'button' and len(texts) == 1 and texts[0] == '获取验证码':
            var = self.new_ctrl('k')
            n.attrs['_picked'] = var
            leaves[0].attrs['_code'] = var
            n.attrs['_tap'] = '() => hSendCode(context, %s)' % var
            return [(var, '', 'code')]
        free_date = (len(texts) == 2 and re.match(r'^(开始|结束)日期$', texts[0]) and re.fullmatch(r'\d{4}\.\d{2}\.\d{2}', texts[1]))
        if not free_date and (not self.has_chevron(n) or n.attrs.get('aria-label') in ('上个月', '下个月')):
            return []
        texts = [t for t in texts if t and t != '*']
        if not texts or len(texts) > 3:
            return []
        label = re.sub(r'\s*\*$', '', texts[0]) if len(texts) >= 2 else ''
        value_node = [l for l in leaves if re.sub(r'\s+', ' ', self.tree_text(l)).strip() not in ('', '*')][-1]
        value = texts[-1]
        kind = None
        if len(texts) == 1 and re.fullmatch(r'\S+[市] · \S+', value):
            kind, label = 'city', '所在城市'
        else:
            for pat, k in self.PICK_RULES:
                if re.search(pat, label):
                    kind = k
                    break
        if kind is None or len(texts) < 2 and kind != 'city':
            return []
        var = self.new_ctrl('s')
        n.attrs['_picked'] = var
        value_node.attrs['_str'] = var
        if re.match(r'^(选填|请选择|请输入)', value):
            value_node.attrs['_ph'] = value
        n.attrs['_tap'] = '() => hPick(context, %s, %s, %s)' % (dstr(kind), dstr(label), var)
        return [(var, value, 'str')]

    def emit_plate(self, n):
        cells = [c for c in self.kids(n) if isinstance(c, Node)]
        label = n.attrs.get('aria-label', '')
        m = re.search(r'车牌号\s*(\S+)', label)
        initial = m.group(1) if m else ''
        bg = parse_color(cells[0].style.get('background', '')) if cells else None
        green = bool(bg and bg[1] > bg[2] and bg[1] > bg[0] + 30)
        linked = 'true' if self.page_name == 'VehicleAdd' else 'false'
        return 'HPlate(initial: %s, green: %s, linked: %s)' % (dstr(initial), 'true' if green else 'false', linked)

    # ── 交互：计数器 / 月份 / 密码显隐 / 列表筛选与删除 ──
    def find_all(self, n, pred, out=None):
        out = [] if out is None else out
        if isinstance(n, Node):
            if pred(n):
                out.append(n)
            for c in n.children:
                self.find_all(c, pred, out)
        return out

    def setup_widgets(self, n, kids):
        """识别 步进器 / 月份切换 / 密码显示 并给节点打上动作标记。返回 (holder 变量名, 创建表达式) 列表。"""
        holders = []
        sub = [c for k in kids if isinstance(k, Node) for c in [k]]
        # 步进器：同一父级里同时存在 减 / 加 控件，中间是数字（可带小数与单位后缀）
        def _txt(c):
            return re.sub(r'\s+', ' ', self.tree_text(c)).strip()

        def _is_minus(c):
            return c.tag in ('button', 'span') and (c.attrs.get('aria-label') in ('减少', '降低折扣') or _txt(c) in ('−', '-', '–'))

        def _is_plus(c):
            if c.tag not in ('button', 'span'):
                return False
            if c.attrs.get('aria-label') in ('增加', '提高折扣') or _txt(c) == '+':
                return True
            return any(isinstance(x, Node) and x.tag == 'svg' and x.raw and 'M12 5v14M5 12h14' in x.raw for x in c.children) and not _txt(c)

        minus = [c for c in sub if _is_minus(c)]
        plus = [c for c in sub if _is_plus(c)]
        if minus and plus:
            num_nodes = [c for c in sub if c.tag in ('span', 'div') and c is not minus[0] and c is not plus[0]
                         and re.fullmatch(r'[\d,]+(\.\d+)?( ?[^\d\s]{1,3})?', _txt(c) or 'x')]
            if num_nodes:
                m = re.fullmatch(r'([\d,]+)(\.\d+)?( ?[^\d\s]{1,3})?', _txt(num_nodes[0]))
                dec = len(m.group(2)) - 1 if m.group(2) else 0
                suffix = m.group(3) or ''
                comma = ',' in m.group(1)
                base = float(m.group(1).replace(',', '') + (m.group(2) or ''))
                scaled = int(round(base * (10 ** dec)))
                if dec:
                    step = 1
                else:
                    step = 1 if base < 100 else (10 if base < 1000 else 100)
                v = self.new_ctrl('c')
                holders.append((v, 'ValCtrl(%d)' % scaled))
                minus[0].attrs['_tap'] = '() => %s.add(-%d)' % (v, step)
                plus[0].attrs['_tap'] = '() => %s.add(%d)' % (v, step)
                num_nodes[0].attrs['_count'] = v
                num_nodes[0].attrs['_cfmt'] = '%d, %s, %s' % (dec, dstr(suffix), 'true' if comma else 'false')
        # 月份切换
        prev = [c for c in sub if c.attrs.get('aria-label') == '上个月']
        nxt = [c for c in sub if c.attrs.get('aria-label') == '下个月']
        if prev and nxt:
            for c in prev:
                pass
            lab = [c for c in sub if c.tag in ('span', 'div') and re.fullmatch(r'\d{4} 年 \d{1,2} 月', self.tree_text(c).strip() or 'x')]
            if lab:
                m = re.fullmatch(r'(\d{4}) 年 (\d{1,2}) 月', self.tree_text(lab[0]).strip())
                v = self.new_ctrl('m')
                holders.append((v, 'ValCtrl(%d)' % (int(m.group(1)) * 12 + int(m.group(2)) - 1)))
                prev[0].attrs['_tap'] = '() => %s.add(-1, min: 0)' % v
                nxt[0].attrs['_tap'] = '() => %s.add(1, min: 0)' % v
                lab[0].attrs['_month'] = v
        # 密码显示
        pwd = [c for c in sub if c.tag == 'input' and c.attrs.get('type') == 'password']
        if pwd:
            toggles = [c for c in sub if c.tag in ('button', 'span') and self.tree_text(c).strip() == '显示']
            if toggles:
                v = self.new_ctrl('p')
                holders.append((v, 'ValCtrl(1)'))
                pwd[0].attrs['_obscure'] = v
                toggles[0].attrs['_tap'] = '() => %s.flip()' % v
                toggles[0].attrs['_pwd'] = v
        return holders

    def delete_buttons(self, n):
        return self.find_all(n, lambda x: x.tag == 'button' and re.match(r'(删除|移除)', x.attrs.get('aria-label', '')) and '此' not in x.attrs.get('aria-label', ''))

    def tab_labels(self, P):
        """P 下的 role=tab 单选组标签（去掉数字）。"""
        tabs = [c for c in P.children if isinstance(c, Node) and c.tag == 'button' and c.attrs.get('role') in ('tab', 'radio')]
        if len(tabs) < 3:
            return None
        return tabs, [re.sub(r'[\d\s·()（）]+', '', self.tree_text(t)) for t in tabs]

    def filter_target(self, Y, labels):
        """Y 或其唯一子容器是否是可按 labels 过滤的列表。"""
        cur = Y
        for _ in range(3):
            if not isinstance(cur, Node):
                return None
            els = [c for c in self.kids(cur) if isinstance(c, Node) and not self.is_abs(c)]
            if len(els) >= 3:
                real = [l for l in labels if l and '全部' not in l]
                if real and all(any(l in self.tree_text(e) for e in els) for l in real):
                    return cur
                return None
            if len(els) == 1:
                cur = els[0]
                continue
            return None
        return None

    def link_filters(self, n, kids):
        """容器 n 内：前面的标签条与后面的列表联动 -> 返回需要在 n 处创建的分组 [(init, multi)]。"""
        out = []
        els = [c for c in kids if isinstance(c, Node)]
        for i, X in enumerate(els):
            for P in self.find_all(X, lambda x: self.tab_labels(x) is not None):
                tabs, labels = self.tab_labels(P)
                if id(tabs[0]) in self.shared:
                    continue
                done = False
                for Y in els[i + 1:]:
                    tgt = self.filter_target(Y, labels)
                    if tgt is not None and id(tgt) not in self.dyn_filter:
                        init = [j for j, t in enumerate(tabs) if self.sel_state(t)] or [0]
                        out.append((tabs, labels, tgt, init, None))
                        done = True
                        break
                if not done:
                    real = [l for l in labels if l and '全部' not in l]
                    after = [Y for Y in els[i + 1:] if any(l in self.tree_text(Y) for l in real)]
                    if len(after) >= 2 and id(n) not in self.dyn_filter:
                        init = [j for j, t in enumerate(tabs) if self.sel_state(t)] or [0]
                        out.append((tabs, labels, n, init, set(id(a) for a in after)))
        return out

    def emit_flex(self, n, inh, direction, disp, parent):
        st = n.style
        kids = self.kids(n)
        holders = self.setup_widgets(n, kids)
        links = self.link_filters(n, kids)
        groups, mapping = self.find_groups(kids)
        gname = None
        own = []          # 在本容器创建的分组 (init, multi)
        gref = {}         # 分组下标 -> 控制器表达式
        for gi, g in enumerate(groups):
            ext = self.shared.get(id(g['cands'][0]))
            if ext:
                gref[gi] = '%s[%d]' % ext
        if any(gi not in gref for gi in range(len(groups))) or links:
            gname = self.new_ctrl('g')
        for gi, g in enumerate(groups):
            if gi not in gref:
                gref[gi] = '%s[%d]' % (gname, len(own))
                own.append((g['initial'], g['multi']))
        for tabs, labels, tgt, init, only in links:
            idx = len(own)
            own.append((init, False))
            self.shared[id(tabs[0])] = (gname, idx)
            self.dyn_filter[id(tgt)] = (gname, idx, labels, only)
        dyn = None
        dyn_codes, dyn_texts = [], []
        els_for_dyn = [c for c in kids if isinstance(c, Node) and not self.is_abs(c)]
        dels = [c for c in els_for_dyn if self.delete_buttons(c)]
        if len(dels) < 2:
            dels = []
        flt = self.dyn_filter.get(id(n))
        item_ids = set()
        if flt:
            item_ids |= (flt[3] if flt[3] is not None else set(id(c) for c in els_for_dyn))
        item_ids |= set(id(c) for c in dels)
        if item_ids:
            dyn = self.new_ctrl('d')
            for i, c in enumerate(els_for_dyn):
                if id(c) in item_ids:
                    for b in self.delete_buttons(c):
                        b.attrs['_tap'] = '() => %s.confirmRemove(context, %d)' % (dyn, len(dyn_texts) + 0 if False else sum(1 for e in els_for_dyn[:i] if id(e) in item_ids))
        # 是否定义了主轴尺寸
        if direction == 'row':
            definite = parent in ('col', 'block', 'grid', 'root', 'abs', 'root_abs', 'root_fixed') or st.get('width') is not None or st.get('flex-grow', '0') not in ('0',)
            if disp == 'inline-flex' and parent in ('block',):
                definite = False
        else:
            definite = st.get('height') is not None and not st.get('height', '').endswith('%') or parent == 'root_fixed'
        ai = st.get('align-items')
        jc = st.get('justify-content', 'flex-start')
        main_map = {'flex-start': 'MainAxisAlignment.start', 'start': 'MainAxisAlignment.start',
                    'center': 'MainAxisAlignment.center', 'flex-end': 'MainAxisAlignment.end',
                    'end': 'MainAxisAlignment.end', 'space-between': 'MainAxisAlignment.spaceBetween',
                    'space-around': 'MainAxisAlignment.spaceAround', 'space-evenly': 'MainAxisAlignment.spaceEvenly'}
        cross_map = {'flex-start': 'CrossAxisAlignment.start', 'start': 'CrossAxisAlignment.start',
                     'center': 'CrossAxisAlignment.center', 'flex-end': 'CrossAxisAlignment.end',
                     'end': 'CrossAxisAlignment.end', 'stretch': 'CrossAxisAlignment.stretch',
                     'baseline': 'CrossAxisAlignment.baseline'}
        gap = px(st.get('gap'), 0.0)
        rowgap = px(st.get('row-gap'), gap)
        wrap = st.get('flex-wrap') == 'wrap'
        flow, absn, behind = [], [], []
        # 子项
        grows = [self.grow(c) for c in kids if isinstance(c, Node) and not self.is_abs(c)]
        scale = 10 if any(abs(g - round(g)) > 1e-6 for g in grows) else 1
        any_grow = any(g > 0 for g in grows)
        self.cur_inh = inh
        any_bg = False
        for c in kids:
            if isinstance(c, Node) and not self.is_abs(c) and (c.style.get('background') not in (None, 'transparent') or 'box-shadow' in c.style):
                any_bg = True
        row_stretch = (direction == 'row' and not wrap and (ai == 'stretch' or (not ai and any_bg)))
        for c in kids:
            if isinstance(c, str):
                tcode = 'Text(%s, style: %s)' % (dstr(re.sub(r'\s+', ' ', c).strip()), self.ts(inh))
                if direction == 'row' and not wrap and not any_grow:
                    tcode = 'Flexible(flex: %d, child: %s)' % (max(1, round(self.est(c, inh))), tcode)
                flow.append(tcode)
                continue
            if self.is_abs(c):
                # CSS 绘制顺序：DOM 中排在后面的 position:relative 子项会盖在前面的绝对定位元素之上
                later = kids[kids.index(c) + 1:]
                if any(isinstance(x, Node) and x.style.get('position') == 'relative' and not self.is_abs(x) for x in later):
                    behind.append(self.emit_abs(c, inh))
                else:
                    absn.append(self.emit_abs(c, inh))
                continue
            if id(c) in mapping:
                gi, idx = mapping[id(c)]
                g = groups[gi]
                on = self.emit(self.variant(c, g, True), inh, direction)
                off = self.emit(self.variant(c, g, False), inh, direction)
                code = 'HSel(ctrl: %s, index: %d, on: %s, off: %s)' % (gref[gi], idx, on, off)
            elif self.selectable(c) and self.toggle_code(c, inh, direction):
                code = self.toggle_code(c, inh, direction)
            else:
                code = self.emit(c, inh, direction if disp in ('flex', 'inline-flex') else 'block')
            if not wrap:
                code = self.wrap_child(c, code, direction, definite, disp, scale, flow, any_grow, inh, ai, row_stretch)
            if dyn and id(c) in item_ids:
                if not dyn_codes:
                    flow.append('...%s.vis([DYN_PLACEHOLDER])' % dyn)
                dyn_codes.append(code)
                dyn_texts.append(dstr(re.sub(r'\s+', ' ', self.tree_text(c)).strip()))
            else:
                flow.append(code)
        if dyn:
            flow = [f.replace('DYN_PLACEHOLDER', ', '.join(dyn_codes)) if f.startswith('...%s.vis' % dyn) else f for f in flow]
        # 布局
        if disp == 'block' and direction == 'col' and not st.get('flex-direction'):
            cross = 'CrossAxisAlignment.stretch'
        elif direction == 'col':
            cross = cross_map.get(ai, 'CrossAxisAlignment.stretch') if ai else 'CrossAxisAlignment.stretch'
        else:
            if ai:
                cross = cross_map.get(ai, 'CrossAxisAlignment.start')
            else:
                cross = 'CrossAxisAlignment.stretch' if any_bg else 'CrossAxisAlignment.start'
        main = main_map.get(jc, 'MainAxisAlignment.start')
        if wrap:
            wc = {'center': 'WrapCrossAlignment.center', 'flex-end': 'WrapCrossAlignment.end'}.get(ai, 'WrapCrossAlignment.start')
            layout = 'hwrap([%s], gap: %s, rowGap: %s, cross: %s)' % (', '.join(flow), num(gap), num(rowgap), wc)
        elif direction == 'row':
            intr = 'CrossAxisAlignment.stretch' in cross
            layout = 'hrow([%s], main: %s, cross: %s, gap: %s%s%s)' % (
                ', '.join(flow), main, cross, num(gap), ', intrinsic: true' if intr else '',
                '' if True else '')
        else:
            layout = 'hcol([%s], main: %s, cross: %s, gap: %s%s)' % (
                ', '.join(flow), main, cross, num(gap), ', min: false' if definite else '')
            width_definite = (parent in ('col', 'block', 'grid', 'root', 'root_fixed', 'abs', 'root_abs')
                              or st.get('width') is not None or self.grow(n) > 0)
            if cross == 'CrossAxisAlignment.stretch' and not width_definite:
                layout = 'IntrinsicWidth(child: %s)' % layout
        if direction == 'row' and not wrap and st.get('overflow') == 'hidden' and self.est(n, inh) > 340:
            layout = 'SingleChildScrollView(scrollDirection: Axis.horizontal, child: %s)' % layout
        if absn or behind:
            layout = 'hstack(%s, [%s]%s)' % (layout, ', '.join(absn), ', behind: [%s]' % ', '.join(behind) if behind else '')
        if dyn:
            extra = ''
            if flt:
                extra = ', filter: %s[%d], labels: [%s]' % (flt[0], flt[1], ', '.join(dstr(l) for l in flt[2]))
            layout = 'HDyn(texts: [%s]%s, builder: (context, %s) => %s)' % (', '.join(dyn_texts), extra, dyn, layout)
        if gname:
            gl = ', '.join('({%s}, %s)' % (', '.join(map(str, init)), 'true' if multi else 'false') for init, multi in own)
            onsel = ''
            for gi, g in enumerate(groups):
                if gref.get(gi, '').startswith(gname + '[') and any('新能源' in self.tree_text(c) for c in g['cands']):
                    idx = int(gref[gi][len(gname) + 1:-1])
                    ne = [i for i, c in enumerate(g['cands']) if '新能源' in self.tree_text(c)][0]
                    onsel = ', onSelect: {%d: (i) => plateEnergy.value = i == %d}' % (idx, ne)
            layout = 'HSelHolder(groups: [%s]%s, builder: (context, %s) => %s)' % (gl, onsel, gname, layout)
        if holders:
            names = ''.join('final %s = ctrls[%d];' % (v, i) for i, (v, _) in enumerate(holders))
            layout = 'HHolder(inits: [%s], builder: (context, ctrls) { %s return %s; })' % (
                ', '.join(e[len('ValCtrl('):-1] for _, e in holders), names, layout)
        return layout

    def grow(self, c):
        if not isinstance(c, Node):
            return 0
        g = c.style.get('flex-grow')
        try:
            return float(g) if g else 0
        except ValueError:
            return 0

    def wrap_child(self, c, code, direction, definite, disp, scale, flow, any_grow=False, inh=None, parent_ai=None, row_stretch=False):
        st = c.style
        g = self.grow(c)
        w = st.get('width')
        if direction == 'row':
            # CSS：有明确高度的子项不会被 align-items: stretch 拉伸（如时间线圆点）
            hv = st.get('height')
            if row_stretch and hv and hv.endswith('px') and c.tag != 'svg' \
                    and st.get('align-self') != 'stretch' and not hv.startswith('0'):
                code = 'UnconstrainedBox(alignment: Alignment.topLeft, constrainedAxis: Axis.horizontal, child: %s)' % code
            if c.style.get('margin-left') == 'auto' and definite:
                flow.append('Spacer()')
            if ((c.tag == 'input' and c.attrs.get('type', 'text') != 'checkbox') or (c.tag == 'textarea')) \
                    and not (w and w.endswith('px')):
                return 'Expanded(child: %s)' % code
            if g > 0 and definite:
                return 'Expanded(flex: %d, child: %s)' % (max(1, round(g * scale)), code)
            if w == '100%' and definite:
                return 'Expanded(child: %s)' % code
            if w and w.endswith('%') and definite:
                return 'Expanded(flex: %d, child: %s)' % (max(1, round(float(w[:-1]) * 10)), code)
            if (not any_grow and w is None and st.get('flex-shrink') != '0' and c.tag not in ('svg', 'input')
                    and self.has_text(c)):
                e = self.est(c, self.inherit(inh, st, c.dark))
                if e > 0:
                    return 'Flexible(flex: %d, child: %s)' % (max(1, round(e)), code)
            return code
        # 列
        if g > 0 and definite and direction == 'col':
            return 'Expanded(flex: %d, child: %s)' % (max(1, round(g * scale)), code)
        asf = st.get('align-self')
        if asf in ('center', 'flex-start', 'flex-end'):
            al = {'center': 'Alignment.topCenter', 'flex-start': 'Alignment.topLeft', 'flex-end': 'Alignment.topRight'}[asf]
            return 'Align(alignment: %s, child: %s)' % (al, code)
        has_w = (w is not None and not w.endswith('%')) or (w and w.endswith('%') and w != '100%')
        inline_child = self.disp(c) in ('inline-flex', 'inline') and disp == 'block'
        if parent_ai in ('center', 'flex-start', 'start', 'flex-end', 'end') and not (st.get('align-self')):
            return code
        if has_w or inline_child or (c.tag == 'svg'):
            if st.get('margin') == '0 auto' or (st.get('margin-left') == 'auto' and st.get('margin-right') == 'auto'):
                return 'Align(alignment: Alignment.topCenter, child: %s)' % code
            return 'Align(alignment: Alignment.topLeft, child: %s)' % code
        return code

    # ── grid ──
    def emit_grid(self, n, inh):
        st = n.style
        cols_def = st.get('grid-template-columns', '')
        m = re.match(r'repeat\((\d+),', cols_def)
        ncols = int(m.group(1)) if m else len(cols_def.split())
        gap = px(st.get('gap'), 0.0)
        rgap = px(st.get('row-gap'), gap)
        cgap = px(st.get('column-gap'), gap)
        rows_def = st.get('grid-template-rows', '').split()
        kids = [c for c in self.kids(n) if isinstance(c, Node) and not self.is_abs(c)]
        # 带 row-span 的特例：左列跨两行
        if any('span' in (c.style.get('grid-row', '')) for c in kids):
            return self.emit_grid_rowspan(n, inh, kids, ncols, cgap, rgap, rows_def)
        cells = []
        for c in kids:
            gc = c.style.get('grid-column', '')
            span = 1
            ms = re.search(r'span\s+(\d+)', gc)
            if ms:
                span = int(ms.group(1))
            cells.append((c, span))
        rows, cur, used = [], [], 0
        for c, span in cells:
            if used + span > ncols:
                rows.append(cur); cur, used = [], 0
            cur.append((c, span)); used += span
        if cur:
            rows.append(cur)
        row_codes = []
        for ri, row in enumerate(rows):
            items = []
            for c, span in row:
                items.append('Expanded(flex: %d, child: %s)' % (span, self.emit(c, inh, 'grid')))
            used = sum(s for _, s in row)
            if used < ncols:
                items.append('Spacer(flex: %d)' % (ncols - used))
            code = 'hrow([%s], cross: CrossAxisAlignment.stretch, gap: %s, intrinsic: true, min: false)' % (', '.join(items), num(cgap))
            if ri < len(rows_def) and px(rows_def[ri]):
                code = 'SizedBox(height: %s, child: %s)' % (num(px(rows_def[ri])), code)
            row_codes.append(code)
        return 'hcol([%s], gap: %s)' % (', '.join(row_codes), num(rgap))

    def emit_grid_rowspan(self, n, inh, kids, ncols, cgap, rgap, rows_def):
        # 约定：kids[0] 跨两行（第 1 列），kids[1], kids[2] 位于第 2 列的第 1/2 行，kids[3] 跨整行
        h = [px(x, 0) for x in rows_def]
        big = kids[0]
        rest = kids[1:3]
        tail = kids[3:]
        right = []
        for i, c in enumerate(rest):
            right.append('SizedBox(height: %s, child: %s)' % (num(h[i]), self.emit(c, inh, 'grid')))
        top_h = h[0] + rgap + h[1]
        top = 'SizedBox(height: %s, child: hrow([Expanded(child: %s), Expanded(child: hcol([%s], gap: %s))], cross: CrossAxisAlignment.stretch, gap: %s, min: false))' % (
            num(top_h), self.emit(big, inh, 'grid'), ', '.join(right), num(rgap), num(cgap))
        out = [top]
        for i, c in enumerate(tail):
            hh = h[2 + i] if 2 + i < len(h) else None
            code = self.emit(c, inh, 'grid')
            out.append('SizedBox(height: %s, child: %s)' % (num(hh), code) if hh else code)
        return 'hcol([%s], gap: %s)' % (', '.join(out), num(rgap))

    # ── 绝对定位 ──
    def emit_abs(self, c, inh, root=False):
        st = c.style
        body = self.emit(c, inh, 'root_abs' if root else 'abs')
        pos = []
        for k in ('left', 'top', 'right', 'bottom'):
            v = px(st.get(k))
            if v is not None or st.get(k) == '0':
                pos.append('%s: %s' % (k, num(v if v is not None else 0)))
        w = st.get('width'); h = st.get('height')
        if w and px(w) is not None and not w.endswith('%'):
            pos.append('width: %s' % num(px(w)))
        if h and px(h) is not None and not h.endswith('%'):
            pos.append('height: %s' % num(px(h)))
        if not pos:
            pos = ['left: 0', 'top: 0']
        return 'Positioned(%s, child: %s)' % (', '.join(pos), body)

    # ── 根 ──
    def emit_body_after_tabs(self, root, name):
        """取 main 里“分段控件之后”的内容，生成可嵌入其他页面的片段（同一界面的不同视图）。"""
        st = root.style
        inh = {'color': parse_color(st.get('color', '#18181B')), 'size': 16.0, 'w': 400, 'lh': None}
        inh['dcolor'] = dark_color_of(inh['color'])
        inh = self.inherit(inh, st, root.dark)
        main = [c for c in self.kids(root) if isinstance(c, Node) and c.tag == 'main'][0]
        kids = [k for k in self.kids(main) if isinstance(k, Node) and not self.is_abs(k)]
        idx = [i for i, k in enumerate(kids) if k.tag == 'nav' and '视图切换' in k.attrs.get('aria-label', '')][0]
        tmp = Node('div', [])
        tmp.style = {'display': 'flex', 'flex-direction': 'column', 'gap': main.style.get('gap', '16px')}
        tmp.children = kids[idx + 1:]
        code = self.emit_flex(tmp, inh, 'col', 'flex', 'col')
        cls = '%sBody' % name
        imp = "import 'svgs.dart';\n" if 'Svgs.' in code else ''
        return """import 'package:flutter/material.dart';
import '../../kit/kit.dart';
%s
/// 由设计稿“%s”页分段控件之后的内容生成，嵌入同一界面的对应视图。
class %s extends StatelessWidget {
  const %s({super.key});

  @override
  Widget build(BuildContext context) {
    return %s;
  }
}
""" % (imp, name, cls, cls, code)

    def emit_page(self, root, name):
        root.attrs['_root'] = '1'
        root._dark = None
        self.page_name = name

        def mark_qr(n):
            for c in n.children:
                if isinstance(c, Node):
                    if c.tag == 'svg' and c.raw and '二维码' in c.raw:
                        n.attrs['_keeplight'] = '1'
                        n._dark = None
                    mark_qr(c)
        mark_qr(root)
        self.refs, self.shared, self.dyn_filter = {}, {}, {}
        self.labels = {}

        def collect_labels(n):
            for c in n.children:
                if isinstance(c, Node):
                    if c.tag == 'label' and c.attrs.get('for'):
                        self.labels[c.attrs['for']] = self.tree_text(c)
                    collect_labels(c)
        collect_labels(root)
        self.prescan(root)
        for k, v in self.global_refs.items():
            for st in ('on', 'off'):
                self.refs.setdefault(k, {}).setdefault(st, v.get(st))
            self.refs[k] = {a: b for a, b in self.refs[k].items() if b is not None}
        st = root.style
        inh = {'color': parse_color(st.get('color', '#18181B')), 'size': 16.0, 'w': 400, 'lh': None}
        inh['dcolor'] = dark_color_of(inh['color'])
        inh = self.inherit(inh, st, root.dark)
        # 弹层页：设计稿把“底部弹层 + 它所覆盖的页面”画在一张图里，这里只生成弹层本体
        self.is_sheet = False
        for c in self.kids(root):
            if isinstance(c, Node) and self.is_abs(c) and c.attrs.get('role') == 'dialog':
                scrim = [x for x in self.kids(root) if isinstance(x, Node) and x.tag == 'a' and self.is_abs(x)]
                m = re.match(r'([A-Za-z]+)\.dc\.html', scrim[0].attrs.get('href', '')) if scrim else None
                self.sheet_parent = m.group(1) if m else ''
                self.is_sheet = True
                drop = ('position', 'left', 'right', 'bottom', 'top', 'box-shadow')
                sst = {k: v for k, v in c.style.items() if k not in drop}
                if 'height' in sst:
                    sst['min-height'] = sst.pop('height')
                sec = c.copy_with_style(sst)
                code = self.emit(sec, inh, 'root_abs')
                cls = '%sSheet' % name
                imp = "import 'svgs.dart';\n" if 'Svgs.' in code else ''
                return """import 'package:flutter/material.dart';
import '../../kit/kit.dart';
%s
class %s extends StatelessWidget {
  const %s({super.key});

  @override
  Widget build(BuildContext context) {
    return %s;
  }
}
""" % (imp, cls, cls, code)
        bg = parse_color(st.get('background', '#F4F4F5'))
        dbg = parse_color(root.dark.get('background', st.get('background', '#F4F4F5')))
        bgcode = dcolor(bg) if dbg == bg else 'dk(context, %s, %s)' % (dcolor(bg), dcolor(dbg))
        height = px(st.get('height'), 844.0)
        kids = self.kids(root)
        disp = st.get('display')
        flow_nodes = [k for k in kids if not self.is_abs(k)]
        abs_nodes = [k for k in kids if self.is_abs(k)]
        grows = any(self.grow(k) > 0 for k in flow_nodes if isinstance(k, Node))
        # 用 root 的子集构造一个临时节点来复用 emit_flex
        tmp = Node('div', [])
        tmp.style = {k: v for k, v in st.items() if k in ('display', 'flex-direction', 'gap', 'align-items', 'justify-content')}
        if 'display' not in tmp.style:
            tmp.style['display'] = 'block'
        tmp.children = flow_nodes
        parent = 'root_fixed' if grows else 'root'
        direction = 'col' if tmp.style.get('flex-direction') == 'column' or tmp.style['display'] == 'block' else 'row'
        flow = self.emit_flex(tmp, inh, direction, tmp.style['display'], parent)
        overlays = []
        for a in abs_nodes:
            ast = a.style
            if ast.get('bottom') == '0' and ast.get('top') is None and ast.get('inset') is None and ast.get('left') == '0' and ast.get('right') == '0':
                body = self.emit(a, inh, 'root_abs')
                overlays.append('HBottomDock(child: %s)' % body)
            elif ast.get('top') == '0' and ast.get('bottom') == '0' and ast.get('left') == '0' and ast.get('right') == '0':
                body = self.emit(a, inh, 'root_abs')
                overlays.append('Positioned.fill(child: %s)' % body)
            else:
                overlays.append(self.emit_abs(a, inh, root=True))
        cls = '%sPage' % name
        return """import 'package:flutter/material.dart';
import '../../kit/kit.dart';
%s
class %s extends StatelessWidget {
  const %s({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: %s,
      height: %s,
      fixedHeight: %s,
      flow: %s,
      overlays: [%s],
    );
  }
}
""" % ("import 'svgs.dart';\n" if 'Svgs.' in (flow + ''.join(overlays)) else '', cls, cls, bgcode, num(height), 'true' if grows else 'false', flow, ', '.join(overlays))


def snake(name):
    return re.sub(r'(?<!^)(?=[A-Z])', '_', name).lower()



def _div_block(src, cls):
    """找到 class="cls" 的 <div ...>...</div> 整块（按嵌套配对），返回 (start, end)。"""
    m = re.search(r'<div\b[^>]*class="%s"[^>]*>' % cls, src)
    if not m:
        return None
    depth, i = 0, m.start()
    for t in re.finditer(r'<div\b|</div>', src[m.start():]):
        depth += 1 if t.group(0) == '<div' else -1
        if depth == 0:
            return m.start(), m.start() + t.end()
    return None


def _cut(src, cls):
    b = _div_block(src, cls)
    return src if not b else src[:b[0]] + src[b[1]:]


def split_variants(name, src):
    """设计稿里用 CSS 单选框 / 复选框切换的页面（目前只有 Recharge），按状态拆成独立页面。"""
    if name != 'Recharge':
        return [(name, src)]
    sel = 'background:#FFFFFF;color:#18181B;box-shadow:0 2px 4px rgba(0,0,0,.04),0 1px 2px rgba(0,0,0,.06);'

    def tidy(t, selected, to_other, other):
        t = re.sub(r'<input[^>]*class="rt"[^>]*>', '', t)
        # 当前页签：选中样式；另一页签：改成跳转链接
        def lab(m):
            tag = m.group(0)
            f = re.search(r'for="(rt\d)"', tag).group(1)
            if f == selected:
                return tag.replace('<label for="%s"' % f, '<span').replace('style="', 'style="' + sel, 1)
            return tag.replace('<label for="%s"' % f, '<a href="%s.dc.html"' % other)
        t = re.sub(r'<label for="rt\d"[^>]*>', lab, t)
        t = re.sub(r'(<a href="[^"]*"[^>]*>[^<]*)</label>', r'\1</a>', t)
        t = re.sub(r'<(\w+)([^>]*)>([^<]*)</label>', lambda m: m.group(0), t)
        return t

    def fix_close(t):
        # label 的结束标签按配对改回 span / a
        out, stack = [], []
        for tok in re.split(r'(<label\b[^>]*>|<span\b[^>]*>|<a\b[^>]*>|</span>|</a>|</label>)', t):
            if tok.startswith('<label'):
                stack.append('label'); out.append(tok)
            elif tok.startswith('<span') or tok.startswith('<a '):
                stack.append(tok[1:].split()[0].rstrip('>')); out.append(tok)
            elif tok in ('</span>', '</a>', '</label>'):
                top = stack.pop() if stack else None
                out.append('</%s>' % top if top else tok)
            else:
                out.append(tok)
        return ''.join(out)

    base = re.sub(r'class="(p1|p2|b1|b2|sh)"', lambda m: 'data-v="%s"' % m.group(1), src)
    base = re.sub(r'<div data-v=', '<div class=', base)  # 保持后面按 class 查找
    base = src
    # 状态 1：储值充值
    a = _cut(_cut(_cut(src, 'p2'), 'b2'), 'sh')
    a = a.replace('class="p1"', 'style="display:flex;flex-direction:column;gap:16px"').replace('class="b1"', 'data-b="1"')
    a = re.sub(r'(<div data-b="1" style=")', r'\1display:flex;', a)
    a = re.sub(r'<label for="sh"[^>]*>', '<a href="RechargeCard.dc.html" style="display:flex">', a)
    a = tidy(a, 'rt1', 'RechargeCard', 'RechargeCard')
    # 状态 2：购买次卡
    b = _cut(_cut(_cut(src, 'p1'), 'b1'), 'sh')
    b = b.replace('class="p2"', 'style="display:flex;flex-direction:column;gap:16px"').replace('class="b2"', 'data-b="1"')
    b = re.sub(r'(<div data-b="1" style=")', r'\1display:flex;', b)
    b = re.sub(r'<label for="sh"([^>]*)>', r'<a href="RechargePick.dc.html"\1>', b)
    b = tidy(b, 'rt2', 'Recharge', 'Recharge')
    # 状态 3：选择套餐弹层（叠在状态 2 之上）
    blk = _div_block(src, 'sh')
    inner = src[blk[0]:blk[1]]
    inner = re.sub(r'^<div class="sh">', '', inner)
    inner = re.sub(r'</div>$', '', inner)
    inner = re.sub(r'<label for="sh"([^>]*)>', r'<a href="RechargeCard.dc.html"\1>', inner)
    head = re.match(r'(.*?<div style="width: 390px[^>]*>)', src, flags=re.S).group(1)
    c = head + inner + '</div></x-dc>' + src.split('</x-dc>', 1)[1]
    return [('Recharge', fix_close(a)), ('RechargeCard', fix_close(b)), ('RechargePick', fix_close(c))]


def _gen_one(gen, name, src, out_dir, done, sheets):
    gen.sel_counter = 0
    try:
        root = extract_page(src)
        code = gen.emit_page(root, name)
    except Exception as e:  # noqa
        print('FAILED', name, repr(e))
        raise
    if name == 'AppointmentSchedule':
        open(os.path.join(out_dir, 'appointment_schedule_body.dart'), 'w', encoding='utf-8').write(
            gen.emit_body_after_tabs(root, name))
    if gen.is_sheet:
        open(os.path.join(out_dir, snake(name) + '_sheet.dart'), 'w', encoding='utf-8').write(code)
        sheets.append((name, gen.sheet_parent))
    else:
        open(os.path.join(out_dir, snake(name) + '_page.dart'), 'w', encoding='utf-8').write(code)
        done.append(name)


def main():
    src_dir, out_dir = sys.argv[1], sys.argv[2]
    only = set(sys.argv[3:])
    names = sorted(f[:-len('.dc.html')] for f in os.listdir(src_dir) if f.endswith('.dc.html'))
    svgs = collections.OrderedDict()
    gen = Gen(svgs)
    done = []
    sheets = []
    for name in names:
        if name in SKIP or name.endswith(SKIP_SUFFIX):
            continue
        tmp = Gen({})
        tmp.refs = gen.global_refs
        for _vn, _vs in split_variants(name, open(os.path.join(src_dir, name + '.dc.html'), encoding='utf-8').read()):
            tmp.prescan(extract_page(_vs))
    for name in names:
        if name in HANDWRITTEN or name in SKIP or name.endswith(SKIP_SUFFIX):
            continue
        if only and name not in only:
            continue
        src0 = open(os.path.join(src_dir, name + '.dc.html'), encoding='utf-8').read()
        for vname, src in split_variants(name, src0):
            _gen_one(gen, vname, src, out_dir, done, sheets)
    # svgs
    lines = ['// 由 tools/design_to_flutter.py 生成，请勿手工修改。', 'class Svgs {', '  Svgs._();']
    for markup, ident in svgs.items():
        lines.append("  static const %s = %s;" % (ident, dstr(re.sub(r'\s+', ' ', markup))))
    lines.append('}')
    open(os.path.join(out_dir, 'svgs.dart'), 'w', encoding='utf-8').write('\n'.join(lines) + '\n')
    # routes
    imports = ["import 'package:flutter/widgets.dart';"]
    entries, sentries, parents = [], [], []
    for name in done:
        imports.append("import '%s_page.dart';" % snake(name))
        entries.append("  '%s': (_) => const %sPage()," % (name, name))
    for name, parent in sheets:
        imports.append("import '%s_sheet.dart';" % snake(name))
        sentries.append("  '%s': (_) => const %sSheet()," % (name, name))
        parents.append("  '%s': '%s'," % (name, parent))
    open(os.path.join(out_dir, 'gen_routes.dart'), 'w', encoding='utf-8').write(
        '// 由 tools/design_to_flutter.py 生成，请勿手工修改。\n' + '\n'.join(imports) +
        '\n\nfinal Map<String, WidgetBuilder> genRoutes = {\n' + '\n'.join(entries) + '\n};\n' +
        '\n/// 底部弹层（设计稿中叠在其他页面上的界面）。\nfinal Map<String, WidgetBuilder> genSheets = {\n' + '\n'.join(sentries) + '\n};\n' +
        '\n/// 弹层所属的页面（设计稿里的遮罩点击目标）。\nconst Map<String, String> sheetParents = {\n' + '\n'.join(parents) + '\n};\n')
    print('generated', len(done), 'pages,', len(sheets), 'sheets,', len(svgs), 'svgs')


if __name__ == '__main__':
    main()
