const api = require('../../utils/api');
const f = require('../../utils/format');
const page = require('../../utils/page');

// 本页只在真实充值入账之后进入（参数 id = 充值流水编号）。线上支付接通前没有入口指向这里。
Page({
  data: { state: 'loading', error: '', r: null },
  onLoad(q) { this.id = q.id; },
  onShow() { if (page.requireLogin() && this.data.state !== 'content') this.reload(); },
  reload() {
    page.load(this, async () => {
      const store = await page.currentStore();
      const res = await api.rechargeDetail(store, this.id);
      const r = res.item;
      return {
        r: {
          total: '+¥' + f.money2(Number(r.amount) + Number(r.gift)),
          amount: '¥' + f.money2(r.amount), gift: Number(r.gift) > 0 ? '+¥' + f.money2(r.gift) : '',
          pay: r.pay || '—', balance: '¥' + f.money2(r.balance_after),
          at: f.md(r.at) + ' ' + f.hm(r.at), no: r.order_no,
        },
      };
    });
  },
  onRetry() { this.reload(); },
  records() { wx.redirectTo({ url: '/pages/orders/orders' }); },
  home() { wx.switchTab({ url: '/pages/home/home' }); },
});
