const api = require('../../utils/api');
const page = require('../../utils/page');

Page({
  data: { state: 'loading', error: '', cars: [], pick: false },
  onLoad(q) { this.setData({ pick: q.pick === '1' }); },
  onShow() { if (page.requireLogin()) this.reload(this.data.state === 'content'); },
  reload(silent) {
    page.load(this, async () => {
      const store = await page.currentStore();
      if (!store) return { cars: [], __empty: true };
      const res = await api.vehicles(store);
      return {
        cars: res.items.map((c) => ({ id: c.id, plate: c.plate, energy: c.energy, ev: c.energy === 'ev', title: [c.brand_model, c.color].filter(Boolean).join(' · ') || '未填写车型', isDefault: c.is_default, visits: c.visits })),
        __empty: res.items.length === 0,
      };
    }, silent);
  },
  onRetry() { this.reload(false); },
  choose(e) {
    if (!this.data.pick) return;
    // 选车模式：把选择写回预约上下文后返回
    const booking = getApp().ctx.booking;
    if (booking) booking.vehicleId = e.currentTarget.dataset.id;
    wx.navigateBack();
  },
  add() { wx.navigateTo({ url: '/pages/car-add/car-add' }); },
});
