const api = require('../../utils/api');
const f = require('../../utils/format');
const v = require('../../utils/view');
const page = require('../../utils/page');

const KINDS = [['all', '全部'], ['service', '服务'], ['recharge', '充值']];
const PAGE = 30;

Page({
  data: { state: 'loading', error: '', kind: 'all', kinds: KINDS, groups: [], summary: null, month: '', more: false, loadingMore: false, work: null },
  rows: [],

  onShow() { if (page.requireLogin()) this.reload(this.data.state === 'content' || this.data.state === 'empty'); },

  reload(silent) {
    page.load(this, async () => {
      const store = await page.currentStore();
      if (!store) return { __empty: true };
      const [res, ov] = await Promise.all([api.orders(store, this.data.kind), page.overview(true)]);
      const items = res.item.items;
      this.more(items);
      const s = res.item.summary || { orders: 0, paid: 0, saved: 0, points: 0 };
      const now = Date.now();
      const p = f.parts(now);
      const work = ov.in_progress ? v.appointmentView(ov.in_progress, now) : null;
      return {
        summary: { paid: f.yuan(s.paid), orders: s.orders, saved: f.yuan(s.saved), points: '+' + f.int(s.points) },
        month: p.y + ' 年 ' + p.m + ' 月',
        work: this.data.kind === 'recharge' ? null : work,
        __empty: items.length === 0 && !work,
        ...this.group(),
      };
    }, silent);
  },

  // 接口多返回一条用来判断是否还有下一页
  more(items) {
    this.hasMore = items.length > PAGE;
    this.rows = items.slice(0, PAGE).map(v.orderRow);
  },
  group() {
    return { groups: v.groupOrders(this.rows, Date.now()), more: this.hasMore };
  },

  loadMore() {
    if (this.data.loadingMore || !this.hasMore || !this.rows.length) return;
    this.setData({ loadingMore: true });
    const before = this.rows[this.rows.length - 1].at;
    api.orders(getApp().ctx.storeId, this.data.kind, before).then((res) => {
      const items = res.item.items;
      this.hasMore = items.length > PAGE;
      this.rows = this.rows.concat(items.slice(0, PAGE).map(v.orderRow));
      this.setData(this.group());
    }).catch((e) => page.toast(e.message)).then(() => this.setData({ loadingMore: false }));
  },
  onReachBottom() { this.loadMore(); },

  onRetry() { this.reload(false); },
  pick(e) {
    const kind = e.currentTarget.dataset.k;
    if (kind === this.data.kind) return;
    this.setData({ kind }, () => this.reload(false));
  },
  open(e) {
    const d = e.currentTarget.dataset;
    if (d.link) page.go('/pages/order-detail/order-detail?id=' + d.id);
  },
  openWork() { page.go('/pages/progress/progress?id=' + this.data.work.id); },
});
