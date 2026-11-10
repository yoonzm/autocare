const api = require('../../utils/api');
const f = require('../../utils/format');
const page = require('../../utils/page');

Page({
  data: { state: 'loading', error: '', o: null },
  onLoad(q) { this.id = q.id; },
  onShow() { if (page.requireLogin() && this.data.state !== 'content') this.reload(); },
  reload() {
    page.load(this, async () => {
      const store = await page.currentStore();
      const res = await api.order(store, this.id);
      const o = res.item;
      return {
        o: {
          store: o.store_name,
          meta: f.md(o.at) + ' ' + f.hm(o.at) + (o.technician ? ' · 技师 ' + o.technician : ''),
          refunded: o.status === 'refunded',
          items: o.items.map((i) => ({ name: i.name + (i.qty > 1 ? ' × ' + i.qty : ''), amount: i.by_package ? '次卡抵扣' : f.yuan(i.total), pkg: i.by_package })),
          cardOff: Number(o.card_off) > 0 ? '-' + f.yuan(o.card_off) : '',
          discountOff: Number(o.discount_off) > 0 ? '-' + f.yuan(o.discount_off) : '',
          payable: '¥' + f.money2(o.payable),
          no: o.order_no, pay: o.pay, points: Number(o.points) > 0 ? '+' + o.points : '',
        },
      };
    });
  },
  onRetry() { this.reload(); },
  back() { page.back('/pages/orders/orders'); },
  again() { page.go('/pages/svc/svc'); },
});
