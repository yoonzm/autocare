const api = require('../../utils/api');
const f = require('../../utils/format');
const v = require('../../utils/view');
const b = require('../../utils/booking');
const svg = require('../../utils/svg');
const page = require('../../utils/page');

// TODO: 真实施工节点（清洗 / 打磨 / 施工 / 固化 / 质检）、节点照片、技师履历与好评率依赖员工端上报（预期后端：work_progress 与 mb_progress），
// 目前没有数据来源。这里只展示有真实时间戳的信息：预约、到店、预计完工、工位和技师；进度百分比按“到店后已用时 / 预计工时”估算，页面如实标注。
Page({
  data: { state: 'loading', error: '', a: null, e: null, nodes: [], ring: '', tel: '' },
  onLoad(q) { this.id = q.id || ''; },
  onShow() { if (page.requireLogin()) this.reload(this.data.state === 'content'); },
  onHide() { clearInterval(this.timer); },
  onUnload() { clearInterval(this.timer); },
  reload(silent) {
    page.load(this, async () => {
      const store = await page.currentStore();
      if (!store) return { __empty: true };
      let raw;
      if (this.id) raw = (await api.appointment(store, this.id)).item;
      else {
        const ov = await page.overview(true);
        raw = ov.in_progress;
        this.tel = ov.store.phone || '';
        if (!raw) return { __empty: true };
      }
      this.raw = raw;
      if (raw.status === 'arrived') { clearInterval(this.timer); this.timer = setInterval(() => this.paint(), 60000); }
      return this.model(Date.now());
    }, silent);
  },
  model(now) {
    const a = v.appointmentView(this.raw, now);
    const working = a.status === 'arrived';
    const e = working ? b.estimate(this.raw, now) : null;
    return {
      a, e, tel: this.tel || (getApp().ctx.overview && getApp().ctx.overview.store.phone) || '',
      nodes: b.timeline(Object.assign({ created_at: this.raw.created_at }, this.raw), now),
      ring: e ? svg.ringUri(92, 9, 'rgba(255,255,255,.14)', '#F5D78E', e.percent / 100) : '',
    };
  },
  paint() { this.setData(this.model(Date.now())); },
  onRetry() { this.reload(false); },
  call() {
    if (this.data.tel) wx.makePhoneCall({ phoneNumber: this.data.tel });
    else page.toast('门店暂未登记电话');
  },
});
