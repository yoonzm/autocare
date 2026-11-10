const api = require('../../utils/api');
const f = require('../../utils/format');
const v = require('../../utils/view');
const page = require('../../utils/page');

const TABS = [['pending', '待到店'], ['done', '已完成'], ['cancelled', '已取消']];

Page({
  data: { state: 'loading', error: '', tab: 'pending', tabs: [], items: [], discount: '', cats: [] },

  onShow() {
    if (!page.requireLogin()) return;
    const tab = this.getTabBar && this.getTabBar();
    if (tab) tab.setData({ selected: 1 });
    this.reload(this.data.state === 'content' || this.data.state === 'empty');
  },

  reload(silent) {
    page.load(
      this,
      async () => {
        const store = await page.currentStore();
        if (!store) return { tabs: [], items: [], __empty: true };
        const [res, ov, svc] = await Promise.all([api.appointments(store, this.data.tab), page.overview(), api.services(store)]);
        const now = Date.now();
        const counts = res.item.counts;
        return {
          tabs: TABS.map(([key, text]) => ({ key, text: key === 'pending' && counts.pending ? text + ' ' + counts.pending : text })),
          items: res.item.items.map((a) => v.appointmentView(a, now)),
          discount: ov ? v.discountText(ov.member.level.discount) : '',
          cats: svc.item.categories.slice(0, 4).map((c) => Object.assign({ name: c }, v.serviceStyle(c, c))),
          __empty: res.item.items.length === 0,
        };
      },
      silent
    );
  },

  onRetry() { this.reload(false); },
  pick(e) {
    const tab = e.currentTarget.dataset.key;
    if (tab === this.data.tab) return;
    this.setData({ tab }, () => this.reload(false));
  },
  open(e) { page.go('/pages/book-detail/book-detail?id=' + e.currentTarget.dataset.id); },
  create() { page.go('/pages/svc/svc'); },
  byCategory(e) { page.go('/pages/svc/svc?cat=' + encodeURIComponent(e.currentTarget.dataset.name)); },
});
