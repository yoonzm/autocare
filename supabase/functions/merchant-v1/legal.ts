import { LEGAL_UPDATED, privacyDoc, termsDoc } from './legal_content.ts';
import type { LegalDoc } from './legal_content.ts';

const escape = (text: string) =>
  text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

export function renderLegalHtml(doc: LegalDoc): string {
  const body = [
    ...doc.intro.map((p) => `<p>${escape(p)}</p>`),
    ...doc.sections.map((section) =>
      `<h2>${escape(section.title)}</h2>` +
      (section.paragraphs ?? []).map((p) => `<p>${escape(p)}</p>`).join('') +
      (section.items?.length ? `<ul>${section.items.map((i) => `<li>${escape(i)}</li>`).join('')}</ul>` : '')
    ),
  ].join('\n');
  return `<!doctype html>
<html lang="zh-CN">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="color-scheme" content="light dark">
<title>${escape(doc.title)} - 汽美管家</title>
<style>
:root{--bg:#fff;--fg:#18181b;--muted:#71717a;--line:#e4e4e7;--accent:#0485f7}
@media (prefers-color-scheme:dark){:root{--bg:#18181b;--fg:#fafafa;--muted:#9a9aa3;--line:#2a2a2e;--accent:#4aa3ff}}
*{box-sizing:border-box}
body{margin:0;padding:20px 20px calc(32px + env(safe-area-inset-bottom));background:var(--bg);color:var(--fg);
  font:15px/1.75 -apple-system,BlinkMacSystemFont,"PingFang SC","Helvetica Neue","Noto Sans SC",sans-serif;-webkit-text-size-adjust:100%}
main{max-width:720px;margin:0 auto}
h1{font-size:22px;line-height:1.3;margin:4px 0 4px}
.meta{color:var(--muted);font-size:13px;margin:0 0 16px;padding-bottom:14px;border-bottom:1px solid var(--line)}
h2{font-size:16px;margin:24px 0 6px}
p{margin:8px 0}
ul{margin:6px 0;padding-left:1.3em}
li{margin:5px 0}
</style>
</head>
<body>
<main>
<h1>${escape(doc.title)}</h1>
<p class="meta">更新日期：${LEGAL_UPDATED} · 生效日期：${LEGAL_UPDATED}</p>
${body}
</main>
</body>
</html>`;
}

export type LegalPage = 'terms' | 'privacy';

export function legalResponse(page: LegalPage, env: (name: string) => string | undefined): Response {
  const ctx = {
    operator: (env('LEGAL_OPERATOR_NAME') ?? '').trim(),
    phone: (env('MERCHANT_SUPPORT_PHONE') ?? '').trim(),
  };
  const html = renderLegalHtml(page === 'terms' ? termsDoc(ctx) : privacyDoc(ctx));
  return new Response(html, {
    headers: {
      'content-type': 'text/html; charset=utf-8',
      'cache-control': 'public, max-age=300',
      'x-content-type-options': 'nosniff',
      'content-security-policy': "default-src 'none'; style-src 'unsafe-inline'; base-uri 'none'; form-action 'none'",
    },
  });
}

/** `GET .../merchant-v1/legal/terms|privacy`；不是这两个页面时返回 null。 */
export function matchLegalPath(pathname: string): LegalPage | null {
  const m = /\/legal\/(terms|privacy)\/?$/.exec(pathname);
  return m ? (m[1] as LegalPage) : null;
}
