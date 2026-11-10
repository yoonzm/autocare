const api = require('../../utils/api');
const v = require('../../utils/view');
const page = require('../../utils/page');

const RINGS = [['#3B9B6B', '#2B7A53'], ['#F5A524', '#D9821A']];

Page({
  data: { state: 'loading', error: '', mine: [], offers: [], buying: '' },
  onShow() { if (page.requireLogin()) this.reload(this.data.state === 'content' || this.data.state === 'empty'); },
  reload(silent) {
    page.load(this, async () => {
      const store = await page.currentStore();
      if (!store) return { __empty: true };
      const res = await api.packages(store);
      const now = Date.now();
      const mine = res.item.mine.map((p, i) => Object.assign(v.myPackage(p, now), { bg: i % 2 ? 'linear-gradient(135deg,#F5A524,#E08A1E)' : 'linear-gradient(135deg,#3B9B6B,#17A864)' }));
      const offers = res.item.offers.map(v.offerView);
      return { mine, offers, __empty: !mine.length && !offers.length };
    }, silent);
  },
  onRetry() { this.reload(false); },
  book() { page.go('/pages/svc/svc'); },
  // TODO: 线上购买次卡需要微信支付商户号与支付回调（预期后端：payment_create / payment_callback，见 docs/member-mini-integration.md）。
  // 接口 mb_package_buy 已存在并明确返回“线上支付暂未开通”，这里原样展示服务端的结论，不模拟购买成功。
  buy(e) {
    if (this.data.buying) return;
    const id = e.currentTarget.dataset.id;
    this.setData({ buying: id });
    api.buyPackage(getApp().ctx.storeId, id).then(() => page.toast('请到店完成购买'))
      .catch((err) => page.toast(err.message)).then(() => this.setData({ buying: '' }));
  },
});
