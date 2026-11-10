// 把 SVG 文本转成可放进 <image src> 的 data URI。小程序没有 btoa，SVG 都是 ASCII，手写 base64 即可。
const A = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

function base64(text) {
  let out = '';
  for (let i = 0; i < text.length; i += 3) {
    const a = text.charCodeAt(i);
    const b = i + 1 < text.length ? text.charCodeAt(i + 1) : NaN;
    const c = i + 2 < text.length ? text.charCodeAt(i + 2) : NaN;
    if (a > 127 || b > 127 || c > 127) throw new Error('SVG 只能包含 ASCII 字符');
    const n = (a << 16) | ((b || 0) << 8) | (c || 0);
    out += A[(n >> 18) & 63] + A[(n >> 12) & 63] + (isNaN(b) ? '=' : A[(n >> 6) & 63]) + (isNaN(c) ? '=' : A[n & 63]);
  }
  return out;
}

const icons = require('./icons');
const cache = {};

/** 图标 data URI；颜色里的 # 在 base64 里不用转义。 */
function iconUri(name, color, size, stroke) {
  const key = [name, color, size, stroke].join('|');
  if (cache[key]) return cache[key];
  const body = (icons[name] || '').replace(/currentColor/g, color);
  const svg =
    '<svg xmlns="http://www.w3.org/2000/svg" width="' + size + '" height="' + size + '" viewBox="0 0 24 24" fill="none" stroke="' + color +
    '" stroke-width="' + stroke + '" stroke-linecap="round" stroke-linejoin="round">' + body + '</svg>';
  cache[key] = 'data:image/svg+xml;base64,' + base64(svg);
  return cache[key];
}

/** 环形进度（施工 / 次卡）：track 灰底 + 进度弧。 */
function ringUri(size, width, track, color, ratio) {
  const r = (size - width) / 2;
  const c = size / 2;
  const len = 2 * Math.PI * r;
  const dash = Math.max(Math.min(ratio, 1), 0) * len;
  const svg =
    '<svg xmlns="http://www.w3.org/2000/svg" width="' + size + '" height="' + size + '" viewBox="0 0 ' + size + ' ' + size + '" fill="none">' +
    '<circle cx="' + c + '" cy="' + c + '" r="' + r + '" stroke="' + track + '" stroke-width="' + width + '"/>' +
    '<circle cx="' + c + '" cy="' + c + '" r="' + r + '" stroke="' + color + '" stroke-width="' + width + '" stroke-linecap="round" stroke-dasharray="' +
    dash.toFixed(1) + ' ' + (len - dash + 1).toFixed(1) + '" transform="rotate(-90 ' + c + ' ' + c + ')"/></svg>';
  return 'data:image/svg+xml;base64,' + base64(svg);
}

module.exports = { base64, iconUri, ringUri };
