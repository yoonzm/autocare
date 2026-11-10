const api = require('../../utils/api');
const f = require('../../utils/format');
const page = require('../../utils/page');

Page({
  data: { state: 'loading', error: '', m: null, code: '', left: 0, ttl: 60, refreshing: false },

  onShow() {
    if (!page.requireLogin()) return;
    // 会员码是敏感凭证：支持时在截屏 / 录屏里隐藏
    try { if (wx.setVisualEffectOnCapture) wx.setVisualEffectOnCapture({ visualEffect: 'hidden' }); } catch (e) { /* 低版本无此能力 */ }
    this.reload();
  },
  onHide() { this.stop(); },
  onUnload() { this.stop(); },

  stop() {
    clearInterval(this.timer);
    this.timer = null;
    try { if (wx.setVisualEffectOnCapture) wx.setVisualEffectOnCapture({ visualEffect: 'none' }); } catch (e) { /* 同上 */ }
  },

  reload() {
    page.load(this, async () => {
      const store = await page.currentStore();
      if (!store) return { __empty: true };
      const [ov, res] = await Promise.all([page.overview(true), api.code(store)]);
      const m = ov.member;
      this.run(res.item);
      return {
        m: { name: m.name, level: m.level.name, phone: f.maskPhone(m.phone), balance: f.yuan(m.balance), points: f.int(m.points), packages: ov.counts.packages + ' 张' },
        code: res.item.code, ttl: res.item.ttl, left: res.item.ttl,
      };
    });
  },

  // 倒计时到 0 自动换新码；刷新失败保留旧码的倒计时并提示，不让用户拿着过期码
  run(item) {
    clearInterval(this.timer);
    const end = Date.now() + item.ttl * 1000;
    this.timer = setInterval(() => {
      const left = Math.max(Math.ceil((end - Date.now()) / 1000), 0);
      this.setData({ left });
      if (left === 0) { clearInterval(this.timer); this.refresh(); }
    }, 1000);
  },

  refresh() {
    if (this.data.refreshing) return;
    this.setData({ refreshing: true });
    api.code(getApp().ctx.storeId).then((res) => {
      this.setData({ code: res.item.code, left: res.item.ttl, ttl: res.item.ttl });
      this.run(res.item);
    }).catch((e) => {
      this.setData({ code: '' });
      page.toast(e.message);
    }).then(() => this.setData({ refreshing: false }));
  },
  onRetry() { this.reload(); },
});
