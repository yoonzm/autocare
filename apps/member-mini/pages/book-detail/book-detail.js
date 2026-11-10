const api = require('../../utils/api');
const f = require('../../utils/format');
const v = require('../../utils/view');
const page = require('../../utils/page');

const REASONS = [['时间有变', '改天再来'], ['已在别处完成', ''], ['其他原因', '']];

Page({
  data: { state: 'loading', error: '', a: null, count: '', canChange: false, sheet: false, reasons: REASONS, reason: '时间有变', busy: false, hint: '' },

  onLoad(q) { this.id = q.id; },
  onShow() { if (page.requireLogin()) this.reload(this.data.state === 'content'); },
  onUnload() { clearTimeout(this.timer); },

  reload(silent) {
    page.load(this, async () => {
      const store = await page.currentStore();
      const res = await api.appointment(store, this.id);
      const a = v.appointmentView(res.item, Date.now());
      this.item = res.item;
      this.tick(a);
      const open = a.status === 'waiting' || a.status === 'late';
      const far = Date.parse(a.starts_at) - Date.now() >= 2 * 3600 * 1000;
      return {
        a,
        canChange: open && far,
        hint: open && !far ? '距到店不足 2 小时，如需取消或改约请直接联系门店。' : '',
        open,
      };
    }, silent);
  },

  // 倒计时每 30 秒更新一次
  tick(a) {
    clearTimeout(this.timer);
    const text = f.countdown(a.starts_at);
    this.setData({ count: a.status === 'waiting' || a.status === 'late' ? (text ? '距到店还有 ' + text + ' · 请准时到店' : '已到预约时间，请尽快到店') : '' });
    if (text) this.timer = setTimeout(() => this.tick(a), 30000);
  },

  onRetry() { this.reload(false); },
  openSheet() { this.setData({ sheet: true, reason: '时间有变' }); },
  closeSheet() { if (!this.data.busy) this.setData({ sheet: false }); },
  pickReason(e) { this.setData({ reason: e.currentTarget.dataset.r }); },

  cancel() {
    if (this.data.busy) return;
    this.setData({ busy: true });
    api.cancel(getApp().ctx.storeId, this.id, this.data.reason).then(() => {
      page.toast('预约已取消');
      this.setData({ sheet: false });
      wx.switchTab({ url: '/pages/book/book' });
    }).catch((e) => {
      page.toast(e.message);
      if (e.status === 409) this.reload(true);
    }).then(() => this.setData({ busy: false }));
  },

  // 改约 = 重新选服务和时间（沿用原服务），提交时原预约在同一事务里取消
  change() {
    const ids = (this.item.items || []).map((i) => i.service_id).filter(Boolean);
    wx.navigateTo({ url: '/pages/svc/svc?replace=' + this.id + (ids.length ? '&services=' + ids.join(',') : '') });
  },
  call() {
    const phone = getApp().ctx.overview && getApp().ctx.overview.store.phone;
    if (phone) wx.makePhoneCall({ phoneNumber: phone });
    else page.toast('门店暂未登记电话');
  },
  // TODO: 导航需要门店经纬度（见首页同处说明）。
  navigate() { page.toast('门店暂未设置地图位置，请按地址前往'); },
});
