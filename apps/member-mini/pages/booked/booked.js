const api = require('../../utils/api');
const f = require('../../utils/format');
const v = require('../../utils/view');
const page = require('../../utils/page');

Page({
  data: { state: 'loading', error: '', a: null },
  onLoad(q) { this.id = q.id; },
  onShow() { if (page.requireLogin() && this.data.state !== 'content') this.reload(); },
  reload() {
    page.load(this, async () => {
      const store = await page.currentStore();
      const res = await api.appointment(store, this.id);
      return { a: v.appointmentView(res.item, Date.now()) };
    });
  },
  onRetry() { this.reload(); },
  home() { wx.switchTab({ url: '/pages/home/home' }); },
  detail() { wx.redirectTo({ url: '/pages/book-detail/book-detail?id=' + this.id }); },
});
