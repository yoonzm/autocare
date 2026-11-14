import { assert, assertEquals } from 'jsr:@std/assert';
import { legalResponse, matchLegalPath, renderLegalHtml } from './legal.ts';
import { privacyDoc, termsDoc } from './legal_content.ts';

Deno.test('路径只匹配协议和隐私两个页面', () => {
  assertEquals(matchLegalPath('/functions/v1/merchant-v1/legal/terms'), 'terms');
  assertEquals(matchLegalPath('/merchant-v1/legal/privacy/'), 'privacy');
  assertEquals(matchLegalPath('/functions/v1/merchant-v1/legal/other'), null);
  assertEquals(matchLegalPath('/functions/v1/merchant-v1'), null);
});

Deno.test('H5 返回 HTML、可缓存且收紧安全头', async () => {
  const res = legalResponse('privacy', () => undefined);
  assertEquals(res.status, 200);
  assertEquals(res.headers.get('content-type'), 'text/html; charset=utf-8');
  assert(res.headers.get('content-security-policy')!.includes("default-src 'none'"));
  const html = await res.text();
  assert(html.includes('<h1>隐私政策</h1>') && html.includes('viewport'));
});

Deno.test('正文只描述现有功能：不提行驶证、会员码扫描、定金和订阅收费', () => {
  for (const doc of [termsDoc({ operator: '', phone: '' }), privacyDoc({ operator: '', phone: '' })]) {
    const text = JSON.stringify(doc);
    for (const word of ['行驶证', '会员码', '定金', '订阅', '示意文本']) assert(!text.includes(word), word);
  }
});

Deno.test('运营主体和客服电话来自配置，未配置时不留占位', async () => {
  const bare = await legalResponse('terms', () => undefined).text();
  assert(!bare.includes('undefined') && !bare.includes('[') && bare.includes('帮助与反馈'));
  const configured = await legalResponse('terms', (n) =>
    ({ LEGAL_OPERATOR_NAME: '某某科技有限公司', MERCHANT_SUPPORT_PHONE: '400-000-0000' })[n]).text();
  assert(configured.includes('某某科技有限公司（以下简称“我们”）') && configured.includes('400-000-0000'));
});

Deno.test('正文会转义 HTML 特殊字符', () => {
  const html = renderLegalHtml({ title: 'a', intro: ['<script>x</script>'], sections: [] });
  assert(!html.includes('<script>x') && html.includes('&lt;script&gt;'));
});
