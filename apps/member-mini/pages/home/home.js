const api = require('../../utils/api');
const f = require('../../utils/format');
const v = require('../../utils/view');
const b = require('../../utils/booking');
const page = require('../../utils/page');

Page({
  data: { state: 'loading', error: '', ov: null, recommended: [], promo: null, work: null, multi: false },

  onShow() {
    if (!page.requireLogin()) return;
    const tab = this.getTabBar && this.getTabBar();
    if (tab) tab.setData({ selected: 0 });
    this.reload(this.data.state === 'content');
  },

  reload(silent) {
    page.load(
      this,
      async () => {
        const store = await page.currentStore();
        if (!store) return { __empty: true };
        const [ov, svc, rc] = await Promise.all([page.overview(true), api.services(store), api.rechargeOptions(store)]);
        const now = Date.now();
        const m = ov.member;
        const first = rc.item.presets[0];
        let work = null;
        if (ov.in_progress) {
          const a = v.appointmentView(ov.in_progress, now);
          const e = b.estimate(ov.in_progress, now);
          work = {
            id: a.id, plate: a.plate, ev: a.ev, text: a.text, percent: e.percent,
            note: '预计 ' + e.finish + ' 完工' + (a.bay_name ? ' · ' + a.bay_name : '') + (a.technician_name ? ' · ' + a.technician_name : ''),
          };
        }
        return {
          ov: {
            store: ov.store,
            storeName: ov.store.name,
            hours: ov.store.open_now ? '营业中 · ' + ov.store.opens_at + '–' + ov.store.closes_at : '休息中 · ' + ov.store.opens_at + '–' + ov.store.closes_at,
            open: ov.store.open_now,
            name: m.name,
            level: m.level.name,
            balance: f.money2(m.balance),
            points: f.int(m.points),
            packages: ov.counts.packages + ' 张',
          },
          work,
          recommended: svc.item.items.slice(0, 4).map((s) => {
            const st = v.serviceStyle(s.category, s.name);
            return { id: s.id, name: s.name, meta: f.duration(s.duration_minutes), price: f.yuan(s.member_price), original: Number(s.member_price) < Number(s.price) ? f.yuan(s.price) : '', cls: st.cls, icon: st.icon };
          }),
          // 充值福利横幅：只在线上充值可用时展示（未开通时不推广一个付不了款的入口）
          promo: rc.item.online && first ? { title: '充 ' + f.yuan(first.amount) + ' 送 ' + f.yuan(first.gift) } : null,
          multi: (getApp().ctx.stores || []).length > 1,
        };
      },
      silent
    );
  },

  onRetry() { this.reload(false); },

  switchStore() {
    const stores = getApp().ctx.stores || [];
    if (stores.length < 2) return;
    wx.showActionSheet({
      itemList: stores.map((s) => s.name),
      success: (res) => {
        page.switchStore(stores[res.tapIndex].store_id);
        this.reload(false);
      },
    });
  },

  go(e) { page.go(e.currentTarget.dataset.url); },
  call() {
    const phone = this.data.ov && this.data.ov.store.phone;
    if (phone) wx.makePhoneCall({ phoneNumber: phone });
    else page.toast('门店暂未登记电话');
  },
  // TODO: 导航需要门店经纬度，目前门店资料只有文字地址（预期后端：stores 增加 latitude/longitude 并随 mb_overview 返回，再调用 wx.openLocation）。
  navigate() { page.toast('门店暂未设置地图位置，请按地址前往'); },
});
