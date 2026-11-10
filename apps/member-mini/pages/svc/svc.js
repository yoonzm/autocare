const api = require('../../utils/api');
const f = require('../../utils/format');
const v = require('../../utils/view');
const b = require('../../utils/booking');
const page = require('../../utils/page');

// 预约上下文放在 app.ctx.booking：{ store, selected: {服务编号: 服务}, replace, vehicleId, day, time, nonce }
Page({
  data: { state: 'loading', error: '', cats: [], cat: '', rows: [], note: '', total: { count: 0, hours: '', price: '' }, can: false, replace: false },
  all: [],
  selected: {},

  onLoad(q) {
    this.initCat = q.cat ? decodeURIComponent(q.cat) : '';
    this.replaceId = q.replace || '';
    this.preset = q.services ? q.services.split(',') : [];
  },

  onShow() {
    if (!page.requireLogin()) return;
    if (this.data.state === 'loading' || this.data.state === 'error') this.reload();
  },

  reload() {
    page.load(this, async () => {
      const store = await page.currentStore();
      if (!store) return { __empty: true };
      const res = await api.services(store);
      this.all = res.item.items;
      const ov = await page.overview();
      const ctx = getApp().ctx;
      const keep = ctx.booking && ctx.booking.store === store ? ctx.booking : null;
      this.selected = {};
      const ids = this.preset.length ? this.preset : keep ? Object.keys(keep.selected) : [];
      this.all.forEach((s) => { if (ids.indexOf(s.id) >= 0) this.selected[s.id] = s; });
      const cat = this.data.cat || (this.initCat && res.item.categories.indexOf(this.initCat) >= 0 ? this.initCat : res.item.categories[0]) || '';
      const d = v.discountText(res.item.discount);
      return Object.assign(
        { cats: res.item.categories, cat, replace: !!this.replaceId, note: d ? ov.member.level.name + '享 ' + d + '，价格以到店结算为准。' : '' },
        this.view(cat),
        { __empty: this.all.length === 0 }
      );
    });
  },

  view(cat) {
    const sel = Object.keys(this.selected).map((k) => this.selected[k]);
    const t = b.totals(sel);
    return {
      rows: this.all.filter((s) => s.category === cat).map((s) => {
        const st = v.serviceStyle(s.category, s.name);
        return { id: s.id, name: s.name, desc: [f.duration(s.duration_minutes), s.description].filter(Boolean).join(' · '), price: f.yuan(s.member_price), original: Number(s.member_price) < Number(s.price) ? f.yuan(s.price) : '', cls: st.cls, icon: st.icon, on: !!this.selected[s.id] };
      }),
      total: { count: t.count, hours: t.count ? '已选 ' + t.count + ' 项 · 约 ' + b.hoursText(t.minutes) : '请选择服务项目', price: t.count ? f.yuan(t.member) : '' },
      can: t.count > 0,
    };
  },

  onRetry() { this.reload(); },
  pickCat(e) {
    const cat = e.currentTarget.dataset.cat;
    this.setData(Object.assign({ cat }, this.view(cat)));
  },
  toggle(e) {
    const id = e.currentTarget.dataset.id;
    if (this.selected[id]) delete this.selected[id];
    else this.selected[id] = this.all.find((s) => s.id === id);
    this.setData(this.view(this.data.cat));
  },
  next() {
    if (!this.data.can) return;
    const app = getApp();
    const prev = app.ctx.booking;
    const store = app.ctx.storeId;
    // 服务组合变了就换一个新的提交标识；同一组合返回上一步再进来仍是同一个
    app.ctx.booking = Object.assign({ vehicleId: '', day: '', time: '', nonce: page.newRequestId() }, prev && prev.store === store ? prev : {}, {
      store, selected: this.selected, replace: this.replaceId,
    });
    wx.navigateTo({ url: '/pages/time/time' });
  },
  back() { page.back('/pages/book/book'); },
});
