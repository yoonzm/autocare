const api = require('../../utils/api');
const f = require('../../utils/format');
const b = require('../../utils/booking');
const page = require('../../utils/page');

Page({
  data: {
    state: 'loading', error: '', strip: [], day: '', slots: [], slotsState: 'content', time: '', tip: '',
    car: null, summary: '', whenText: '', busy: false, replace: false,
  },

  onLoad() {
    this.booking = getApp().ctx.booking;
    if (!this.booking || !Object.keys(this.booking.selected).length) wx.redirectTo({ url: '/pages/svc/svc' });
  },

  onShow() {
    if (!page.requireLogin() || !this.booking) return;
    // 从“我的爱车”选车返回时只刷新车辆，不重置日期时段
    if (this.data.state === 'loading' || this.data.state === 'error') this.reload();
    else this.refreshCar();
  },

  ids() { return Object.keys(this.booking.selected); },

  reload() {
    page.load(this, async () => {
      const store = this.booking.store;
      const ids = this.ids();
      const sel = ids.map((i) => this.booking.selected[i]);
      const day0 = this.booking.day || '';
      // 先用一个合法日期探测门店设置（休息日 / 可预约天数），再按设置生成日期条
      const probe = await api.slots(store, f.dayKey(Date.now()), ids);
      const settings = probe.item.settings;
      const strip = b.dateStrip(Date.now(), settings);
      const day = day0 && strip.some((d) => d.day === day0 && !d.disabled) ? day0 : b.firstOpenDay(strip);
      this.settings = settings;
      this.estimate = probe.item.estimate;
      const car = await this.pickCar();
      const t = b.totals(sel);
      return {
        strip, day, car, replace: !!this.booking.replace, time: day === day0 ? this.booking.time : '',
        tip: '施工' + f.duration(t.minutes) + '，如需取消请至少提前 ' + probe.item.cancel_lead_hours + ' 小时。',
        summary: sel.map((s) => s.name).join(' + '),
      };
    }).then(() => this.loadSlots());
  },

  async pickCar() {
    const list = (await api.vehicles(this.booking.store)).items;
    this.cars = list;
    const chosen = list.find((c) => c.id === this.booking.vehicleId) || list.find((c) => c.is_default) || list[0];
    if (chosen) this.booking.vehicleId = chosen.id;
    return chosen ? { id: chosen.id, plate: chosen.plate, energy: chosen.energy, text: [chosen.brand_model, chosen.color].filter(Boolean).join(' · ') } : null;
  },

  refreshCar() {
    this.pickCar().then((car) => this.setData({ car })).catch(() => {});
  },

  loadSlots() {
    if (this.data.state !== 'content') return;
    const day = this.data.day;
    this.setData({ slotsState: 'loading' });
    api.slots(this.booking.store, day, this.ids()).then((res) => {
      if (day !== this.data.day) return;
      const slots = res.item.slots.map((s) => ({ time: s.time, ok: s.available }));
      const keep = slots.some((s) => s.time === this.data.time && s.ok) ? this.data.time : '';
      this.setData({ slots, time: keep, slotsState: slots.length ? 'content' : 'empty' }, () => this.sync());
    }).catch((e) => { if (day === this.data.day) this.setData({ slotsState: 'error', error: e.message }); });
  },

  sync() {
    const { day, time } = this.data;
    this.booking.day = day;
    this.booking.time = time;
    this.setData({ whenText: time ? f.dateTime(f.bjIso(day, time)) : '请选择到店时间' });
  },

  pickDay(e) {
    const d = e.currentTarget.dataset;
    if (d.off || d.day === this.data.day) return;
    this.setData({ day: d.day, time: '' }, () => { this.sync(); this.loadSlots(); });
  },
  pickSlot(e) {
    const d = e.currentTarget.dataset;
    if (d.off) return;
    this.setData({ time: d.time }, () => this.sync());
  },
  onRetry() { this.reload(); },
  retrySlots() { this.loadSlots(); },
  chooseCar() { wx.navigateTo({ url: '/pages/cars/cars?pick=1' }); },
  addCar() { wx.navigateTo({ url: '/pages/car-add/car-add' }); },

  submit() {
    if (this.data.busy) return;
    if (!this.data.time) return page.toast('请选择到店时间');
    if (!this.data.car) return page.toast('请先添加服务车辆');
    this.setData({ busy: true });
    const bk = this.booking;
    // 提交标识 = 本次进入的随机数 + 内容摘要：网络失败重试同一内容不会重复预约，改了时间 / 车辆则是新请求
    const content = [this.ids().sort().join(','), bk.day, bk.time, bk.vehicleId, bk.replace || ''].join('|');
    api.book(bk.store, {
      service_ids: this.ids(), starts_at: f.bjIso(bk.day, bk.time), vehicle_id: bk.vehicleId, replace_id: bk.replace || undefined,
    }, bk.nonce + ':' + content.length + ':' + hash(content)).then((res) => {
      getApp().ctx.booking = null;
      wx.redirectTo({ url: '/pages/booked/booked?id=' + res.item.id });
    }).catch((err) => {
      page.toast(err.message);
      // 时段被抢走：刷新可约时段
      if (err.status === 409) this.loadSlots();
    }).then(() => this.setData({ busy: false }));
  },
  back() { if (!this.data.busy) page.back('/pages/svc/svc'); },
});

function hash(s) {
  let h = 5381;
  for (let i = 0; i < s.length; i++) h = ((h * 33) ^ s.charCodeAt(i)) >>> 0;
  return h.toString(16);
}
